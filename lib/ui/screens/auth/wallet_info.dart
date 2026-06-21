import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../../app/theme.dart';
import '../../../core/core_constants/colors.dart';
import '../../../data/locator.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/blockfrost_service.dart';
import '../../../services/cardano_wallet_service.dart';
import '../../../services/dialog_service.dart';
import '../../shared_widgets/default_button.dart';
import '../../shared_widgets/loader.dart';
import 'auth_widgets/scanning_widget.dart';
import 'verification_complete_screen.dart';

enum _WalletMode { choose, importSeed, newWallet, linkAddress }

class WalletInfo extends StatefulWidget {
  /// When true, this screen is the final onboarding step (after registration's
  /// document flow, or after login when a verified driver has no wallet yet).
  /// A successful save — or a skip — enters the app. When false (opened from the
  /// Profile tab), a successful save simply pops back.
  final bool fromOnboarding;
  const WalletInfo({super.key, this.fromOnboarding = false});

  @override
  State<WalletInfo> createState() => _WalletInfoState();
}

class _WalletInfoState extends State<WalletInfo> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _walletCtrl = TextEditingController();
  final TextEditingController _mnemonicCtrl = TextEditingController();
  late final MobileScannerController _scannerCtrl;

  _WalletMode _mode = _WalletMode.choose;
  bool _isBusy = false;
  List<String>? _generatedMnemonic;
  bool _mnemonicCopied = false;

  @override
  void initState() {
    super.initState();
    _scannerCtrl = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
    final authVm = context.read<AuthVm>();
    if (authVm.walletAddress != null) {
      _walletCtrl.text = authVm.walletAddress!;
    }
  }

  @override
  void dispose() {
    _walletCtrl.dispose();
    _mnemonicCtrl.dispose();
    _scannerCtrl.dispose();
    super.dispose();
  }

  // ── Actions ───────────────────────────────────────────────────────────────

  Future<void> _importMnemonic(AuthVm authVm) async {
    final words = _mnemonicCtrl.text.trim().toLowerCase().split(RegExp(r'\s+'));
    final error = await locator<CardanoWalletService>().validateMnemonic(words);
    if (error != null) {
      locator<DialogService>().showSnackBar('Invalid mnemonic', error);
      return;
    }
    setState(() => _isBusy = true);
    try {
      final address = await locator<CardanoWalletService>().importWallet(words);
      final success = await authVm.updateWalletAddress({'address': address});
      if (!mounted) return;
      if (success) {
        _finishWith('Wallet linked', 'Your Cardano wallet has been imported.');
      }
    } catch (e) {
      locator<DialogService>().showSnackBar('Import failed', e.toString());
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _confirmNewWallet(AuthVm authVm) async {
    if (_generatedMnemonic == null) return;
    setState(() => _isBusy = true);
    try {
      final address = await locator<CardanoWalletService>()
          .importWallet(_generatedMnemonic!);
      final success = await authVm.updateWalletAddress({'address': address});
      if (!mounted) return;
      if (success) {
        _finishWith('Wallet created', 'Your new Cardano wallet has been saved.');
      }
    } catch (e) {
      locator<DialogService>().showSnackBar('Error', e.toString());
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }

  Future<void> _saveLinkAddress(AuthVm authVm) async {
    if (!_formKey.currentState!.validate()) return;
    final wallet = _walletCtrl.text.trim();
    final success = await authVm.updateWalletAddress({'address': wallet});
    if (!mounted) return;
    if (success) {
      _finishWith('Wallet saved', 'Your Cardano address has been linked.');
    }
  }

  void _generateNewMnemonic() {
    final mnemonic = locator<CardanoWalletService>().generateMnemonic();
    setState(() {
      _generatedMnemonic = mnemonic;
      _mode = _WalletMode.newWallet;
      _mnemonicCopied = false;
    });
  }

  void _scanQr(BuildContext context) {
    locator<DialogService>().showCustomModal(
      context: context,
      customModal: ScanningWidget(
        mobileScannerController: _scannerCtrl,
        onCapture: (capture) {
          setState(() {
            _walletCtrl.text = capture.barcodes.first.displayValue ?? '';
          });
          Navigator.pop(context);
        },
      ),
    );
  }

  /// Completes the screen: during onboarding this advances to the verification
  /// complete screen (which enters the app); from Profile it pops back. The
  /// success snackbar is deferred (handled inside DialogService) so it survives
  /// the navigation.
  void _finishWith(String title, String message) {
    if (widget.fromOnboarding) {
      Get.offAll(() => const VerificationCompleteScreen());
    } else {
      Get.back();
      locator<DialogService>().showSnackBar(title, message);
    }
  }

  /// Skips the wallet step during onboarding and advances to the verification
  /// complete screen.
  void _skip() {
    Get.offAll(() => const VerificationCompleteScreen());
    locator<DialogService>().showSnackBar(
      'Wallet skipped',
      'Add a payout wallet from your profile to receive ADA earnings.',
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthVm>();
    final busy = _isBusy || authVm.isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                Expanded(child: _buildBody(authVm)),
                _buildFooter(authVm),
              ],
            ),
            if (busy) const Loader(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(top: 8.h, left: 8.w),
      child: (_mode != _WalletMode.choose || !widget.fromOnboarding)
          ? IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
              color: AppColors.primaryColor,
              onPressed: () {
                if (_mode == _WalletMode.choose) {
                  Get.back();
                } else {
                  setState(() => _mode = _WalletMode.choose);
                }
              },
            )
          : SizedBox(height: 8.h + 48),
    );
  }

  Widget _buildBody(AuthVm authVm) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: switch (_mode) {
        _WalletMode.choose => _buildChooseMode(authVm),
        _WalletMode.importSeed => _buildImportSeedMode(authVm),
        _WalletMode.newWallet => _buildNewWalletMode(authVm),
        _WalletMode.linkAddress => _buildLinkAddressMode(authVm),
      },
    );
  }

  // ── Choose mode ───────────────────────────────────────────────────────────

  Widget _buildChooseMode(AuthVm authVm) {
    final hasWallet =
        authVm.walletAddress != null && authVm.walletAddress!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Gap(16.h),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: AppColors.purple,
            borderRadius: BorderRadius.circular(22),
          ),
          child: const Icon(Icons.account_balance_wallet_outlined,
              color: Colors.white, size: 36),
        )
            .animate()
            .fade(begin: 0, end: 1, duration: 400.ms)
            .scale(
                begin: const Offset(0.8, 0.8),
                end: const Offset(1, 1),
                duration: 400.ms,
                curve: Curves.easeOut),

        Gap(24.h),

        Text(
          'Your payout wallet',
          style: AppThemes.getCustomTextStyle(
            fontFamily: 'Outfit',
            fontSize: 28,
            weight: FontWeight.w700,
            color: AppColors.primaryColor,
          ),
          textAlign: TextAlign.center,
        ).animate(delay: 80.ms).fade(begin: 0, end: 1, duration: 400.ms),

        Gap(8.h),

        Text(
          'Connect a Cardano wallet to receive your ADA ride earnings.',
          style: AppThemes.getCustomTextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            weight: FontWeight.w400,
            color: const Color(0xFF6B7280),
          ),
          textAlign: TextAlign.center,
        ).animate(delay: 120.ms).fade(begin: 0, end: 1, duration: 400.ms),

        if (hasWallet) ...[
          Gap(16.h),
          _BalancePill(address: authVm.walletAddress!),
        ],

        Gap(32.h),

        _OptionCard(
          icon: Icons.download_rounded,
          title: 'Import existing wallet',
          subtitle: 'Enter your 12 or 24-word seed phrase',
          onTap: () => setState(() => _mode = _WalletMode.importSeed),
        ).animate(delay: 180.ms).fade(begin: 0, end: 1, duration: 400.ms),

        Gap(12.h),

        _OptionCard(
          icon: Icons.add_circle_outline_rounded,
          title: 'Create new wallet',
          subtitle: 'Generate a fresh Cardano wallet in-app',
          onTap: _generateNewMnemonic,
        ).animate(delay: 210.ms).fade(begin: 0, end: 1, duration: 400.ms),

        Gap(12.h),

        _OptionCard(
          icon: Icons.link_rounded,
          title: 'Link address only',
          subtitle: 'Paste or scan a receive address',
          onTap: () => setState(() => _mode = _WalletMode.linkAddress),
        ).animate(delay: 240.ms).fade(begin: 0, end: 1, duration: 400.ms),

        Gap(24.h),

        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Don\'t have a wallet yet?  Try Lace, Nami or Eternl.',
            style: AppThemes.getCustomTextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              weight: FontWeight.w400,
              color: const Color(0xFF6B7280),
            ),
          ),
        ),
        Gap(10.h),
        Align(
          alignment: Alignment.centerLeft,
          child: Wrap(
            spacing: 10,
            children: ['Lace', 'Nami', 'Eternl']
                .map((n) => _WalletPill(name: n))
                .toList(),
          ),
        ).animate(delay: 280.ms).fade(begin: 0, end: 1, duration: 400.ms),

        Gap(24.h),
      ],
    );
  }

  // ── Import seed mode ──────────────────────────────────────────────────────

  Widget _buildImportSeedMode(AuthVm authVm) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap(8.h),
        Text(
          'Import wallet',
          style: AppThemes.getCustomTextStyle(
            fontFamily: 'Outfit',
            fontSize: 26,
            weight: FontWeight.w700,
            color: AppColors.primaryColor,
          ),
        ),
        Gap(6.h),
        Text(
          'Enter your 12 or 24-word seed phrase, separated by spaces.',
          style: AppThemes.getCustomTextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            weight: FontWeight.w400,
            color: const Color(0xFF6B7280),
          ),
        ),
        Gap(24.h),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFEEEAF8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: TextField(
            controller: _mnemonicCtrl,
            maxLines: 5,
            keyboardType: TextInputType.multiline,
            style: AppThemes.getCustomTextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              weight: FontWeight.w400,
              color: AppColors.primaryColor,
            ),
            decoration: InputDecoration(
              hintText: 'word1 word2 word3 ...',
              hintStyle: AppThemes.getCustomTextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                weight: FontWeight.w400,
                color: const Color(0xFF9CA3AF),
              ),
              contentPadding: const EdgeInsets.all(16),
              border: InputBorder.none,
            ),
          ),
        ),
        Gap(16.h),
        _InfoBanner(
          icon: Icons.lock_outline_rounded,
          text:
              'Your seed phrase is encrypted and stored only on this device. Never share it with anyone.',
          bg: const Color(0xFFFFF3CD),
          fg: const Color(0xFF92400E),
          iconColor: const Color(0xFFB45309),
          border: const Color(0xFFFFD700),
        ),
        Gap(24.h),
      ],
    );
  }

  // ── New wallet mode ───────────────────────────────────────────────────────

  Widget _buildNewWalletMode(AuthVm authVm) {
    final words = _generatedMnemonic ?? [];
    final mnemonicStr = words.join(' ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Gap(8.h),
        Text(
          'Back up your seed phrase',
          style: AppThemes.getCustomTextStyle(
            fontFamily: 'Outfit',
            fontSize: 24,
            weight: FontWeight.w700,
            color: AppColors.primaryColor,
          ),
        ),
        Gap(6.h),
        Text(
          'Write these 24 words down in order and keep them somewhere safe. You cannot recover your wallet without them.',
          style: AppThemes.getCustomTextStyle(
            fontFamily: 'Inter',
            fontSize: 14,
            weight: FontWeight.w400,
            color: const Color(0xFF6B7280),
          ),
        ),
        Gap(20.h),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: words
                    .asMap()
                    .entries
                    .map((e) => _WordChip(index: e.key + 1, word: e.value))
                    .toList(),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: mnemonicStr));
                  setState(() => _mnemonicCopied = true);
                },
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _mnemonicCopied
                          ? Icons.check_circle_rounded
                          : Icons.copy_rounded,
                      color: _mnemonicCopied
                          ? const Color(0xFF16A34A)
                          : const Color(0xFF9CA3AF),
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _mnemonicCopied ? 'Copied!' : 'Copy to clipboard',
                      style: AppThemes.getCustomTextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        weight: FontWeight.w500,
                        color: _mnemonicCopied
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Gap(16.h),
        _InfoBanner(
          icon: Icons.warning_rounded,
          text:
              'If you lose this seed phrase, your funds cannot be recovered. RideChain cannot help you.',
          bg: const Color(0xFFFEE2E2),
          fg: const Color(0xFF991B1B),
          iconColor: const Color(0xFFDC2626),
          border: const Color(0xFFFCA5A5),
        ),
        Gap(24.h),
      ],
    );
  }

  // ── Link address mode ─────────────────────────────────────────────────────

  Widget _buildLinkAddressMode(AuthVm authVm) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Gap(16.h),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.purple,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(Icons.link_rounded, color: Colors.white, size: 32),
          ),
          Gap(20.h),
          Text(
            'Link receive address',
            style: AppThemes.getCustomTextStyle(
              fontFamily: 'Outfit',
              fontSize: 24,
              weight: FontWeight.w700,
              color: AppColors.primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
          Gap(6.h),
          Text(
            'Paste or scan the Cardano address where you want to receive your ADA earnings.',
            style: AppThemes.getCustomTextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              weight: FontWeight.w400,
              color: const Color(0xFF6B7280),
            ),
            textAlign: TextAlign.center,
          ),
          Gap(28.h),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Cardano wallet address',
              style: AppThemes.getCustomTextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                weight: FontWeight.w500,
                color: const Color(0xFF374151),
              ),
            ),
          ),
          Gap(6.h),
          TextFormField(
            controller: _walletCtrl,
            keyboardType: TextInputType.multiline,
            maxLines: 3,
            style: AppThemes.getCustomTextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              weight: FontWeight.w400,
              color: AppColors.primaryColor,
            ),
            decoration: InputDecoration(
              hintText: 'addr1qx9k7...',
              hintStyle: AppThemes.getCustomTextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                weight: FontWeight.w400,
                color: const Color(0xFF9CA3AF),
              ),
              filled: true,
              fillColor: const Color(0xFFEEEAF8),
              prefixIcon: const Icon(Icons.account_balance_wallet_outlined,
                  color: Color(0xFF9CA3AF), size: 20),
              suffixIcon: GestureDetector(
                onTap: () => _scanQr(context),
                child: const Padding(
                  padding: EdgeInsets.all(12),
                  child: Icon(Icons.qr_code_2_outlined,
                      color: Color(0xFF6B7280), size: 22),
                ),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'Please enter your wallet address'
                : null,
          ),
          Gap(16.h),
          _InfoBanner(
            icon: Icons.shield_outlined,
            text:
                'Double-check this address. ADA payments are sent on the Cardano blockchain and cannot be reversed.',
            bg: const Color(0xFFEEEAF8),
            fg: const Color(0xFF6B7280),
            iconColor: AppColors.purple,
          ),
          Gap(12.h),
          GestureDetector(
            onTap: () async {
              final data = await Clipboard.getData('text/plain');
              if (data?.text != null) {
                setState(() => _walletCtrl.text = data!.text!);
              }
            },
            child: Text(
              'Paste from clipboard',
              style: AppThemes.getCustomTextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                weight: FontWeight.w600,
                color: AppColors.purple,
              ),
            ),
          ),
          Gap(24.h),
        ],
      ),
    );
  }

  // ── Footer ────────────────────────────────────────────────────────────────

  Widget _buildFooter(AuthVm authVm) {
    final showPrimary = _mode != _WalletMode.choose;
    if (!showPrimary && !widget.fromOnboarding) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 24.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showPrimary)
            DefaultButton(
              onBtnTap: () => _onPrimaryAction(authVm),
              btnText: _primaryLabel(),
              btnColor: AppColors.purple,
              btnTextColor: AppColors.white,
            ),
          if (widget.fromOnboarding) ...[
            Gap(12.h),
            GestureDetector(
              onTap: _skip,
              child: Text(
                'Skip for now',
                style: AppThemes.getCustomTextStyle(
                  fontFamily: 'Inter',
                  fontSize: 15,
                  weight: FontWeight.w500,
                  color: const Color(0xFF6B7280),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _primaryLabel() => switch (_mode) {
        _WalletMode.importSeed => 'Import wallet',
        _WalletMode.newWallet => 'I\'ve saved my seed phrase',
        _WalletMode.linkAddress => 'Save address',
        _WalletMode.choose => '',
      };

  Future<void> _onPrimaryAction(AuthVm authVm) async {
    switch (_mode) {
      case _WalletMode.importSeed:
        await _importMnemonic(authVm);
      case _WalletMode.newWallet:
        await _confirmNewWallet(authVm);
      case _WalletMode.linkAddress:
        await _saveLinkAddress(authVm);
      case _WalletMode.choose:
        break;
    }
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _BalancePill extends StatelessWidget {
  final String address;
  const _BalancePill({required this.address});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: locator<BlockfrostService>().getLovelaceBalance(address),
      builder: (context, snap) {
        final ada = snap.hasData ? (snap.data! / 1000000) : null;
        final text = snap.connectionState == ConnectionState.waiting
            ? 'Checking balance…'
            : snap.hasError
                ? 'Balance unavailable'
                : '₳ ${ada!.toStringAsFixed(2)} on-chain';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFFEEEAF8),
            borderRadius: BorderRadius.circular(30),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.account_balance_wallet_rounded,
                  color: AppColors.purple, size: 16),
              const SizedBox(width: 8),
              Text(
                text,
                style: AppThemes.getCustomTextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  weight: FontWeight.w600,
                  color: AppColors.purple,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoBanner extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color bg;
  final Color fg;
  final Color iconColor;
  final Color? border;

  const _InfoBanner({
    required this.icon,
    required this.text,
    required this.bg,
    required this.fg,
    required this.iconColor,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
        border: border != null ? Border.all(color: border!) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppThemes.getCustomTextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                weight: FontWeight.w400,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _OptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: const Color(0xFFEEEAF8),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.purple, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppThemes.getCustomTextStyle(
                        fontFamily: 'Inter',
                        fontSize: 15,
                        weight: FontWeight.w600,
                        color: AppColors.primaryColor,
                      )),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: AppThemes.getCustomTextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        weight: FontWeight.w400,
                        color: const Color(0xFF9CA3AF),
                      )),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFF9CA3AF), size: 22),
          ],
        ),
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  final int index;
  final String word;
  const _WordChip({required this.index, required this.word});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$index. $word',
        style: AppThemes.getCustomTextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          weight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _WalletPill extends StatelessWidget {
  final String name;
  const _WalletPill({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Text(
        name,
        style: AppThemes.getCustomTextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          weight: FontWeight.w500,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}
