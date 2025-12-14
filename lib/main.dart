// // ignore_for_file: use_build_context_synchronously
// import 'dart:async';
// import 'dart:developer';
// import 'dart:io' show Platform;

// import 'package:app_badge_plus/app_badge_plus.dart';
// import 'package:british_body_admin/material/materials.dart';
// import 'package:british_body_admin/screens/auth/login_screen.dart';
// import 'package:british_body_admin/screens/dashborad.dart/changingworkerphone/changingworkerphone.dart';
// import 'package:british_body_admin/screens/navigator.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// // ignore: depend_on_referenced_packages
// import 'package:firebase_core/firebase_core.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_isolate/flutter_isolate.dart';
// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:map_location_picker/map_location_picker.dart';
// import 'package:geolocator/geolocator.dart'; // <--- ADDED GEOLOCATOR IMPORT
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:sizer/sizer.dart';
// import 'package:timezone/data/latest_all.dart' as tz;
// import 'package:timezone/timezone.dart' as tz;
// import 'package:upgrader/upgrader.dart';

// import 'firebase_options.dart';

// // --- BACKGROUND LOCATION DISCLOSURE FUNCTION ---
// // This dialog must be shown before requesting ACCESS_BACKGROUND_LOCATION
// Future<bool> showBackgroundLocationDisclosure(BuildContext context) async {
//   return await showDialog<bool>(
//     context: context,
//     barrierDismissible: false, // User must make a choice
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: const Text('Continuous Location Tracking Required 📍'),
//         content: const Text(
//           'For this app to effectively manage and track worker activity, we need access to your device\'s location **all the time**, even when the app is closed or in the background.\n\n'
//           'This data is essential for our core function: providing real-time worker location updates and ensuring efficient job dispatch.',
//           style: TextStyle(fontWeight: FontWeight.bold),
//         ),
//         actions: <Widget>[
//           TextButton(
//             child: const Text('No Thanks'),
//             onPressed: () => Navigator.of(context).pop(false),
//           ),
//           ElevatedButton(
//             child: const Text('Continue'),
//             onPressed: () => Navigator.of(context).pop(true),
//           ),
//         ],
//       );
//     },
//   ) ?? false;
// }
// // ----------------------------------------------


// Future<void> _firebaseMessaginBackgroundHandler(RemoteMessage message) async {
//   await Firebase.initializeApp();

//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   List<String> notificationTitles =
//       prefs.getStringList('notificationTitles') ?? [];
//   List<String> notificationBodies =
//       prefs.getStringList('notificationBodies') ?? [];

//   notificationTitles.add(message.notification?.title ?? 'British Body Admin');
//   notificationBodies.add(message.notification?.body ?? 'Notification');

//   await prefs.setStringList('notificationTitles', notificationTitles);
//   await prefs.setStringList('notificationBodies', notificationBodies);

//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//     message.notification?.android?.channelId ?? 'daily_channel_id',
//     'Foreground Notifications',
//     channelDescription: 'Notifications shown when the app is in the foreground',
//     importance: Importance.high,
//     priority: Priority.high,
//   );

//   NotificationDetails notificationDetails =
//       NotificationDetails(android: androidDetails);

//   flutterLocalNotificationsPlugin.show(
//     message.data.hashCode,
//     message.notification?.title,
//     message.notification?.body,
//     notificationDetails,
//   );
// }

// Future<void> _firebaseMessagingForgroundHandler(RemoteMessage message) async {
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   List<String> notificationTitles =
//       prefs.getStringList('notificationTitles') ?? [];
//   List<String> notificationBodies =
//       prefs.getStringList('notificationBodies') ?? [];

//   notificationTitles.add(message.notification?.title ?? 'British Body Admin');
//   notificationBodies.add(message.notification?.body ?? 'Notification');

//   await prefs.setStringList('notificationTitles', notificationTitles);
//   await prefs.setStringList('notificationBodies', notificationBodies);

//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
//     message.notification?.android?.channelId ?? 'daily_channel_id',
//     'Foreground Notifications',
//     channelDescription: 'Notifications shown when the app is in the foreground',
//     importance: Importance.high,
//     priority: Priority.high,
//   );

//   NotificationDetails notificationDetails =
//       NotificationDetails(android: androidDetails);

//   flutterLocalNotificationsPlugin.show(
//     message.data.hashCode,
//     message.notification?.title,
//     message.notification?.body,
//     notificationDetails,
//   );
// }

// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// bool logedin = true;
// String email = '';
// String city = '';
// @pragma('vm:entry-point')

// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   FirebaseMessaging.onBackgroundMessage(_firebaseMessaginBackgroundHandler);
//   FirebaseMessaging.onMessage.listen(_firebaseMessagingForgroundHandler);

//   if (kIsWeb) {
//     await Firebase.initializeApp(
//         options: FirebaseOptions(
//             apiKey: "AIzaSyB_ic561lFl7k5i27nBAe6kammJrm6HHHA",
//             authDomain: "british-body-admin.firebaseapp.com",
//             projectId: "british-body-admin",
//             storageBucket: "british-body-admin.firebasestorage.app",
//             messagingSenderId: "528586385117",
//             appId: "1:528586385117:web:673bc1552ac4605be99d34",
//             measurementId: "G-6XTCNC81HG"));
//   } else {
//     await Firebase.initializeApp(
//       options: DefaultFirebaseOptions.currentPlatform,
//     );
//   }

//   await FirebaseMessaging.instance.requestPermission(
//     alert: true,
//     announcement: false,
//     badge: true,
//     carPlay: false,
//     criticalAlert: false,
//     provisional: false,
//     sound: true,
//   );
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
//       FlutterLocalNotificationsPlugin();
//   const AndroidInitializationSettings initializationSettingsAndroid =
//       AndroidInitializationSettings('app_icon');
//   final DarwinInitializationSettings initializationSettingsDarwin =
//       DarwinInitializationSettings(
//     requestSoundPermission: true,
//     requestBadgePermission: false,
//     requestAlertPermission: true,
//   );

//   final InitializationSettings initializationSettings = InitializationSettings(
//     android: initializationSettingsAndroid,
//     iOS: initializationSettingsDarwin,
//   );
//   await flutterLocalNotificationsPlugin.initialize(initializationSettings,
//       onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
//   await flutterLocalNotificationsPlugin
//       .resolvePlatformSpecificImplementation<
//               IOSFlutterLocalNotificationsPlugin>()
//       ?.requestPermissions(
//         alert: true,
//         badge: true,
//         sound: true,
//       );
//   if (!kIsWeb) {
//     try {
//       await AppBadgePlus.updateBadge(0);
//     } catch (e) {
//       if (kDebugMode) {
//         print(e);
//       }
//     }
//   }

//   await flutterLocalNotificationsPlugin.initialize(initializationSettings,
//       onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);

//   await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
//       alert: true, badge: true, sound: true);

//   await flutterLocalNotificationsPlugin.initialize(
//     initializationSettings,
//     onDidReceiveNotificationResponse:
//         (NotificationResponse notificationResponse) async {},
//     onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
//   );

//   SharedPreferences preference = await SharedPreferences.getInstance();

//   logedin = preference.getBool('logedin') ?? false;
//   runApp(
//     // MultiProvider(
//     // 	 providers: [
//     // 	 	 ChangeNotifierProvider(create: (_) => Listprovider()),
//     // 	 ],
//     // child:
//     const MyApp(),
//     // ),
//   );
// }

// void onDidReceiveNotificationResponse(
//     NotificationResponse notificationResponse) async {
//   final String? payload = notificationResponse.payload;
//   if (notificationResponse.payload != null) {
//     debugPrint('notification payload: $payload');
//   }
//   await navigatorKey.currentState?.push(
//     MaterialPageRoute<void>(builder: (context) => Navigation(email: email)), // Fixed Navigation constructor call
//   );
// }

// final DarwinInitializationSettings initializationSettingsDarwin =
//     DarwinInitializationSettings(
//   requestSoundPermission: true,
//   notificationCategories: [
//     DarwinNotificationCategory(
//       'demoCategory',
//       actions: <DarwinNotificationAction>[
//         DarwinNotificationAction.plain('id_1', 'Action 1'),
//         DarwinNotificationAction.plain(
//           'id_2',
//           'Action 2',
//           options: <DarwinNotificationActionOption>{
//             DarwinNotificationActionOption.destructive,
//           },
//         ),
//         DarwinNotificationAction.plain(
//           'id_3',
//           'Action 3',
//           options: <DarwinNotificationActionOption>{
//             DarwinNotificationActionOption.foreground,
//           },
//         ),
//       ],
//       options: <DarwinNotificationCategoryOption>{
//         DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
//       },
//     )
//   ],
// );

// @pragma('vm:entry-point')
// void notificationTapBackground(NotificationResponse notificationResponse) {}

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   void _handeMessageOpenTerminated(RemoteMessage message) {
//     _handleMessageOprn(message);
//   }

//   void _handeMessageOpenBackground(RemoteMessage message) {
//     _handleMessageOprn(message);
//   }

//   static const MethodChannel _channel = MethodChannel('hama.com/channel_test');
//   Map<String, String> channelMap = {
//     "id": "Notifications",
//     "name": "Notifications",
//     "description": "Notifications",
//     "icon": "notification_icon",
//   };

//   void _createNewChannel() async {
//     try {
//       await _channel.invokeMethod('createNotificationChannel', channelMap);
//     } on PlatformException catch (e) {
//       if (kDebugMode) {
//         print(e);
//       }
//     }
//   }

//   Future<void> setupInteractedMessage() async {
//     RemoteMessage? initialMessage =
//         await FirebaseMessaging.instance.getInitialMessage();
//     if (initialMessage != null) {
//       _handeMessageOpenTerminated(initialMessage);
//     }
//     FirebaseMessaging.onMessageOpenedApp.listen(_handeMessageOpenBackground);
//   }

//   @override
//   void initState() {
//     super.initState();

//     if (!kIsWeb && Platform.isAndroid) {
//       _createNewChannel();
//     }
//     islogeding();
//     setupInteractedMessage();
    
//     // Call the permission handler after the initial build has completed
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       _handlePermission(context); 
//     });
//   }

//   final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

//   // --- MODIFIED _handlePermission FUNCTION ---
//   Future<bool> _handlePermission(BuildContext context) async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     // Test if location services are enabled.
//     serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return false;
//     }
    
//     // Check current permission status
//     permission = await _geolocatorPlatform.checkPermission();
    
//     if (permission == LocationPermission.denied) {
//       // Request general location permission (When In Use)
//       permission = await _geolocatorPlatform.requestPermission();
//     }

//     // Check if we have 'Always' permission (needed for background tracking)
//     // This check is required for Android 10+ flow.
//     if (permission != LocationPermission.always) {
//         // Show the Prominent Disclosure Dialog before asking for "Allow all the time"
//         bool consented = await showBackgroundLocationDisclosure(context);
        
//         if (consented) {
//           // If the user consents, request the 'Always' permission again.
//           // This will trigger the system prompt for "Allow all the time" or redirect to settings.
//           permission = await _geolocatorPlatform.requestPermission();
//         } else {
//           // User declined the prominent disclosure
//           return false;
//         }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       // Permissions are denied forever, maybe prompt user to open app settings.
//       return false;
//     }

//     // Ensure we have 'Always' permission for background functionality
//     return permission == LocationPermission.always;
//   }
//   // ------------------------------------------

//   void _handleMessageOprn(RemoteMessage message) {
//     _handeMessageOpenBackground(message);
//     // ... (Your original commented logic remains here)
//   }

//   islogeding() async {
//     final SharedPreferences preference = await SharedPreferences.getInstance();

//     logedin = preference.getBool('logedin') ?? false;
//     email = preference.getString('email') ?? '';
//     city = preference.getString('city') ?? '';
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Sizer(
//       builder: (context, orientation, deviceType) {
//         return UpgradeAlert(
//           dialogStyle: UpgradeDialogStyle.cupertino,
//           child: MaterialApp(
//             navigatorKey: navigatorKey,
//             supportedLocales: const [
//               Locale('en', 'US'),
//             ],
//             debugShowCheckedModeBanner: false,
//             theme: ThemeData(
//               fontFamily: 'kurdish',
//               colorScheme:
//                   ColorScheme.fromSeed(seedColor: Material1.primaryColor),
//               useMaterial3: true,
//             ),
//             initialRoute: '/',
//               routes: {
//           '/': (context) => logedin
//               ? UserSessionManager(
//                   email: email,
//                   child: Navigation(email: email),
//                 )
//               : const LoginScreen(),
//       },
//           ),
//         );
//       },
//     );
//   }
// }
// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:developer';
import 'dart:io' show Platform;

import 'package:app_badge_plus/app_badge_plus.dart';
import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/auth/login_screen.dart';
import 'package:british_body_admin/screens/dashborad.dart/changingworkerphone/changingworkerphone.dart';
import 'package:british_body_admin/screens/navigator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:upgrader/upgrader.dart';

import 'firebase_options.dart';

Future<void> _firebaseMessaginBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();

  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> notificationTitles =
      prefs.getStringList('notificationTitles') ?? [];
  List<String> notificationBodies =
      prefs.getStringList('notificationBodies') ?? [];

  notificationTitles.add(message.notification?.title ?? 'British Body Admin');
  notificationBodies.add(message.notification?.body ?? 'Notification');

  await prefs.setStringList('notificationTitles', notificationTitles);
  await prefs.setStringList('notificationBodies', notificationBodies);

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    message.notification?.android?.channelId ?? 'daily_channel_id',
    'Foreground Notifications',
    channelDescription: 'Notifications shown when the app is in the foreground',
    importance: Importance.high,
    priority: Priority.high,
  );

  NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

  flutterLocalNotificationsPlugin.show(
    message.data.hashCode,
    message.notification?.title,
    message.notification?.body,
    notificationDetails,
  );
}

Future<void> _firebaseMessagingForgroundHandler(RemoteMessage message) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  List<String> notificationTitles =
      prefs.getStringList('notificationTitles') ?? [];
  List<String> notificationBodies =
      prefs.getStringList('notificationBodies') ?? [];

  notificationTitles.add(message.notification?.title ?? 'British Body Admin');
  notificationBodies.add(message.notification?.body ?? 'Notification');

  await prefs.setStringList('notificationTitles', notificationTitles);
  await prefs.setStringList('notificationBodies', notificationBodies);

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    message.notification?.android?.channelId ?? 'daily_channel_id',
    'Foreground Notifications',
    channelDescription: 'Notifications shown when the app is in the foreground',
    importance: Importance.high,
    priority: Priority.high,
  );

  NotificationDetails notificationDetails =
      NotificationDetails(android: androidDetails);

  flutterLocalNotificationsPlugin.show(
    message.data.hashCode,
    message.notification?.title,
    message.notification?.body,
    notificationDetails,
  );
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

bool logedin = true;
String email = '';
String city = '';
@pragma('vm:entry-point')

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessaginBackgroundHandler);
  FirebaseMessaging.onMessage.listen(_firebaseMessagingForgroundHandler);

  if (kIsWeb) {
    await Firebase.initializeApp(
        options: FirebaseOptions(
            apiKey: "AIzaSyB_ic561lFl7k5i27nBAe6kammJrm6HHHA",
            authDomain: "british-body-admin.firebaseapp.com",
            projectId: "british-body-admin",
            storageBucket: "british-body-admin.firebasestorage.app",
            messagingSenderId: "528586385117",
            appId: "1:528586385117:web:673bc1552ac4605be99d34",
            measurementId: "G-6XTCNC81HG"));
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('app_icon');
  final DarwinInitializationSettings initializationSettingsDarwin =
      DarwinInitializationSettings(
    requestSoundPermission: true,
    requestBadgePermission: false,
    requestAlertPermission: true,
  );

  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsDarwin,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
      ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
  if (!kIsWeb) {
    try {
      await AppBadgePlus.updateBadge(0);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  await flutterLocalNotificationsPlugin.initialize(initializationSettings,
      onDidReceiveNotificationResponse: onDidReceiveNotificationResponse);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse:
        (NotificationResponse notificationResponse) async {},
    onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
  );

  SharedPreferences preference = await SharedPreferences.getInstance();

  logedin = preference.getBool('logedin') ?? false;
  runApp(
    const MyApp(),
  );
}

void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse) async {
  final String? payload = notificationResponse.payload;
  if (notificationResponse.payload != null) {
    debugPrint('notification payload: $payload');
  }
  await navigatorKey.currentState?.push(
    MaterialPageRoute<void>(builder: (context) => Navigation(email: email)),
  );
}

final DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
  requestSoundPermission: true,
  notificationCategories: [
    DarwinNotificationCategory(
      'demoCategory',
      actions: <DarwinNotificationAction>[
        DarwinNotificationAction.plain('id_1', 'Action 1'),
        DarwinNotificationAction.plain(
          'id_2',
          'Action 2',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.destructive,
          },
        ),
        DarwinNotificationAction.plain(
          'id_3',
          'Action 3',
          options: <DarwinNotificationActionOption>{
            DarwinNotificationActionOption.foreground,
          },
        ),
      ],
      options: <DarwinNotificationCategoryOption>{
        DarwinNotificationCategoryOption.hiddenPreviewShowTitle,
      },
    )
  ],
);

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  void _handeMessageOpenTerminated(RemoteMessage message) {
    _handleMessageOprn(message);
  }

  void _handeMessageOpenBackground(RemoteMessage message) {
    _handleMessageOprn(message);
  }

  static const MethodChannel _channel = MethodChannel('hama.com/channel_test');
  Map<String, String> channelMap = {
    "id": "Notifications",
    "name": "Notifications",
    "description": "Notifications",
    "icon": "notification_icon",
  };

  void _createNewChannel() async {
    try {
      await _channel.invokeMethod('createNotificationChannel', channelMap);
    } on PlatformException catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> setupInteractedMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();
    if (initialMessage != null) {
      _handeMessageOpenTerminated(initialMessage);
    }
    FirebaseMessaging.onMessageOpenedApp.listen(_handeMessageOpenBackground);
  }

  @override
  void initState() {
    super.initState();

    if (!kIsWeb && Platform.isAndroid) {
      _createNewChannel();
    }
    islogeding();
    setupInteractedMessage();
    
    // ❌ لابردنی بانگکردنی پێرمشنی لۆکەیشن لێرەوە
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _handlePermission(context); 
    // });
  }

  void _handleMessageOprn(RemoteMessage message) {
    _handeMessageOpenBackground(message);
  }

  islogeding() async {
    final SharedPreferences preference = await SharedPreferences.getInstance();

    logedin = preference.getBool('logedin') ?? false;
    email = preference.getString('email') ?? '';
    city = preference.getString('city') ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return UpgradeAlert(
          dialogStyle: UpgradeDialogStyle.cupertino,
          child: MaterialApp(
            navigatorKey: navigatorKey,
            supportedLocales: const [
              Locale('en', 'US'),
            ],
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'kurdish',
              colorScheme:
                  ColorScheme.fromSeed(seedColor: Material1.primaryColor),
              useMaterial3: true,
            ),
            initialRoute: '/',
            routes: {
              '/': (context) => logedin
                  ? UserSessionManager(
                      email: email,
                      child: Navigation(email: email),
                    )
                  : const LoginScreen(),
            },
          ),
        );
      },
    );
  }
}