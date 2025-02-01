// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'package:british_body_admin/screens/auth/login.dart';
import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/navigator.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:map_location_picker/map_location_picker.dart';
// import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
// import 'dart:io' show Platform;
// ignore: depend_on_referenced_packages
import 'package:firebase_core/firebase_core.dart';
import 'package:upgrader/upgrader.dart';
import 'firebase_options.dart';


Future<void> _firebaseMessaginBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}

void _firebaseMessagingForgroundHandler(RemoteMessage message) {
  if (message.notification != null) {}
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

bool logedin = true;
String email = '';
String city = '';
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessaginBackgroundHandler);
  FirebaseMessaging.onMessage.listen(_firebaseMessagingForgroundHandler);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await FirebaseMessaging.instance.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  // try {
  //   await AppBadgePlus.updateBadge(0);
  // } catch (e) {
  //   if (kDebugMode) {
  //     print(e);
  //   }
  // }

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
      alert: true, badge: true, sound: true);

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

  // static const MethodChannel _channel = MethodChannel('hama.com/channel_test');
  // Map<String, String> channelMap = {
  //   "id": "Notifications",
  //   "name": "Notifications",
  //   "description": "Notifications",
  //   "icon": "notification_icon",
  // };

  // void _createNewChannel() async {
  //   try {
  //     await _channel.invokeMethod('createNotificationChannel', channelMap);
  //   } on PlatformException catch (e) {
  //     if (kDebugMode) {
  //       print(e);
  //     }
  //   }
  // }

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
    // locationsfunction();

    // if (Platform.isAndroid) {
    //   _createNewChannel();
    // }
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
              Locale('ar', 'IQ'),
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
                return logedin ?  Navigation(email:email) : const Login();
              }
            },
          ),
        );
      },
    );
  }
}
