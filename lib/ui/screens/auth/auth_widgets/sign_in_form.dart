import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import '../../../../core/utility.dart';
import '../../../shared_widgets/custom_textfield.dart';

class SignInForm extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const SignInForm({super.key, required this.formKey, required this.emailController, required this.passwordController});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final ValueNotifier<bool> _obscureText = ValueNotifier(true);


  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: widget.emailController,
            hintText: "Email Address",
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null) {
                return "Email input field must not be empty";
              }
              if(!Utils.emailRegex.hasMatch(value)) {
                return "Please enter a valid email address";
              }
              return null;
            },
          )
          .animate()
          .slide(
            begin: const Offset(0, 0.3),
            end: const Offset(0, 0), // End at center
            duration: 600.ms,
            curve: Curves.easeOutBack,
          )
          .fade(begin: 0, end: 1, duration: 500.ms),
          Gap(10.h),
          ValueListenableBuilder<bool>(
            valueListenable: _obscureText,
            builder: (_, obscureText, __) {
              return CustomTextField(
                controller: widget.passwordController,
                keyboardType: TextInputType.visiblePassword,
                hintText: 'Password',
                obscureText: obscureText,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureText ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    _obscureText.value = !obscureText;
                  },
                ),
              ).animate(delay: 100.ms)
                  .slide(
                begin: const Offset(0, -0.3),
                end: const Offset(0, 0), // End at center
                duration: 600.ms,
                curve: Curves.easeOutBack,
              )
                  .fade(begin: 0, end: 1, duration: 500.ms);
            },
          ),
        ],
      ),
    );
  }
}
