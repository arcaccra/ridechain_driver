import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ridechain_driiver/data/locator.dart';
import 'package:ridechain_driiver/services/dialog_service.dart';
import 'package:ridechain_driiver/ui/screens/auth/vehicle_registration_documents.dart';

import '../../../core/core_constants/colors.dart';
import '../../../core/core_constants/label.dart';
import '../../../providers/auth_provider.dart';
import '../../../services/rides_service.dart';
import '../../shared_widgets/custom_dropdown_widget.dart';
import '../../shared_widgets/custom_textfield.dart';
import '../../shared_widgets/loader.dart';
import 'auth_widgets/capture_document_image_or_file_card.dart';
import 'login_screen.dart';

class IdCardDocuments extends StatefulWidget {
  const IdCardDocuments({super.key});

  @override
  State<IdCardDocuments> createState() => _IdCardDocumentsState();
}

class _IdCardDocumentsState extends State<IdCardDocuments> {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  final TextEditingController _idNumber = TextEditingController();
  final focusNode = FocusNode();
  String? selectedIdType;
  File? idFrontImage;
  File? idBackImage;
  File? licenseCert;
  dio.MultipartFile? frontMultipartImage;
  dio.MultipartFile? backMultipartImage;
  dio.MultipartFile? licenseCertMultipartImage;

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthVm>(context);
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            Form(
              key: _globalKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Gap(16.h),
                  // Top row: back + step counter
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (authVm.isRegistration) {
                              Get.offAll(() => const LoginScreen());
                            } else {
                              Get.back();
                            }
                          },
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
                        const Spacer(),
                        Text(
                          '2/6',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(12.h),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Step label row
                        Row(
                          children: [
                            Text(
                              'VERIFICATION · STEP 3 OF 4',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: AppColors.purple,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'License',
                              style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                        Gap(8.h),
                        // 6-segment progress bar (2 filled)
                        Row(
                          children: List.generate(
                            6,
                            (i) => Expanded(
                              child: Container(
                                height: 4.h,
                                margin: EdgeInsets.only(right: i < 5 ? 4.w : 0),
                                decoration: BoxDecoration(
                                  color: i < 2
                                      ? AppColors.purple
                                      : AppColors.purple.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(2.r),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Gap(20.h),
                        Text(
                          "Driver's license",
                          style: TextStyle(
                            fontFamily: 'BeauSans',
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        Gap(6.h),
                        Text(
                          "We need a photo of your valid driver's license.",
                          style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
                        ),
                        Gap(20.h),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Front image status tile (visual indicator)
                          _UploadTile(
                            label: "Driver's license",
                            sublabel: 'Front side, clearly visible',
                            file: idFrontImage,
                          ),
                          Gap(10.h),
                          // Front image capture card
                          CaptureDocumentImageOrFileCard(
                            title: "Select front image of the ID Card",
                            imageFile: idFrontImage,
                            onCameraTap: () async {
                              Navigator.pop(context);
                              File? image = await authVm.captureImage(
                                context,
                                source: ImageSource.camera,
                              );
                              if (image != null) {
                                var multiImage =
                                    authVm.convertImageToMultipartFile(image);
                                setState(() {
                                  idFrontImage = image;
                                  frontMultipartImage = multiImage;
                                });
                              }
                            },
                            onFileTap: () async {
                              File? file = await authVm.captureFile();
                              if (file != null) {
                                var multiFile =
                                    await authVm.convertFileToMultipartFile(file);
                                setState(() {
                                  idFrontImage = file;
                                  frontMultipartImage = multiFile;
                                });
                              }
                            },
                            onGalleryTap: () async {
                              Navigator.pop(context);
                              File? image = await authVm.captureImage(
                                context,
                                source: ImageSource.gallery,
                              );
                              if (image != null) {
                                var multiImage =
                                    authVm.convertImageToMultipartFile(image);
                                setState(() {
                                  idFrontImage = image;
                                  frontMultipartImage = multiImage;
                                });
                              }
                            },
                          ),
                          Gap(10.h),
                          // Back image capture card
                          CaptureDocumentImageOrFileCard(
                            title: "Select back image of the ID Card",
                            imageFile: idBackImage,
                            onCameraTap: () async {
                              Navigator.pop(context);
                              File? image = await authVm.captureImage(
                                context,
                                source: ImageSource.camera,
                              );
                              if (image != null) {
                                var multiImage =
                                    authVm.convertImageToMultipartFile(image);
                                setState(() {
                                  idBackImage = image;
                                  backMultipartImage = multiImage;
                                });
                              }
                            },
                            onFileTap: () async {
                              File? file = await authVm.captureFile();
                              if (file != null) {
                                var multiFile =
                                    await authVm.convertFileToMultipartFile(file);
                                setState(() {
                                  idBackImage = file;
                                  backMultipartImage = multiFile;
                                });
                              }
                            },
                            onGalleryTap: () async {
                              Navigator.pop(context);
                              File? image = await authVm.captureImage(
                                context,
                                source: ImageSource.gallery,
                              );
                              if (image != null) {
                                var multiImage =
                                    authVm.convertImageToMultipartFile(image);
                                setState(() {
                                  idBackImage = image;
                                  backMultipartImage = multiImage;
                                });
                              }
                            },
                          ),
                          Gap(10.h),
                          // License certificate capture card
                          CaptureDocumentImageOrFileCard(
                            title: "Capture image for the license certificate",
                            imageFile: licenseCert,
                            onCameraTap: () async {
                              Navigator.pop(context);
                              File? image = await authVm.captureImage(
                                context,
                                source: ImageSource.camera,
                              );
                              if (image != null) {
                                var multiImage =
                                    authVm.convertImageToMultipartFile(image);
                                setState(() {
                                  licenseCert = image;
                                  licenseCertMultipartImage = multiImage;
                                });
                              }
                            },
                            onFileTap: () async {
                              File? file = await authVm.captureFile();
                              if (file != null) {
                                var multiFile =
                                    await authVm.convertFileToMultipartFile(file);
                                setState(() {
                                  licenseCert = file;
                                  licenseCertMultipartImage = multiFile;
                                });
                              }
                            },
                            onGalleryTap: () async {
                              Navigator.pop(context);
                              File? image = await authVm.captureImage(
                                context,
                                source: ImageSource.gallery,
                              );
                              if (image != null) {
                                var multiImage =
                                    authVm.convertImageToMultipartFile(image);
                                setState(() {
                                  licenseCert = image;
                                  licenseCertMultipartImage = multiImage;
                                });
                              }
                            },
                          ),
                          Gap(12.h),
                          // Info box
                          Container(
                            padding: EdgeInsets.all(14.w),
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  size: 18.w,
                                  color: Colors.grey[500],
                                ),
                                Gap(8.w),
                                Expanded(
                                  child: Text(
                                    "Make sure all four corners are visible and the text is readable. Blurry images may delay approval.",
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey[600],
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Gap(20.h),
                          // ID Type label + dropdown
                          Text(
                            'ID Type',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Gap(6.h),
                          CustomDropdown(
                            items: RidesService.idTypes,
                            value: selectedIdType,
                            onChanged: (value) {
                              setState(() {
                                selectedIdType = value;
                              });
                            },
                            hintText: Label.selectIdType,
                            labelText: Label.idType,
                            prefixIcon: const Icon(Icons.badge_outlined),
                          ),
                          Gap(12.h),
                          // ID Number label + text field
                          Text(
                            'ID Number',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Gap(6.h),
                          CustomTextField(
                            labelText: 'Driver Id Number',
                            hintText: "Enter vehicle plate number",
                            keyboardType: TextInputType.text,
                            controller: _idNumber,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Driver Id number must not be empty';
                              }
                              return null;
                            },
                          ),
                          Gap(80.h),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Bottom Continue button
            Positioned(
              left: 24.w,
              right: 24.w,
              bottom: 24.h,
              child: SizedBox(
                width: double.infinity,
                height: 52.h,
                child: ElevatedButton.icon(
                  onPressed: authVm.isLoading
                      ? null
                      : () async {
                          if (_globalKey.currentState!.validate()) {
                            final idNumber = _idNumber.text.trim();
                            Map<String, dynamic> body = {
                              'id_type': RidesService.idMap[selectedIdType],
                              'id_number': idNumber,
                              'id_front_image': frontMultipartImage,
                              'id_back_image': backMultipartImage,
                              'insurance_cert': licenseCertMultipartImage,
                            };
                            bool driverExists = authVm.checkIfDriverExists();
                            final bool success = await authVm.uploadDriverDocs(
                              body,
                              driverExists: driverExists,
                            );
                            if (success) {
                              Get.off(
                                () => VehicleRegistrationDocuments(
                                  isRegistration: authVm.isRegistration,
                                ),
                              );
                            } else {
                              setState(() {
                                frontMultipartImage = null;
                                backMultipartImage = null;
                                licenseCertMultipartImage = null;
                                idBackImage = null;
                                idFrontImage = null;
                                licenseCert = null;
                              });
                              locator<DialogService>().showSnackBar(
                                "Failure",
                                "something happened when trying to upload document. please try again",
                              );
                            }
                          }
                        },
                  icon: authVm.isLoading
                      ? SizedBox(
                          width: 18.w,
                          height: 18.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Icon(Icons.arrow_forward, color: Colors.white, size: 18.w),
                  label: Text(
                    'Continue',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26.r),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
            if (authVm.isLoading)
              const Loader(loaderText: "uploading driver documents.."),
          ],
        ),
      ),
    );
  }
}

class _UploadTile extends StatelessWidget {
  final String label;
  final String sublabel;
  final File? file;

  const _UploadTile({
    required this.label,
    required this.sublabel,
    this.file,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.purple.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: AppColors.purple.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              file != null ? Icons.check_circle : Icons.description_outlined,
              color: file != null ? Colors.green : AppColors.purple,
              size: 24.w,
            ),
          ),
          Gap(14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                Gap(2.h),
                Text(
                  file != null ? 'Uploaded ✓' : sublabel,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: file != null ? Colors.green : Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          Icon(
            file != null ? Icons.check : Icons.upload_outlined,
            color: file != null ? Colors.green : Colors.grey[400],
            size: 20.w,
          ),
        ],
      ),
    );
  }
}
