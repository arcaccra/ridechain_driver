import 'dart:ui';
import 'dart:ui' as ui;

import 'package:dio/dio.dart' as dio;
import 'package:flutter/cupertino.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';

import '../core/cache_helper.dart';
import '../data/constants/api_constants.dart';
import '../data/models/user_model.dart';
import '../ui/screens/auth/image_capture_screen.dart';
import '../ui/screens/auth/login_screen.dart';
import '../ui/screens/auth/password_screen.dart';
import '../ui/screens/auth/register_screen.dart';
import 'http_service.dart';

class LoginService extends HttpService {
  /// Builds a [dio.FormData] from [data], cloning any [dio.MultipartFile] so the
  /// original instances are never finalized by a request. Without this, a
  /// retry (or any second submit) reuses an already-finalized MultipartFile and
  /// throws "The MultipartFile has already been finalized".
  dio.FormData _formData(Map<String, dynamic> data) {
    final safe = data.map(
      (key, value) =>
          MapEntry(key, value is dio.MultipartFile ? value.clone() : value),
    );
    return dio.FormData.fromMap(safe);
  }

  //login
  login(Map<String, dynamic> data) async {
    var body = _formData(data);
    var response = await loginPost(Api.login, body: body);
    return response;
  }

  //register
  register(Map<String, dynamic> data) async {
    var body = _formData(data);
    var response = await loginPost(Api.register, body: body);
    return response;
  }

  fetchUserById(int id) async {
    var response = await get("${Api.user}$id");
    return response;
  }

  //get wallet address
  Future getWalletById(int id) async {
    var response = await get("${Api.wallets}$id/");
    return response;
  }

  //get wallet address
  Future getWalletAddress() async {
    var response = await get(Api.wallets);
    return response;
  }

  //update wallet address
  Future updateWalletAddress(Map<String, dynamic> data) async {
    var body = _formData(data);
    var response = await post(Api.wallets, body: body);
    return response;
  }

  //upload the form
  Future uploadDriverDocs(Map<String, dynamic> data) async {
    var body = _formData(data);
    var response = await post(Api.drivers, body: body);
    return response;
  }

  //upload the form
  updateDriverDocs(Map<String, dynamic> data, int id) async {
    var body = _formData(data);
    var response = await put("${Api.drivers}$id/update/", body: body);
    return response;
  }

  //get the drivers
  getDrivers() async {
    var response = await get(Api.drivers);
    return response;
  }

  //logout
  logout() async {
    var response = await loginPost(Api.logout);
    return response;
  }

  //is user logged in
  Future<bool> isUserSignedIn() async {
    var data = await CacheHelper.instance.readModel(CacheHelper.authKey);
    if (data == null) return false;
    AuthModel? model = AuthModel.fromJson(data);
    if (model.token != null) return true;
    return false;
  }

  //check the page for the
  Future<Object? Function()> checkRegistrationPage() async {
    Map? data = await CacheHelper.instance.readModel(
      CacheHelper.registerProcessKey,
    );

    if (data != null) {
      if (data.containsKey("full_name")) {
        return () => Get.offAll(() => const RegisterScreen());
      }
      if (data.containsKey("avatar")) {
        return () => Get.to(() => const ImageCaptureScreen());
      }
      if (data.containsKey("password1")) {
        return () => Get.to(() => const PasswordScreen());
      }
    }
    return () => Get.to(() => const LoginScreen());
  }

  //get all locations
  loadAllLocations() async {
    var response = await get("${Api.rides}locations/");
    return response;
  }

  Future<BitmapDescriptor> svgToBitmap({
    required BuildContext context,
    required String svgAssetPath,
    Size size = const Size(16, 32),
  }) async {
    final pictureInfo = await vg.loadPicture(
      SvgAssetLoader(svgAssetPath),
      null,
    );
    final devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
    final width = (size.width * devicePixelRatio).toInt();
    final height = (size.height * devicePixelRatio).toInt();

    final scaleFactor = (width / pictureInfo.size.width).clamp(0.1, 10.0);
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)
      ..scale(scaleFactor)
      ..drawPicture(pictureInfo.picture);

    final image = await recorder.endRecording().toImage(width, height);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  //driver documents
  List<Map<String, dynamic>> driverDocumentsMap = [
    {
      "name": "National ID",
      "desc": "Valid government-issued national id",
      "key": "national_id",
    },
    {
      "name": "Driver's License",
      "desc": "Valid government-issued driver's license",
      "key": "driver_license",
    },
    {
      "name": "Vehicle Registration",
      "desc": "Current vehicle registration certificate",
      "key": "vehicle_registration_cert",
    },
    {
      "name": "Insurance Certificate",
      "desc": "Valid vehicle insurance documentation",
      "key": "insurance_cert",
    },
  ];
}
