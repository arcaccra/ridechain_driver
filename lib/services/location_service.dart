import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
//import 'package:maps_launcher/maps_launcher.dart';
import '../core/core_constants/label.dart';
import '../data/locator.dart';
import 'dialog_service.dart';


class LocationService {
  //check for location permission
  // ✅ Add a flag to track ongoing permission requests
  bool _isRequestingPermission = false;
  LocationPermission? _cachedPermission;
  DateTime? _lastPermissionCheck;

  // Cache duration (5 minutes)
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Thread-safe permission check with caching
  Future<bool> checkLocationPermission(BuildContext context) async {
    // ✅ Return cached result if recent
    if (_cachedPermission != null &&
        _lastPermissionCheck != null &&
        DateTime.now().difference(_lastPermissionCheck!) < _cacheDuration) {
      return _cachedPermission == LocationPermission.always ||
          _cachedPermission == LocationPermission.whileInUse;
    }

    // ✅ Wait if another request is in progress
    if (_isRequestingPermission) {
      log('Permission request already in progress, waiting...');
      // Wait for the ongoing request to complete (max 10 seconds)
      int attempts = 0;
      while (_isRequestingPermission && attempts < 100) {
        await Future.delayed(Duration(milliseconds: 100));
        attempts++;
      }

      // Return the result from the completed request
      if (_cachedPermission != null) {
        return _cachedPermission == LocationPermission.always ||
            _cachedPermission == LocationPermission.whileInUse;
      }
    }

    // ✅ Set lock before requesting
    _isRequestingPermission = true;

    try {
      LocationPermission permission;

      // Check current permission
      permission = await Geolocator.checkPermission();

      // If denied, request permission
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          locator<DialogService>().showSnackBar(
              "Error",
              Label.noGPSPermission
          );

          // Cache the denial
          _cachedPermission = permission;
          _lastPermissionCheck = DateTime.now();
          return false;
        }
      }

      // Handle permanently denied
      if (permission == LocationPermission.deniedForever) {
        _showPermanentlyDeniedDialog(context);
        _cachedPermission = permission;
        _lastPermissionCheck = DateTime.now();
        return false;
      }

      // Cache successful permission
      _cachedPermission = permission;
      _lastPermissionCheck = DateTime.now();

      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;

    } catch (e) {
      log('Error checking location permission: $e');
      return false;
    } finally {
      // ✅ Always release the lock
      _isRequestingPermission = false;
    }
  }

  /// Show dialog for permanently denied permissions
  void _showPermanentlyDeniedDialog(BuildContext context) {
    locator<DialogService>().showAlertDialog(
      context: context,
      message: 'Location permission is permanently denied. Please enable it in Settings.',
      type: AlertDialogType.error,
      okayText: 'Open Settings',
      cancelText: 'Cancel',
      onOkayBtnTap: () {
        Geolocator.openAppSettings();
        Navigator.pop(context);
      },
      onCancelBtnTap: () {
        Navigator.pop(context);
      },
    );
  }

  void clearPermissionCache() {
    _cachedPermission = null;
    _lastPermissionCheck = null;
  }

  //calculate the distance and time
  int calculateTime(double taskLat, double taskLng, double userLocationLat, double userLocationLng) {
    double distanceInMeters = Geolocator.distanceBetween(taskLat, taskLng, userLocationLat, userLocationLng);
    double speed = 5.0; //assuming that the walkig speed is 5m/s
    double estimatedTime = distanceInMeters / speed;
    return estimatedTime.round();
  }

  double calculateDistance(double taskLat, double taskLng, double userLocationLat, double userLocationLng){
    double distanceInMeters = Geolocator.distanceBetween(taskLat, taskLng, userLocationLat, userLocationLng);
    return distanceInMeters;
  }

  //launch the url for google maps
  Future<void> launchGoogleMapsNavigation(double taskLat, double taskLng, {String? title}) async {
    final availableMaps = await MapLauncher.installedMaps;
    if(availableMaps.isNotEmpty) {
      await availableMaps.first.showDirections(destination: Coords(taskLat, taskLng), destinationTitle: title);
    }
  }

  //
  Future<void> checkGPSAccess() async {
    bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!isLocationServiceEnabled) {
      locator<DialogService>().showSnackBar(
          "Location Access Required",Label.checkGPSAccess
      );
    }
  }

  Future<Position> getUserLocation() async {
    Position currentPosition = await Geolocator.getCurrentPosition();
    return currentPosition;
  }


  //create the stream for collecting data
  StreamSubscription? _subscription;

  final StreamController<Position> _controller = StreamController<Position>.broadcast();

  Stream<Position> get stream => _controller.stream;

  final LocationSettings locationSettings = const LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 0,
  );

  startListeningToPosition() async {
    if (_subscription != null) return; // already running, prevent double-start
    await Geolocator.requestPermission().then((value) {}).onError((error, stackTrace) async {
      await Geolocator.requestPermission();
    });
    _subscription = Geolocator.getPositionStream(locationSettings: locationSettings).listen((position) {
      if (!_controller.isClosed) _controller.add(position);
    });
  }

  stopListening() {
    _subscription?.cancel();
    _subscription = null;
  }

  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    if (!_controller.isClosed) _controller.close();
  }

  //get current location
  Future<Position> getCurrentUserLocation() async {
    await Geolocator.requestPermission().then((value) {}).onError((error, stackTrace) async {
      await Geolocator.requestPermission();
    });
    return await Geolocator.getCurrentPosition();
  }


  // //open the map launcher
  // showDirectionToDriver(double latitude, double longitude) async {
  //  await MapsLauncher.launchCoordinates(latitude, longitude, "Show direction to driver");
  // }
}