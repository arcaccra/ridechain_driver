import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// Top-level background message handler
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Background message received — handled silently
}

class FCMService {
  static final FCMService instance = FCMService._internal();
  factory FCMService() => instance;
  FCMService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  
  FirebaseMessaging get fcm => _fcm;



  // Notification channels
  static const String CHANNEL_TRIP_REQUEST = 'trip_request_channel';
  static const String CHANNEL_TRIP_UPDATES = 'trip_updates_channel';
  static const String CHANNEL_PAYMENT = 'payment_channel';

  bool _isInitialized = false;
  StreamSubscription<String>? _tokenRefreshSubscription;

  // ========================================
  // INITIALIZATION
  // ========================================
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {


      //load the dot.env
      await dotenv.load(fileName: ".env");

      // Request permissions
      NotificationSettings settings = await _fcm.requestPermission(alert: true, badge: true, sound: true, criticalAlert: true);

      if (settings.authorizationStatus != AuthorizationStatus.authorized) {
        return;
      }

      // // Get and save FCM token
      // String? token = await _fcm.getToken();
      // if (token != null) {
      //   await _saveFCMToken(userId, token);
      // }
      //
      // // Listen for token refresh
      // _fcm.onTokenRefresh.listen((newToken) {
      //   _saveFCMToken(userId, newToken);
      // });

      // Create notification channels
      await _createNotificationChannels();

      // Set up message handlers
      await _setupMessageHandlers();

      _isInitialized = true;
    } catch (e) {
      throw e;
    }
  }


  //save user fcm token and activate refresh token
  saveAnActivateTokenRefresh(String userId) async {
    // Get and save FCM token
    String? token = await _fcm.getToken();
    if (token != null) {
      await _saveFCMToken(userId, token);
    }

    // Cancel any existing token refresh subscription to prevent leaks
    await _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription = _fcm.onTokenRefresh.listen((newToken) {
      _saveFCMToken(userId, newToken);
    });
  }

  // Create Android notification channels
  Future<void> _createNotificationChannels() async {
    if (Platform.isAndroid) {
      final androidPlugin = _localNotifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();


      //TODO: This will go to the user application as its users that reuqests for trips
      // Trip Request Channel
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          CHANNEL_TRIP_REQUEST,
          'Trip Requests',
          description: 'Notifications for incoming trip requests',
          importance: Importance.high,
          //sound: RawResourceAndroidNotificationSound('trip_request'),
          enableVibration: true,
          enableLights: true,
          ledColor: Color.fromARGB(255, 255, 152, 0),
        ),
      );

      //TODO: This will go to the driver application as its drivers that accept or reject trip requests
      // Trip Updates Channel
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          CHANNEL_TRIP_UPDATES,
          'Trip Updates',
          description: 'Notifications for trip status changes',
          importance: Importance.high,
          //sound: RawResourceAndroidNotificationSound('trip_started'),
          enableVibration: true,
          enableLights: true,
          ledColor: Color.fromARGB(255, 76, 175, 80),
        ),
      );

      //TODO: This will go to the user application as its users that make payments
      // Payment Channel
      await androidPlugin?.createNotificationChannel(
        const AndroidNotificationChannel(
          CHANNEL_PAYMENT,
          'Payment Updates',
          description: 'Notifications for payment confirmations',
          importance: Importance.max,
          //sound: RawResourceAndroidNotificationSound('payment_completed'),
          enableVibration: true,
          enableLights: true,
          ledColor: Color.fromARGB(255, 33, 150, 243),
        ),
      );
    }

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(requestAlertPermission: true, requestBadgePermission: true, requestSoundPermission: true);

    await _localNotifications.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _handleNotificationTap,
    );
  }

  // Setup message handlers
  Future<void> _setupMessageHandlers() async {
    // Background message handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Notification tap when app in background
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundNotificationTap);

    // Check if app was opened from notification (terminated state)
    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      _handleBackgroundNotificationTap(initialMessage);
    }
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;

    if (notification == null) return;

    // Show local notification
    _showLocalNotification(title: notification.title ?? 'Notification', body: notification.body ?? '', payload: jsonEncode(data), type: data['type'] ?? 'general');
  }

  // Show local notification
  Future<void> _showLocalNotification({required String title, required String body, required String payload, required String type}) async {
    // Determine channel and sound
    String channelId;
    String? soundFile;

    switch (type) {
      case 'trip_request':
        channelId = CHANNEL_TRIP_REQUEST;
        //soundFile = null;
        break;
      case 'trip_request_response':
      case 'trip_status_update':
        channelId = CHANNEL_TRIP_UPDATES;
        soundFile = null;
        break;
      case 'payment_completed':
        channelId = CHANNEL_PAYMENT;
        soundFile = null;
        break;
      default:
        channelId = CHANNEL_TRIP_UPDATES;
        soundFile = null;
    }

    final androidDetails = AndroidNotificationDetails(
      channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: Importance.high,
      priority: Priority.high,
      sound: soundFile != null ? RawResourceAndroidNotificationSound(soundFile) : null,
      icon: '@mipmap/ic_launcher',
      color: _getNotificationColor(type),
      enableVibration: true,
      styleInformation: BigTextStyleInformation(body, contentTitle: title),
    );

    final iosDetails = DarwinNotificationDetails(presentAlert: true, presentBadge: true, presentSound: true, sound: soundFile != null ? '$soundFile.caf' : null, badgeNumber: 1);

    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      NotificationDetails(android: androidDetails, iOS: iosDetails),
      payload: payload,
    );
  }

  // Handle notification tap (local notification)
  void _handleNotificationTap(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = Map<String, String>.from(jsonDecode(response.payload!) as Map);
        //TODO: Handle the notification navigation, NavigationService will help with this
        //NavigationService.handleNotificationNavigation(data['action'], data);
      } catch (_) {}
    }
  }

  // Handle notification tap from background/terminated (FCM)
  void _handleBackgroundNotificationTap(RemoteMessage message) {
    final data = Map<String, String>.from(message.data);
    // Small delay to ensure navigation is ready
    Future.delayed(const Duration(milliseconds: 500), () {
      //TODO: Take the action type and the data and navigate to the page requested
      //NavigationService.handleNotificationNavigation(data['action'], data);
    });
  }

  //On-Login, create a save the fcm token for the user
  // Save FCM token
  Future<void> _saveFCMToken(String userId, String token) async {
    try {
      await _firestore.collection('users').doc(userId).set({'fcmToken': token, 'fcmTokenUpdatedAt': DateTime.now(), 'platform': Platform.isAndroid ? 'android' : 'ios', 'userId': userId}, SetOptions(merge: true));
    } catch (_) {}
  }

  // ========================================
  // SEND NOTIFICATIONS (Direct from app)
  // ========================================

  // Send trip request notification
  Future<void> sendTripRequestNotification({required String tripId, required String userId, required String driverToken, required String userName, required String destination}) async {
    await _sendFCMNotification(token: driverToken, title: '🚗 New Trip Request', body: '$userName wants to join your trip to $destination', data: {'type': 'trip_request', 'tripId': tripId, 'userId': userId, 'action': 'view_request'}, sound: 'trip_request', channelId: CHANNEL_TRIP_REQUEST);
  }

  // Send trip response notification
  Future<void> sendTripResponseNotification({required String userToken, required String tripId, required String requestId, required bool accepted, required String driverName}) async {
    await _sendFCMNotification(
      token: userToken,
      title: accepted ? 'Request Accepted!' : 'Request Declined',
      body: accepted ? '$driverName accepted your trip request' : '$driverName declined your trip request',
      data: {'type': 'trip_request_response', 'tripId': tripId, 'requestId': requestId, 'status': accepted ? 'accepted' : 'declined', 'action': accepted ? 'view_trip' : 'find_trip'},
      sound: 'trip_accepted',
      channelId: CHANNEL_TRIP_UPDATES,
    );
  }

  Future<void> sendAlertNotificationToPassenger({required String userToken, required String driverName, String? body}) async {
    await _sendFCMNotification(
      token: userToken,
      title:'Passenger Alerted',
      body: body ?? 'The driver $driverName is waiting for you at the pickup location',
      data: {'type': 'passenger_alert'},
      sound: 'trip_accepted',
      channelId: CHANNEL_TRIP_UPDATES,
    );
  }

  // Send trip status update notification
  Future<void> sendTripStatusNotification({required List<String> passengerTokens, required String tripId, required String status, required String driverName}) async {
    String title, body;

    switch (status) {
      case 'arrived_pickup':
        title = 'Driver Arrived';
        body = '$driverName has arrived at pickup location';
        break;
      case 'started':
        title = 'Trip Started';
        body = '$driverName has started the trip';
        break;
      case 'completed':
        title = 'Trip Completed';
        body = 'Your trip has been completed. Thank you!';
        break;
      case 'approaching_pickup':
        title = 'Approaching Pickup';
        body = 'Your driver is approaching pickup. Thank you!';
        break;
      default:
        return;
    }

    await Future.wait(passengerTokens.map((token) => _sendFCMNotification(token: token, title: title, body: body, data: {'type': 'trip_status_update', 'status': status, 'action': 'view_trip', 'ride_uuid': tripId}, sound: 'trip_started', channelId: CHANNEL_TRIP_UPDATES)));
  }

  // Send payment notification
  Future<void> sendPaymentNotification({required String token, required String paymentId, required String tripId, required double amount, required bool isDriver, String? userName}) async {
    await _sendFCMNotification(
      token: token,
      title: isDriver ? '💰 Payment Received' : '💳 Payment Completed',
      body: isDriver ? 'You received \$${amount.toStringAsFixed(2)}${userName != null ? ' from $userName' : ''}' : 'Payment of \$${amount.toStringAsFixed(2)} processed successfully',
      data: {'type': 'payment_completed', 'paymentId': paymentId, 'tripId': tripId, 'amount': amount.toString(), 'role': isDriver ? 'driver' : 'passenger', 'action': isDriver ? 'view_earnings' : 'view_receipt'},
      sound: 'payment_completed',
      channelId: CHANNEL_PAYMENT,
    );
  }

  //get the access token
  Future<AccessCredentials> _getAccessToken() async {
    final serviceAccountPath = dotenv.env['PATH_TO_SECRET'];

    String serviceAccountJson = await rootBundle.loadString(serviceAccountPath!);

    final serviceAccount = ServiceAccountCredentials.fromJson(serviceAccountJson);

    final scopes = ['https://www.googleapis.com/auth/firebase.messaging'];

    final client = await clientViaServiceAccount(serviceAccount, scopes);
    return client.credentials;
  }

  // Future<bool> _sendFCMNotification({required String token, required String title, required String body, required Map<String, String> data, String? sound, String? channelId}) async {
  //
  //   if(token.isEmpty) return false;
  //   //TODO: add this to send fcm token
  //   final credentials = await _getAccessToken();
  //   final accessToken = credentials.accessToken.data;
  //
  //   await Future.delayed(Duration(seconds: 2));
  //
  //   final String _fcmEndpoint = 'https://fcm.googleapis.com/v1/projects/${dotenv.env['PROJECT_ID']}/messages:send';
  //
  //   try {
  //     final response = await http.post(
  //       Uri.parse(_fcmEndpoint),
  //       headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $accessToken'},
  //       body: jsonEncode({
  //         'token': token,
  //         'priority': 'high',
  //         'notification': {'title': title, 'body': body, 'sound': sound ?? 'default', 'android_channel_id': channelId ?? 'default_channel', 'click_action': 'FLUTTER_NOTIFICATION_CLICK'},
  //         'data': data,
  //       }),
  //     );
  //
  //     if (response.statusCode == 200) {
  //       print('✅ FCM notification sent');
  //       return true;
  //     } else {
  //       print('❌ FCM error: ${response.statusCode} - ${response.body}');
  //       return false;
  //     }
  //   } catch (e) {
  //     print('❌ Error sending FCM: $e');
  //     return false;
  //   }
  // }

  // Helper methods

  // Core FCM send method - CORRECTED for FCM v1 API
  Future<bool> _sendFCMNotification({
    required String token,
    required String title,
    required String body,
    required Map<String, String> data,
    String? sound,
    String? channelId,
    String? imageUrl,
    String? priority,
  }) async {
    if (token.isEmpty) return false;

    try {
      // Get access token
      final credentials = await _getAccessToken();
      final accessToken = credentials.accessToken.data;

      final String fcmEndpoint =
          'https://fcm.googleapis.com/v1/projects/${dotenv.env['PROJECT_ID']}/messages:send';

      // CORRECT FCM v1 API payload structure
      final payload = {
        'message': {  // ← MUST wrap everything in 'message' object
          'token': token,
          'notification': {
            'title': title,
            'body': body,
            if (imageUrl != null) 'image': imageUrl,
          },
          'data': data,
          'android': {
            'priority': priority ?? 'high',
            'notification': {
              'sound': sound ?? 'default',
              'channel_id': channelId ?? 'default_channel',
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              // Additional Android-specific options
              'notification_priority': 'PRIORITY_HIGH',
              'visibility': 'PUBLIC',
            },
          },
          'apns': {
            'headers': {
              'apns-priority': '10',
            },
            'payload': {
              'aps': {
                'sound': sound ?? 'default',
                'badge': 1,
                'content-available': 1,
              },
            },
          },
        },
      };

      final response = await http.post(
        Uri.parse(fcmEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    } catch (_) {
      return false;
    }
  }

  String _getChannelName(String channelId) {
    switch (channelId) {
      case CHANNEL_TRIP_REQUEST:
        return 'Trip Requests';
      case CHANNEL_TRIP_UPDATES:
        return 'Trip Updates';
      case CHANNEL_PAYMENT:
        return 'Payment Updates';
      default:
        return 'Notifications';
    }
  }

  String _getChannelDescription(String channelId) {
    switch (channelId) {
      case CHANNEL_TRIP_REQUEST:
        return 'Incoming trip requests';
      case CHANNEL_TRIP_UPDATES:
        return 'Trip status updates';
      case CHANNEL_PAYMENT:
        return 'Payment confirmations';
      default:
        return 'App notifications';
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'trip_request':
        return const Color.fromARGB(255, 255, 152, 0);
      case 'trip_request_response':
      case 'trip_status_update':
        return const Color.fromARGB(255, 76, 175, 80);
      case 'payment_completed':
        return const Color.fromARGB(255, 33, 150, 243);
      default:
        return const Color.fromARGB(255, 158, 158, 158);
    }
  }

  // Cleanup
  Future<void> dispose(String userId) async {
    await _firestore.collection('users').doc(userId).update({'fcmToken': FieldValue.delete()});
    await _fcm.deleteToken();
  }
}
