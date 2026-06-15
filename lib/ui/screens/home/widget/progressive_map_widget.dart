import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../app/theme.dart';
import '../../../../core/core_constants/colors.dart';
import '../../../../core/core_constants/label.dart';
import '../../../../core/core_constants/media.dart';
import '../../../../data/locator.dart';
import '../../../../data/models/ride_model.dart';
import '../../../../providers/rides_provider.dart';
import '../../../../services/dialog_service.dart';
import '../../../../services/location_service.dart';
import '../../../../services/login_service.dart';
import '../../../../services/rides_service.dart';

class ProgressiveMapWidget extends StatefulWidget {
  final Stream<Position> locationStream;
  final Function(GoogleMapController) onMapCreated;
  final Function()? approachingDestination;
  final Function()? approachingPickup;
  final VoidCallback? onLocationFound;
  final List<RideModel> availableRides;
  const ProgressiveMapWidget({super.key, this.approachingDestination, this.approachingPickup, required this.locationStream, required this.onMapCreated, this.onLocationFound, this.availableRides = const []});

  @override
  State<ProgressiveMapWidget> createState() => _ProgressiveMapWidgetState();
}

class _ProgressiveMapWidgetState extends State<ProgressiveMapWidget> with TickerProviderStateMixin {
  GoogleMapController? _mapController;
  bool _isLocationFound = false;
  bool _hasAnimatedToLocation = false;
  Position? _userLocation;
  Set<Marker> _markers = {};
  BitmapDescriptor? _rideMarkerIcon;

  // Animation controllers
  late AnimationController _pulseController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _fadeAnimation;

  // Default camera position (you can set this to your city/country center)
  static final LatLng _defaultLocation = LatLng(Label.countryLat, Label.countryLng); // San Francisco
  static const double _defaultZoom = 10.0;
  static const double _userLocationZoom = 12.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _initializeAnimations();
    _createCustomMarkerIcon();
  }

  @override
  void didChangeDependencies() {
    _createCustomMarkerIcon();
    super.didChangeDependencies();
  }

  //check for changes and update the widget appropriately
  @override
  void didUpdateWidget(ProgressiveMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.availableRides != widget.availableRides) {
      _updateDriverMarkers();
    }
  }

  //initialize the animations
  void _initializeAnimations() {
    // Pulse animation for loading indicator
    _pulseController = AnimationController(duration: const Duration(seconds: 2), vsync: this);
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));

    // Fade animation for smooth transitions
    _fadeController = AnimationController(duration: const Duration(milliseconds: 800), vsync: this);
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut));

    // Start pulse animation
    _pulseController.repeat(reverse: true);
  }

  //animate the camera to the user location
  Future<void> _animateToUserLocation(Position position) async {
    if (_mapController == null || _hasAnimatedToLocation) return;

    setState(() {
      _userLocation = position;
      _isLocationFound = true;
      _hasAnimatedToLocation = true;
    });

    // Stop pulse animation and start fade animation
    _pulseController.stop();
    await _fadeController.forward();

    try {
      await _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: _userLocationZoom,
            tilt: 0,
            bearing: 0,
          ),
        ),
      );
    } catch (e) {
      log("Camera animation error: $e");
    }
    // Callback when location is found and animated to
    widget.onLocationFound!();
  }

  //Create custom marker icon for drivers
  Future<void> _createCustomMarkerIcon() async {
    _rideMarkerIcon = await locator<LoginService>().svgToBitmap(context: context, svgAssetPath: Media.rideMarker);
    if (mounted) {
      _updateDriverMarkers();
    }
  }

  //get the driver markers
  // Update driver markers on map
  void _updateDriverMarkers() {
    if (_rideMarkerIcon == null || widget.availableRides.isEmpty) return;

    final Set<Marker> newMarkers = {};

    for (final ride in widget.availableRides) {
      newMarkers.add(
        Marker(
          markerId: MarkerId('driver_${ride.uuid}'),
          position: ride.latLng,
          icon: _rideMarkerIcon!,
          //onTap: () => _onDriverMarkerTapped(driver),
          infoWindow: InfoWindow(title: ride.driver?.user?.fullName, snippet: '${ride.driver?.vehicleType} • ⭐ ${ride.driver?.vehiclePlateNumber}'),
        ),
      );
    }

    setState(() {
      _markers.clear();
      _markers = newMarkers;
    });
  }

  @override
  Widget build(BuildContext context) {
    final rideVm = Provider.of<RideProvider>(context);
    return Stack(
      children: [
        // Main Google Map - Always Visible
        SizedBox(
          height: double.infinity,
          width: double.infinity,
          child: StreamBuilder<Position>(
            stream: widget.locationStream,
            builder: (context, snapshot) {
              // if(snapshot.hasData) {
              //   final newPosition = snapshot.data!;
              //   final hasLocationChanged = _userLocation == null || (_userLocation?.latitude != newPosition.latitude || _userLocation?.longitude != newPosition.longitude);
              //   if(hasLocationChanged) {
              //     WidgetsBinding.instance.addPostFrameCallback((_) {
              //       _handleLocationUpdate(newPosition);
              //     });
              //   }
              // }
              if (snapshot.hasData && snapshot.data!.latitude != _userLocation?.latitude && snapshot.data!.longitude != _userLocation?.longitude) {
                _userLocation = snapshot.data!;
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_userLocation != null) {
                    // Callback when location is found and animated to
                    widget.onLocationFound!();
                  }
                  _animateToUserLocation(_userLocation!);
                });
              }

                //   if(rideVm.currentRideState == RideState.driverEnRouteToPickUp) {
                //     var distance = locator<LocationService>().calculateDistance(rideVm.selectedRide?.dropOff?.latitude ?? 0.0, rideVm.selectedRide?.dropOff?.longitude ?? 0.0, _userLocation?.latitude ?? 0.0, _userLocation?.longitude ?? 0.0,);
                //     log("DISTANCE FROM PICKUP===>> $distance");
                //     if(distance <= 20) {
                //       WidgetsBinding.instance.addPostFrameCallback((_) {
                //         widget.approachingPickup!();
                //       });
                //     }
                //   }
                //
                //     if(locator<RidesService>().checkIfTripHasStarted(rideState: rideVm.currentRideState, model: rideVm.selectedRide)) {
                //       var distance = locator<LocationService>().calculateDistance(rideVm.selectedRide?.dropOff?.latitude ?? 0.0, rideVm.selectedRide?.dropOff?.longitude ?? 0.0, _userLocation?.latitude ?? 0.0, _userLocation?.longitude ?? 0.0,);
                //       log("DISTANCE ===>> $distance");
                //       if(distance <= 10000) {
                //         WidgetsBinding.instance.addPostFrameCallback((_) {
                //           widget.approachingDestination!();
                //         });
                //       }
                //     }

              return GoogleMap(
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                  widget.onMapCreated(controller);
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _updateDriverMarkers();
                  });
                },
                myLocationEnabled: _isLocationFound,
                myLocationButtonEnabled: false,
                mapType: MapType.normal,
                markers: _markers,
                initialCameraPosition: CameraPosition(target: _defaultLocation, zoom: _defaultZoom),
                // Add custom styling for better UX
                zoomControlsEnabled: false,
                mapToolbarEnabled: false,
                compassEnabled: true,
                rotateGesturesEnabled: true,
                scrollGesturesEnabled: true,
                tiltGesturesEnabled: true,
                zoomGesturesEnabled: true,
              );
            },
          ),
        ),

        // Loading Overlay - Only shows while getting location
        if (!_isLocationFound) _buildLoadingOverlay(),

        // Success Animation - Shows when location is found
        if (_isLocationFound && _fadeController.isAnimating) _buildSuccessAnimation(),
      ],
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.3),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated location icon
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.blue.withValues(alpha: 0.1), shape: BoxShape.circle),
                      child: const Icon(Icons.location_searching, size: 32, color: AppColors.primaryColor),
                    ),
                  );
                },
              ),
              Gap(16),
              Text(Label.findingLocation, style: AppThemes.appBeauSansMedium),
              Gap(8),
              Text(Label.mayTakeSeconds, style: AppThemes.getCustomTextStyle(fontSize: 14, weight: FontWeight.w400)),
            ],
          ),
        ),
      ),
    );
  }

  // The success animation is built using an AnimatedBuilder widget. The animation is controlled by the _fadeAnimation controller.
  // The opacity of the container is decreased as the animation progresses, which creates a fade out effect.
  // The color of the container is gradually changed to become more transparent, creating a fading effect.
  // The size of the inner container is increased as the animation progresses, creating a scaling effect.
  // The icon inside the inner container is also scaled up, creating a bouncing effect.
  // The box shadow of the inner container is also changed as the animation progresses, creating a ripple effect.
  Widget _buildSuccessAnimation() {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: 1.0 - _fadeAnimation.value,
          child: Container(
            color: Colors.green.withValues(alpha: 0.1 * (1.0 - _fadeAnimation.value)),
            child: Center(
              child: Transform.scale(
                scale: 1.0 + (_fadeAnimation.value * 0.2),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.green.withOpacity(0.3), spreadRadius: 10, blurRadius: 20)],
                  ),
                  child: const Icon(Icons.location_on, size: 32, color: Colors.white),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showLocationError() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              SizedBox(width: 8),
              Text(Label.unableToGetLocation),
            ],
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: Label.retry,
            textColor: Colors.white,
            onPressed: () {
              setState(() {
                _isLocationFound = false;
                _hasAnimatedToLocation = false;
              });
              _pulseController.repeat(reverse: true);
              _fadeController.reset();
            },
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

void _handleLocationUpdate(Position newPosition) async {
  if(!mounted) return;

  final isFirstLocation = _userLocation == null;

  setState(() {
    _userLocation = newPosition;
  });

  //Only animate to location on first update
  if(isFirstLocation && !_hasAnimatedToLocation) {
    await _animateToUserLocation(newPosition);

    //Notify parent widget after animation completes
    if(mounted && widget.onLocationFound != null) {
      widget.onLocationFound!();
    }
  }
}
}
