
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../ui/shared_widgets/no_internet_modal.dart';
import 'dialog_service.dart';


class ConnectionService {

  DialogService dialogService = DialogService();
  GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();
  StreamSubscription? _subscription;

  final StreamController<List<ConnectivityResult>> _controller = StreamController<List<ConnectivityResult>>.broadcast();

  Stream<List<ConnectivityResult>> get stream => _controller.stream;


  checkConnection() async {
    if (_subscription != null) return; // already running
    _subscription = Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      // Got a new connectivity status!
      if (result.contains(ConnectivityResult.mobile) || result.contains(ConnectivityResult.wifi) || result == ConnectivityResult.ethernet) {
        Get.back();
      }else {
        dialogService.showCustomModal(context: navigatorKey.currentContext!, isDismissible: false, customModal: NoInternetModal());
      }
      _controller.add(result);
    });
  }


  closeConnection() {
    _subscription?.cancel();
    _subscription = null;
    if (!_controller.isClosed) _controller.close();
  }
}