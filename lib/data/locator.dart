

import 'package:get_it/get_it.dart';
import 'package:ridechain_driiver/services/trip_firebase_service.dart';
import '../services/blockfrost_service.dart';
import '../services/cardano_wallet_service.dart';
import '../services/connectivity_service.dart';
import '../services/dialog_service.dart';
import '../services/image_service.dart';
import '../services/location_service.dart';
import '../services/login_service.dart';
import '../services/rides_service.dart';

final GetIt locator = GetIt.instance;



void setUpLocator() {
  locator.registerLazySingleton<DialogService>(() => DialogService());
  locator.registerLazySingleton<LoginService>(() => LoginService());
  locator.registerLazySingleton<FilePickerService>(() => FilePickerService());
  locator.registerLazySingleton<RidesService>(() => RidesService());
  locator.registerLazySingleton<LocationService>(() => LocationService());
  locator.registerLazySingleton<ConnectionService>(() => ConnectionService());
  locator.registerLazySingleton<TripFirebaseService>(() => TripFirebaseService());
  locator.registerLazySingleton<CardanoWalletService>(() => CardanoWalletService());
  locator.registerLazySingleton<BlockfrostService>(() => BlockfrostService());
}