import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/models/user_model.dart';
import 'fcm_service.dart';

class TripFirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FCMService _notificationService = FCMService();

  // ========================================
  // 1. DRIVER ACCEPTS/DECLINES REQUEST
  // ========================================
  Future<void> respondToTripRequest({required AuthModel driver, required String tripId, required String requestId, required bool accept}) async {
    try {
      print('📤 Responding to trip request...');

      // 1. Update request status in Firestore
      final requestRef = _firestore.collection('trips').doc(tripId).collection('requests').doc(requestId);

      await requestRef.update({'status': accept ? 'accepted' : 'declined', 'respondedAt': DateTime.now()});

      print('✅ Request status updated in Firestore');

      // 2. Get request details
      final requestDoc = await requestRef.get();
      final requestData = requestDoc.data()!;
      final userId = requestData['userId'];

      // 3. If accepted, add user to trip passengers
      if (accept) {
        await _firestore.collection('trips').doc(tripId).update({
          'passengerIds': FieldValue.arrayUnion([userId]),
        });
        print('✅ User added to trip passengers');
      }

      // 4. Get user's FCM token
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final userToken = userDoc.data()?['fcmToken'];

      if (userToken == null) {
        print('⚠️ User FCM token not found');
        return;
      }

      // 5. Get driver details
      final driverName = driver.user?.fullName ?? 'Driver';

      // 6. Send notification to user
      await _notificationService.sendTripResponseNotification(userToken: userToken, tripId: tripId, requestId: requestId, accepted: accept, driverName: driverName);

      print('✅ Response notification sent to user');
    } catch (e) {
      print('❌ Error responding to trip request: $e');
      throw e;
    }
  }

  // ========================================
  // 1. DRIVER ACCEPTS/DECLINES REQUEST
  // ========================================
  Future<void> alertPassenger({required AuthModel driver, required String passengerId, String? body}) async {
    try {
      print('📤 Alerting to passenger...');

      // 4. Get user information
      final userDoc = await _firestore.collection('users').doc(passengerId).get();
      final userToken = userDoc.data()?['fcmToken'];

      if (userToken == null) {
        print('⚠️ User FCM token not found');
        return;
      }

      // 5. Get driver details
      final driverName = driver.user?.fullName ?? 'Driver';

      // 6. Send notification to user
      await _notificationService.sendAlertNotificationToPassenger(userToken: userToken, driverName: driverName, body: body);

      print('✅ Response notification sent to user');
    } catch (e) {
      print('❌ Error responding to trip request: $e');
      throw e;
    }
  }

  // ========================================
  // 2. DRIVER UPDATES TRIP STATUS
  // ========================================
  Future<void> updateTripStatus({
    required String tripId,
    required String status, // 'arrived_pickup', 'started', 'completed'
    required UserModel driver,
    List<String>? passengers,
  }) async {
    try {
      print('📤 Updating trip status to: $status');

      // 1. Update trip status in Firestore
      final updates = <String, dynamic>{'status': status};

      if (status == 'started') {
        updates['startedAt'] = DateTime.now();
      } else if (status == 'completed') {
        updates['completedAt'] = DateTime.now();
      }

      await _firestore.collection('trips').doc(tripId).update(updates);
      print('✅ Trip status updated in Firestore');

      // 2. Get trip details
      final tripDoc = await _firestore.collection('trips').doc(tripId).get();
      final tripData = tripDoc.data()!;

      List<String> passengerIds = [];
      if (passengers != null && passengers.isNotEmpty) {
        passengerIds = List<String>.from(passengers);
      } else {
        passengerIds = List<String>.from(tripData['passengerIds'] ?? []);
      }


      if (passengerIds.isEmpty) {
        print('⚠️ No passengers in trip');
        return;
      }

      // 3. Get driver details
      // final currentUser = FirebaseAuth.instance.currentUser!;
      // final driverDoc = await _firestore.collection('users').doc(currentUser.uid).get();
      final driverName = driver.fullName ?? "Driver";

      // 4. Get all passenger tokens
      final passengerDocs = await Future.wait(passengerIds.map((id) => _firestore.collection('users').doc(id).get()));

      final passengerTokens = passengerDocs.map((doc) => doc.data()?['fcmToken'] as String?).where((token) => token != null).cast<String>().toList();

      if (passengerTokens.isEmpty) {
        print('⚠️ No valid passenger tokens found');
        return;
      }

      // 5. Send notifications to all passengers
      await _notificationService.sendTripStatusNotification(passengerTokens: passengerTokens, tripId: tripId, status: status, driverName: driverName);

      print('Trip status notifications sent to ${passengerTokens.length} passengers');
    } catch (e) {
      print('Error updating trip status: $e');
      throw e;
    }
  }

  // ========================================
  // 3. PAYMENT COMPLETED
  // ========================================
  Future<void> completePayment({required String paymentId, required String tripId, required String userId, required double amount}) async {
    try {
      print('📤 Processing payment completion...');

      // 1. Update payment status in Firestore
      await _firestore.collection('payments').doc(paymentId).update({'status': 'completed', 'completedAt': DateTime.now()});
      print('✅ Payment status updated in Firestore');

      // 2. Get trip details
      final tripDoc = await _firestore.collection('trips').doc(tripId).get();
      final tripData = tripDoc.data()!;
      final driverId = tripData['driverId'];

      // 3. Get user and driver details
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final driverDoc = await _firestore.collection('users').doc(driverId).get();

      final userToken = userDoc.data()?['fcmToken'];
      final driverToken = driverDoc.data()?['fcmToken'];
      final userName = userDoc.data()?['name'];

      // 4. Send notification to user (passenger)
      if (userToken != null) {
        await _notificationService.sendPaymentNotification(token: userToken, paymentId: paymentId, tripId: tripId, amount: amount, isDriver: false);
        print('✅ Payment notification sent to user');
      }

      // 5. Send notification to driver
      if (driverToken != null) {
        await _notificationService.sendPaymentNotification(token: driverToken, paymentId: paymentId, tripId: tripId, amount: amount, isDriver: true, userName: userName);
        print('✅ Payment notification sent to driver');
      }

      print('✅ Payment completed successfully');
    } catch (e) {
      print('❌ Error completing payment: $e');
      throw e;
    }
  }

  // ========================================
  // HELPER METHODS
  // ========================================

  // Get trip details
  Future<Map<String, dynamic>?> getTripDetails(String tripId) async {
    try {
      final tripDoc = await _firestore.collection('trips').doc(tripId).get();
      return tripDoc.data();
    } catch (e) {
      print('❌ Error getting trip details: $e');
      return null;
    }
  }

  // Get trip requests (for driver)
  Stream<QuerySnapshot> getTripRequests(String tripId) {
    return _firestore.collection('trips').doc(tripId).collection('requests').where('status', isEqualTo: 'pending').orderBy('createdAt', descending: true).snapshots();
  }

  // Get user's trips (for passenger)
  Stream<QuerySnapshot> getUserTrips(String userId) {
    return _firestore.collection('trips').where('passengerIds', arrayContains: userId).orderBy('createdAt', descending: true).snapshots();
  }

  // Get driver's trips
  Stream<QuerySnapshot> getDriverTrips(String driverId) {
    return _firestore.collection('trips').where('driverId', isEqualTo: driverId).orderBy('createdAt', descending: true).snapshots();
  }

  // Cancel trip
  Future<void> cancelTrip(String tripId) async {
    try {
      await _firestore.collection('trips').doc(tripId).update({'status': 'cancelled', 'cancelledAt': FieldValue.serverTimestamp()});
      print('✅ Trip cancelled');
    } catch (e) {
      print('❌ Error cancelling trip: $e');
      throw e;
    }
  }

  // Create new trip
  Future<void> createTrip({required String driverId, required int pickupLocation, required int dropOffLocation, required String destination, required DateTime scheduledTime, required String tripId}) async {
    try {
      await _firestore.collection('trips').doc(tripId).set({
        'driverId': driverId,
        'pickupLocation': pickupLocation,
        'dropoffLocation': dropOffLocation,
        'destination': destination,
        'scheduledTime': Timestamp.fromDate(scheduledTime),
        'status': 'pending',
        'passengerIds': [],
        'createdAt': DateTime.now(),
      });
      //print('✅ Trip created: ${tripRef.id}');
    } catch (e) {
      print('❌ Error creating trip: $e');
      //throw e;
    }
  }

  //create a new user whether driver
  Future<void> createNewUser({required UserModel user}) async {
    try {
      await _firestore.collection('users').doc(user.driver!.id.toString()).set({
        'userId': user.driver!.id.toString(),
        'name': user.fullName,
        'createdAt': DateTime.now(),
      });
    } catch (e) {
      rethrow;
    }
  }

}
