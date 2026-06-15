import 'dart:io';

import 'package:dio/dio.dart' as dio;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:ridechain_driiver/providers/auth_provider.dart';

import '../../../core/core_constants/colors.dart';
import '../../../core/core_constants/label.dart';
import '../../../data/locator.dart';
import '../../../services/dialog_service.dart';
import '../../../services/rides_service.dart';
import '../../shared_widgets/custom_dropdown_widget.dart';
import '../../shared_widgets/custom_textfield.dart';
import '../navigation/app_navigation_screen.dart';
import 'auth_widgets/capture_document_image_or_file_card.dart';

class DocumentUpload extends StatefulWidget {
  final bool isRegistration;
  const DocumentUpload({super.key, required this.isRegistration});

  @override
  State<DocumentUpload> createState() => _DocumentUploadState();
}

class _DocumentUploadState extends State<DocumentUpload> {
  // ID documents
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

  // Vehicle documents
  final GlobalKey<FormState> _vehicleGlobalKey = GlobalKey<FormState>();
  final TextEditingController _vehiclePlateNumber = TextEditingController();
  String? selectedVehicle;
  String? selectedColor;
  File? vehicleImage;
  File? licenseImage;
  dio.MultipartFile? licenseMultipartImage;
  dio.MultipartFile? vehicleMultipartImage;

  late AuthVm authVm;
  Map<String, dynamic> allDocumentMap = {};
  final _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    authVm = context.read<AuthVm>();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _idNumber.dispose();
    _vehiclePlateNumber.dispose();
    focusNode.dispose();
    super.dispose();
  }

  Future<void> _nextPage() async {
    if (_currentPage == 0) {
      if (!_globalKey.currentState!.validate()) return;
      if (selectedIdType == null) {
        locator<DialogService>().showSnackBar('No ID Type Selected', 'Please select an ID card type');
        return;
      }
      if (idFrontImage == null || idBackImage == null) {
        locator<DialogService>().showSnackBar('No ID Image Selected', 'Please select ID card images');
        return;
      }
      if (licenseCert == null) {
        locator<DialogService>().showSnackBar('Missing Insurance', 'Please upload your insurance certificate');
        return;
      }
      final idNumber = _idNumber.text.trim();
      allDocumentMap.addAll({
        'id_type': RidesService.idMap[selectedIdType],
        'id_number': idNumber,
        'id_front_image': frontMultipartImage,
        'id_back_image': backMultipartImage,
        'insurance_cert': licenseCertMultipartImage,
      });
      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
    } else if (_currentPage == 1) {
      if (!_vehicleGlobalKey.currentState!.validate()) return;
      if (selectedVehicle == null) {
        locator<DialogService>().showSnackBar('No Vehicle Type', 'Please select a vehicle type');
        return;
      }
      if (selectedColor == null) {
        locator<DialogService>().showSnackBar('No Vehicle Color', 'Please select a vehicle color');
        return;
      }
      if (vehicleImage == null) {
        locator<DialogService>().showSnackBar('No Vehicle Image', 'Please upload a vehicle photo');
        return;
      }
      if (licenseImage == null) {
        locator<DialogService>().showSnackBar('No License Image', 'Please upload your license');
        return;
      }
      allDocumentMap.addAll({
        'vehicle_image': vehicleMultipartImage,
        'vehicle_type': selectedVehicle!.toUpperCase(),
        'vehicle_color': selectedColor!.toUpperCase(),
        'vehicle_plate_number': _vehiclePlateNumber.text.trim(),
        'license_image': licenseMultipartImage,
      });
      bool driverExists = authVm.checkIfDriverExists();
      final bool success = await authVm.uploadDriverDocs(allDocumentMap, driverExists: driverExists);
      if (success) {
        if (widget.isRegistration) {
          Get.offAll(() => const AppNavigationScreen());
        } else {
          Get.back();
        }
      } else {
        setState(() {
          frontMultipartImage = null;
          backMultipartImage = null;
          licenseCertMultipartImage = null;
          idBackImage = null;
          idFrontImage = null;
          licenseCert = null;
          vehicleMultipartImage = null;
          vehicleImage = null;
        });
        locator<DialogService>().showSnackBar('Upload Failed', 'Something went wrong. Please try again.');
      }
    }
  }

  void _previousPage() {
    _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
  }

  @override
  Widget build(BuildContext context) {
    authVm = context.watch<AuthVm>();
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _currentPage > 0 ? _previousPage : () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.chevron_left, color: Colors.black),
                    ),
                  ),
                  Gap(12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _currentPage == 0 ? 'Identity documents' : 'Vehicle documents',
                          style: TextStyle(
                            fontFamily: 'BeauSans',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          'Step ${_currentPage + 1} of 2',
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Progress bar
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                children: List.generate(2, (i) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: i < 1 ? 6.w : 0),
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: i <= _currentPage ? AppColors.purple : Colors.grey[200],
                        borderRadius: BorderRadius.circular(2.r),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Gap(16.h),
            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) => setState(() => _currentPage = page),
                children: [
                  _buildIdDocumentsPage(),
                  _buildVehiclePage(),
                ],
              ),
            ),
            // Continue button
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
              child: SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: authVm.isLoading ? null : _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.purple,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(27.r),
                    ),
                    elevation: 0,
                  ),
                  child: authVm.isLoading
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                      : Text(
                          _currentPage == 1 ? 'Submit documents' : 'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
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

  Widget _buildIdDocumentsPage() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Form(
        key: _globalKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Verify your identity',
              style: TextStyle(
                fontFamily: 'BeauSans',
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            Gap(4.h),
            Text(
              'Upload your ID and insurance documents.',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
            ),
            Gap(20.h),
            _sectionLabel('ID Type'),
            Gap(6.h),
            CustomDropdown(
              items: RidesService.idTypes,
              value: selectedIdType,
              onChanged: (value) => setState(() => selectedIdType = value),
              hintText: Label.selectIdType,
              labelText: Label.idType,
              prefixIcon: const Icon(Icons.credit_card_outlined),
            ),
            Gap(12.h),
            _sectionLabel('ID Number'),
            Gap(6.h),
            CustomTextField(
              hintText: 'Enter your ID number',
              keyboardType: TextInputType.text,
              controller: _idNumber,
              validator: (value) {
                if (value == null || value.isEmpty) return 'ID number is required';
                return null;
              },
            ),
            Gap(16.h),
            _sectionLabel('ID Front Image'),
            Gap(6.h),
            CaptureDocumentImageOrFileCard(
              title: 'Front of ID card',
              imageFile: idFrontImage,
              onCameraTap: () async {
                Navigator.pop(context);
                File? image = await authVm.captureImage(context, source: ImageSource.camera);
                if (image != null) {
                  setState(() {
                    idFrontImage = image;
                    frontMultipartImage = authVm.convertImageToMultipartFile(image);
                  });
                }
              },
              onGalleryTap: () async {
                Navigator.pop(context);
                File? image = await authVm.captureImage(context, source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    idFrontImage = image;
                    frontMultipartImage = authVm.convertImageToMultipartFile(image);
                  });
                }
              },
              onFileTap: () async {
                File? file = await authVm.captureFile();
                if (file != null) {
                  setState(() {
                    idFrontImage = file;
                    frontMultipartImage = null;
                  });
                  authVm.convertFileToMultipartFile(file).then((v) {
                    setState(() => frontMultipartImage = v);
                  });
                }
              },
            ),
            Gap(12.h),
            _sectionLabel('ID Back Image'),
            Gap(6.h),
            CaptureDocumentImageOrFileCard(
              title: 'Back of ID card',
              imageFile: idBackImage,
              onCameraTap: () async {
                Navigator.pop(context);
                File? image = await authVm.captureImage(context, source: ImageSource.camera);
                if (image != null) {
                  setState(() {
                    idBackImage = image;
                    backMultipartImage = authVm.convertImageToMultipartFile(image);
                  });
                }
              },
              onGalleryTap: () async {
                Navigator.pop(context);
                File? image = await authVm.captureImage(context, source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    idBackImage = image;
                    backMultipartImage = authVm.convertImageToMultipartFile(image);
                  });
                }
              },
              onFileTap: () async {
                File? file = await authVm.captureFile();
                if (file != null) {
                  setState(() => idBackImage = file);
                  authVm.convertFileToMultipartFile(file).then((v) {
                    setState(() => backMultipartImage = v);
                  });
                }
              },
            ),
            Gap(12.h),
            _sectionLabel('Insurance Certificate'),
            Gap(6.h),
            CaptureDocumentImageOrFileCard(
              title: 'Insurance certificate',
              imageFile: licenseCert,
              onCameraTap: () async {
                Navigator.pop(context);
                File? image = await authVm.captureImage(context, source: ImageSource.camera);
                if (image != null) {
                  setState(() {
                    licenseCert = image;
                    licenseCertMultipartImage = authVm.convertImageToMultipartFile(image);
                  });
                }
              },
              onGalleryTap: () async {
                Navigator.pop(context);
                File? image = await authVm.captureImage(context, source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    licenseCert = image;
                    licenseCertMultipartImage = authVm.convertImageToMultipartFile(image);
                  });
                }
              },
              onFileTap: () async {
                File? file = await authVm.captureFile();
                if (file != null) {
                  setState(() => licenseCert = file);
                  authVm.convertFileToMultipartFile(file).then((v) {
                    setState(() => licenseCertMultipartImage = v);
                  });
                }
              },
            ),
            Gap(24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildVehiclePage() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Form(
        key: _vehicleGlobalKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Register your vehicle',
              style: TextStyle(
                fontFamily: 'BeauSans',
                fontSize: 22.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            Gap(4.h),
            Text(
              'Upload your vehicle details and license.',
              style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
            ),
            Gap(20.h),
            _sectionLabel('Vehicle Photo'),
            Gap(6.h),
            CaptureDocumentImageOrFileCard(
              title: 'Vehicle photo',
              imageFile: vehicleImage,
              onCameraTap: () async {
                Navigator.pop(context);
                File? image = await authVm.captureImage(context, source: ImageSource.camera);
                if (image != null) {
                  setState(() {
                    vehicleImage = image;
                    vehicleMultipartImage = authVm.convertImageToMultipartFile(image);
                  });
                }
              },
              onGalleryTap: () async {
                Navigator.pop(context);
                File? image = await authVm.captureImage(context, source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    vehicleImage = image;
                    vehicleMultipartImage = authVm.convertImageToMultipartFile(image);
                  });
                }
              },
              onFileTap: () async {
                File? file = await authVm.captureFile();
                if (file != null) {
                  setState(() => vehicleImage = file);
                  authVm.convertFileToMultipartFile(file).then((v) {
                    setState(() => vehicleMultipartImage = v);
                  });
                }
              },
            ),
            Gap(12.h),
            _sectionLabel('Vehicle Type'),
            Gap(6.h),
            CustomDropdown(
              items: RidesService.vehicleTypes,
              value: selectedVehicle,
              onChanged: (value) => setState(() => selectedVehicle = value),
              hintText: Label.selectVehicleType,
              labelText: Label.vehicleType,
              prefixIcon: const Icon(Icons.directions_car_outlined),
            ),
            Gap(12.h),
            _sectionLabel('Vehicle Color'),
            Gap(6.h),
            CustomDropdown(
              items: RidesService.carColors,
              value: selectedColor,
              onChanged: (value) => setState(() => selectedColor = value),
              hintText: Label.chooseColor,
              labelText: Label.carColor,
              prefixIcon: const Icon(Icons.palette_outlined),
              borderRadius: 12,
              fontSize: 16,
            ),
            Gap(12.h),
            _sectionLabel('License Plate Number'),
            Gap(6.h),
            CustomTextField(
              hintText: 'e.g. GR-1234-20',
              keyboardType: TextInputType.text,
              controller: _vehiclePlateNumber,
              validator: (value) {
                if (value == null || value.isEmpty) return 'Plate number is required';
                return null;
              },
            ),
            Gap(12.h),
            _sectionLabel('Driver\'s License'),
            Gap(6.h),
            CaptureDocumentImageOrFileCard(
              title: "Driver's license",
              imageFile: licenseImage,
              onCameraTap: () async {
                Navigator.pop(context);
                File? image = await authVm.captureImage(context, source: ImageSource.camera);
                if (image != null) {
                  setState(() {
                    licenseImage = image;
                    licenseMultipartImage = authVm.convertImageToMultipartFile(image);
                  });
                }
              },
              onGalleryTap: () async {
                Navigator.pop(context);
                File? image = await authVm.captureImage(context, source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    licenseImage = image;
                    licenseMultipartImage = authVm.convertImageToMultipartFile(image);
                  });
                }
              },
              onFileTap: () async {
                File? file = await authVm.captureFile();
                if (file != null) {
                  setState(() => licenseImage = file);
                  authVm.convertFileToMultipartFile(file).then((v) {
                    setState(() => licenseMultipartImage = v);
                  });
                }
              },
            ),
            Gap(24.h),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }
}
