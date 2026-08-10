import 'package:flutter_local_notifications/flutter_local_notifications.dart';


class NotificationService {


  static final FlutterLocalNotificationsPlugin
      _notifications =
      FlutterLocalNotificationsPlugin();



  static Future<void> initialize() async {


    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings(
          '@mipmap/ic_launcher',
        );


    const InitializationSettings settings =
        InitializationSettings(
          android: androidSettings,
        );


    await _notifications.initialize(settings);



    // Request Android notification permission
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();

  }




  static Future<void> showNotification({

    required String title,

    required String body,

  }) async {



    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(

      'freshtrack_channel',

      'FreshTrack Alerts',

      channelDescription:
          'Food expiry notifications',

      importance:
          Importance.max,

      priority:
          Priority.high,

      playSound: true,

    );



    const NotificationDetails details =
        NotificationDetails(

          android: androidDetails,

        );




    await _notifications.show(

      DateTime.now()
          .millisecondsSinceEpoch
          .remainder(100000),

      title,

      body,

      details,

    );


  }

}