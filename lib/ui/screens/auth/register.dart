import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_multi_formatter/formatters/formatter_utils.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';


import '../../../app/theme.dart';
import '../../../core/core_constants/colors.dart';
import '../../../core/core_constants/label.dart';
import '../../../data/locator.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/dialog_service.dart';
import '../../shared_widgets/default_button.dart';
import '../../shared_widgets/loader.dart';
import 'auth_widgets/get_user_image.dart';
import 'auth_widgets/no_account.dart';
import 'auth_widgets/password_form.dart';
import 'auth_widgets/sign_up_form.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {

  final GlobalKey<FormState> _registerFormKey = GlobalKey<FormState>();
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _nameCtrl = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordCtrl = TextEditingController();
  final TextEditingController _confirmPasswordCtrl = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _countryNotifier = ValueNotifier<Country?>(null);
  final _pageController = PageController();
  int _currentPage = 0;


  //providers
  late AuthVm authVm;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    authVm = context.read<AuthVm>();
  }

  Future<void> _nextPage() async {
    if (_currentPage == 1) {
      if (!_registerFormKey.currentState!.validate()) return;
      FocusManager.instance.primaryFocus?.unfocus();
      final phoneNumber = _phoneController.text.trim();
      final country = _countryNotifier.value!;
      final formattedNumber = '+${country.phoneCode}${toNumericString(phoneNumber)}';
      final email = _emailCtrl.text.trim();
      final username = _nameCtrl.text.trim();
      Map body = {"phone_number": formattedNumber, "email": email, "full_name": username, "country": "GH"};
      authVm.addToRegisterMap("phone_number", formattedNumber);
      authVm.addToRegisterMap("email", email);
      authVm.addToRegisterMap("full_name", username,);
      authVm.addToRegisterMap("country", "GH");
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else if (_currentPage == 2) {

      if (!_formKey.currentState!.validate()) return;
      var password1 = _passwordCtrl.text.trim();
      authVm.addToRegisterMap("password1", password1);
      var password2 = _confirmPasswordCtrl.text.trim();
      authVm.addToRegisterMap("password2", password2);
      authVm.addToRegisterMap("isDriver", true);
      await authVm.register();

    } else if (_currentPage == 0) {
      if(authVm.imageFile == null) {
        locator<DialogService>().showSnackBar("No Image Selected", "Please select an image to proceed");
        return;
      }
      authVm.addToRegisterMap("avatar", authVm.selectedFile);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }


  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }



  @override
  void dispose() {
    // TODO: implement dispose
    _emailCtrl.dispose();
    _nameCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    _phoneController.dispose();
    _countryController.dispose();
    _pageController.dispose();
    _countryNotifier.dispose();
    _registerFormKey.currentState?.dispose();
    _formKey.currentState?.dispose();
    authVm.clearBodyAndImages();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    authVm  = context.watch<AuthVm>();
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: _currentPage > 0
            ? IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: _previousPage,
        )
            : IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.primaryColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: (_currentPage + 1) / 3,
                          backgroundColor: AppColors.greyAd,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.purple),
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                          '${_currentPage + 1}/3',
                          style: AppThemes.getCustomTextStyle(fontFamily: "Zain", weight: FontWeight.w500, color: AppColors.fill, fontSize: 16, lineHeight: 1.33)
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (page) => setState(() => _currentPage = page),
                    children: [
                      _buildImageUploadPage(),
                      _buildPersonalInfoPage(),
                      _buildPasswordPage(),

                    ],
                  ),
                ),
              ],
            ),
            Visibility(visible: authVm.isLoading, child: const Loader()),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SizedBox(
            height: 55,
            child: DefaultButton(
              onBtnTap: _nextPage,
              btnText: _currentPage == 3 ? Label.buttonRegisterLabel : Label.buttonContinueLabel,
              isIconPresent: false,
              btnColor: AppColors.purple,
              btnTextColor: AppColors.white,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalInfoPage(){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Gap(20.h),
            Text(Label.registerScreenTitleLabel, style: AppThemes.getCustomTextStyle(fontFamily: "Zain", weight: FontWeight.w800, color: AppColors.primaryColor, fontSize: 38, lineHeight: 1.33), textAlign: TextAlign.center)
                .animate(delay: 100.ms)
                .slide(
              begin: const Offset(0, -0.3),
              end: const Offset(0, 0), // End at center
              duration: 600.ms,
              curve: Curves.easeOutBack,
            )
                .fade(begin: 0, end: 1, duration: 600.ms),
            Gap(4.h),
            Text(Label.registerScreenMessageLabel, style: AppThemes.getCustomTextStyle(fontFamily: "Zain", weight: FontWeight.w500, color: AppColors.greyAd, fontSize: 24, lineHeight: 1.33), textAlign: TextAlign.center)
                .animate(delay: 100.ms)
                .slide(
              begin: const Offset(0, -0.3),
              end: const Offset(0, 0), // End at center
              duration: 600.ms,
              curve: Curves.easeOutBack,
            )
                .fade(begin: 0, end: 1, duration: 600.ms),
            Gap(0.12.sh),
            SignUpForm(emailController: _emailCtrl, nameController: _nameCtrl, countryController: _countryController, phoneController: _phoneController, formKey: _registerFormKey, countryNotifier: _countryNotifier),

            Gap(30.h),
            NoAccount(
              title: Label.registerYesAccountLabel,
              actionTitle: Label.registerSignInLabel,
              onPressed: () {
                Get.back();
              },
            ),
            Gap(30.h),
          ],
        ),
      ),
    );
  }

  Widget _buildPasswordPage(){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Gap(20.h),
            Text(Label.passwordScreenTitleLabel, style: AppThemes.getCustomTextStyle(fontFamily: "Zain", weight: FontWeight.w800, color: AppColors.primaryColor, fontSize: 38, lineHeight: 1.33), textAlign: TextAlign.center)
                .animate(delay: 100.ms)
                .slide(
              begin: const Offset(0, -0.3),
              end: const Offset(0, 0), // End at center
              duration: 600.ms,
              curve: Curves.easeOutBack,
            )
                .fade(begin: 0, end: 1, duration: 600.ms),
            Gap(4.h),
            Text(Label.passwordScreenMessageLabel, style: AppThemes.getCustomTextStyle(fontFamily: "Zain", weight: FontWeight.w500, color: AppColors.greyAd, fontSize: 24, lineHeight: 1.33), textAlign: TextAlign.center)
                .animate(delay: 100.ms)
                .slide(
              begin: const Offset(0, -0.3),
              end: const Offset(0, 0), // End at center
              duration: 600.ms,
              curve: Curves.easeOutBack,
            )
                .fade(begin: 0, end: 1, duration: 600.ms),
            Gap(0.15.sh),
            PasswordForm(formKey: _formKey, passwordController: _passwordCtrl, confirmPasswordController: _confirmPasswordCtrl,),
          ],
        ),
      ),
    );
  }

  Widget _buildImageUploadPage(){
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Gap(20.h),
            Text(Label.imageTitleLabel, style: AppThemes.getCustomTextStyle(fontFamily: "Zain", weight: FontWeight.w800, color: AppColors.primaryColor, fontSize: 38, lineHeight: 1.33), textAlign: TextAlign.center)
                .animate(delay: 100.ms)
                .slide(
              begin: const Offset(0, -0.3),
              end: const Offset(0, 0), // End at center
              duration: 600.ms,
              curve: Curves.easeOutBack,
            )
                .fade(begin: 0, end: 1, duration: 600.ms),
            Gap(4.h),
            Text(Label.imageMessageLabel, style: AppThemes.getCustomTextStyle(fontFamily: "Zain", weight: FontWeight.w500, color: AppColors.greyAd, fontSize: 24, lineHeight: 1.33), textAlign: TextAlign.center)
                .animate(delay: 100.ms)
                .slide(
              begin: const Offset(0, -0.3),
              end: const Offset(0, 0), // End at center
              duration: 600.ms,
              curve: Curves.easeOutBack,
            )
                .fade(begin: 0, end: 1, duration: 600.ms),
            Gap(0.15.sh),
            GetUserImage(
              imageFile: authVm.imageFile,
              onCameraTap: () {
                authVm.captureProfilePicture(context,
                    source: ImageSource.camera);
                Get.back();
              },
              onGalleryTap: () {
                authVm.captureProfilePicture(context,
                    source: ImageSource.gallery);
                Get.back();
              },
            ),
            Gap(30.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Profile Picture ", style: AppThemes.getCustomTextStyle(
                  fontFamily: "BeauSans",
                  fontSize: 12,
                  weight: FontWeight.w300,
                ),),
                Text("Upload", style: AppThemes.getCustomTextStyle(
                  fontFamily: "BeauSans",
                  fontSize: 12,
                  weight: FontWeight.w600,
                ),),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
