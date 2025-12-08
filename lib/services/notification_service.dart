import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Top-level background handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Handling a background message: ${message.messageId}");
}

class NotificationService {
  static final NotificationService _notificationService =
      NotificationService._internal();

  factory NotificationService() {
    return _notificationService;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Initialize Local Notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('ic_notification');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestSoundPermission: false,
      requestBadgePermission: false,
      requestAlertPermission: false,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // 2. Setup Firebase Messaging
    await _setupFirebaseMessaging();

    // 3. Configure Local Timezone
    await _configureLocalTimeZone();

    // 4. Create Reminders Channel
    const AndroidNotificationChannel remindersChannel =
        AndroidNotificationChannel(
      'reminders_channel',
      'Reminders',
      description: 'Notifications for case reminders',
      importance: Importance.max,
      playSound: true,
    );

    final androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    await androidImplementation?.createNotificationChannel(remindersChannel);

    // NOTE: Permission requests removed from init() to prevent showing before splash screen
    // Call requestNotificationPermissions() method when needed (e.g., after onboarding)

    // 5. Subscribe to News Topic
    await subscribeToTopic('news');

    // 6. Check First Run
    // await checkForFirstRunAndNotify();
  }

  Future<void> subscribeToTopic(String topic) async {
    await FirebaseMessaging.instance.subscribeToTopic(topic);
    debugPrint('Subscribed to topic: $topic');
  }

  Future<void> checkForFirstRunAndNotify() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstRun = prefs.getBool('is_first_run_news') ?? true;

    if (isFirstRun) {
      debugPrint('First run detected (news). showing welcome notification.');
      await showNotification(
        id: 888, // Unique ID for welcome
        title: 'Welcome to Law Genie News',
        body:
            'Stay updated with the latest legal news and developments right here.',
      );
      await prefs.setBool('is_first_run_news', false);
    }
  }

  /// Request notification permissions (call this after onboarding or when needed)
  Future<NotificationSettings> requestNotificationPermissions() async {
    // Request notification permission for Android 13+
    final androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidImplementation?.requestNotificationsPermission();

    // Request Firebase Messaging permission (iOS and Android)
    NotificationSettings settings =
        await FirebaseMessaging.instance.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    debugPrint('User granted permission: ${settings.authorizationStatus}');
    return settings;
  }

  StreamSubscription? _orderSubscription;

  void monitorUserOrders(String userId) {
    // Cancel existing subscription if any
    _orderSubscription?.cancel();

    debugPrint('Starting order monitor for user: $userId');

    // Subscribe to user-specific topic for Backend Cloud Functions notifications
    subscribeToTopic('user_$userId');

    final collection = FirebaseFirestore.instance
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .where('status', whereIn: ['pending', 'processing', 'completed']);
    // Monitor active orders.

    _orderSubscription = collection.snapshots().listen((snapshot) async {
      for (var change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.modified ||
            change.type == DocumentChangeType.added) {
          final data = change.doc.data() as Map<String, dynamic>;
          final orderId = change.doc.id;

          // Check for Preview
          if (data.containsKey('previewUrl') && data['previewUrl'] != null) {
            await _checkAndNotify(
              key: 'notified_preview_$orderId',
              id: orderId.hashCode,
              title: 'Certified Copy Preview Available',
              body: 'A preview for your order is ready. Tap to view.',
            );
          }

          // Check for Final File
          if (data.containsKey('finalFileUrl') &&
              data['finalFileUrl'] != null) {
            await _checkAndNotify(
              key: 'notified_final_$orderId',
              id: orderId.hashCode + 1,
              title: 'Certified Copy Ready',
              body: 'Your certified copy is ready for download.',
            );
          }
        }
      }
    });
  }

  Future<void> _checkAndNotify({
    required String key,
    required int id,
    required String title,
    required String body,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    bool alreadyNotified = prefs.getBool(key) ?? false;

    if (!alreadyNotified) {
      debugPrint('Triggering local notification for: $title');
      await showNotification(id: id, title: title, body: body);
      await prefs.setBool(key, true);
    }
  }

  // ... existing methods ...
  Future<void> _configureLocalTimeZone() async {
    try {
      final timeZoneName = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(timeZoneName.toString()));
    } catch (e) {
      debugPrint('Could not configure local timezone: $e');
      // Fallback
      try {
        tz.setLocalLocation(tz.getLocation('UTC'));
      } catch (_) {}
    }
  }

  // ... rest of existing code ...

  Future<void> _setupFirebaseMessaging() async {
    // Set Background Handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    // Create Android Channel for Heads-up notifications
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'news_channel', // id matches the one used in showNotification
      'News Updates', // title
      description: 'Notifications for new legal news',
      importance: Importance.max,
    );

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    // Foreground Message Handler
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('Got a message whilst in the foreground!');
      debugPrint('Message data: ${message.data}');

      if (message.notification != null) {
        debugPrint(
          'Message also contained a notification: ${message.notification}',
        );
        showNotification(
          id: message.hashCode,
          title: message.notification!.title ?? 'New Notification',
          body: message.notification!.body ?? '',
          imageUrl: message.notification!.android?.imageUrl,
        );
      }
    });
  }

  Future<String> _downloadAndSaveFile(String url, String fileName) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final String filePath = '${directory.path}/$fileName';
    final http.Response response = await http.get(Uri.parse(url));
    final File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? imageUrl,
  }) async {
    BigPictureStyleInformation? bigPictureStyleInformation;

    try {
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final String bigPicturePath = await _downloadAndSaveFile(
          imageUrl,
          'bigPicture-$id.jpg',
        );
        bigPictureStyleInformation = BigPictureStyleInformation(
          FilePathAndroidBitmap(bigPicturePath),
          largeIcon: FilePathAndroidBitmap(bigPicturePath),
          contentTitle: '<b>$title</b>',
          htmlFormatContentTitle: true,
          summaryText: body,
          htmlFormatSummaryText: true,
        );
      }
    } catch (e) {
      debugPrint('Error downloading image for notification: $e');
    }

    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'news_channel',
      'News Updates',
      channelDescription: 'Notifications for new legal news',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
      styleInformation: bigPictureStyleInformation,
    );
    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );
    await flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      platformChannelSpecifics,
    );
  }

  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'reminders_channel',
          'Reminders',
          channelDescription: 'Notifications for case reminders',
          importance: Importance.max,
          priority: Priority.high,
          icon: 'ic_notification',
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }
}
