import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../../core/core_constants/colors.dart';
import '../../../providers/auth_provider.dart';
import '../../shared_widgets/loader.dart';

class ImageCaptureScreen extends StatelessWidget {
  const ImageCaptureScreen({super.key});

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
                  // Top row: back + step counter
                  Row(
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
                        '2/4',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Gap(16.h),
                  // Step label row
                  Row(
                    children: [
                      Text(
                        'STEP 2 OF 4',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.purple,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'Photo',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  Gap(8.h),
                  // 4-segment progress bar (2 filled)
                  Row(
                    children: List.generate(
                      4,
                      (i) => Expanded(
                        child: Container(
                          height: 4.h,
                          margin: EdgeInsets.only(right: i < 3 ? 6.w : 0),
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
                  Gap(24.h),
                  Text(
                    'Add a profile photo',
                    style: TextStyle(
                      fontFamily: 'BeauSans',
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                  Gap(6.h),
                  Text(
                    'Step 2 of 4 · Passengers will see this before the trip.',
                    style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
                  ),
                  Gap(32.h),
                  // Avatar area
                  Center(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 120.w,
                          height: 120.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.purple.withValues(alpha: 0.08),
                            border: Border.all(
                              color: AppColors.purple.withValues(alpha: 0.3),
                              width: 2,
                            ),
                          ),
                          child: authVm.imageFile != null
                              ? ClipOval(
                                  child: Image.file(authVm.imageFile!, fit: BoxFit.cover),
                                )
                              : Icon(
                                  Icons.person_outline,
                                  size: 56.w,
                                  color: AppColors.purple.withValues(alpha: 0.4),
                                ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 36.w,
                            height: 36.w,
                            decoration: BoxDecoration(
                              color: AppColors.purple,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: Icon(Icons.camera_alt, color: Colors.white, size: 18.w),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Gap(36.h),
                  // Take a photo button
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        authVm.captureProfilePicture(context, source: ImageSource.camera);
                      },
                      icon: Icon(Icons.camera_alt_outlined, color: Colors.white, size: 20.w),
                      label: Text(
                        'Take a photo',
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
                  Gap(12.h),
                  // Choose from gallery
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        authVm.captureProfilePicture(context, source: ImageSource.gallery);
                      },
                      icon: Icon(Icons.upload_outlined, color: Colors.black87, size: 18.w),
                      label: Text(
                        'Choose from gallery',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        backgroundColor: Colors.grey[100],
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
                  onPressed: authVm.imageFile != null && !authVm.isLoading
                      ? () async {
                          authVm.addToRegisterMap("avatar", authVm.selectedFile);
                          await authVm.register();
                        }
                      : null,
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
                    backgroundColor: authVm.imageFile != null
                        ? AppColors.purple
                        : AppColors.purple.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26.r),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ),
            if (authVm.isLoading) const Loader(),
          ],
        ),
      ),
    );
  }
}
