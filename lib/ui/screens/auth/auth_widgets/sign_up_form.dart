import 'package:country_picker/country_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_multi_formatter/formatters/phone_input_formatter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';

import '../../../../core/utility.dart';
import '../../../shared_widgets/custom_textfield.dart';

class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key, required this.emailController, required this.nameController, required this.countryController, required this.phoneController, required this.formKey, required this.countryNotifier});

  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController nameController;
  final TextEditingController phoneController;
  final TextEditingController countryController;
  final ValueNotifier<Country?> countryNotifier;

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final phoneFocusNode = FocusNode();

  void pickCountry() {
    showCountryPicker(
      context: context,
      onSelect: (country) {
        if (country == widget.countryNotifier.value) return;
        widget.countryNotifier.value = country;
        phoneFocusNode.requestFocus();
      },
    );
  }

  @override
  void initState() {
    super.initState();
    widget.countryNotifier.addListener(() {
      if (widget.countryNotifier.value == null) {
        widget.phoneController.clear();
        widget.countryController.clear();
      } else {
        widget.countryController.text = '+'
            '${widget.countryNotifier.value!.phoneCode}';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: widget.formKey,
      child: Column(
        children: [
          CustomTextField(
            controller: widget.nameController,
            hintText: "Full name",
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: TextInputType.name,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return "Name input field must not be empty";
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
          CustomTextField(
            controller: widget.emailController,
            hintText: "Email Address",
            autovalidateMode: AutovalidateMode.onUserInteraction,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
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
          ValueListenableBuilder(
            valueListenable: widget.countryNotifier,
            builder: (_, country, __) {
              return Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      controller: widget.countryController,
                      readOnly: true,
                      labelText: country == null ? '+123' : '',
                      onTap: pickCountry,
                      validator: (value) {
                        if (!isPhoneValid(
                          widget.phoneController.text,
                          defaultCountryCode: country?.countryCode,
                        )) {
                          return '';
                        }
                        return null;
                      },
                    ),
                  ),
                  const Gap(8),
                  Expanded(
                    flex: 3,
                    child: CustomTextField(
                      labelText: 'Phone',
                      focusNode: phoneFocusNode,
                      hintText: "54 000 0000",
                      readOnly: country == null,
                      onTap: () {
                        if (country == null) {
                          pickCountry();
                        }
                      },
                      keyboardType: TextInputType.phone,
                      controller: widget.phoneController,
                      validator: (value) {
                        if (!isPhoneValid(
                          value!,
                          defaultCountryCode: country?.countryCode,
                        )) {
                          return 'Invalid Phone number';
                        }
                        return null;
                      },
                      inputFormatters: [
                        PhoneInputFormatter(
                          defaultCountryCode: country?.countryCode,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
