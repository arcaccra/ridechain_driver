import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../core/core_constants/colors.dart';
import '../../../providers/auth_provider.dart';
import 'image_capture_screen.dart';

class PasswordScreen extends StatefulWidget {
  const PasswordScreen({super.key});

  @override
  State<PasswordScreen> createState() => _PasswordScreenState();
}

class _PasswordScreenState extends State<PasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthVm>(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(16.h),
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[100],
                      ),
                      child: const Icon(Icons.chevron_left, color: Colors.black),
                    ),
                  ),
                  Gap(24.h),
                  Text(
                    'Secure your account',
                    style: TextStyle(
                      fontFamily: 'BeauSans',
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  Gap(8.h),
                  Text(
                    'Step 4 of 4 · Create a password to finish.',
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
                  ),
                  Gap(12.h),
                  // All 4 segments filled
                  Row(
                    children: List.generate(
                      4,
                      (i) => Expanded(
                        child: Container(
                          height: 4.h,
                          margin: EdgeInsets.only(right: i < 3 ? 6.w : 0),
                          decoration: BoxDecoration(
                            color: AppColors.purple,
                            borderRadius: BorderRadius.circular(2.r),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Gap(28.h),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Gap(6.h),
                            TextFormField(
                              controller: _passwordCtrl,
                              obscureText: _obscurePassword,
                              onChanged: (v) => setState(() {}),
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  size: 20.w,
                                  color: Colors.grey[400],
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 20.w,
                                    color: Colors.grey[400],
                                  ),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(color: Colors.grey[200]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(color: Colors.grey[200]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(color: AppColors.purple, width: 1.5),
                                ),
                              ),
                              validator: (v) =>
                                  (v?.length ?? 0) < 6 ? 'Min 6 characters' : null,
                            ),
                            Gap(8.h),
                            // Password strength bar
                            _buildStrengthBar(),
                            Gap(20.h),
                            Text(
                              'Confirm password',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Gap(6.h),
                            TextFormField(
                              controller: _confirmPasswordCtrl,
                              obscureText: true,
                              decoration: InputDecoration(
                                hintText: '••••••••',
                                prefixIcon: Icon(
                                  Icons.lock_outline,
                                  size: 20.w,
                                  color: Colors.grey[400],
                                ),
                                suffixIcon: _confirmPasswordCtrl.text == _passwordCtrl.text &&
                                        _confirmPasswordCtrl.text.isNotEmpty
                                    ? Icon(Icons.check, color: Colors.green, size: 20.w)
                                    : null,
                                filled: true,
                                fillColor: Colors.white,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(color: Colors.grey[200]!),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(color: Colors.grey[200]!),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                  borderSide: BorderSide(color: AppColors.purple, width: 1.5),
                                ),
                              ),
                              onChanged: (v) => setState(() {}),
                              validator: (v) =>
                                  v != _passwordCtrl.text ? 'Passwords do not match' : null,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 24.w,
              right: 24.w,
              bottom: 24.h,
              child: SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: authVm.isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            var password1 = _passwordCtrl.text.trim();
                            authVm.addToRegisterMap("password1", password1);
                            var password2 = _confirmPasswordCtrl.text.trim();
                            authVm.addToRegisterMap("password2", password2);
                            Get.to(() => ImageCaptureScreen());
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                    elevation: 0,
                  ),
                  child: authVm.isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        )
                      : Text(
                          'Create account',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStrengthBar() {
    final pw = _passwordCtrl.text;
    int strength = 0;
    if (pw.length >= 6) strength++;
    if (pw.contains(RegExp(r'[A-Z]'))) strength++;
    if (pw.contains(RegExp(r'[0-9!@#\$&*~]'))) strength++;
    final labels = ['', 'Weak', 'Good', 'Strong'];
    final colors = [Colors.red, Colors.orange, AppColors.purple];
    return Row(
      children: [
        ...List.generate(
          3,
          (i) => Expanded(
            child: Container(
              height: 4.h,
              margin: EdgeInsets.only(right: i < 2 ? 4.w : 8.w),
              decoration: BoxDecoration(
                color: i < strength ? colors[i] : Colors.grey[200],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
        ),
        if (strength > 0)
          Text(
            labels[strength],
            style: TextStyle(
              fontSize: 12.sp,
              color: colors[strength - 1],
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
