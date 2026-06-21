import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Request permission for Android 13+
    if (!kIsWeb) {
      await Permission.notification.request();
    }

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsDarwin,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap here if needed
      },
    );
  }

  Future<void> showTransactionSuccess({
    required String type,
    required String stockTicker,
    required int shares,
    required double totalAmount,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'transaction_channel_id',
      'Transactions',
      channelDescription: 'Notifications for successful transactions',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
    );
    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    final isBuy = type.toLowerCase() == 'buy';
    final actionStr = isBuy ? 'Purchased' : 'Sold';
    
    await flutterLocalNotificationsPlugin.show(
      id: Random().nextInt(1000),
      title: 'Transaction Successful',
      body: 'Successfully $actionStr $shares shares of $stockTicker for \$${totalAmount.toStringAsFixed(2)}',
      notificationDetails: platformChannelSpecifics,
    );
  }

  Future<void> scheduleQuizReminder() async {
    // For demo purposes, we will delay 5 seconds then show the notification.
    // This allows the user to tap the button, put the app in background,
    // and see the notification pop up.
    Future.delayed(const Duration(seconds: 5), () async {
      const AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'quiz_reminder_channel_id',
        'Quiz Reminders',
        channelDescription: 'Reminders to complete daily quizzes',
        importance: Importance.max,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      );
      const NotificationDetails platformChannelSpecifics =
          NotificationDetails(android: androidPlatformChannelSpecifics);

      await flutterLocalNotificationsPlugin.show(
        id: Random().nextInt(1000),
        title: 'Fintell Academy',
        body: '💡 Time for your daily financial quiz! Test your knowledge now.',
        notificationDetails: platformChannelSpecifics,
      );
    });
  }
}
