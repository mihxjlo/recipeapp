import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

import '../main.dart';
import '../screens/random_meal_screen.dart';


@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message: ${message.messageId}');
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
  FlutterLocalNotificationsPlugin();

  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();


  Future<void> initialize() async {
    try {

      print('Initializing timezones...');
      tz.initializeTimeZones();
      print('Timezones initialized');

      // ask for permission
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      print('Permission status: ${settings.authorizationStatus}');



      const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');


      const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initializationSettings =
      InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      await _localNotifications.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onNotificationTap,
      );


      String? token = await _firebaseMessaging.getToken();
      print('FCM Token: $token');


      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);


      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);


      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);


      await _createNotificationChannel();

      print('Notification service fully initialized');
    } catch (e) {
      print('Error initializing notification service: $e');
      rethrow;
    }
  }

  //  Android notification channel
  Future<void> _createNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'recipes_channel', // id
      'Recipes Notifications', // name
      description: 'Notifications for recipes', // description
      importance: Importance.high,
      enableVibration: true,
      playSound: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  // Handle foreground messages
  void _handleForegroundMessage(RemoteMessage message) {
    print('Foreground message: ${message.notification?.title}');

    if (message.notification != null) {
      _showLocalNotification(
        title: message.notification!.title ?? 'Recipes',
        body: message.notification!.body ?? '',
        payload: message.data['route'],
      );
    }
  }

  // Handle message opened app
  void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message opened app: ${message.data}');

  }


  Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'recipes_channel',
      'Recipes Notifications',
      channelDescription: 'Notifications for recipes',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      icon: '@mipmap/ic_launcher',
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      0,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }


  void _onNotificationTap(NotificationResponse response) {
    print('Notification tapped: ${response.payload}');

    // Navigate to random recipe screen
    if (response.payload == 'random_meal') {
      Future.delayed(const Duration(milliseconds: 500), () {
        final context = navigatorKey.currentContext;
        if (context != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RandomMealScreen(),
            ),
          );
        }
      });
    }
  }


  Future<void> scheduleDailyRecipeNotification({
    required int hour,
    required int minute,
  }) async {
    try {
      await _localNotifications.zonedSchedule(
        0, // ID
        'Recipe of the day',
        'Dsicover a new taste!',
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'recipes_channel',
            'Recipes Notifications',
            channelDescription: 'Daily reminder for recipes',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // repeat every day
      );

      print('Daily notification scheduled for $hour:${minute.toString().padLeft(
          2, '0')}');

      final pending = await _localNotifications.pendingNotificationRequests();
      print('Total pending notifications: ${pending.length}');

    } catch(e){
      print('Error scheduling notification: $e');
      rethrow;
    }
  }

  // calculate next time for noti
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    try {
      final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
      print('Current time: $now');

      tz.TZDateTime scheduledDate = tz.TZDateTime(
        tz.local,
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      );

      print('Initial scheduled date: $scheduledDate');


      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
        print('Adjusted to tomorrow: $scheduledDate');
      }

      return scheduledDate;
    } catch (e) {
      print('Error calculating next time: $e');
      rethrow;
    }
  }


  Future<void> sendTestNotification() async {
    await _showLocalNotification(
      title: 'Welcome to the Recipe App!',
      body: 'We have a special recipe for you!',
      payload: 'random_meal',
    );
  }


  Future<void> subscribeToTopic(String topic) async {
    await _firebaseMessaging.subscribeToTopic(topic);
    print('Subscribed to topic: $topic');
  }


  Future<void> unsubscribeFromTopic(String topic) async {
    await _firebaseMessaging.unsubscribeFromTopic(topic);
    print('Unsubscribed from topic: $topic');
  }


  Future<void> cancelDailyNotification() async {
    await _localNotifications.cancel(0);
    print('Daily notification cancelled');
  }


  Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
    print('All notifications cancelled');
  }

  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    return await _localNotifications.pendingNotificationRequests();
  }

}