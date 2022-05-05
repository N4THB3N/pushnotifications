import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class PushNotificationsService {
  static FirebaseMessaging messaging = FirebaseMessaging.instance;
  static String? token;
  static StreamController<String> _messageStream =
      new StreamController.broadcast();
  static Stream<String> get messagesStream => _messageStream.stream;

  static const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description:
        'This channel is used for important notifications.', // description
    importance: Importance.max,
  );

  static final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future _backgroundHandler(RemoteMessage message) async {
    // print('onBackgroundHandler: ${message.messageId}');

    _messageStream.add(message.data['product'] ?? 'No title');
  }

  static Future _onMessageHandler(RemoteMessage message) async {
    // print('onMessageHandler: ${message.messageId}');

    _messageStream.add(message.data['product'] ?? 'No title');

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    RemoteNotification? notification = message.notification;
    String iconName = AndroidInitializationSettings('@mipmap/ic_launcher')
        .defaultIcon
        .toString();

    // Si `onMessage` es activado con una notificación, construimos nuestra propia
    // notificación local para mostrar a los usuarios, usando el canal creado.
    if (notification != null) {
      flutterLocalNotificationsPlugin.show(
          notification.hashCode,
          notification.title,
          notification.body,
          NotificationDetails(
            android: AndroidNotificationDetails(channel.id, channel.name,
                channelDescription: channel.description, icon: iconName),
          ));
    }
  }

  static Future _onMessageOpenApp(RemoteMessage message) async {
    // print('onMessageOpenApp: ${message.messageId}');
    _messageStream.add(message.data['product'] ?? 'No title');
  }

  static Future initializeApp() async {
    //Push Notifications
    await Firebase.initializeApp();
    token = await FirebaseMessaging.instance.getToken();
    print('Token: $token');

    //Handlers
    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
    FirebaseMessaging.onMessage.listen(_onMessageHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenApp);

    //Local Notifications
  }

  static closeStreams() {
    _messageStream.close();
  }
}

// // SHA1: 02:21:48:C2:7A:72:A2:77:B8:F9:2E:3B:04:B1:00:4F:6E:6C:BF:44

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:firebase_core/firebase_core.dart';

// class PushNotificationsService {
//   static FirebaseMessaging messaging = FirebaseMessaging.instance;
//   static String? token;

//   static Future _backgroundHandler(RemoteMessage message) async {
//     print('background handler ${message.messageId}');
//   }

//   static Future _onMessageHandler(RemoteMessage message) async {
//     print('on Message handler ${message.messageId}');
//   }

//   static Future _onMessageOpenApp(RemoteMessage message) async {
//     print('onMessageOpenApp handler ${message.messageId}');
//   }

//   static Future initializeApp() async {
//     // Push notifications

//     await Firebase.initializeApp();
//     token = await FirebaseMessaging.instance.getToken();
//     print('Token: $token');

//     // Handlers
//     FirebaseMessaging.onBackgroundMessage(_backgroundHandler);
//     FirebaseMessaging.onMessage.listen(_onMessageHandler);
//     FirebaseMessaging.onMessageOpenedApp.listen(_onMessageOpenApp);

//     // Local Notifications
//   }
// }
