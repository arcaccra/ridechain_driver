import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class CardanoUtxo {
  final String txHash;
  final int txIndex;
  final int lovelace;

  const CardanoUtxo({
    required this.txHash,
    required this.txIndex,
    required this.lovelace,
  });
}

/// Thin wrapper around the Blockfrost REST API.
/// Project ID and network are loaded from .env at runtime.
class BlockfrostService {
  late final String _projectId;
  late final String _baseUrl;

  BlockfrostService() {
    _projectId = dotenv.env['BLOCKFROST_PROJECT_ID'] ?? '';
    final network = dotenv.env['BLOCKFROST_NETWORK'] ?? 'preprod';
    _baseUrl = 'https://cardano-$network.blockfrost.io/api/v0';
  }

  Map<String, String> get _headers => {
        'project_id': _projectId,
        'Content-Type': 'application/json',
      };

  // ── Address ───────────────────────────────────────────────────────────────

  /// Returns the ADA balance in lovelace for [address], or 0 if the address
  /// has never appeared on-chain.
  Future<int> getLovelaceBalance(String address) async {
    final uri = Uri.parse('$_baseUrl/addresses/$address');
    final res = await http.get(uri, headers: _headers);

    if (res.statusCode == 404) return 0;
    _assertOk(res, 'getLovelaceBalance');

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final amounts = data['amount'] as List<dynamic>;
    final lovelaceEntry = amounts.firstWhere(
      (a) => a['unit'] == 'lovelace',
      orElse: () => {'quantity': '0'},
    );
    return int.parse(lovelaceEntry['quantity'] as String);
  }

  /// Returns unspent UTXOs for [address].
  Future<List<CardanoUtxo>> getUtxos(String address) async {
    final uri = Uri.parse('$_baseUrl/addresses/$address/utxos');
    final res = await http.get(uri, headers: _headers);

    if (res.statusCode == 404) return [];
    _assertOk(res, 'getUtxos');

    final list = jsonDecode(res.body) as List<dynamic>;
    return list.map((u) {
      final amounts = u['amount'] as List<dynamic>;
      final lovelaceEntry = amounts.firstWhere(
        (a) => a['unit'] == 'lovelace',
        orElse: () => {'quantity': '0'},
      );
      return CardanoUtxo(
        txHash: u['tx_hash'] as String,
        txIndex: u['tx_index'] as int,
        lovelace: int.parse(lovelaceEntry['quantity'] as String),
      );
    }).toList();
  }

  // ── Submission ────────────────────────────────────────────────────────────

  /// Submits a signed transaction. [cborHex] is the hex-encoded signed CBOR
  /// produced by [CardanoWalletService.signTransaction].
  ///
  /// Returns the transaction hash on success.
  Future<String> submitTransaction(String cborHex) async {
    final uri = Uri.parse('$_baseUrl/tx/submit');
    final bytes = _hexToBytes(cborHex);

    final res = await http.post(
      uri,
      headers: {
        'project_id': _projectId,
        'Content-Type': 'application/cbor',
      },
      body: bytes,
    );

    _assertOk(res, 'submitTransaction');
    // Blockfrost returns the tx hash as a bare quoted string
    return jsonDecode(res.body) as String;
  }

  // ── Confirmation polling ──────────────────────────────────────────────────

  /// Polls until the transaction with [txHash] appears on-chain or until
  /// [maxAttempts] * [intervalSeconds] seconds have elapsed.
  ///
  /// Returns true when confirmed, false on timeout.
  Future<bool> awaitConfirmation(
    String txHash, {
    int maxAttempts = 30,
    int intervalSeconds = 10,
  }) async {
    final uri = Uri.parse('$_baseUrl/txs/$txHash');
    for (var i = 0; i < maxAttempts; i++) {
      await Future.delayed(Duration(seconds: intervalSeconds));
      try {
        final res = await http.get(uri, headers: _headers);
        if (res.statusCode == 200) {
          log('[BlockfrostService] tx $txHash confirmed after ${(i + 1) * intervalSeconds}s');
          return true;
        }
      } catch (e) {
        log('[BlockfrostService] poll attempt ${i + 1} error: $e');
      }
    }
    return false;
  }

  // ── Latest slot (for TTL) ─────────────────────────────────────────────────

  /// Returns the current blockchain slot number. Used to set a transaction TTL
  /// (typically current slot + 7200 ≈ 2 hours on mainnet).
  Future<int> getLatestSlot() async {
    final uri = Uri.parse('$_baseUrl/blocks/latest');
    final res = await http.get(uri, headers: _headers);
    _assertOk(res, 'getLatestSlot');
    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return data['slot'] as int;
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  void _assertOk(http.Response res, String caller) {
    if (res.statusCode < 200 || res.statusCode >= 300) {
      log('[BlockfrostService] $caller failed — ${res.statusCode}: ${res.body}');
      throw Exception('Blockfrost $caller failed (${res.statusCode}): ${res.body}');
    }
  }

  Uint8List _hexToBytes(String hex) {
    final bytes = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return Uint8List.fromList(bytes);
  }
}
