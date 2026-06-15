import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';

import '../../../shared_widgets/custom_textfield.dart';



class PasswordForm extends StatefulWidget {
  const PasswordForm({super.key, required this.passwordController, required this.formKey, required this.confirmPasswordController});

  final GlobalKey<FormState> formKey;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;

  @override
  State<PasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends State<PasswordForm> {

  final obscurePasswordNotifier = ValueNotifier(true);
  final obscureConfirmPasswordNotifier = ValueNotifier(true);

  @override
  void dispose() {
    obscurePasswordNotifier.dispose();
    obscureConfirmPasswordNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: obscurePasswordNotifier,
            builder: (_, value, __) {
              return CustomTextField(
                labelText: 'Password',
                controller: widget.passwordController,
                keyboardType: TextInputType.visiblePassword,
                suffixIcon: GestureDetector(
                  onTap: () {
                    obscurePasswordNotifier.value =
                    !obscurePasswordNotifier.value;
                  },
                  child: Icon(
                    value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
                obscureText: value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Password must not be empty';
                  }
                  if (value.length < 8) {
                    return 'Password must be at least 8 characters';
                  }
                  return null;
                },
              ).animate()
                  .slide(
                begin: const Offset(0, 0.3),
                end: const Offset(0, 0), // End at center
                duration: 600.ms,
                curve: Curves.easeOutBack,
              )
                  .fade(begin: 0, end: 1, duration: 500.ms);
            },
          ),
          const Gap(10),
          ValueListenableBuilder(
            valueListenable: obscureConfirmPasswordNotifier,
            builder: (_, value, __) {
              return CustomTextField(
                labelText: 'Confirm Password',
                controller: widget.confirmPasswordController,
                keyboardType: TextInputType.visiblePassword,
                suffixIcon: GestureDetector(
                  onTap: () {
                    obscureConfirmPasswordNotifier.value =
                    !obscureConfirmPasswordNotifier.value;
                  },
                  child: Icon(
                    value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                  ),
                ),
                obscureText: value,
                validator: (value) {
                  if (value! != widget.passwordController.text.trim()) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ).animate()
                  .slide(
                begin: const Offset(0, 0.3),
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
