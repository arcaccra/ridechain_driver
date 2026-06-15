import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/core_constants/colors.dart';

enum _ScanState { scanning, verifying, verified }

class ScanScreen extends StatefulWidget {
  final String? passengerName;
  final String? pickupLocation;
  final VoidCallback? onBoardingConfirmed;

  const ScanScreen({
    super.key,
    this.passengerName,
    this.pickupLocation,
    this.onBoardingConfirmed,
  });

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen>
    with SingleTickerProviderStateMixin {
  _ScanState _state = _ScanState.scanning;
  MobileScannerController? _controller;
  late AnimationController _scanLineController;
  late Animation<double> _scanLineAnim;

  String _scannedPassengerName = '';
  String _scannedPickupLocation = '';
  String _scannedInitials = '';

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
    );
    _scanLineController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _scanLineAnim =
        Tween<double>(begin: 0.0, end: 1.0).animate(_scanLineController);
  }

  @override
  void dispose() {
    _controller?.dispose();
    _scanLineController.dispose();
    super.dispose();
  }

  void _onQrDetected(BarcodeCapture capture) {
    if (_state != _ScanState.scanning) return;
    final barcode = capture.barcodes.firstOrNull;
    if (barcode?.rawValue == null) return;

    _controller?.stop();

    setState(() => _state = _ScanState.verifying);

    // Parse QR data — expected format: "name|location" or just use raw value as name
    final raw = barcode!.rawValue!;
    final parts = raw.split('|');
    final name = parts.isNotEmpty ? parts[0] : raw;
    final location = parts.length > 1 ? parts[1] : (widget.pickupLocation ?? '');

    final initials = name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join()
        .toUpperCase();

    // Simulate network verification delay
    Future.delayed(const Duration(milliseconds: 1500), () {
      if (!mounted) return;
      setState(() {
        _state = _ScanState.verified;
        _scannedPassengerName = widget.passengerName ?? name;
        _scannedPickupLocation = widget.pickupLocation ?? location;
        _scannedInitials =
            widget.passengerName != null ? _getInitials(widget.passengerName!) : initials;
      });
    });
  }

  String _getInitials(String name) {
    return name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join()
        .toUpperCase();
  }

  void _resetScan() {
    setState(() => _state = _ScanState.scanning);
    _controller?.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Stack(
        children: [
          // Camera background (only when scanning/verifying)
          if (_state != _ScanState.verified)
            Positioned.fill(
              child: MobileScanner(
                controller: _controller!,
                onDetect: _onQrDetected,
              ),
            ),

          // Dark overlay
          Positioned.fill(
            child: Container(color: const Color(0xCC1A1A1A)),
          ),

          // Content
          SafeArea(
            child: Column(
              children: [
                // Back button
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 40.w,
                        height: 40.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.chevron_left,
                          color: Colors.white,
                          size: 24.w,
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // QR Scan Frame
                _buildScanFrame(),

                const Spacer(),

                // Bottom content
                _buildBottomContent(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanFrame() {
    return SizedBox(
      width: 260.w,
      height: 260.w,
      child: Stack(
        children: [
          // QR content area
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.r),
                color: _state == _ScanState.verified
                    ? Colors.white
                    : Colors.black.withValues(alpha: 0.3),
              ),
              child: _state == _ScanState.verified
                  ? _buildVerifiedQrContent()
                  : null,
            ),
          ),

          // Corner brackets
          ..._buildCornerBrackets(),

          // Scan line animation (scanning state)
          if (_state == _ScanState.scanning)
            Positioned.fill(
              child: AnimatedBuilder(
                animation: _scanLineAnim,
                builder: (context, _) {
                  return Align(
                    alignment: Alignment(0, (_scanLineAnim.value * 2) - 1),
                    child: Container(
                      height: 2.h,
                      margin: EdgeInsets.symmetric(horizontal: 12.w),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(1.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withValues(alpha: 0.5),
                            blurRadius: 6,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          // Verifying spinner
          if (_state == _ScanState.verifying)
            Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(
                      color: Colors.green,
                      strokeWidth: 2,
                    ),
                    Gap(12.h),
                    Text(
                      'Verifying...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildVerifiedQrContent() {
    return Stack(
      children: [
        // QR pattern background (simplified representation)
        Positioned.fill(
          child: CustomPaint(
            painter: _QrPatternPainter(),
          ),
        ),
        // Green check overlay in center
        Center(
          child: Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.4),
                  blurRadius: 20,
                  spreadRadius: 4,
                ),
              ],
            ),
            child: Icon(Icons.check, color: Colors.white, size: 32.w),
          ),
        ),
      ],
    );
  }

  List<Widget> _buildCornerBrackets() {
    const double size = 28;
    const double thickness = 3.5;
    const color = Colors.white;
    const radius = Radius.circular(4);

    Widget corner({
      required double top,
      required double left,
      required double? bottom,
      required double? right,
      required bool flipH,
      required bool flipV,
    }) {
      return Positioned(
        top: top >= 0 ? top : null,
        left: left >= 0 ? left : null,
        bottom: bottom,
        right: right,
        child: Transform.scale(
          scaleX: flipH ? -1 : 1,
          scaleY: flipV ? -1 : 1,
          child: CustomPaint(
            size: const Size(size, size),
            painter: _CornerBracketPainter(
              color: color,
              thickness: thickness,
              radius: radius,
            ),
          ),
        ),
      );
    }

    return [
      corner(top: 0, left: 0, bottom: null, right: null, flipH: false, flipV: false),
      corner(top: 0, left: -1, bottom: null, right: 0, flipH: true, flipV: false),
      corner(top: -1, left: 0, bottom: 0, right: null, flipH: false, flipV: true),
      corner(top: -1, left: -1, bottom: 0, right: 0, flipH: true, flipV: true),
    ];
  }

  Widget _buildBottomContent() {
    if (_state == _ScanState.scanning || _state == _ScanState.verifying) {
      return Padding(
        padding: EdgeInsets.only(bottom: 48.h),
        child: Column(
          children: [
            Text(
              'Point at the passenger\'s QR code',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            Gap(6.h),
            Text(
              _state == _ScanState.verifying
                  ? 'Verifying booking on the network...'
                  : 'Verifying booking on the network...',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 13.sp,
              ),
            ),
          ],
        ),
      );
    }

    // Verified state — passenger card
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Passenger row
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: AppColors.purple.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    _scannedInitials,
                    style: TextStyle(
                      color: AppColors.purple,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              Gap(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _scannedPassengerName,
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.check, size: 12.w, color: Colors.green),
                        Gap(3.w),
                        Text(
                          'Valid booking',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.green,
                          ),
                        ),
                        if (_scannedPickupLocation.isNotEmpty) ...[
                          Text(
                            ' · $_scannedPickupLocation',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'Verified',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          Gap(16.h),
          // Confirm boarding button
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton.icon(
              onPressed: () {
                widget.onBoardingConfirmed?.call();
                Get.back();
              },
              icon: Icon(Icons.check, color: Colors.white, size: 18.w),
              label: Text(
                'Confirm boarding',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26.r),
                ),
                elevation: 0,
              ),
            ),
          ),
          Gap(8.h),
          // Scan again
          TextButton(
            onPressed: _resetScan,
            child: Text(
              'Scan again',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 13.sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CornerBracketPainter extends CustomPainter {
  final Color color;
  final double thickness;
  final Radius radius;

  const _CornerBracketPainter({
    required this.color,
    required this.thickness,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path()
      ..moveTo(0, size.height)
      ..lineTo(0, radius.x)
      ..arcToPoint(Offset(radius.x, 0), radius: radius)
      ..lineTo(size.width, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(_CornerBracketPainter old) => false;
}

class _QrPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black87;
    final cellSize = size.width / 21;

    // Simplified QR-like pattern using a few blocks
    const pattern = [
      [0, 0, 7, 7], [1, 0, 7, 7], [2, 0, 7, 7],
      [0, 1, 7, 7], [1, 1, 7, 7], [2, 1, 7, 7],
      [14, 0, 7, 7], [15, 0, 7, 7], [16, 0, 7, 7],
      [0, 14, 7, 7], [1, 14, 7, 7], [2, 14, 7, 7],
    ];

    // Draw random-ish QR modules
    for (int row = 0; row < 21; row++) {
      for (int col = 0; col < 21; col++) {
        // Corner squares
        bool isCornerTL = row < 7 && col < 7;
        bool isCornerTR = row < 7 && col > 13;
        bool isCornerBL = row > 13 && col < 7;

        if (isCornerTL || isCornerTR || isCornerBL) {
          // Draw finder pattern
          bool isOuter = row == 0 || row == 6 || col == 0 || col == 6 ||
              (isCornerTR && (row == 0 || row == 6 || col == 14 || col == 20)) ||
              (isCornerBL && (row == 14 || row == 20 || col == 0 || col == 6));
          bool isInner = row >= 2 && row <= 4 && col >= 2 && col <= 4 ||
              (isCornerTR && row >= 2 && row <= 4 && col >= 16 && col <= 18) ||
              (isCornerBL && row >= 16 && row <= 18 && col >= 2 && col <= 4);

          if (isOuter || isInner) {
            canvas.drawRect(
              Rect.fromLTWH(
                col * cellSize,
                row * cellSize,
                cellSize,
                cellSize,
              ),
              paint,
            );
          }
        } else {
          // Pseudo-random data modules
          final hash = (row * 31 + col * 17 + row * col) % 3;
          if (hash == 0) {
            canvas.drawRect(
              Rect.fromLTWH(
                col * cellSize,
                row * cellSize,
                cellSize,
                cellSize,
              ),
              paint,
            );
          }
        }
      }
    }
  }

  @override
  bool shouldRepaint(_QrPatternPainter old) => false;
}
