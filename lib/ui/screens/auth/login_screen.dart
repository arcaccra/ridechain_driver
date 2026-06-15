import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:ridechain_driiver/ui/screens/auth/register_screen.dart';

import '../../../core/core_constants/colors.dart';
import '../../../core/core_constants/media.dart';
import '../../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthVm>();
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Gap(32.h),
                // Logo
                Center(
                  child: SvgPicture.asset(
                    Media.car,
                    width: 56.w,
                    height: 56.w,
                  ),
                ),
                Gap(32.h),
                // Heading
                Text(
                  'Welcome back',
                  style: TextStyle(
                    fontFamily: 'BeauSans',
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.black,
                  ),
                ),
                Gap(6.h),
                Text(
                  'Sign in to continue driving',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[500],
                  ),
                ),
                Gap(36.h),
                // Email field
                _buildLabel('Email address'),
                Gap(6.h),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration(
                    hint: 'you@example.com',
                    icon: Icons.email_outlined,
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Email is required';
                    if (!v.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                Gap(16.h),
                // Password field
                _buildLabel('Password'),
                Gap(6.h),
                TextFormField(
                  controller: _passwordCtrl,
                  obscureText: _obscurePassword,
                  decoration: _inputDecoration(
                    hint: '••••••••',
                    icon: Icons.lock_outline,
                    suffix: GestureDetector(
                      onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                      child: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: Colors.grey[400],
                        size: 20.w,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Password is required';
                    return null;
                  },
                ),
                Gap(32.h),
                // Sign in button
                SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: authVm.isLoading
                        ? null
                        : () async {
                            if (_formKey.currentState!.validate()) {
                              authVm.addToRegisterMap('email', _emailCtrl.text.trim());
                              authVm.addToRegisterMap('password', _passwordCtrl.text.trim());
                              await authVm.login();
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purple,
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(27.r),
                      ),
                      elevation: 0,
                    ),
                    child: authVm.isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2)
                        : Text(
                            'Sign in',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                Gap(24.h),
                // Sign up link
                Center(
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => const RegisterScreen());
                      context.read<AuthVm>().setRegistrationMode(true);
                    },
                    child: RichText(
                      text: TextSpan(
                        text: "Don't have an account?  ",
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[500],
                        ),
                        children: [
                          TextSpan(
                            text: 'Sign up',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: AppColors.purple,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Gap(32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
      prefixIcon: Icon(icon, color: Colors.grey[400], size: 20.w),
      suffixIcon: suffix != null
          ? Padding(padding: EdgeInsets.only(right: 12.w), child: suffix)
          : null,
      suffixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
      filled: true,
      fillColor: Colors.white,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide(color: Colors.grey[200]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: AppColors.purple, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14.r),
        borderSide: const BorderSide(color: Colors.red, width: 1.5),
      ),
    );
  }
}
