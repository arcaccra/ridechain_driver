import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:ridechain_driiver/ui/screens/auth/driver_document_upload.dart';
import 'package:ridechain_driiver/ui/screens/auth/id_card_documents.dart';
import 'package:ridechain_driiver/ui/screens/auth/wallet_info.dart';
import 'package:ridechain_driiver/ui/screens/create_ride/create_new_ride.dart';
import 'package:ridechain_driiver/ui/screens/home/show_available_cars.dart';
import 'package:ridechain_driiver/ui/screens/home/widget/confirm_and_start_ride.dart';
import 'package:ridechain_driiver/ui/screens/home/widget/driver_at_pick_up_card.dart';
import 'package:ridechain_driiver/ui/screens/home/widget/driver_info_update.dart';
import 'package:ridechain_driiver/ui/screens/home/widget/progressive_map_widget.dart';
import 'package:ridechain_driiver/ui/screens/home/widget/trip_started_card.dart';
import '../../../app/theme.dart';
import '../../../core/core_constants/colors.dart';
import '../../../core/core_constants/label.dart';
import '../../../core/utility.dart';
import '../../../data/locator.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/rides_provider.dart';
import '../../../services/dialog_service.dart';
import '../../../services/fcm_service.dart';
import '../../../services/location_service.dart';
import '../../../services/trip_firebase_service.dart';
import '../../shared_widgets/ride_searching_loader.dart';
import '../../shared_widgets/top_container.dart';
import 'bottom_card_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final location = locator<LocationService>();
  final dialog = locator<DialogService>();
  GoogleMapController? mapController;
  late AuthVm authVm;
  late RideProvider rideProvider;

  //call the app to get the location

  //TODO: load drivers markers for visualization

  //show searching available cars
  bool isAvailableCars = false;
  bool isRiderComing = false;

  bool onFirstLocationTry = true;


  @override
  void initState() {
    super.initState();

    // Initialize your location stream here
    _initializeApp();
    //location.startListeningToPosition();
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  //reset to idle
  void _resetToIdle() {
    setState(() {
      rideProvider.updateRideState(RideState.idle);
    });
  }

  Future<void> _initializeApp() async {
    if (!mounted) return;

    try {
      authVm = context.read<AuthVm>();
      rideProvider = context.read<RideProvider>();

      if (authVm.currentUser?.id == null) {
        dialog.showSnackBar(
            "Authentication Error",
            "User session not found. Please login again."
        );
        return;
      }

      rideProvider.fetchDriverRides();

      // ✅ REMOVE THIS - location already initialized by navigation screen
      // location.startListeningToPosition();

      // // ✅ Only check if location is already running
      // if (!location.stream) {
      //   // Location wasn't started by navigation screen, start it now
      //   bool hasPermission = await location.checkLocationPermission(context);
      //   if (hasPermission && mounted) {
      //     location.startListeningToPosition();
      //   }
      // // }

      // A driver who skipped the document step has no driver profile yet, so
      // guard against null instead of force-unwrapping.
      final driverId = authVm.currentUser?.driver?.id?.toString();
      if (driverId != null && authVm.hasDriverSubmittedDocs()) {
        FCMService.instance.saveAnActivateTokenRefresh(driverId);
      }

      //_listenToRemoteMessagesFromRide();

    } catch (e, stackTrace) {
      log('Initialization error: $e', stackTrace: stackTrace);
      if (mounted) {
        dialog.showSnackBar(
            "Initialization Error",
            "Failed to initialize: ${e.toString()}"
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    authVm = context.watch<AuthVm>();
    rideProvider = context.watch<RideProvider>();
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            //this is the new implementation
            buildMapWidget(),
            
            buildTopContainer(),
            
            if(authVm.needsProfileCompletion) buildBannerForFileUpload(),
            
            //build the bottom card
            buildBottomCard(),
          ],
        ),
      ),
    );
  }

  //build map widget
  Widget buildMapWidget() {
    return ProgressiveMapWidget(
      locationStream: location.stream,
      onMapCreated: (controller) => mapController = controller,
      availableRides: rideProvider.rides,
      approachingPickup: () async {
        rideProvider.updateRideState(RideState.driverAtPickupLocation);
        await locator<TripFirebaseService>().updateTripStatus(tripId: rideProvider.selectedRide!.uuid!, status: 'arrived_pickup', driver: authVm.currentUser!, passengers: rideProvider.selectedRide?.passengers!.map((e) => e.id.toString()).toList());
      },
      approachingDestination: (){
        locator<DialogService>().showAlertDialog(
        context: context,
        message: Label.approachingDestination, type: AlertDialogType.error, okayText: Label.yes,
        cancelText: Label.no,
            onCancelBtnTap: (){
          Navigator.pop(context);
        },
        onOkayBtnTap: (){
          Navigator.pop(context);
          if(authVm.currentUser?.walletAddress == null){
            //Get.to(()=> RateDriverScreen());
          } else {
            //Get.to(()=> PayForTrip());
          }
        });
      },
      onLocationFound: () {
        // Called when location is found and animation completes
        setState(() {
          onFirstLocationTry = false;
        });
      },
    );
  }

  //build top container
  Widget buildTopContainer() {
    return Positioned(
        top: kToolbarHeight + 15.h,
        left: 0,
        right: 0,
        child: Center(child: HomeTopContainer())
    );
  }

  Widget buildBannerForFileUpload() {
    final docsMissing = !authVm.hasCompleteDocuments;
    return Positioned(
        top: kToolbarHeight + 60.h,
        left: 20,
        right: 20,
        child: Center(
          child: DriverInfoUpdate(
            title: docsMissing
                ? 'Complete your verification'
                : 'Add your payout wallet',
            message: docsMissing
                ? 'Submit your documents and add a wallet before you can create or start rides.'
                : 'Add a Cardano wallet to receive your ADA earnings before creating or starting rides.',
            updateDriver: () {
              if (docsMissing) {
                authVm.setRegistrationMode(false);
                authVm.checkIfDriverHasCompleteDocumentation(false);
              } else {
                Get.to(() => const WalletInfo());
              }
            },
          ),
        )
    );
  }

  //build bottom card
  Widget buildBottomCard() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 16,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          );
        },
        child: _buildCurrentCard(),
      ),
    );
  }

  //build the current card to show
  _buildCurrentCard(){
    switch (rideProvider.currentRideState) {
      case RideState.idle:
        return _letsRideCard();

      case RideState.tripsAvailable:
        return _buildAvailableCarsCard();

      case RideState.searchingRides:
        return _buildLoadingCard(null, searchingRides: true);

      case RideState.searchingRideDetails:
        return _buildLoadingCard(Label.fetchingRideDetails);

      case RideState.driverAtPickupLocation:
        return _driverAtPickupCard();
      case RideState.tripStarted:
        return _showTripStartedCard();
      case RideState.tripEnded:
        return _buildTripHasEnded();
      case RideState.driverEnRouteToPickUp:
        return _buildDriverEnRoute();
    }
  }

  _buildDriverEnRoute() {
    return _HomeStateCard(
      icon: Icons.navigation_outlined,
      iconColor: AppColors.purple,
      iconBgColor: AppColors.purple.withValues(alpha: 0.1),
      title: 'En route to pickup',
      subtitle: rideProvider.selectedRide?.pickUp?.name ?? 'Pickup location',
      rightLabel: '7 min',
      rightSubLabel: 'ETA',
      progressValue: 0.3,
      progressColor: AppColors.purple,
      primaryBtnText: "✓  I've arrived",
      primaryBtnColor: AppColors.purple,
      secondaryBtnText: 'Directions',
      secondaryBtnIcon: Icons.navigation_outlined,
      onPrimaryBtnTap: () async {
        rideProvider.updateRideState(RideState.driverAtPickupLocation);
        await locator<TripFirebaseService>().updateTripStatus(
          tripId: rideProvider.selectedRide!.uuid!,
          status: 'arrived_pickup',
          driver: authVm.currentUser!,
          passengers: rideProvider.selectedRide?.passengers!.map((e) => e.id.toString()).toList(),
        );
      },
      onSecondaryBtnTap: () {},
    );
  }

  _buildTripHasEnded() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          Gap(20.h),
          Container(
            width: 60.w,
            height: 60.w,
            decoration: BoxDecoration(
              color: Colors.green.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: Colors.green, size: 30.w),
          ),
          Gap(16.h),
          Text(
            'Trip completed!',
            style: TextStyle(
              fontFamily: 'BeauSans',
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: Colors.black,
            ),
          ),
          Gap(4.h),
          Text(
            'Payment settled on Cardano',
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[500]),
          ),
          Gap(20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('⊛ ', style: TextStyle(fontSize: 18.sp, color: AppColors.purple)),
              Text(
                '37.0',
                style: TextStyle(
                  fontFamily: 'BeauSans',
                  fontSize: 36.sp,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              Gap(6.w),
              Text(
                'ADA',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600, color: Colors.grey[600]),
              ),
            ],
          ),
          Gap(16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Row(
              children: [
                Text('Tx', style: TextStyle(fontSize: 13.sp, color: Colors.grey[500])),
                const Spacer(),
                Text(
                  'a3f9...paid · ${rideProvider.selectedRide?.passengers?.length ?? 0} riders',
                  style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                ),
                Gap(8.w),
                const Icon(Icons.check, color: Colors.green, size: 16),
              ],
            ),
          ),
          Gap(20.h),
          SizedBox(
            width: double.infinity,
            height: 52.h,
            child: ElevatedButton(
              onPressed: () async {
                final ride = rideProvider.selectedRide;
                final passengerCount = ride?.passengers?.length ?? 0;
                final pricePerSeat = double.tryParse(ride?.pricePerSeat ?? '0') ?? 0.0;
                final totalEarned = pricePerSeat * passengerCount;

                await showModalBottomSheet(
                  context: context,
                  backgroundColor: Colors.transparent,
                  isDismissible: false,
                  enableDrag: false,
                  builder: (ctx) {
                    Future.delayed(const Duration(milliseconds: 1500), () {
                      if (ctx.mounted) Navigator.of(ctx).pop();
                    });
                    return Container(
                      margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 32.h),
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24.r),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 24,
                            offset: const Offset(0, -4),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 56.w,
                            height: 56.w,
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.payments_outlined, color: Colors.green, size: 26.w),
                          ),
                          Gap(14.h),
                          Text(
                            'You earned',
                            style: TextStyle(fontSize: 14.sp, color: Colors.grey[500]),
                          ),
                          Gap(6.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('⊛ ', style: TextStyle(fontSize: 18.sp, color: AppColors.purple)),
                              Text(
                                totalEarned.toStringAsFixed(1),
                                style: TextStyle(
                                  fontFamily: 'BeauSans',
                                  fontSize: 38.sp,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black,
                                ),
                              ),
                              Gap(6.w),
                              Text(
                                'ADA',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ],
                          ),
                          Gap(10.h),
                          Text(
                            '$passengerCount rider${passengerCount == 1 ? '' : 's'} · ⊛ ${pricePerSeat.toStringAsFixed(1)} ADA/seat',
                            style: TextStyle(fontSize: 12.sp, color: Colors.grey[400]),
                          ),
                        ],
                      ),
                    );
                  },
                );

                await locator<TripFirebaseService>().updateTripStatus(
                  tripId: ride!.uuid!,
                  status: 'completed',
                  driver: authVm.currentUser!,
                  passengers: ride.passengers!.map((e) => e.id.toString()).toList(),
                );
                rideProvider.updateRideState(RideState.idle);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.purple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(26.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Back to dashboard',
                style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Returns true (and shows a banner-aligned snackbar) when the driver hasn't
  /// finished onboarding, blocking ride creation/starting.
  bool _blockIfIncomplete() {
    if (!authVm.hasCompleteDocuments) {
      locator<DialogService>().showSnackBar("Finish verification",
          "Submit your required documents before creating or starting rides.",
          isError: true);
      return true;
    }
    if (!authVm.hasWallet) {
      locator<DialogService>().showSnackBar("Add a payout wallet",
          "Add your Cardano wallet to receive ADA before creating or starting rides.",
          isError: true);
      return true;
    }
    return false;
  }

  //build the destination input card
  Widget _letsRideCard() {
    return BottomCardWidget(
      onBtnTap: () {
        if(_blockIfIncomplete()) return;
        rideProvider.fetchDriverRides();
      },
      onCreateRide: () {
        if(_blockIfIncomplete()) return;
        Get.to(()=> CreateNewRide());
      },
    );
  }

  //show available drivers card
  _buildAvailableCarsCard() {
    return ShowAvailableCarsWidget(
      onCancel: () {
        rideProvider.updateRideState(RideState.idle);
      },
      onRideTap: (rideUuid) async {
        bool tripDetailFound = await rideProvider.fetchRideDetails(rideUuid);
        if(tripDetailFound) {
          locator<DialogService>().showCustomModal(context: context, customModal: ConfirmAndStartRide(
            ride: rideProvider.selectedRide,
            onAccept: () async {
              // DateTime tripDate = DateTime(rideProvider.selectedRide!.departureTime!.year, rideProvider.selectedRide!.departureTime!.month, rideProvider.selectedRide!.departureTime!.day);
              // log(tripDate.toIso8601String());
              //  final isTripDueDate = Utils.isTripDue(tripDate);
              //  if(isTripDueDate) {
              //    locator<DialogService>().showSnackBar("No Access", "Trip's departure date has not come yet.");
              //    return;
              //  }
              Navigator.pop(context);
              rideProvider.updateRideState(RideState.driverEnRouteToPickUp);
              await rideProvider.updateRide(rideProvider.selectedRide!.uuid!, 'ENROUTE_PICKUP');
              await locator<TripFirebaseService>().updateTripStatus(tripId: rideProvider.selectedRide!.uuid!, status: 'approaching_pickup', driver: authVm.currentUser!, passengers: rideProvider.selectedRide?.passengers!.map((e) => e.id.toString()).toList());

            },
          ));
        } else {
          rideProvider.updateRideState(RideState.tripsAvailable);
        }

      },
      onCreateNewRide: (){
        // if(!authVm.hasDriverSubmittedDocs()) {
        //   locator<DialogService>().showSnackBar("No Access", "Please submit all your required documents to start a trip.");
        //   return;
        // }
        Get.to(()=> CreateNewRide());
      },
    );
  }

  //build loader card
  _buildLoadingCard(String? loaderText, {bool searchingRides = false}){
    return RideSearchingLoader(title: loaderText ?? Label.fetchingMyRides, onBtnTap: (){
      if(searchingRides) {
        rideProvider.updateRideState(RideState.idle);
      } else {
        rideProvider.updateRideState(RideState.tripsAvailable);
      }

    },);
  }

  _showTripStartedCard() {
    return Container(
      height: 0.5.sh,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: TripStartedCard(
        passengers: rideProvider.selectedRide!.passengers,
        onTripComplete: () async {
          rideProvider.updateRideState(RideState.tripsAvailable);
          await rideProvider.updateRide(rideProvider.selectedRide!.uuid!, 'COMPLETED');
          locator<DialogService>().showSnackBar("Trip Completed", "Trip has ended. Payment made will be credited to your account at the end of the business day");
        },
      ),
    );
  }

  _driverAtPickupCard() {
    return Container(
      height: 0.5.sh,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: DriverAtPickUpCard(
        onCancel: () async {
          //rideProvider.updateRideState(RideState.tripsAvailable);
          await rideProvider.updateRide(rideProvider.selectedRide!.uuid!, 'CANCELLED');
          locator<DialogService>().showSnackBar("No more waiting", "You can proceed with the trip but can cancel trip if riders are not at pickup.");
        },
        onEndTrip: () async {
          rideProvider.updateRideState(RideState.tripsAvailable);
          await rideProvider.updateRide(rideProvider.selectedRide!.uuid!, 'CANCELLED');
          locator<DialogService>().showSnackBar("Trip Cancelled", "Trip has been cancelled.");
        },
        onStartTrip: () async {
          await rideProvider.updateRide(rideProvider.selectedRide!.uuid!, 'IN_PROGRESS');
          await locator<TripFirebaseService>().updateTripStatus(
            tripId: rideProvider.selectedRide!.uuid!,
            status: 'started',
            driver: authVm.currentUser!,
            passengers: rideProvider.selectedRide?.passengers!.map((e) => e.id.toString()).toList(),
          );
          rideProvider.updateRideState(RideState.tripStarted);
        },
        passengers: rideProvider.selectedRide?.passengers ?? [],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private reusable card for en-route and similar navigation states
// ---------------------------------------------------------------------------
class _HomeStateCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;
  final String title;
  final String subtitle;
  final String rightLabel;
  final String rightSubLabel;
  final double progressValue;
  final Color progressColor;
  final String primaryBtnText;
  final Color primaryBtnColor;
  final String? secondaryBtnText;
  final IconData? secondaryBtnIcon;
  final VoidCallback onPrimaryBtnTap;
  final VoidCallback? onSecondaryBtnTap;

  const _HomeStateCard({
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
    required this.title,
    required this.subtitle,
    required this.rightLabel,
    required this.rightSubLabel,
    required this.progressValue,
    required this.progressColor,
    required this.primaryBtnText,
    required this.primaryBtnColor,
    this.secondaryBtnText,
    this.secondaryBtnIcon,
    required this.onPrimaryBtnTap,
    this.onSecondaryBtnTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          Gap(16.h),
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: iconColor, size: 22.w),
              ),
              Gap(12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontFamily: 'BeauSans',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    rightLabel,
                    style: TextStyle(
                      fontFamily: 'BeauSans',
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.purple,
                    ),
                  ),
                  Text(
                    rightSubLabel,
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey[400]),
                  ),
                ],
              ),
            ],
          ),
          Gap(12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(2.r),
            child: LinearProgressIndicator(
              value: progressValue,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation(progressColor),
              minHeight: 4,
            ),
          ),
          Gap(16.h),
          if (secondaryBtnText != null)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: OutlinedButton.icon(
                      onPressed: onSecondaryBtnTap,
                      icon: Icon(secondaryBtnIcon, size: 16.w, color: Colors.black,),
                      label: Text(secondaryBtnText!, style: TextStyle(fontSize: 14.sp, color: Colors.black)),
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                      ),
                    ),
                  ),
                ),
                Gap(12.w),
                Expanded(
                  child: SizedBox(
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: onPrimaryBtnTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryBtnColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        primaryBtnText,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          else
            SizedBox(
              width: double.infinity,
              height: 52.h,
              child: ElevatedButton(
                onPressed: onPrimaryBtnTap,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryBtnColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(26.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  primaryBtnText,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
