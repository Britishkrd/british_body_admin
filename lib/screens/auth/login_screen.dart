// import 'dart:io';

// import 'package:british_body_admin/material/materials.dart';
// import 'package:british_body_admin/ok.dart';
// import 'package:british_body_admin/screens/auth/forgetpassword.dart';
// import 'package:british_body_admin/screens/auth/tester_home_screen.dart';
// import 'package:british_body_admin/screens/navigator.dart';
// import 'package:british_body_admin/shared/confirm_dialog.dart';
// import 'package:british_body_admin/shared/custom_email.dart';
// import 'package:british_body_admin/shared/custom_password.dart';
// import 'package:british_body_admin/sharedprefrences/sharedprefernences.dart';
// import 'package:british_body_admin/utils/color.dart';
// import 'package:british_body_admin/utils/textstyle.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:device_info_plus/device_info_plus.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:map_location_picker/map_location_picker.dart';
// import 'package:sizer/sizer.dart';
// import 'package:url_launcher/url_launcher.dart';

// class LoginScreen extends StatefulWidget {
//   const LoginScreen({super.key});

//   @override
//   State<LoginScreen> createState() => _LoginScreenState();
// }

// class _LoginScreenState extends State<LoginScreen> {
//   TextEditingController emailcontroller = TextEditingController();
//   TextEditingController passwordcontroller = TextEditingController();
//   final GeolocatorPlatform geolocatorPlatform = GeolocatorPlatform.instance;
//   double latitude = 0.0;
//   double longtitude = 0.0;
//   bool _obscurePassword = true;
  
//   bool _hasShownLocationDisclosure = false; // ADD THIS

//   @override
//   void initState() {
//     super.initState();
//   }

//   // UPDATED: Show disclosure first, then request permission
//   Future<void> getlocation() async {
//     // Show prominent disclosure dialog first
//     if (!_hasShownLocationDisclosure) {
//       bool userAccepted = await LocationDisclosureDialog(context: context).show();
//       _hasShownLocationDisclosure = true;
      
//       if (!userAccepted) {
//         // User declined - still allow login but location might be 0,0
//         return;
//       }
//     }
    
//     final hasPermission = await handlePermission();
//     if (hasPermission) {
//       getCurrentPosition();
//     }
//   }

  
//   Future<void> getCurrentPosition() async {
//     try {
//       final position = await geolocatorPlatform.getCurrentPosition();
//       latitude = position.latitude;
//       longtitude = position.longitude;
//     } catch (e) {
//       // Handle error - keep default 0,0
//       print('Error getting location: $e');
//     }
//   }

//   // UPDATED: Better permission handling
//   Future<bool> handlePermission() async {
//     bool serviceEnabled;
//     LocationPermission permission;

//     // Check if location services are enabled
//     serviceEnabled = await geolocatorPlatform.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return false;
//     }

//     // Check current permission status
//     permission = await geolocatorPlatform.checkPermission();
    
//     if (permission == LocationPermission.denied) {
//       // Request permission
//       permission = await geolocatorPlatform.requestPermission();
//       if (permission == LocationPermission.denied) {
//         return false;
//       }
//     }

//     if (permission == LocationPermission.deniedForever) {
//       return false;
//     }

//     return true;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: () {
//         FocusScope.of(context).unfocus();
//       },
//       child: Scaffold(
//         backgroundColor: backgroundColor,
//         body: Directionality(
//           textDirection: TextDirection.rtl, // RTL for Kurdish
//           child: Center(
//             child: SingleChildScrollView(
//               padding: EdgeInsets.symmetric(horizontal: 10),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   SizedBox(
//                     height: 110,
//                     width: 110,
//                     child: Image.asset('lib/assets/logo.png'),
//                   ),
//                   SizedBox(height: 3.h),
//                   Text(
//                     'بەخێربێیت دووبارە',
//                     textAlign: TextAlign.center,
//                     style: kurdishTextStyle(
//                       18,
//                       blackColor,
//                     ),
//                   ),
//                   SizedBox(height: 1.h),
//                   Text(
//                     'چوونەژوورەوە بکە بۆ ناو ئەکاونتەکەت!',
//                     textAlign: TextAlign.center,
//                     style: kurdishTextStyle(
//                       16,
//                       Colors.grey[600]!,
//                     ),
//                   ),
//                   SizedBox(height: 4.h),
//                   Container(
//                     padding: EdgeInsets.all(16.sp),
//                     decoration: BoxDecoration(
//                       color: whiteColor,
//                       borderRadius: BorderRadius.circular(12.0),
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         CustomEmailField(controller: emailcontroller),
//                         Divider(height: 1, color: Colors.grey[300]),
//                         CustomPasswordField(
//                           controller: passwordcontroller,
//                           isObscurePassword: _obscurePassword,
//                           onPressed: () {
//                             setState(() {
//                               _obscurePassword = !_obscurePassword;
//                             });
//                           },
//                         ),
//                         SizedBox(height: 2.h),
//                         Align(
//                           alignment:
//                               Alignment.centerLeft, // Align to left for RTL
//                           child: TextButton(
//                             onPressed: () {
//                               Navigator.push(context,
//                                   MaterialPageRoute(builder: (context) {
//                                 return const Forgetpassword();
//                               }));
//                             },
//                             style: TextButton.styleFrom(
//                               padding: EdgeInsets.zero,
//                               minimumSize: Size.zero,
//                               tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                             ),
//                             child: Text(
//                               'وشەی نهێنیت لەبیرکردووە ؟',
//                               style: TextStyle(
//                                   color: Material1.primaryColor,
//                                   fontSize: 14.sp),
//                             ),
//                           ),
//                         ),
//                         SizedBox(height: 3.h),
                    
// ElevatedButton(
//   onPressed: () async {
//      // UPDATED: Request location permission with disclosure before login
//                             await getlocation();
                            
//     String? email = emailcontroller.text.toLowerCase();
//     String? password = passwordcontroller.text;
//     UserCredential? userCredential;
    
//     try {
//       userCredential = await FirebaseAuth.instance
//           .signInWithCredential(
//               EmailAuthProvider.credential(
//                   email: email, password: password));
//     } catch (e) {
//       await LoginConfirmationDialog(
//               context: context,
//               content: 'ئیمێڵ یان وشەی نهێنی هەڵەیە')
//           .show();
//       return;
//     }
    
//     FirebaseFirestore.instance
//         .collection('user')
//         .doc(email)
//         .get()
//         .then((value) async {
//       if (value.exists) {
//         if (value.data()?['password'] != password ||
//             userCredential?.user == null) {
//           Material1.showdialog(
//               context, 'هەڵە', 'وشەی نهێنی هەڵەیە', [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: Text('باشە',
//                   style: TextStyle(
//                       color: Material1.primaryColor)),
//             )
//           ]);
//           return;
//         }
        
//         if (value.data()?['email'] != email) {
//           Material1.showdialog(
//               context, 'هەڵە', 'ئیمێڵ هەڵەیە', [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(context);
//               },
//               child: Text('باشە',
//                   style: TextStyle(
//                       color: Material1.primaryColor)),
//             )
//           ]);
//           return;
//         }
        
//         // Check user permissions first
//         List<dynamic> userPermissions = value.data()?['permissions'] ?? [];
//         bool isTester = userPermissions.contains('isTester');
        
//         // Only check device ID if user is NOT a tester
//        // Only handle device ID for NON-testers
// if (!isTester) {
//   String deviceid = await getDeviceId();

//   // Block login if device ID doesn't match (and it's not empty)
//   if ((value.data()?['deviceid'] ?? '') != '' &&
//       value.data()?['deviceid'] != deviceid) {
//     await LoginConfirmationDialog(
//       context: context,
//       content: 'ناتوانیت لەم ئامێرە چوونەژوورەوە بکەیت',
//     ).show();
//     return;
//   }

//   // Only update deviceid for regular users (NOT testers)
//   if (deviceid.isNotEmpty) {
//     await value.reference.set(
//       {'deviceid': deviceid},
//       SetOptions(merge: true),
//     );
//   }
// } else {
//   // This is a TESTER
//   // Force deviceid to remain empty ("") in Firestore
//   await value.reference.set(
//     {'deviceid': ''},  // ← This is critical!
//     SetOptions(merge: true),
//   );
// }
//         String fcm = '';
//         try {
//           fcm = await FirebaseMessaging.instance
//                   .getToken() ??
//               '';
//         } catch (e) {
//           fcm = '';
//         }

//         value.reference.set({
//           'token': fcm,
//           'lat': latitude,
//           'long': longtitude
//         }, SetOptions(merge: true));
        
//         Sharedpreference.setuser(
//             value.data()?['name'] ?? '',
//             value.data()?['email'] ?? '',
//             value.data()?['location'] ?? '',
//             value.data()?['email'] ?? '',
//             value.data()?['salary'] ?? '0',
//             value.data()?['age'] ?? '',
//             latitude,
//             longtitude,
//             (value.data()?['worklat'] ?? 0.0).toDouble(),
//             (value.data()?['worklong'] ?? 0.0).toDouble(),
//             value.data()?['starthour'] ?? 0,
//             value.data()?['endhour'] ?? 0,
//             value.data()?['startmin'] ?? 0,
//             value.data()?['endmin'] ?? 0,
//             true,
//             fcm,
//             value.data()?['checkin'] ?? false,
//             value.data()?['permissions'] ?? [],
//             value.data()?['weekdays'] ?? []);
        
//         // Navigate based on user type
//         if (isTester) {
//           // Navigate to Tester Home Screen
//           Navigator.pushReplacement(context,
//               MaterialPageRoute(
//             builder: (context) {
//               return TesterHomeScreen(email: email);
//             },
//           ));
//         } else {
//           // Navigate to regular Navigation screen
//           Navigator.pushReplacement(context,
//               MaterialPageRoute(
//             builder: (context) {
//               return Navigation(email: email);
//             },
//           ));
//         }
//       } else {
//         LoginConfirmationDialog(
//                 context: context,
//                 content: 'ئیمێڵەکە هەڵەیە')
//             .show();
//       }
//     });
//   },
//   style: ElevatedButton.styleFrom(
//     backgroundColor: Material1.primaryColor,
//     foregroundColor: Colors.white,
//     padding: EdgeInsets.symmetric(vertical: 16.0),
//     shape: RoundedRectangleBorder(
//       borderRadius: BorderRadius.circular(8.0),
//     ),
//     textStyle: TextStyle(fontSize: 18.sp),
//   ),
//   child: Row(
//     mainAxisAlignment: MainAxisAlignment.center,
//     children: [
//       Text(
//         'چوونەژوورەوە',
//         style: kurdishTextStyle(14, whiteColor),
//       ),
//       SizedBox(width: 1.w),
//       Icon(Icons.login),
//     ],
//   ),
// )
//                       ],
//                     ),
//                   ),
//                   SizedBox(height: 5.h),
//                   RichText(
//                     textAlign: TextAlign.center,
//                     text: TextSpan(
//                       children: [
//                         TextSpan(
//                           text:
//                               'تەنها ئەکاونتە ئەدمینە ڕەسمییەکان\nدەتوانن چوونەژوورەوە بکەن ',
//                           style: kurdishTextStyle(14, Colors.grey[600]!),
//                         ),
//                         WidgetSpan(
//                           alignment:
//                               PlaceholderAlignment.middle, // Add this line
//                           child: InkWell(
//                             onTap: () async {
//                               if (!await launchUrl(
//                                   Uri.parse('https://www.britishbody.uk/'))) {
//                                 throw Exception('Could not launch ');
//                               }
//                             },
//                             child: Text('Britsh Body@',
//                                 style: kurdishTextStyle(14, foregroundColor)),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Future<String> getDeviceId() async {
//     var deviceInfo = DeviceInfoPlugin();

//     if (kIsWeb) {
//       return 'web-device';
//     } else if (Platform.isAndroid) {
//       AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
//       return androidInfo.id;
//     } else if (Platform.isIOS) {
//       IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
//       return iosInfo.identifierForVendor ?? iosInfo.localizedModel;
//     } else {
//       return 'unknown-device';
//     }
//   }
// }

import 'dart:io';

import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/ok.dart';
import 'package:british_body_admin/screens/auth/forgetpassword.dart';
import 'package:british_body_admin/screens/auth/tester_home_screen.dart';
import 'package:british_body_admin/screens/navigator.dart';
import 'package:british_body_admin/shared/confirm_dialog.dart';
import 'package:british_body_admin/shared/custom_email.dart';
import 'package:british_body_admin/shared/custom_password.dart';
import 'package:british_body_admin/sharedprefrences/sharedprefernences.dart';
import 'package:british_body_admin/utils/color.dart';
import 'package:british_body_admin/utils/textstyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  final GeolocatorPlatform geolocatorPlatform = GeolocatorPlatform.instance;
  double latitude = 0.0;
  double longtitude = 0.0;
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  // --- دایەلۆگی ئاگاداری لۆکەیشنی پشتەوە ---
  Future<bool> _showBackgroundLocationDisclosure(BuildContext context) async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('پێویستی بە شوێنی ئامێرەکەت هەیە 📍'),
          content: const Text(
            'بۆ بەڕێوەبردن و چاودێریکردنی چالاکی کارمەندان، پێویستمان بە دەستگەیشتن بە شوێنی ئامێرەکەت هەیە **هەموو کات**، تەنانەت کاتێک ئەپەکە داخراوە یان لە پشتەوەیە.\n\n'
            'ئەم داتایانە گرنگن بۆ کارکردنی سەرەکی ئەپەکە: پێدانی نوێکاریەکانی شوێنی کارمەند بە ڕاستەوخۆ و دڵنیابوون لە ناردنی کار بە شێوەیەکی کاریگەر.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('نەخێر سوپاس'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Material1.primaryColor,
              ),
              child: const Text('بەردەوام بە', style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    ) ?? false;
  }

  // --- پێرمشنی لۆکەیشن تەنها بۆ نۆن-تێستەرەکان ---
  Future<bool> _handleLocationPermissionForNonTester(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // تاقیکردنەوەی چالاکبوونی خزمەتگوزاری لۆکەیشن
    serviceEnabled = await geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }
    
    // پشکنینی دۆخی پێرمشن
    permission = await geolocatorPlatform.checkPermission();
    
    if (permission == LocationPermission.denied) {
      // داواکردنی پێرمشنی لۆکەیشنی گشتی (کاتی بەکارهێنان)
      permission = await geolocatorPlatform.requestPermission();
    }

    // پشکنین بۆ پێرمشنی 'هەموو کات' (پێویستە بۆ چاودێریی پشتەوە)
    if (permission != LocationPermission.always) {
      // پیشاندانی دایەلۆگی ئاگاداری پێش داواکردنی "ڕێگەدان هەموو کات"
      bool consented = await _showBackgroundLocationDisclosure(context);
      
      if (consented) {
        // ئەگەر بەکارهێنەر ڕازی بوو، دووبارە داواکردنی پێرمشنی 'هەموو کات'
        permission = await geolocatorPlatform.requestPermission();
      } else {
        // بەکارهێنەر ڕەتیکردەوە
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return permission == LocationPermission.always;
  }

  // --- وەرگرتنی لۆکەیشنی ئێستا ---
  Future<void> _getCurrentPosition() async {
    try {
      final position = await geolocatorPlatform.getCurrentPosition();
      latitude = position.latitude;
      longtitude = position.longitude;
    } catch (e) {
      print('هەڵە لە وەرگرتنی لۆکەیشن: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: 110,
                    width: 110,
                    child: Image.asset('lib/assets/logo.png'),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    'بەخێربێیت دووبارە',
                    textAlign: TextAlign.center,
                    style: kurdishTextStyle(18, blackColor),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'چوونەژوورەوە بکە بۆ ناو ئەکاونتەکەت!',
                    textAlign: TextAlign.center,
                    style: kurdishTextStyle(16, Colors.grey[600]!),
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.all(16.sp),
                    decoration: BoxDecoration(
                      color: whiteColor,
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomEmailField(controller: emailcontroller),
                        Divider(height: 1, color: Colors.grey[300]),
                        CustomPasswordField(
                          controller: passwordcontroller,
                          isObscurePassword: _obscurePassword,
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                        SizedBox(height: 2.h),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return const Forgetpassword();
                              }));
                            },
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: Text(
                              'وشەی نهێنیت لەبیرکردووە ؟',
                              style: TextStyle(
                                  color: Material1.primaryColor, fontSize: 14.sp),
                            ),
                          ),
                        ),
                        SizedBox(height: 3.h),
                        ElevatedButton(
                          onPressed: _isLoading ? null : () => _handleLogin(),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Material1.primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            textStyle: TextStyle(fontSize: 18.sp),
                          ),
                          child: _isLoading
                              ? CircularProgressIndicator(color: Colors.white)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      'چوونەژوورەوە',
                                      style: kurdishTextStyle(14, whiteColor),
                                    ),
                                    SizedBox(width: 1.w),
                                    Icon(Icons.login),
                                  ],
                                ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 5.h),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text:
                              'تەنها ئەکاونتە ئەدمینە ڕەسمییەکان\nدەتوانن چوونەژوورەوە بکەن ',
                          style: kurdishTextStyle(14, Colors.grey[600]!),
                        ),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: InkWell(
                            onTap: () async {
                              if (!await launchUrl(
                                  Uri.parse('https://www.britishbody.uk/'))) {
                                throw Exception('Could not launch ');
                              }
                            },
                            child: Text('Britsh Body@',
                                style: kurdishTextStyle(14, foregroundColor)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- فەنکشنی سەرەکی لۆگین ---
  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    String email = emailcontroller.text.toLowerCase().trim();
    String password = passwordcontroller.text;
    UserCredential? userCredential;

    // 1. چوونەژوورەوەی Firebase Auth
    try {
      userCredential = await FirebaseAuth.instance.signInWithCredential(
          EmailAuthProvider.credential(email: email, password: password));
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      await LoginConfirmationDialog(
              context: context, content: 'ئیمێڵ یان وشەی نهێنی هەڵەیە')
          .show();
      return;
    }

    // 2. وەرگرتنی زانیاری بەکارهێنەر لە Firestore
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc(email)
          .get();

      if (!userDoc.exists) {
        setState(() {
          _isLoading = false;
        });
        await LoginConfirmationDialog(context: context, content: 'ئیمێڵەکە هەڵەیە')
            .show();
        return;
      }

      Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;

      // 3. پشکنینی وشەی نهێنی
      if (userData['password'] != password || userCredential?.user == null) {
        setState(() {
          _isLoading = false;
        });
        Material1.showdialog(context, 'هەڵە', 'وشەی نهێنی هەڵەیە', [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('باشە', style: TextStyle(color: Material1.primaryColor)),
          )
        ]);
        return;
      }

      // 4. پشکنینی ئیمێڵ
      if (userData['email'] != email) {
        setState(() {
          _isLoading = false;
        });
        Material1.showdialog(context, 'هەڵە', 'ئیمێڵ هەڵەیە', [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('باشە', style: TextStyle(color: Material1.primaryColor)),
          )
        ]);
        return;
      }

      // 5. پشکنینی پێرمشنەکان
      List<dynamic> userPermissions = userData['permissions'] ?? [];
      bool isTester = userPermissions.contains('isTester');

      // 6. کاری ناسنامەی ئامێر تەنها بۆ نۆن-تێستەرەکان
      if (!isTester) {
        String deviceid = await getDeviceId();

        if ((userData['deviceid'] ?? '') != '' &&
            userData['deviceid'] != deviceid) {
          setState(() {
            _isLoading = false;
          });
          await LoginConfirmationDialog(
            context: context,
            content: 'ناتوانیت لەم ئامێرە چوونەژوورەوە بکەیت',
          ).show();
          return;
        }

        if (deviceid.isNotEmpty) {
          await userDoc.reference.set(
            {'deviceid': deviceid},
            SetOptions(merge: true),
          );
        }

        // ⭐ 7. داواکردنی پێرمشنی لۆکەیشن تەنها بۆ نۆن-تێستەرەکان
        bool hasLocationPermission =
            await _handleLocationPermissionForNonTester(context);
        
        if (hasLocationPermission) {
          // وەرگرتنی لۆکەیشنی ئێستا ئەگەر پێرمشن هەبوو
          await _getCurrentPosition();
        }
        // ئەگەر پێرمشن نەبوو، بەردەوام دەبێت بە latitude = 0 و longitude = 0

      } else {
        // ئەمە تێستەرە - ناسنامەی ئامێر بەتاڵ بمێنێتەوە
        await userDoc.reference.set(
          {'deviceid': ''},
          SetOptions(merge: true),
        );
        // ⭐ تێستەرەکان پێویستیان بە پێرمشنی لۆکەیشن نییە
      }

      // 8. وەرگرتنی FCM Token
      String fcm = '';
      try {
        fcm = await FirebaseMessaging.instance.getToken() ?? '';
      } catch (e) {
        fcm = '';
      }

      // 9. نوێکردنەوەی زانیاری بەکارهێنەر لە Firestore
      await userDoc.reference.set({
        'token': fcm,
        'lat': latitude,
        'long': longtitude,
      }, SetOptions(merge: true));

      // 10. هەڵگرتنی زانیاری بەکارهێنەر لە SharedPreferences
      Sharedpreference.setuser(
        userData['name'] ?? '',
        userData['email'] ?? '',
        userData['location'] ?? '',
        userData['email'] ?? '',
        userData['salary'] ?? '0',
        userData['age'] ?? '',
        latitude,
        longtitude,
        (userData['worklat'] ?? 0.0).toDouble(),
        (userData['worklong'] ?? 0.0).toDouble(),
        userData['starthour'] ?? 0,
        userData['endhour'] ?? 0,
        userData['startmin'] ?? 0,
        userData['endmin'] ?? 0,
        true,
        fcm,
        userData['checkin'] ?? false,
        userData['permissions'] ?? [],
        userData['weekdays'] ?? [],
      );

      setState(() {
        _isLoading = false;
      });

      // 11. ڕەوانەکردن بەپێی جۆری بەکارهێنەر
      if (isTester) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => TesterHomeScreen(email: email),
          ),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Navigation(email: email),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      await LoginConfirmationDialog(
        context: context,
        content: 'هەڵەیەک ڕوویدا: $e',
      ).show();
    }
  }

  Future<String> getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();

    if (kIsWeb) {
      return 'web-device';
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? iosInfo.localizedModel;
    } else {
      return 'unknown-device';
    }
  }
}