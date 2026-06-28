import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ridechain_driiver/ui/screens/navigation/app_navigation_screen.dart';

import '../../../core/core_constants/colors.dart';
import '../../../providers/auth_provider.dart';
import '../../shared_widgets/custom_textfield.dart';
import '../../shared_widgets/loader.dart';

class VehicleRegistrationDocuments extends StatefulWidget {
  final bool isRegistration;
  const VehicleRegistrationDocuments({super.key, this.isRegistration = false});

  @override
  State<VehicleRegistrationDocuments> createState() =>
      _VehicleRegistrationDocumentsState();
}

class _VehicleRegistrationDocumentsState
    extends State<VehicleRegistrationDocuments> {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  final TextEditingController _vehiclePlateNumber = TextEditingController();
  final focusNode = FocusNode();
  String? selectedVehicle;
  String? selectedColor;
  File? vehicleImage;
  File? licenseImage;
  dio.MultipartFile? licenseMultipartImage;
  dio.MultipartFile? vehicleMultipartImage;

  static const List<String> _vehicleTypes = [
    'Sedan',
    'SUV',
    'Truck',
    'Van',
    'Minivan',
    'Saloon',
    'Other',
  ];

  static const Map<String, Color> _colors = {
    'Black': Colors.black,
    'White': Colors.white,
    'Silver': const Color(0xFFAAAAAA),
    'Red': Colors.red,
    'Blue': Colors.blue,
    'Green': Colors.green,
    'Yellow': Colors.amber,
    'Orange': Colors.orange,
    'Brown': const Color(0xFF8B4513),
  };

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
                        const Spacer(),
                        Text(
                          '5/6',
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
                              'Vehicle',
                              style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                            ),
                          ],
                        ),
                        Gap(8.h),
                        // 6-segment progress bar (5 filled)
                        Row(
                          children: List.generate(
                            6,
                            (i) => Expanded(
                              child: Container(
                                height: 4.h,
                                margin: EdgeInsets.only(right: i < 5 ? 4.w : 0),
                                decoration: BoxDecoration(
                                  color: i < 5
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
                          'Vehicle information',
                          style: TextStyle(
                            fontFamily: 'BeauSans',
                            fontSize: 26.sp,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                        Gap(6.h),
                        Text(
                          'Add a photo of your car and its details.',
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
                          // Vehicle photo upload zone
                          GestureDetector(
                            onTap: () async {
                              await _showVehicleImagePicker(context, authVm);
                            },
                            child: Container(
                              width: double.infinity,
                              height: 160.h,
                              decoration: BoxDecoration(
                                color: vehicleImage != null
                                    ? null
                                    : AppColors.purple.withValues(alpha: 0.04),
                                borderRadius: BorderRadius.circular(16.r),
                                border: Border.all(
                                  color: AppColors.purple.withValues(alpha: 0.3),
                                  width: 1.5,
                                ),
                              ),
                              clipBehavior: Clip.antiAlias,
                              child: vehicleImage != null
                                  ? Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.file(vehicleImage!, fit: BoxFit.cover),
                                        Positioned(
                                          top: 8.h,
                                          right: 8.w,
                                          child: Container(
                                            padding: EdgeInsets.all(6.w),
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              borderRadius: BorderRadius.circular(20.r),
                                            ),
                                            child: Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 16.w,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  : Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.camera_alt_outlined,
                                          size: 36.w,
                                          color: AppColors.purple,
                                        ),
                                        Gap(8.h),
                                        Text(
                                          'Add vehicle photo',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.purple,
                                          ),
                                        ),
                                        Gap(4.h),
                                        Text(
                                          'Tap to take a photo or choose from gallery',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                            ),
                          ),
                          Gap(20.h),
                          // Vehicle type chips
                          Text(
                            'Vehicle type',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Gap(10.h),
                          Wrap(
                            spacing: 8.w,
                            runSpacing: 8.h,
                            children: _vehicleTypes.map((type) {
                              final isSelected = selectedVehicle == type;
                              return GestureDetector(
                                onTap: () => setState(() => selectedVehicle = type),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 16.w,
                                    vertical: 8.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.purple.withValues(alpha: 0.08)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(20.r),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.purple
                                          : Colors.grey[300]!,
                                      width: isSelected ? 1.5 : 1,
                                    ),
                                  ),
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: isSelected
                                          ? FontWeight.w600
                                          : FontWeight.w400,
                                      color: isSelected
                                          ? AppColors.purple
                                          : Colors.black87,
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          Gap(20.h),
                          // Color swatches
                          Text(
                            'Color',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Gap(10.h),
                          Wrap(
                            spacing: 10.w,
                            runSpacing: 10.h,
                            children: _colors.entries.map((entry) {
                              final isSelected = selectedColor == entry.key;
                              return GestureDetector(
                                onTap: () => setState(() => selectedColor = entry.key),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                      width: 36.w,
                                      height: 36.w,
                                      decoration: BoxDecoration(
                                        color: entry.value,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: isSelected
                                              ? AppColors.purple
                                              : Colors.grey[300]!,
                                          width: isSelected ? 2.5 : 1,
                                        ),
                                        boxShadow: isSelected
                                            ? [
                                                BoxShadow(
                                                  color: AppColors.purple
                                                      .withValues(alpha: 0.3),
                                                  blurRadius: 6,
                                                  spreadRadius: 1,
                                                ),
                                              ]
                                            : null,
                                      ),
                                      child: isSelected
                                          ? Icon(
                                              Icons.check,
                                              size: 16.w,
                                              color: entry.value == Colors.white ||
                                                      entry.value == Colors.yellow ||
                                                      entry.value == Colors.amber
                                                  ? Colors.black
                                                  : Colors.white,
                                            )
                                          : null,
                                    ),
                                    Gap(4.h),
                                    Text(
                                      entry.key,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: isSelected
                                            ? AppColors.purple
                                            : Colors.grey[500],
                                        fontWeight: isSelected
                                            ? FontWeight.w600
                                            : FontWeight.w400,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                          Gap(20.h),
                          // Plate number field
                          Text(
                            'Plate number',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Gap(6.h),
                          CustomTextField(
                            labelText: 'Vehicle plate number',
                            hintText: "Enter vehicle plate number",
                            keyboardType: TextInputType.text,
                            controller: _vehiclePlateNumber,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Vehicle plate number must not be empty';
                              }
                              return null;
                            },
                          ),
                          Gap(16.h),
                          // Vehicle license image card
                          Text(
                            'Vehicle license',
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Gap(8.h),
                          GestureDetector(
                            onTap: () async {
                              await _showLicenseImagePicker(context, authVm);
                            },
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(16.w),
                              decoration: BoxDecoration(
                                color: licenseImage != null
                                    ? AppColors.purple.withValues(alpha: 0.04)
                                    : AppColors.purple.withValues(alpha: 0.04),
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
                                      licenseImage != null
                                          ? Icons.check_circle
                                          : Icons.description_outlined,
                                      color: licenseImage != null
                                          ? Colors.green
                                          : AppColors.purple,
                                      size: 24.w,
                                    ),
                                  ),
                                  Gap(14.w),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Vehicle license',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        Gap(2.h),
                                        Text(
                                          licenseImage != null
                                              ? 'Uploaded ✓'
                                              : 'Upload vehicle license document',
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            color: licenseImage != null
                                                ? Colors.green
                                                : Colors.grey[500],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    licenseImage != null
                                        ? Icons.check
                                        : Icons.upload_outlined,
                                    color: licenseImage != null
                                        ? Colors.green
                                        : Colors.grey[400],
                                    size: 20.w,
                                  ),
                                ],
                              ),
                            ),
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
                            if (selectedVehicle == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select a vehicle type'),
                                ),
                              );
                              return;
                            }
                            if (selectedColor == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Please select a vehicle color'),
                                ),
                              );
                              return;
                            }
                            final licensePlateNumber =
                                _vehiclePlateNumber.text.trim();
                            Map<String, dynamic> body = {
                              'vehicle_image': vehicleMultipartImage,
                              'vehicle_type': selectedVehicle!.toUpperCase(),
                              'vehicle_color': selectedColor!.toUpperCase(),
                              'vehicle_plate_number': licensePlateNumber,
                              'licence_image': licenseMultipartImage,
                            };
                            final bool success = await authVm.updateDriverDocs(
                              body,
                              authVm.currentUser!.driver!.id!,
                            );
                            if (success) {
                              if (widget.isRegistration) {
                                Get.offAll(() => AppNavigationScreen());
                              } else {
                                Get.back();
                              }
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
              const Loader(loaderText: "Updating driver documents"),
          ],
        ),
      ),
    );
  }

  Future<void> _showVehicleImagePicker(
      BuildContext context, AuthVm authVm) async {
    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Gap(16.h),
            Text(
              'Select vehicle image',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
            ),
            Gap(16.h),
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: AppColors.purple),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(context);
                File? image =
                    await authVm.captureImage(context, source: ImageSource.camera);
                if (image != null) {
                  var multiImage = authVm.convertImageToMultipartFile(image);
                  setState(() {
                    vehicleImage = image;
                    vehicleMultipartImage = multiImage;
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: AppColors.purple),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(context);
                File? image =
                    await authVm.captureImage(context, source: ImageSource.gallery);
                if (image != null) {
                  var multiImage = authVm.convertImageToMultipartFile(image);
                  setState(() {
                    vehicleImage = image;
                    vehicleMultipartImage = multiImage;
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.attach_file_outlined, color: AppColors.purple),
              title: const Text('Choose a file'),
              onTap: () async {
                Navigator.pop(context);
                File? file = await authVm.captureFile();
                if (file != null) {
                  var multiFile = await authVm.convertFileToMultipartFile(file);
                  setState(() {
                    vehicleImage = file;
                    vehicleMultipartImage = multiFile;
                  });
                }
              },
            ),
            Gap(8.h),
          ],
        ),
      ),
    );
  }

  Future<void> _showLicenseImagePicker(
      BuildContext context, AuthVm authVm) async {
    await showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Gap(16.h),
            Text(
              'Select vehicle license image',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
            ),
            Gap(16.h),
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: AppColors.purple),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(context);
                File? image =
                    await authVm.captureImage(context, source: ImageSource.camera);
                if (image != null) {
                  var multiImage = authVm.convertImageToMultipartFile(image);
                  setState(() {
                    licenseImage = image;
                    licenseMultipartImage = multiImage;
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: AppColors.purple),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(context);
                File? image =
                    await authVm.captureImage(context, source: ImageSource.gallery);
                if (image != null) {
                  var multiImage = authVm.convertImageToMultipartFile(image);
                  setState(() {
                    licenseImage = image;
                    licenseMultipartImage = multiImage;
                  });
                }
              },
            ),
            ListTile(
              leading: Icon(Icons.attach_file_outlined, color: AppColors.purple),
              title: const Text('Choose a file'),
              onTap: () async {
                Navigator.pop(context);
                File? file = await authVm.captureFile();
                if (file != null) {
                  var multiFile = await authVm.convertFileToMultipartFile(file);
                  setState(() {
                    licenseImage = file;
                    licenseMultipartImage = multiFile;
                  });
                }
              },
            ),
            Gap(8.h),
          ],
        ),
      ),
    );
  }
}
