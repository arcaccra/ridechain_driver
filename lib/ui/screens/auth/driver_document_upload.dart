import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:provider/provider.dart';
import 'package:ridechain_driiver/data/locator.dart';
import 'package:ridechain_driiver/providers/auth_provider.dart';
import 'package:ridechain_driiver/services/login_service.dart';
import 'package:ridechain_driiver/ui/screens/auth/auth_widgets/document_info_tile.dart';
import 'package:ridechain_driiver/ui/screens/auth/section/document_capture_widget.dart';
import 'package:ridechain_driiver/ui/shared_widgets/default_back_button.dart';

import '../../../core/core_constants/colors.dart';
import 'auth_widgets/top_driver_document_container.dart';

class DriverDocumentUpload extends StatelessWidget {
  const DriverDocumentUpload({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = Provider.of<AuthVm>(context);
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: kToolbarHeight),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              DefaultBackButton(),
              Gap(18.h),
              TopDriverDocumentContainer(progress: 0),
              Expanded(child: ListView.builder(
                  itemCount: locator<LoginService>().driverDocumentsMap.length,
                  itemBuilder: (context, index) {
                    final driverDoc = locator<LoginService>().driverDocumentsMap[index];
                    return GestureDetector(
                      onTap: (){
                          Get.to(()=> DocumentCaptureSection(showSecondImage: index == 0 || index == 1 ? true : false));
                      },
                      child: DocumentInfoTile(name: driverDoc['name'], desc: driverDoc['desc'], isUploaded: authVm.driverDocs['key'] != null));
                  }
              )),
            ],
          ),
        ),
      ),
    );
  }
}
