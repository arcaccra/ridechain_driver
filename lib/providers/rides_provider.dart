

import 'dart:developer' as developer;
import '../data/models/api_response.dart';
import '../data/models/booked_model.dart';
import '../data/models/ride_model.dart';
import 'base_provider.dart';

enum RideState {
  idle,
  searchingRides,// Initial state - show destination input
  searchingRideDetails, //This state fetched the rides details
  tripsAvailable, // state when searching for ride
  tripStarted, // show when the cars are available
  tripEnded, // Trip has ended
  driverEnRouteToPickUp, // Driver on route to pick up
  driverAtPickupLocation, // driver at pickup location
}

class RideProvider extends BaseProvider {


  List<RideModel> rides = [];

  RideModel? selectedRide;

  BookedRideModel? bookedRide;

  String selectedRideId = "";

  bool fetchingRides = false;

  RideState currentRideState = RideState.idle;

  fetchDriverRides() async {
    fetchingRides = true;
    currentRideState = RideState.searchingRides;
    try {
      var response = await rideService.fetchRides();
      developer.log(response.toString());
      var apiResponse = ApiResponse.parse(response);
      if(apiResponse.allGood!) {
        List ridesData = List.from(apiResponse.listWithoutDataKey);
        if(ridesData.isNotEmpty) {
          rides.clear();
          rides = ridesData.map((e)=> RideModel.fromJson(e)).toList();
          updateRideState(RideState.tripsAvailable);
        } else {
          updateRideState(RideState.idle);
          dialog.showSnackBar("Oops😫", "No rides found for driver");
        }
      }
    } on Exception catch(e) {
      dialog.showSnackBar("An unexpected error occurred", e.toString());
    } finally {
      updateUi(()=> fetchingRides = false);
    }
  }
  
  //fetch ride details
  Future<bool> fetchRideDetails(String rideUuid) async {
    setUiState(UiState.loading);
    updateRideState(RideState.searchingRideDetails);
    try {
      var response = await rideService.fetchRideDetails(rideUuid);
      developer.log(response.toString());
      var apiResponse = ApiResponse.parse(response);
      if(apiResponse.allGood!) {
        selectedRide = RideModel.fromJson(apiResponse.mappedObjects!);
        if(selectedRide != null) {
          updateRideState(RideState.tripsAvailable);
          return true;
        } else {
          updateRideState(RideState.tripsAvailable);
          dialog.showSnackBar("Oops😫", "No ride details for this ride");
        }
      }
    } on Exception catch(e) {
      dialog.showSnackBar("An unexpected error occurred", e.toString());
      updateRideState(RideState.tripsAvailable);
    } finally {
      setUiState(UiState.done);
    }
    return false;
  }

  Future<bool> createRide(Map<String, dynamic> rideMap, ) async {
    setUiState(UiState.loading);
    try {
      var response = await rideService.createRide(rideMap);
      developer.log(response.toString());
      var apiResponse = ApiResponse.parse(response);
      if(apiResponse.allGood!) {
        RideModel ride = RideModel.fromJson(apiResponse.mappedObjects!);
        tripService.createTrip(tripId: ride.uuid!, driverId: ride.driver!.id.toString(), pickupLocation: ride.pickUp, dropOffLocation: ride.dropOff, destination: "destination", scheduledTime: ride.departureTime!);
        await fetchDriverRides();
        return true;
      } else {
        dialog.showSnackBar("An unexpected error occurred", apiResponse.message!);
        return false;
      }
    } on Exception catch(e) {
      dialog.showSnackBar("An unexpected error occurred", e.toString());
    } finally {
      setUiState(UiState.done);
    }
    return false;
  }

  //update ride
  Future<void> updateRide(String rideUuid, String status) async {
    setUiState(UiState.loading);
    try {
      var response = await rideService.updateRide(rideUuid, status);
      developer.log(response.toString());
      var apiResponse = ApiResponse.parse(response);
      if(apiResponse.allGood!) {
      }
    } on Exception catch(e) {
      dialog.showSnackBar("An unexpected error occurred", e.toString());
    } finally {
      setUiState(UiState.done);
    }
  }


  // Improved state management methods
  void updateRideState(RideState newState) {
    if (currentRideState != newState) {
        currentRideState = newState;
    }
    if (hasListeners) notifyListeners();
  }

  setSelectedRide(RideModel ride) {
    selectedRide = ride;
    selectedRideId = ride.uuid!;
    if (hasListeners) notifyListeners();
  }

  reset(){
    selectedRide = null;
    selectedRideId = "";
    if (hasListeners) notifyListeners();
  }


  resetRideState() {
    currentRideState = RideState.idle;
    rides.clear();
    selectedRide = null;
    selectedRideId = "";
    if (hasListeners) notifyListeners();
  }

}