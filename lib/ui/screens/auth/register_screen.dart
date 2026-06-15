import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../../core/core_constants/colors.dart';
import '../../../core/core_constants/label.dart';
import '../../../data/locator.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/dialog_service.dart';
import 'otp_screen.dart';
import 'password_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryNotifier = ValueNotifier<Country?>(null);

  AuthVm? authVm;

  @override
  void initState() {
    authVm = context.read<AuthVm>();
    super.initState();
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _countryNotifier.dispose();
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
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                Padding(
                  padding: EdgeInsets.all(16.w),
                  child: GestureDetector(
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
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Form(
                      key: _globalKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Gap(8.h),
                          Text(
                            'Create your\ndriver account',
                            style: TextStyle(
                              fontFamily: 'BeauSans',
                              fontSize: 28.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                              height: 1.2,
                            ),
                          ),
                          Gap(8.h),
                          Text(
                            'Step 1 of 4 · Tell us about yourself',
                            style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
                          ),
                          Gap(12.h),
                          // 4-segment progress bar
                          Row(
                            children: List.generate(
                              4,
                              (i) => Expanded(
                                child: Container(
                                  height: 4.h,
                                  margin: EdgeInsets.only(right: i < 3 ? 6.w : 0),
                                  decoration: BoxDecoration(
                                    color: i == 0
                                        ? AppColors.purple
                                        : AppColors.purple.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(2.r),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Gap(28.h),
                          // Full name field
                          Text(
                            'Full name',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Gap(6.h),
                          _buildField(
                            controller: _nameCtrl,
                            hint: 'e.g. Kojo Mensah',
                            icon: Icons.person_outline,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          Gap(16.h),
                          // Email field
                          Text(
                            'Email address',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Gap(6.h),
                          _buildField(
                            controller: _emailCtrl,
                            hint: 'you@email.com',
                            icon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          Gap(16.h),
                          // Phone field
                          Text(
                            'Phone number',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Gap(6.h),
                          _buildField(
                            controller: _phoneController,
                            hint: '+233 24 000 0000',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          Gap(16.h),
                          // Country field
                          Text(
                            'Country',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Gap(6.h),
                          ValueListenableBuilder<Country?>(
                            valueListenable: _countryNotifier,
                            builder: (_, country, __) => GestureDetector(
                              onTap: () => showCountryPicker(
                                context: context,
                                showPhoneCode: true,
                                onSelect: (c) {
                                  _countryNotifier.value = c;
                                  _countryController.text = c.name;
                                },
                              ),
                              child: Container(
                                height: 52.h,
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12.r),
                                  border: Border.all(color: Colors.grey[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.language_outlined,
                                        size: 20.w, color: Colors.grey[400]),
                                    Gap(10.w),
                                    Expanded(
                                      child: Text(
                                        country?.name ?? 'Select country',
                                        style: TextStyle(
                                          fontSize: 15.sp,
                                          color: country == null
                                              ? Colors.grey[400]
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    Icon(Icons.keyboard_arrow_down,
                                        color: Colors.grey[400]),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          Gap(40.h),
                        ],
                      ),
                    ),
                  ),
                ),
                // Continue button
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton.icon(
                      onPressed: authVm.isLoading
                          ? null
                          : () async {
                              if (_globalKey.currentState!.validate()) {
                                FocusManager.instance.primaryFocus?.unfocus();
                                final country = _countryNotifier.value;
                                if (country == null) {
                                  locator<DialogService>().showSnackBar(
                                      "No Country Selected",
                                      "Please select your country code before continuing");
                                  return;
                                }
                                final phoneNumber = _phoneController.text.trim();
                                final formattedNumber =
                                    '+${country.phoneCode}${toNumericString(phoneNumber)}';
                                final email = _emailCtrl.text.trim();
                                final username = _nameCtrl.text.trim();
                                authVm.addToRegisterMap(
                                    "phone_number", formattedNumber);
                                authVm.addToRegisterMap("email", email);
                                authVm.addToRegisterMap("full_name", username);
                                authVm.addToRegisterMap("country", "GH");
                                locator<DialogService>().showAlertDialog(
                                  context: context,
                                  message:
                                      "Is your number $formattedNumber correct?",
                                  okayText: Label.yes,
                                  showTitle: true,
                                  title: "Warning",
                                  cancelText: Label.no,
                                  type: AlertDialogType.warning,
                                  showCancelBtn: true,
                                  onOkayBtnTap: () async {
                                    Navigator.pop(context);
                                    Get.to(() => const PasswordScreen(),
                                        transition: Transition.leftToRight);
                                  },
                                );
                              }
                            },
                      icon: authVm.isLoading
                          ? SizedBox(
                              width: 18.w,
                              height: 18.w,
                              child: const CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2),
                            )
                          : const Icon(Icons.arrow_forward,
                              color: Colors.white, size: 18),
                      label: Text(
                        'Continue',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.purple,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28.r)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14.sp),
        prefixIcon: Icon(icon, size: 20.w, color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
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
    );
  }
}
