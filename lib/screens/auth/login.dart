import 'dart:io';

import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/auth/forgetpassword.dart';
import 'package:british_body_admin/screens/navigator.dart';
import 'package:british_body_admin/sharedprefrences/sharedprefernences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:sizer/sizer.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();
  final GeolocatorPlatform geolocatorPlatform = GeolocatorPlatform.instance;
  double latitude = 0.0;
  double longtitude = 0.0;

  @override
  void initState() {
    super.initState();
    getlocation();
  }

  getlocation() async {
    final hasPermission = await handlePermission();

    if (hasPermission) {
      getCurrentPosition();
    }
  }

  Future<void> getCurrentPosition() async {
    final position = await geolocatorPlatform.getCurrentPosition();
    latitude = position.latitude;
    longtitude = position.longitude;
    return;
  }

  Future<bool> handlePermission() async {
    bool serviceEnabled;
    LocationPermission permission;
    permission = await geolocatorPlatform.requestPermission();

    // Test if location services are enabled.
    serviceEnabled = await geolocatorPlatform.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await geolocatorPlatform.checkPermission();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 60.w,
              height: 20.h,
              child: Icon(
                Icons.person,
                size: 50.sp,
                color: Material1.primaryColor,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 5.h),
              width: 90.w,
              height: 8.h,
              child: Material1.textfield(
                  hint: 'example@example.com',
                  controller: emailcontroller,
                  textColor: Material1.primaryColor),
            ),
            Container(
              margin: EdgeInsets.only(top: 5.h),
              width: 90.w,
              height: 8.h,
              child: Material1.textfield(
                  hint: '******',
                  controller: passwordcontroller,
                  textColor: Material1.primaryColor),
            ),
            Container(
              alignment: Alignment.topRight,
              width: 90.w,
              height: 6.h,
              child: TextButton(
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return const Forgetpassword();
                    }));
                  },
                  child: Text(
                    'forgot password?',
                    style: TextStyle(
                        color: Material1.primaryColor, fontSize: 16.sp),
                  )),
            ),
            Container(
              margin: EdgeInsets.only(top: 5.h),
              width: 90.w,
              height: 8.h,
              child: Material1.button(
                  label: 'login',
                  buttoncolor: Material1.primaryColor,
                  textcolor: Colors.white,
                  function: () async {
                    String? email = emailcontroller.text;
                    String? password = passwordcontroller.text;
                    UserCredential? userCredential;
                    try {
                      userCredential = await FirebaseAuth.instance
                          .signInWithCredential(EmailAuthProvider.credential(
                              email: email, password: password));
                    } catch (e) {
                      Material1.showdialog(context, 'Error',
                          'email or password is not correct', [
                        Material1.button(
                            label: 'ok',
                            buttoncolor: Material1.primaryColor,
                            textcolor: Colors.white,
                            function: () {
                              Navigator.pop(context);
                            })
                      ]);
                    }
                    FirebaseFirestore.instance
                        .collection('user')
                        .doc(email)
                        .get()
                        .then((value) async {
                      if (value.exists) {
                        if (value.data()?['password'] != password ||
                            userCredential?.user == null) {
                          Material1.showdialog(
                              context, 'Error', 'password is not correct', [
                            Material1.button(
                                label: 'ok',
                                buttoncolor: Material1.primaryColor,
                                textcolor: Colors.white,
                                function: () {
                                  Navigator.pop(context);
                                })
                          ]);
                          return;
                        }
                        if (value.data()?['email'] != email) {
                          Material1.showdialog(
                              context, 'Error', 'email is not correct', [
                            Material1.button(
                                label: 'ok',
                                buttoncolor: Material1.primaryColor,
                                textcolor: Colors.white,
                                function: () {
                                  Navigator.pop(context);
                                })
                          ]);
                          return;
                        }
                        String deviceid = await getDeviceId();

                        if (value.data()?['deviceid'] != '' &&
                            value.data()?['deviceid'] != deviceid) {
                          Material1.showdialog(context, 'Error',
                              'you can not log in from this device', [
                            Material1.button(
                                label: 'ok',
                                buttoncolor: Material1.primaryColor,
                                textcolor: Colors.white,
                                function: () {
                                  Navigator.pop(context);
                                })
                          ]);
                          return;
                        }
                        String fcm = '';
                        try {
                          fcm =
                              await FirebaseMessaging.instance.getToken() ?? '';
                        } catch (e) {
                          fcm = '';
                        }

                        if (deviceid != '') {
                          value.reference.set(
                              {'deviceid': deviceid}, SetOptions(merge: true));
                        }

                        value.reference.set(
                            {'token': fcm, 'lat': latitude, 'long': longtitude},
                            SetOptions(merge: true));
                        Sharedpreference.setuser(
                            value.data()?['name'] ?? '',
                            value.data()?['email'] ?? '',
                            value.data()?['location'] ?? '',
                            value.data()?['email'] ?? '',
                            value.data()?['salary'] ?? '0',
                            value.data()?['age'] ?? '',
                            latitude,
                            longtitude,
                            value.data()?['worklat'] ?? 0.0,
                            value.data()?['worklong'] ?? 0.0,
                            value.data()?['starthour'] ?? 0,
                            value.data()?['endhour'] ?? 0,
                            value.data()?['startmin'] ?? 0,
                            value.data()?['endmin'] ?? 0,
                            true,
                            fcm,
                            value.data()?['checkin'] ?? false,
                            value.data()?['permissions'] ?? [],
                            value.data()?['weekdays'] ?? []);
                        Navigator.pushReplacement(context, MaterialPageRoute(
                          builder: (context) {
                            return Navigation(
                              email: email,
                            );
                          },
                        ));
                      } else {
                        Material1.showdialog(
                            context, 'Error', 'email is not correct', [
                          Material1.button(
                              label: 'ok',
                              buttoncolor: Material1.primaryColor,
                              textcolor: Colors.white,
                              function: () {
                                Navigator.pop(context);
                              })
                        ]);
                      }
                    });
                  }),
            ),
          ],
        ),
      ),
    ));
  }

  // Future<String> getDeviceId() async {
  //   var deviceInfo = DeviceInfoPlugin();
  //   if (Platform.isAndroid) {
  //     AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //     return androidInfo.id;
  //   } else {
  //     IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
  //     return iosInfo.identifierForVendor ?? iosInfo.localizedModel;
  //   }
  // }
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


// import 'package:british_body_admin/screens/auth/forgetpassword.dart';
// import 'package:british_body_admin/screens/navigator.dart';
// import 'package:british_body_admin/sharedprefrences/sharedprefernences.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'dart:io';

// import 'package:british_body_admin/material/materials.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:map_location_picker/map_location_picker.dart';
// import 'package:sizer/sizer.dart';
// import 'package:device_info_plus/device_info_plus.dart';

// class Login extends StatefulWidget {
//   const Login({super.key});

//   @override
//   State<Login> createState() => _LoginState();
// }

// class _LoginState extends State<Login> {
//   TextEditingController emailcontroller = TextEditingController();
//   TextEditingController passwordcontroller = TextEditingController();
//   final GeolocatorPlatform geolocatorPlatform = GeolocatorPlatform.instance;
//   double latitude = 0.0;
//   double longtitude = 0.0;
//   bool _obscurePassword = true; // For toggling password visibility

//   @override
//   void initState() {
//     super.initState();
//     getlocation();
//   }

//   getlocation() async {
//     final hasPermission = await handlePermission();

//     if (hasPermission) {
//       getCurrentPosition();
//     }
//   }

//   Future<void> getCurrentPosition() async {
//     final position = await geolocatorPlatform.getCurrentPosition();
//     latitude = position.latitude;
//     longtitude = position.longitude;
//     return;
//   }

//   Future<bool> handlePermission() async {
//     bool serviceEnabled;
//     LocationPermission permission;
//     permission = await geolocatorPlatform.requestPermission();

//     // Test if location services are enabled.
//     serviceEnabled = await geolocatorPlatform.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       return false;
//     }

//     permission = await geolocatorPlatform.checkPermission();
//     if (permission == LocationPermission.denied) {
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
//     return Scaffold(
//       backgroundColor: Colors.grey[50], // Very light grey background
//       body: Center(
//         child: SingleChildScrollView(
//           padding: EdgeInsets.symmetric(horizontal: 5.w),
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               SizedBox(
//                 height: 15.h,
//                 child: const Placeholder(), // Replace with your actual image/logo
//               ),
//               SizedBox(height: 3.h),
//               Text(
//                 'Welcome back',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 24.sp,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.black87,
//                 ),
//               ),
//               SizedBox(height: 1.h),
//               Text(
//                 'Sign in to access your account',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 14.sp,
//                   color: Colors.grey[600],
//                 ),
//               ),
//               SizedBox(height: 4.h),
//               Container(
//                 padding: EdgeInsets.all(16.sp),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12.0),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.stretch,
//                   children: [
//                     TextFormField(
//                       controller: emailcontroller,
//                       keyboardType: TextInputType.emailAddress,
//                       style: TextStyle(fontSize: 16.sp, color: Colors.black87),
//                       decoration: InputDecoration(
//                         prefixIcon: Icon(Icons.email_outlined, color: Colors.grey[400]),
//                         labelText: 'Email',
//                         labelStyle: TextStyle(color: Colors.grey[600]),
//                         border: InputBorder.none, // Remove default border
//                       ),
//                     ),
//                     Divider(height: 1, color: Colors.grey[300]),
//                     TextFormField(
//                       controller: passwordcontroller,
//                       obscureText: _obscurePassword,
//                       style: TextStyle(fontSize: 16.sp, color: Colors.black87),
//                       decoration: InputDecoration(
//                         prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[400]),
//                         labelText: 'Password',
//                         labelStyle: TextStyle(color: Colors.grey[600]),
//                         border: InputBorder.none,
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
//                             color: Colors.grey[400],
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _obscurePassword = !_obscurePassword;
//                             });
//                           },
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 2.h),
//                     Align(
//                       alignment: Alignment.centerRight,
//                       child: TextButton(
//                         onPressed: () {
//                           Navigator.push(context,
//                               MaterialPageRoute(builder: (context) {
//                             return const Forgetpassword();
//                           }));
//                         },
//                         style: TextButton.styleFrom(
//                           padding: EdgeInsets.zero,
//                           minimumSize: Size.zero,
//                           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
//                         ),
//                         child: Text(
//                           'Forgot password?',
//                           style: TextStyle(
//                               color: Material1.primaryColor, fontSize: 14.sp),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 3.h),
//                     ElevatedButton(
//                       onPressed: () async {
//                         String? email = emailcontroller.text;
//                         String? password = passwordcontroller.text;
//                         UserCredential? userCredential;
//                         try {
//                           userCredential = await FirebaseAuth.instance
//                               .signInWithCredential(EmailAuthProvider.credential(
//                                   email: email, password: password));
//                         } catch (e) {
//                           Material1.showdialog(context, 'Error',
//                               'Email or password is not correct', [
//                             TextButton(
//                               onPressed: () {
//                                 Navigator.pop(context);
//                               },
//                               child: Text('OK', style: TextStyle(color: Material1.primaryColor)),
//                             ),
//                           ]);
//                           return;
//                         }
//                         FirebaseFirestore.instance
//                             .collection('user')
//                             .doc(email)
//                             .get()
//                             .then((value) async {
//                           if (value.exists) {
//                             if (value.data()?['password'] != password ||
//                                 userCredential?.user == null) {
//                               Material1.showdialog(
//                                   context, 'Error', 'Password is not correct', [
//                                 TextButton(
//                                   onPressed: () {
//                                     Navigator.pop(context);
//                                   },
//                                   child: Text('OK', style: TextStyle(color: Material1.primaryColor)),
//                                 )
//                               ]);
//                               return;
//                             }
//                             if (value.data()?['email'] != email) {
//                               Material1.showdialog(
//                                   context, 'Error', 'Email is not correct', [
//                                 TextButton(
//                                   onPressed: () {
//                                     Navigator.pop(context);
//                                   },
//                                   child: Text('OK', style: TextStyle(color: Material1.primaryColor)),
//                                 )
//                               ]);
//                               return;
//                             }
//                             String deviceid = await getDeviceId();

//                             if (value.data()?['deviceid'] != '' &&
//                                 value.data()?['deviceid'] != deviceid) {
//                               Material1.showdialog(context, 'Error',
//                                   'You cannot log in from this device', [
//                                 TextButton(
//                                   onPressed: () {
//                                     Navigator.pop(context);
//                                   },
//                                   child: Text('OK', style: TextStyle(color: Material1.primaryColor)),
//                                 )
//                               ]);
//                               return;
//                             }
//                             String fcm = '';
//                             try {
//                               fcm =
//                                   await FirebaseMessaging.instance.getToken() ?? '';
//                             } catch (e) {
//                               fcm = '';
//                             }

//                             if (deviceid != '') {
//                               value.reference.set(
//                                   {'deviceid': deviceid}, SetOptions(merge: true));
//                             }

//                             value.reference.set(
//                                 {'token': fcm, 'lat': latitude, 'long': longtitude},
//                                 SetOptions(merge: true));
//                             Sharedpreference.setuser(
//                                 value.data()?['name'] ?? '',
//                                 value.data()?['email'] ?? '',
//                                 value.data()?['location'] ?? '',
//                                 value.data()?['email'] ?? '',
//                                 value.data()?['salary'] ?? '0',
//                                 value.data()?['age'] ?? '',
//                                 latitude,
//                                 longtitude,
//                                 value.data()?['worklat'] ?? 0.0,
//                                 value.data()?['worklong'] ?? 0.0,
//                                 value.data()?['starthour'] ?? 0,
//                                 value.data()?['endhour'] ?? 0,
//                                 value.data()?['startmin'] ?? 0,
//                                 value.data()?['endmin'] ?? 0,
//                                 true,
//                                 fcm,
//                                 value.data()?['checkin'] ?? false,
//                                 value.data()?['permissions'] ?? [],
//                                 value.data()?['weekdays'] ?? []);
//                             Navigator.pushReplacement(context,
//                                 MaterialPageRoute(
//                               builder: (context) {
//                                 return Navigation(
//                                   email: email,
//                                 );
//                               },
//                             ));
//                           } else {
//                             Material1.showdialog(
//                                 context, 'Error', 'Email is not correct', [
//                               TextButton(
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                 },
//                                 child: Text('OK', style: TextStyle(color: Material1.primaryColor)),
//                               )
//                             ]);
//                           }
//                         });
//                       },
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Material1.primaryColor,
//                         foregroundColor: Colors.white,
//                         padding: EdgeInsets.symmetric(vertical: 16.0),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8.0),
//                         ),
//                         textStyle: TextStyle(fontSize: 18.sp),
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           const Text('Sign In'),
//                           SizedBox(width: 1.w),
//                           const Icon(Icons.arrow_forward),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               SizedBox(height: 5.h),
//               Text(
//                 'Only authorized admin accounts\ncan access the ©SulyNet',
//                 textAlign: TextAlign.center,
//                 style: TextStyle(
//                   fontSize: 12.sp,
//                   color: Colors.grey[500],
//                 ),
//               ),
//             ],
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