import 'dart:developer';

import 'package:cardano_dart_types/cardano_dart_types.dart';
import 'package:cardano_flutter_sdk/cardano_flutter_sdk.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Manages the local Cardano wallet: mnemonic storage, address derivation,
/// and transaction signing. Private keys never leave this service.
class CardanoWalletService {
  static const _mnemonicKey = 'cardano_mnemonic';
  static const _addressKey = 'cardano_address';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // ── Mnemonic generation ───────────────────────────────────────────────────

  /// Generates a fresh 24-word BIP39 mnemonic. Does NOT store it —
  /// the caller must show it to the user for backup, then call [importWallet].
  List<String> generateMnemonic() {
    return WalletFactory.generateNewMnemonic(
      wordsCount: MnemonicsWordsCount.w24,
    );
  }

  /// Validates a mnemonic list by attempting derivation. Returns an error
  /// message or null when valid.
  Future<String?> validateMnemonic(List<String> words) async {
    if (words.length != 12 && words.length != 15 && words.length != 24) {
      return 'Mnemonic must be 12, 15, or 24 words.';
    }
    try {
      await WalletFactory.fromMnemonic(NetworkId.mainnet, words);
      return null;
    } catch (_) {
      return 'Invalid mnemonic — check for spelling errors.';
    }
  }

  // ── Wallet import ─────────────────────────────────────────────────────────

  /// Derives a Cardano Shelley address from [words], persists the mnemonic
  /// and address to secure storage, and returns the bech32 address.
  ///
  /// Throws if [words] form an invalid mnemonic.
  Future<String> importWallet(
    List<String> words, {
    NetworkId network = NetworkId.mainnet,
  }) async {
    final wallet = await WalletFactory.fromMnemonic(network, words);
    final addrKit = await wallet.getPaymentAddressKit(addressIndex: 0);
    final address = addrKit.address.bech32Encoded;

    await _storage.write(key: _mnemonicKey, value: words.join(' '));
    await _storage.write(key: _addressKey, value: address);

    log('[CardanoWalletService] Wallet imported — address: $address');
    return address;
  }

  // ── Queries ───────────────────────────────────────────────────────────────

  /// Returns the stored bech32 address, or null if no wallet has been imported.
  Future<String?> getStoredAddress() => _storage.read(key: _addressKey);

  /// True when a mnemonic is present in secure storage.
  Future<bool> hasMnemonic() async {
    final v = await _storage.read(key: _mnemonicKey);
    return v != null && v.isNotEmpty;
  }

  // ── Signing ───────────────────────────────────────────────────────────────

  /// Signs an unsigned transaction (provided as hex-encoded CBOR) and returns
  /// the fully signed transaction as a hex string ready for Blockfrost.
  ///
  /// Drivers receive ADA rather than spend it, so this is unused in the driver
  /// app today; it is kept for parity with the passenger app and future use
  /// (e.g. driver-initiated withdrawals or refunds).
  ///
  /// [unsignedTxHex]  — hex CBOR of the unsigned transaction
  /// [signerAddress]  — bech32 address whose key should sign
  Future<String> signTransaction({
    required String unsignedTxHex,
    required String signerAddress,
    NetworkId network = NetworkId.mainnet,
  }) async {
    final mnemonicStr = await _storage.read(key: _mnemonicKey);
    if (mnemonicStr == null) {
      throw Exception('No wallet found. Please import your wallet first.');
    }

    final words = mnemonicStr.split(' ');
    final wallet = await WalletFactory.fromMnemonic(network, words);

    final tx = CardanoTransaction.deserializeFromHex(unsignedTxHex);
    final witnessSet = await wallet.signTransaction(
      tx: tx,
      witnessBech32Addresses: {signerAddress},
    );

    final signedTx = tx.copyWithAdditionalSignatures(witnessSet);
    return signedTx.serializeHexString();
  }

  // ── Cleanup ───────────────────────────────────────────────────────────────

  /// Removes all wallet data from secure storage (e.g. on logout or wallet swap).
  Future<void> clearWallet() async {
    await _storage.delete(key: _mnemonicKey);
    await _storage.delete(key: _addressKey);
  }
}
