// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:developer';
import 'package:british_body_admin/screens/auth/login.dart';
import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/navigator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:map_location_picker/map_location_picker.dart';
// import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'dart:io' show Platform;
// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'package:upgrader/upgrader.dart';
import 'firebase_options.dart';
import 'package:flutter_isolate/flutter_isolate.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:app_badge_plus/app_badge_plus.dart';

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
Future<void> settinglocalnotifications(String notification) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Baghdad'));
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  SharedPreferences preference = await SharedPreferences.getInstance();
  email = preference.getString('email') ?? '';
  if (email.isEmpty) {
    return;
  }
  bool isweekly = false;
  bool ismonthly = false;

  FirebaseFirestore.instance
      .collection('user')
      .doc(email)
      .collection('tasks')
      .where('isnotificationset', isEqualTo: false)
      .get()
      .then((value) async {
    for (var doc in value.docs) {
      try {
        isweekly = doc['isweekly'];
      } catch (e) {
        isweekly = false;
      }
      try {
        ismonthly = doc['ismonthly'];
      } catch (e) {
        ismonthly = false;
      }

      if (ismonthly) {
        const AndroidNotificationDetails androidDetails =
            AndroidNotificationDetails(
          'channel_default1',
          'Monthly Notifications',
          channelDescription: 'Sends notifications at a fixed time every month',
          importance: Importance.high,
          priority: Priority.high,
        );

        const NotificationDetails notificationDetails =
            NotificationDetails(android: androidDetails);

        final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
        tz.TZDateTime scheduledDate = tz.TZDateTime(
            tz.local,
            now.year,
            now.month,
            doc['start'].toDate().day,
            doc['start'].toDate().hour,
            (doc['start'].toDate().minute - 10));

        if (scheduledDate.isBefore(now)) {
          scheduledDate = tz.TZDateTime(
              tz.local,
              now.year,
              now.month + 1,
              int.parse(doc['dayofthemonth']),
              doc['start'].toDate().hour,
              (doc['start'].toDate().minute - 10));
        }

        await flutterLocalNotificationsPlugin.zonedSchedule(
          (doc['time'].seconds + now.day).toInt(),
          doc['name'],
          "١٠ خولەک یان کەمتری ماوە دەست پێبکات ${doc['name']} ئەرکی",
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
        );
      }
      if (isweekly) {
        List<int> days = List<int>.from(doc['weekdays']);
        for (var day in days) {
          const AndroidNotificationDetails androidDetails =
              AndroidNotificationDetails(
            'channel_default1',
            'Weekly Notifications',
            channelDescription:
                'Sends notifications at a fixed time every week',
            importance: Importance.high,
            priority: Priority.high,
          );

          const NotificationDetails notificationDetails =
              NotificationDetails(android: androidDetails);

          final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
          tz.TZDateTime scheduledDate = tz.TZDateTime(
              tz.local,
              now.year,
              now.month,
              day,
              doc['start'].toDate().hour,
              (doc['start'].toDate().minute - 10));

          if (scheduledDate.isBefore(now)) {
            scheduledDate = scheduledDate.add(Duration(days: 7));
          }

          await flutterLocalNotificationsPlugin.zonedSchedule(
            (doc['time'].seconds + day).toInt(),
            doc['name'],
            "١٠ خولەک یان کەمتری ماوە دەست پێبکات ${doc['name']} ئەرکی",
            scheduledDate,
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          );
        }
      }
      if (doc['isdaily']) {
        const AndroidNotificationDetails androidDetails =
            AndroidNotificationDetails(
          'channel_default1',
          'Daily Notifications',
          channelDescription: 'Sends notifications at a fixed time every day',
          importance: Importance.high,
          priority: Priority.high,
        );

        const NotificationDetails notificationDetails =
            NotificationDetails(android: androidDetails);

        final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
        tz.TZDateTime scheduledDate = tz.TZDateTime(
            tz.local,
            now.year,
            now.month,
            now.day,
            doc['start'].toDate().hour,
            (doc['start'].toDate().minute - 10));

        if (scheduledDate.isBefore(now)) {
          scheduledDate = scheduledDate.add(Duration(days: 1));
        }

        await flutterLocalNotificationsPlugin.zonedSchedule(
          (doc['time'].seconds + 72).toInt(),
          doc['name'],
          "١٠ خولەک یان کەمتری ماوە دەست پێبکات ${doc['name']} ئەرکی",
          scheduledDate,
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }

      if (!(ismonthly || isweekly || doc['isdaily'])) {
        for (var i = 0; i < doc['startnotificationdates'].length; i++) {
          if (doc['startnotificationdates'][i]
              .toDate()
              .isBefore(DateTime.now())) {
            continue;
          }
          flutterLocalNotificationsPlugin.zonedSchedule(
            (doc['time'].seconds + i).toInt(),
            doc['name'],
            "١٠ خولەک یان کەمتری ماوە دەست پێبکات ${doc['name']} ئەرکی",
            tz.TZDateTime(
                tz.local,
                doc['startnotificationdates'][i].toDate().year,
                doc['startnotificationdates'][i].toDate().month,
                doc['startnotificationdates'][i].toDate().day,
                doc['startnotificationdates'][i].toDate().hour,
                doc['startnotificationdates'][i].toDate().minute),
            const NotificationDetails(
                android: AndroidNotificationDetails(
                    'channel_default1', 'your channel name',
                    channelDescription: 'your channel description')),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
        for (var i = 0; i < doc['endnotificationdates'].length; i++) {
          if (doc['startnotificationdates'][i]
              .toDate()
              .isBefore(DateTime.now())) {
            continue;
          }
          flutterLocalNotificationsPlugin.zonedSchedule(
            (doc['time'].seconds + doc['startnotificationdates'].length + 1 + i)
                .toInt(),
            doc['name'],
            "١٠ خولەک یان کەمتری ماوە کۆتایی پێبێت ${doc['name']} ئەرکی",
            tz.TZDateTime(
                tz.local,
                doc['endnotificationdates'][i].toDate().year,
                doc['endnotificationdates'][i].toDate().month,
                doc['endnotificationdates'][i].toDate().day,
                doc['endnotificationdates'][i].toDate().hour,
                doc['endnotificationdates'][i].toDate().minute),
            const NotificationDetails(
                android: AndroidNotificationDetails(
                    'your channel id', 'your channel name',
                    channelDescription: 'your channel description')),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
      }
    }
  }).then((value) {
    FirebaseFirestore.instance
        .collection('user')
        .doc(email)
        .collection('tasks')
        .where('isnotificationset', isEqualTo: false)
        .get()
        .then((value) {
      for (var doc in value.docs) {
        FirebaseFirestore.instance
            .collection('user')
            .doc(email)
            .collection('tasks')
            .doc(doc.id)
            .update({'isnotificationset': true});
      }
    });
  });
  FirebaseFirestore.instance
      .collection('user')
      .doc(email)
      .collection('tasks')
      .where('isdaily', isEqualTo: true)
      .where('end', isGreaterThanOrEqualTo: DateTime.now())
      .get()
      .then((value) {
    for (var snapshot in value.docs) {
      DateTime? lastupdate;
      DateTime? lastsystemupdate;
      try {
        lastsystemupdate = snapshot.data()['lastsystemupdate'].toDate();
      } catch (e) {
        lastsystemupdate = null;
      }
      try {
        lastupdate = snapshot.data()['lastupdate'].toDate();
      } catch (e) {
        lastupdate = null;
      }
      if (lastsystemupdate != null) {
        if (lastsystemupdate.day != DateTime.now().day) {
          if (lastupdate != null) {
            if (lastupdate.day != DateTime.now().day &&
                snapshot.data()['status'] != 'pending') {
              snapshot.reference.update(
                  {'status': 'pending', 'lastsystemupdate': DateTime.now()});
            }
          }
        }
      } else {
        if (lastupdate != null) {
          if (lastupdate.day != DateTime.now().day &&
              snapshot.data()['status'] != 'pending') {
            snapshot.reference.update(
                {'status': 'pending', 'lastsystemupdate': DateTime.now()});
          }
        }
      }
    }
  });
  FirebaseFirestore.instance
      .collection('user')
      .doc(email)
      .collection('tasks')
      .where('isweekly', isEqualTo: true)
      .where('end', isGreaterThanOrEqualTo: DateTime.now())
      .get()
      .then((value) {
    for (var snapshot in value.docs) {
      if (snapshot.data()['weekdays'].contains(DateTime.now().weekday)) {
        DateTime? lastupdate;
        DateTime? lastsystemupdate;
        try {
          lastsystemupdate = snapshot.data()['lastsystemupdate'].toDate();
        } catch (e) {
          lastsystemupdate = null;
        }
        try {
          lastupdate = snapshot.data()['lastupdate'].toDate();
        } catch (e) {
          lastupdate = null;
        }
        log(lastupdate.toString());
        log(lastsystemupdate.toString());
        if (lastsystemupdate != null) {
          if (lastsystemupdate.day != DateTime.now().day) {
            if (lastupdate != null) {
              if (lastupdate.day != DateTime.now().day &&
                  snapshot.data()['status'] != 'pending') {
                snapshot.reference.update(
                    {'status': 'pending', 'lastsystemupdate': DateTime.now()});
              }
            }
          }
        } else {
          if (lastupdate != null) {
            if (lastupdate.day != DateTime.now().day &&
                snapshot.data()['status'] != 'pending') {
              snapshot.reference.update(
                  {'status': 'pending', 'lastsystemupdate': DateTime.now()});
            }
          }
        }
      }
    }
  });
  FirebaseFirestore.instance
      .collection('user')
      .doc(email)
      .collection('tasks')
      .where('ismonthly', isEqualTo: true)
      .where('end', isGreaterThanOrEqualTo: DateTime.now())
      .get()
      .then((value) {
    for (var snapshot in value.docs) {
      DateTime? lastupdate;
      DateTime? lastsystemupdate;
      if (int.parse(snapshot.data()['dayofthemonth']) != DateTime.now().day) {
        return;
      }
      try {
        lastsystemupdate = snapshot.data()['lastsystemupdate'].toDate();
      } catch (e) {
        lastsystemupdate = null;
      }
      try {
        lastupdate = snapshot.data()['lastupdate'].toDate();
      } catch (e) {
        lastupdate = null;
      }
      if (lastsystemupdate != null) {
        if (lastsystemupdate.day != DateTime.now().day) {
          if (lastupdate != null) {
            if (lastupdate.day != DateTime.now().day &&
                snapshot.data()['status'] != 'pending') {
              snapshot.reference.update(
                  {'status': 'pending', 'lastsystemupdate': DateTime.now()});
            }
          }
        }
      } else {
        if (lastupdate != null) {
          if (lastupdate.day != DateTime.now().day &&
              snapshot.data()['status'] != 'pending') {
            snapshot.reference.update(
                {'status': 'pending', 'lastsystemupdate': DateTime.now()});
          }
        }
      }
    }
  });
}

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
  }else{
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
    // MultiProvider(
    //   providers: [
    //     ChangeNotifierProvider(create: (_) => Listprovider()),
    //   ],
    // child:
    const MyApp(),
    // ),
  );
}

void onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse) async {
  final String? payload = notificationResponse.payload;
  if (notificationResponse.payload != null) {
    debugPrint('notification payload: $payload');
  }
  await navigatorKey.currentState?.push(
    MaterialPageRoute<void>(builder: (context) => Navigator()),
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
    // final FlutterLocalization localization = FlutterLocalization.instance;

    // localization.init(
    //   mapLocales: [
    //     const MapLocale('en', AppLocale.en),
    //     const MapLocale('ar', AppLocale.ar),
    //     const MapLocale('fa', AppLocale.fa),
    //   ],
    //   initLanguageCode: 'fa',
    // );
    // localization.onTranslatedLanguage = _onTranslatedLanguage;
    // localization.translate('fa');
  }

  // void _onTranslatedLanguage(Locale? locale) {
  //   setState(() {});
  // }

  @override
  void initState() {
    super.initState();
    // FlutterIsolate.spawn(settinglocalnotifications, "hello world");
    if (!kIsWeb) {
  FlutterIsolate.spawn(settinglocalnotifications, "hello world");
}
    // locationsfunction();

   if (!kIsWeb && Platform.isAndroid) {
  _createNewChannel();
}
    islogeding();
    setupInteractedMessage();
    _handlePermission();
  }

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  Future<bool> _handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    permission = await _geolocatorPlatform.requestPermission();

    // Test if location services are enabled.
    serviceEnabled = await _geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await _geolocatorPlatform.checkPermission();
    if (permission == LocationPermission.denied) {
      if (permission == LocationPermission.denied) {
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  void _handleMessageOprn(RemoteMessage message) {
    _handeMessageOpenBackground(message);
    // if (message.data['message'] == 'chat') {
    //   String documentPath = message.data['path'];
    //   DocumentReference<Map<String, dynamic>> documentReference =
    //       FirebaseFirestore.instance.doc(documentPath);
    //   navigatorKey.currentState?.push(
    //     MaterialPageRoute(
    //       builder: (context) => Messaging(
    //           data: documentReference,
    //           order: Ordermodel.fromMap({
    //             'restname': message.data['restname'],
    //             'customername': message.data['customername'],
    //             'email': message.data['email'],
    //             'url': message.data['url'],
    //             'token': message.data['token'],
    //           })),
    //     ),
    //   );
    // } else {
    //   navigatorKey.currentState?.push(
    //     MaterialPageRoute(builder: (context) {
    //       islogeding();
    //       return logedin ? const Home() : const Login();
    //     }),
    //   );
    // }
  }

  islogeding() async {
    final SharedPreferences preference = await SharedPreferences.getInstance();

    logedin = preference.getBool('logedin') ?? false;
    email = preference.getString('email') ?? '';
    city = preference.getString('city') ?? '';
  }

  // locationsfunction() async {
  //   final SharedPreferences preference = await SharedPreferences.getInstance();

  //   List<String> locations = preference.getStringList('locations') ?? [];
  //   context.read<Listprovider>().setinglocations(locations);
  //   String location = preference.getString('location') ?? locations.first;
  //   context.read<Listprovider>().setinglocation(location);
  // }

  @override
  Widget build(BuildContext context) {
    // final FlutterLocalization localization = FlutterLocalization.instance;

    return Sizer(
      builder: (context, orientation, deviceType) {
        return UpgradeAlert(
          dialogStyle: UpgradeDialogStyle.cupertino,
          child: MaterialApp(
            navigatorKey: navigatorKey,
            supportedLocales: const [
              Locale('en', 'US'),
            ],
            // localizationsDelegates: localization.localizationsDelegates,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              fontFamily: 'rabar',
              colorScheme:
                  ColorScheme.fromSeed(seedColor: Material1.primaryColor),
              useMaterial3: true,
            ),
            initialRoute: '/',
            routes: {
              '/': (context) {
                islogeding();
                return logedin ? Navigation(email: email) : const Login();
              }
            },
          ),
        );
      },
    );
  }
}
