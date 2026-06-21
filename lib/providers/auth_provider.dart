

import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart' as dio;
import 'package:image/image.dart' as img;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ridechain_driiver/data/models/wallet.dart';
import 'package:ridechain_driiver/ui/screens/auth/document_upload.dart';
import 'package:ridechain_driiver/ui/screens/auth/id_card_documents.dart';
import 'package:ridechain_driiver/ui/screens/auth/vehicle_registration_documents.dart';
import 'package:ridechain_driiver/ui/screens/auth/wallet_info.dart';

import '../core/cache_helper.dart';
import '../data/models/api_response.dart';
import '../data/models/driver_model.dart';
import '../data/models/location_model.dart';
import '../data/models/user_model.dart';
import '../ui/screens/auth/otp_screen.dart';
import '../ui/screens/auth/password_screen.dart';
import '../services/fcm_service.dart';
import '../ui/screens/navigation/app_navigation_screen.dart';
import 'base_provider.dart';

class AuthVm extends BaseProvider {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  AuthModel? _currentUser;
  UserModel? _model;
  Wallet? userWallet;
  List<DriverModel> allDrivers = [];
  String _verificationId = '';
  bool _authIsLoading = false;
  bool isRegistration = true;
  String? _errorMessage;
  String? walletAddress;
  List<LocationModel> allLocations = [];
  Map<String, dynamic> driverDocs = {
    "driver_license" : null,
    "vehicle_registration_cert" : null,
    "insurance_cert" : null,
    "national_id" : null,
  };

  File? imageFile;

  dio.MultipartFile? selectedFile;

  Map<String, dynamic> body = {};

  AuthModel? get currentAuth => _currentUser;
  UserModel? get currentUser => _model;
  bool get isLoading => _authIsLoading;
  String? get errorMessage => _errorMessage;

  /// True when the driver has submitted all required KYC documents.
  bool get hasCompleteDocuments => hasDriverSubmittedDocs();

  /// True when a Cardano payout wallet address is on file.
  bool get hasWallet =>
      walletAddress != null && walletAddress!.trim().isNotEmpty;

  /// True when the driver still needs to finish onboarding (documents and/or
  /// wallet). Used to gate ride creation and to show the home banner.
  bool get needsProfileCompletion => !hasCompleteDocuments || !hasWallet;


  //
  setRegistrationMode(bool mode) {
    isRegistration = mode;
    if (hasListeners) notifyListeners();
  }

  //login into the application
  login() async {
    updateUi(()=> _authIsLoading = true);
    _clearError();
    try{
      var response = await auth.login(body);
      var apiResponse = ApiResponse.parse(response);
      debugPrint("${apiResponse.mappedObjects}");
      if(apiResponse.code == 200 || apiResponse.code == 201) {
        _currentUser = AuthModel.fromJson(apiResponse.mappedObjects!);
        if(_currentUser != null) {
          await CacheHelper.instance.cacheModel(CacheHelper.authKey, _currentUser);
          await fetchUserById(_currentUser!.user!.id!);
          await getWalletAddress();
          //Fetch the location for the application
          await getLocations();
          _clearError();
          clearBodyAndImages();
          if (_model?.id != null) {
            await FCMService.instance.saveAnActivateTokenRefresh(_model!.id!.toString());
          }
          // If the driver is fully verified but has no payout wallet yet, give
          // them a chance to add one (skippable) before entering the app.
          // Otherwise go straight in — the home banner covers anything missing.
          if (hasCompleteDocuments && !hasWallet) {
            Get.offAll(() => const WalletInfo(fromOnboarding: true),
                transition: Transition.leftToRight);
          } else {
            Get.offAll(() => const AppNavigationScreen(),
                transition: Transition.leftToRight);
          }
        }
      } else {
        dialog.showSnackBar("Login failed",
            "Invalid phone number or password. Please try again.", isError: true);
      }
    } catch (e) {
      dialog.showSnackBar("Something went wrong", e.toString(), isError: true);
    } finally {
      updateUi(()=> _authIsLoading = false);
    }
  }

  //register into the application
  register() async {
    updateUi(()=> _authIsLoading = true);
    _clearError();
    try{
      var response = await auth.register(body);
      var apiResponse = ApiResponse.parse(response);
      debugPrint("${apiResponse.mappedObjects}");
      if(apiResponse.code == 200 || apiResponse.code == 201) {
        _currentUser = AuthModel.fromJson(apiResponse.mappedObjects!);
        _model = _currentUser?.user;
        if(_currentUser != null) {
          await CacheHelper.instance.cacheModel(CacheHelper.authKey, _currentUser);
          await CacheHelper.instance.cacheModel(CacheHelper.userKey, _model);
          _clearError();
          clearBodyAndImages();
          setRegistrationMode(true);
          dialog.showSnackBar(
              "Account created", "Next, let's verify your documents.");
          // Registration always proceeds to the document submission flow
          // (which is skippable), then the wallet step.
          Get.offAll(() => const DocumentUpload(isRegistration: true),
              transition: Transition.leftToRight);
        }
      } else {
        dialog.showSnackBar(
            "Registration failed", "We couldn't create your account. Please try again.",
            isError: true);
      }
    } catch (e, st) {
      log('[AuthVm.register] error: $e', stackTrace: st);
      dialog.showSnackBar("Registration failed", e.toString(), isError: true);
      imageFile = null;
      selectedFile = null;
    } finally {
      updateUi(()=> _authIsLoading = false);
    }
  }

  //clear the register map
  addToRegisterMap(String key, dynamic value) {
    body[key] = value;
    if (hasListeners) notifyListeners();
  }

  //update driver documents
  Future<bool> fetchUserById(int id) async {
    updateUi(()=> _authIsLoading = true);
    try{
      var response = await auth.fetchUserById(id);
      var apiResponse = ApiResponse.parse(response);
      if(apiResponse.code == 200 || apiResponse.code == 201) {
        _model = UserModel.fromJson(apiResponse.mappedObjects!);
        if(_model != null) {
          await CacheHelper.instance.cacheModel(CacheHelper.userKey, _model);
        }
        return true;
      }
    } catch (e) {
      dialog.showSnackBar("An unexpected error occurred", e.toString());
    } finally {
      updateUi(()=> _authIsLoading = false);
    }
    return false;
  }

  Future<bool> updateWalletAddress(Map<String, dynamic> body) async {
    updateUi(()=> _authIsLoading = true);
    try{
      var response = await auth.updateWalletAddress(body);
      var apiResponse = ApiResponse.parse(response);
      if(apiResponse.code == 200 || apiResponse.code == 201) {
        userWallet = Wallet.fromJson(apiResponse.mappedObjects!);
        String address = apiResponse.mappedObjects?['address'];
        if(_model != null) {
          await CacheHelper.instance.cacheString(CacheHelper.walletKey, address);
          await CacheHelper.instance.cacheModel(CacheHelper.walletInfoKey, userWallet);
          walletAddress = address;
        }
        return true;
      }
    } catch (e) {
      dialog.showSnackBar("An unexpected error occurred", e.toString());
    } finally {
      updateUi(()=> _authIsLoading = false);
    }
    return false;
  }

  bool loadingWallet = false;
  //get the wallet by id
  Future<Wallet?> getWalletById(int id) async {
    updateUi(() => loadingWallet = true);
    try{
      var response = await auth.getWalletById(id);
      var apiResponse = ApiResponse.parse(response);
      if(apiResponse.code == 200 || apiResponse.code == 201) {
        userWallet = Wallet.fromJson(apiResponse.mappedObjects!);
        String address = apiResponse.mappedObjects?['address'];
        if(_model != null) {
          await CacheHelper.instance.cacheString(CacheHelper.walletKey, address);
          walletAddress = address;
        }
        return userWallet;
      }
    } catch (e) {
      dialog.showSnackBar("An unexpected error occurred", e.toString());
    } finally {
      updateUi(()=> loadingWallet = false);
    }
    return userWallet;
  }

  Future<bool> getWalletAddress() async {
    updateUi(()=> _authIsLoading = true);
    try{
      var response = await auth.getWalletAddress();
      var apiResponse = ApiResponse.parse(response);
      if(apiResponse.code == 200 || apiResponse.code == 201) {
        userWallet = Wallet.fromJson(apiResponse.mappedObjects!);
        String address = apiResponse.mappedObjects?['address'];
        if(_model != null) {
          await CacheHelper.instance.cacheString(CacheHelper.walletKey, address);
          await CacheHelper.instance.cacheModel(CacheHelper.walletInfoKey, userWallet);
          walletAddress = address;
        }
        return true;
      }
    } catch (e) {
      // A missing wallet is normal for newly registered drivers — don't alarm
      // the user. Just leave walletAddress null; the onboarding/banner handles it.
      log('[AuthVm] getWalletAddress: no wallet on file yet ($e)');
    } finally {
      updateUi(()=> _authIsLoading = false);
    }
    return false;
  }

  //fetch the user info
  fetchUserInfo() async {
    var response = await CacheHelper.instance.readModel(CacheHelper.authKey);
    var userResponse = await CacheHelper.instance.readModel(CacheHelper.userKey);
    if(response != null) {
      _currentUser = AuthModel.fromJson(response);
    }
    //this is user response
    if(userResponse != null) {
      _model = UserModel.fromJson(userResponse);
    }
    List? locations = await CacheHelper.instance.readModel(CacheHelper.locationsKey);
    if(locations != null) {
      allLocations = locations.map((e)=> LocationModel.fromJson(e)).toList();
    }

    String? address = CacheHelper.instance.readString(CacheHelper.walletKey);
    if(address != null) {
      walletAddress = address;
    }

    var wallet = await CacheHelper.instance.readModel(CacheHelper.walletInfoKey);
    if(wallet != null) {
      userWallet = Wallet.fromJson(wallet);
    }

    if (hasListeners) notifyListeners();
  }

  //update driver documents
  Future<bool> uploadDriverDocs(Map<String, dynamic> body, {bool driverExists = false}) async {
    updateUi(()=> _authIsLoading = true);
    _clearError();
    try{
      debugPrint("Does the driver exists $driverExists");
      var response = driverExists ? await auth.updateDriverDocs(body, _model!.driver!.id!)  : await auth.uploadDriverDocs(body);
      var apiResponse = ApiResponse.parse(response);
      debugPrint("Driver submission documents ${apiResponse.mappedObjects}");
      if(apiResponse.code == 200 || apiResponse.code == 201) {
        bool success = await fetchUserById(_model!.id!);
        if(success) {
          dialog.showSnackBar("Success", "user documents has been successfully submitted");
          await tripService.createNewUser(user: _model!);
          return true;
        }
      }
    } catch (e, stacktrace) {
      dialog.showSnackBar("An unexpected error occurred", e.toString());
      debugPrint("This is the error =====>>$e");
      debugPrint("This is the stacktrace =====>>$stacktrace");
    } finally {
      updateUi(()=> _authIsLoading = false);
    }
    return false;
  }

  //check if driver has incomplete documentation
  checkIfDriverHasCompleteDocumentation(bool registerFlow) {
    if(_model?.driver?.idFrontImage == null
        || _model?.driver?.idNumber == null
        || _model?.driver?.idBackImage == null
        || _model?.driver?.idType == null
        || _model?.driver?.insuranceCert == null
        || _model?.driver?.licenceImage == null
        || _model?.driver?.vehicleImage == null
        || _model?.driver?.vehiclePlateNumber == null
        || _model?.driver?.vehicleType == null
        || _model?.driver?.vehicleColor == null
    ) {
      if(registerFlow) {
        Get.offAll(() => DocumentUpload(isRegistration: registerFlow), transition: Transition.leftToRight);
      } else {
        Get.to(() => DocumentUpload(isRegistration: false), transition: Transition.leftToRight);
      }
    }
  }

  bool checkIfDriverExists() {
    if(_model?.driver?.idFrontImage != null
        || _model?.driver?.idNumber != null
        || _model?.driver?.idBackImage != null
        || _model?.driver?.idType != null
        || _model?.driver?.insuranceCert != null
        || _model?.driver?.vehicleImage != null
        || _model?.driver?.vehiclePlateNumber != null
        || _model?.driver?.vehicleType != null
        || _model?.driver?.vehicleColor != null
    ) {
      return true;
    }
    return false;
  }

  bool hasDriverSubmittedDocs() {
    if(_model?.driver?.idFrontImage == null
        || _model?.driver?.idNumber == null
        || _model?.driver?.idBackImage == null
        || _model?.driver?.idType == null
        || _model?.driver?.insuranceCert == null
        || _model?.driver?.licenceImage == null
    || _model?.driver?.vehicleImage == null
        || _model?.driver?.vehiclePlateNumber == null
        || _model?.driver?.vehicleType == null
        || _model?.driver?.vehicleColor == null
    ) {
      return false;
    }
    return true;
  }




  //update driver docs
  Future<bool> updateDriverDocs(Map<String, dynamic> body, int id) async {
    updateUi(()=> _authIsLoading = true);
    _clearError();
    try{
      var response = await auth.updateDriverDocs(body, id);
      var apiResponse = ApiResponse.parse(response);
      if(apiResponse.code == 200 || apiResponse.code == 201) {
        await fetchUserById(_model!.id!);
        return true;
      }
    } catch (e, stacktrace) {
      dialog.showSnackBar("An unexpected error occurred", e.toString());
    } finally {
      updateUi(()=> _authIsLoading = false);
    }
    return false;
  }

  createMap(Map _body){
    if(body.isEmpty) {
      body = Map.from(_body);
    }
    if (hasListeners) notifyListeners();
  }

  // Send OTP to phone number
  Future<void> sendOTP(String phoneNumber) async {
    try {
      updateUi(()=> _authIsLoading = true);
      _clearError();

      // Format phone number (ensure it has country code)
      String formattedPhone = _formatPhoneNumber(phoneNumber);

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        timeout: const Duration(seconds: 60),

        // Verification completed (Android only - auto-verification)
        verificationCompleted: (PhoneAuthCredential credential) async {
          Get.to(() => const OtpScreen(), transition: Transition.leftToRight);
        },

        // Verification failed
        verificationFailed: (FirebaseAuthException e) {
          _setError(_getErrorMessage(e));
          dialog.showSnackBar("An unexpected error occurred", e.toString());
          updateUi(()=> _authIsLoading = false);
        },

        // Code sent successfully
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          updateUi(()=> _authIsLoading = false);
          Get.to(() => const OtpScreen(), transition: Transition.leftToRight);
          debugPrint('OTP sent successfully to $formattedPhone');
        },

        // Code auto-retrieval timeout
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          updateUi(()=> _authIsLoading = false);
        },
      );
    } catch (e) {
      _setError('Failed to send OTP: ${e.toString()}');
      dialog.showSnackBar("Failed to send OTP:", e.toString());
      updateUi(()=> _authIsLoading = false);
    }
  }

  // Verify OTP code
  Future<bool> verifyOTP(String otp) async {
    try {
      updateUi(()=> _authIsLoading = true);
      _clearError();

      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: otp,
      );

      await _auth.signInWithCredential(credential);
      if (hasListeners) notifyListeners();
      return true;

    } on FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e));
      dialog.showSnackBar("OTP Error", _getErrorMessage(e));
      return false;
    } catch (e) {
      dialog.showSnackBar("Invalid OTP", e.toString());
      return false;
    } finally {
      updateUi(()=> _authIsLoading = false);
    }
  }

  // Resend OTP
  Future<void> resendOTP(String phoneNumber) async {
    await sendOTP(phoneNumber);
  }

  void _setError(String error) {
    _errorMessage = error;
    if (hasListeners) notifyListeners();
  }

  // Format phone number with country code
  String _formatPhoneNumber(String phoneNumber) {
    // If already in E.164 format, return as-is
    if (phoneNumber.startsWith('+')) return phoneNumber;

    // Remove any non-digit characters
    String cleaned = phoneNumber.replaceAll(RegExp(r'\D'), '');
    return '+$cleaned';
  }

  // Get user-friendly error messages
  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return 'The phone number is not valid.';
      case 'too-many-requests':
        return 'Too many requests. Please try again later.';
      case 'operation-not-allowed':
        return 'Phone authentication is not enabled.';
      case 'invalid-verification-code':
        return 'The verification code is invalid.';
      case 'invalid-verification-id':
        return 'The verification ID is invalid.';
      case 'credential-already-in-use':
        return 'This phone number is already associated with another account.';
      case 'session-expired':
        return 'The verification session has expired. Please try again.';
      default:
        return 'An error occurred: ${e.message}';
    }
  }

  //image capture
  //capture function captures the image of the user and saves the multipart file
  captureProfilePicture(context, {ImageSource? source}) async {
    updateUi(()=> _authIsLoading = true);
    var pickedImage = await image.captureImage(source);
    if (pickedImage != null) {
      imageFile = File(pickedImage!.path);
      var decodedImage = img.decodeImage(imageFile!.readAsBytesSync());
      if (decodedImage == null) {
        dialog.showSnackBar("Error", "Could not process image. Please try again.");
        updateUi(()=> _authIsLoading = false);
        return;
      }
      var encodedImage = img.encodeJpg(decodedImage);
      selectedFile = dio.MultipartFile.fromBytes(encodedImage, filename: "image_$imageFile.jpg");
    } else {
      dialog.showSnackBar("Error", "Error picking image... Please try again.");
      updateUi(()=> _authIsLoading = false);
    }
    updateUi(()=> _authIsLoading = false);
  }

  Future<File?> captureImage(context, {ImageSource? source}) async {
    updateUi(()=> _authIsLoading = true);
    File? capturedImage;
    var pickedImage = await image.captureImage(source);
    if (pickedImage != null) {
      capturedImage = File(pickedImage!.path);
    } else {
      dialog.showSnackBar("Error", "Error picking image... Please try again.");
      updateUi(()=> _authIsLoading = false);
    }
    updateUi(()=> _authIsLoading = false);
    return capturedImage;
  }

  //this will help capture the file
  Future<File?> captureFile() async {
    File? capturedFile;
    updateUi(()=> _authIsLoading = true);
    var platformFile = await image.pickDocument();
    if(platformFile != null) {
      capturedFile = File(platformFile.path!);
    } else {
      dialog.showSnackBar("Error", "Error picking file... Please try again.");
      updateUi(()=> _authIsLoading = false);
    }
    updateUi(()=> _authIsLoading = false);
    return capturedFile;
  }

  dio.MultipartFile? convertImageToMultipartFile(File file) {
    dio.MultipartFile? multipartFile;
    try{
      var decodedImage = img.decodeImage(file.readAsBytesSync());
      if (decodedImage == null) return null;
      var encodedImage = img.encodeJpg(decodedImage);
      multipartFile = dio.MultipartFile.fromBytes(encodedImage, filename: "image_$file.jpg");
    } catch (e) {
      debugPrint('Error converting to Dio MultipartFile: $e');
    }
    return multipartFile;
  }

  Future<dio.MultipartFile?> convertFileToMultipartFile(File? file) async {
    dio.MultipartFile? multipartFile;
    try {
        if (file?.path != null) {
          return await dio.MultipartFile.fromFile(
            file!.path,
            filename: "file_$file",
          );
        }
      return multipartFile;
    } catch (e) {
      debugPrint('Error converting to Dio MultipartFile: $e');
      return null;
    }
  }


  bool isFirstTimeDriverLoad = true;
  //get all the drivers
  ///TODO: This call should fetch the drivers based on a radius around their location
  Future<List<DriverModel>> getAllDrivers() async {
    if(isFirstTimeDriverLoad) _authIsLoading = true;
    try {
      var response = await auth.getDrivers();
      isFirstTimeDriverLoad = false;
      var apiResponse = ApiResponse.parse(response);
      if(apiResponse.code == 200 || apiResponse.code == 201) {
        List driversList = apiResponse.listWithoutDataKey;
        allDrivers = driversList.map((e)=> DriverModel.fromJson(e)).toList();
        return allDrivers;
      } else {
        return [];
      }
    } on Exception catch(e) {
      dialog.showSnackBar("An unexpected error occurred", e.toString());
    } finally {
      updateUi(()=> _authIsLoading = false);
    }
    return [];
  }

  Future<bool> logout() async {
    setUiState(UiState.loading);
    try{
      await auth.logout();
      //log(response);
      //var apiResponse = ApiResponse.parse(response);
      //if(apiResponse.code == 200 || apiResponse.code == 201) {
      await CacheHelper.instance.clearCache();
      return true;
      //}
    } on Exception catch(e) {
      dialog.showSnackBar("An unexpected error occurred", e.toString());
    } finally {
      setUiState(UiState.done);
    }
    return false;
  }

  //get all locations
  getLocations() async {
    _authIsLoading = true;
    try{
      var response = await auth.loadAllLocations();
      var apiResponse = ApiResponse.parse(response);
      if(apiResponse.code == 200 || apiResponse.code == 201) {
        List locations = apiResponse.listWithoutDataKey;
        allLocations = locations.map((e)=> LocationModel.fromJson(e)).toList();
        await CacheHelper.instance.cacheModel(CacheHelper.locationsKey, locations);
      } else {
        allLocations = [];
      }

    } on Exception catch(e) {
      dialog.showSnackBar("An unexpected error occurred", e.toString());
    } finally {
      updateUi(()=> _authIsLoading = false);
    }
  }

  //create the ride



  //clear body and images {}

  clearBodyAndImages() {
    body.clear();
    imageFile = null;
    selectedFile = null;
    if (hasListeners) notifyListeners();
  }

  //clear the error
  void _clearError() {
    _errorMessage = null;
    if (hasListeners) notifyListeners();
  }


}