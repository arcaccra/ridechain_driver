
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../data/constants/api_constants.dart';
import '../data/models/ride_model.dart';
import '../providers/rides_provider.dart';
import 'http_service.dart';

class RidesService extends HttpService {


  //get rides for destination
  Future fetchRides() async {
    var response = await get("${Api.rides}rides/");
    return response;
  }

  //create ride
  Future createRide(Map<String,dynamic> rideMap) async {
    FormData formData = FormData.fromMap(rideMap);
    var response = await post("${Api.rides}rides/", body: formData);
    return response;
  }


  //book a ride
  Future fetchRideDetails(String rideUuid) async {
    var response = await get("${Api.rides}rides/$rideUuid/");
    return response;
  }

  //get rides for destination
  Future updateRide(String rideUuid, String status) async {
    var data = {
      "status": status,
    };
    var body = FormData.fromMap(data);
    var response = await put("${Api.rides}rides/$rideUuid/update/", body: body);
    return response;
  }

  checkIfTripHasStarted({RideModel? model, required RideState rideState}) {
    return model != null && rideState == RideState.tripStarted;
  }

  static const List<String> vehicleTypes = [
    'Sedan',
    'SUV',
    'Truck',
    'Van',
    'Minivan',
    'Saloon',
    'Other',
  ];

  // ========================================
  // CAR COLORS
  // ========================================

  /// Static list of common car colors
  static const List<String> carColors = [
    'White',
    'Black',
    'Silver',
    'Gray',
    'Red',
    'Blue',
    'Green',
    'Yellow',
    'Orange',
  ];


  static const List<String> idTypes = [
    'National ID',
    'Passport',
    'Driver license',
    'Voter ID'
  ];

  static Map<String, dynamic> idMap = {
    'National ID' : 'NATIONAL_ID',
    'Passport' : 'PASSPORT',
    'Driver license' : 'DRIVER_LICENSE',
    'Voter ID' : 'VOTER_ID'
  };

  // ========================================
  // MATERIAL COLOR CONVERTER
  // ========================================

  /// Converts a common car color name to a Material Color
  /// Returns the closest matching MaterialColor or a default color if no match found
  ///
  /// Example:
  /// ```dart
  /// MaterialColor redColor = VehicleHelper.getCarMaterialColor('Red');
  /// MaterialColor blueColor = VehicleHelper.getCarMaterialColor('blue'); // Case insensitive
  /// ```
  static MaterialColor getCarMaterialColor(String colorName) {
    // Normalize input: trim and convert to lowercase for comparison
    final normalizedColor = colorName.trim().toLowerCase();

    switch (normalizedColor) {
      case 'red':
      case 'maroon':
      case 'burgundy':
        return Colors.red;

      case 'pink':
        return Colors.pink;

      case 'purple':
        return Colors.purple;

      case 'blue':
      case 'navy':
        return Colors.blue;

      case 'teal':
      case 'turquoise':
        return Colors.teal;

      case 'cyan':
        return Colors.cyan;

      case 'green':
        return Colors.green;

      case 'yellow':
      case 'gold':
        return Colors.yellow;

      case 'orange':
        return Colors.orange;

      case 'brown':
        return Colors.brown;

      case 'gray':
      case 'grey':
      case 'silver':
      case 'charcoal':
        return Colors.grey;

      case 'white':
      case 'beige':
        return Colors.blueGrey; // Closest neutral for white/beige

      case 'black':
        return _createBlackMaterialColor(); // Custom black MaterialColor

      default:
      // Return a default color for unrecognized colors
        return Colors.grey;
    }
  }

  static MaterialColor _createBlackMaterialColor() {
    return const MaterialColor(
      0xFF000000,
      <int, Color>{
        50: Color(0xFF000000),
        100: Color(0xFF000000),
        200: Color(0xFF000000),
        300: Color(0xFF000000),
        400: Color(0xFF000000),
        500: Color(0xFF000000),
        600: Color(0xFF000000),
        700: Color(0xFF000000),
        800: Color(0xFF000000),
        900: Color(0xFF000000),
      },
    );
  }



}