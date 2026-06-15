

import 'package:flutter/cupertino.dart';
import 'package:ridechain_driiver/services/trip_firebase_service.dart';
import '../data/locator.dart';
import '../services/dialog_service.dart';
import '../services/image_service.dart';
import '../services/login_service.dart';
import '../services/rides_service.dart';

enum UiState {idle, loading, done, error}
class BaseProvider with ChangeNotifier {


  var auth =  locator<LoginService>();
  var dialog = locator<DialogService>();
  var image = locator<FilePickerService>();
  var rideService = locator<RidesService>();
  var tripService = locator<TripFirebaseService>();

  UiState uiState = UiState.idle;

  bool get isLoading => uiState == UiState.loading;

  bool get done => uiState == UiState.done;

  bool get error => uiState == UiState.error;


  setUiState(UiState _uiState) {
    uiState = _uiState;
    if (hasListeners) notifyListeners();
  }


  updateUi(VoidCallback func) {
    func();
    if (hasListeners) notifyListeners();
  }
}