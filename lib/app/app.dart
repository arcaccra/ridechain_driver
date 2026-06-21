import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:provider/provider.dart';
import 'package:ridechain_driiver/app/theme.dart';

import '../core/providers.dart';
import '../data/locator.dart';
import '../services/connectivity_service.dart';
import '../services/dialog_service.dart';
import '../ui/screens/splash/splash_screen.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    locator<ConnectionService>().checkConnection();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    locator<ConnectionService>().closeConnection();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(393, 852),
        minTextAdapt: true,
        builder: (context, child) {
          return MultiProvider(
            providers: providers,
            child: GetMaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Ryde Driver',
              theme: AppThemes.appThemeData[AppTheme.darkTheme],
              scaffoldMessengerKey: rootScaffoldMessengerKey,
              home: const SplashScreen(),
            ),
          );
        }
    );
  }
}