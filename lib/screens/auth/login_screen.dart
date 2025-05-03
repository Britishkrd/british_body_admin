import 'dart:io';

import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/auth/forgetpassword.dart';
import 'package:british_body_admin/screens/navigator.dart';
import 'package:british_body_admin/shared/confirm_dialog.dart';
import 'package:british_body_admin/shared/custom_email.dart';
import 'package:british_body_admin/sharedprefrences/sharedprefernences.dart';
import 'package:british_body_admin/utils/color.dart';
import 'package:british_body_admin/utils/textstyle.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:map_location_picker/map_location_picker.dart';
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
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: Directionality(
          textDirection: TextDirection.rtl, // RTL for Kurdish
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
                    style: kurdishTextStyle(
                      18,
                      blackColor,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'چوونەژوورەوە بکە بۆ ناو ئەکاونتەکەت!',
                    textAlign: TextAlign.center,
                    style: kurdishTextStyle(
                      16,
                      Colors.grey[600]!,
                    ),
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
                        TextFormField(
                          controller: emailcontroller,
                          keyboardType: TextInputType.emailAddress,
                          textAlign: TextAlign.right, // Right align text
                          style: TextStyle(fontSize: 17, color: Colors.black87),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email_outlined,
                                color: Colors.grey[400]),
                            labelText: 'ئیمێڵ',
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            border: InputBorder.none,
                          ),
                        ),
                        // CustomEmailField(
                        //   controller: emailcontroller,
                          
                        //     validator: (value) {
                        //     const pattern =
                        //         r'(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)';
                        //     final regExp = RegExp(pattern);
                        //     if (value!.isEmpty) {
                        //       return 'تکایە ئیمێڵەکەت داخڵ بکە';
                        //     } else if (!regExp.hasMatch(value)) {
                        //       return 'تکایە ئیمێڵی درووست داخڵ';
                        //     }
                        //     return null;
                          
                        //   },
                        
                        // ),
                        Divider(height: 1, color: Colors.grey[300]),
                        TextFormField(
                          controller: passwordcontroller,
                          obscureText: _obscurePassword,
                          textAlign: TextAlign.right, // Right align text
                          style: TextStyle(fontSize: 17, color: Colors.black87),
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock_outlined,
                                color: Colors.grey[400]),
                            labelText: 'وشەی نهێنی',
                            labelStyle: TextStyle(color: Colors.grey[600]),
                            border: InputBorder.none,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.grey[400],
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Align(
                          alignment:
                              Alignment.centerLeft, // Align to left for RTL
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
                                  color: Material1.primaryColor,
                                  fontSize: 14.sp),
                            ),
                          ),
                        ),
                        SizedBox(height: 3.h),
                        ElevatedButton(
                          onPressed: () async {
                            // Login logic remains the same
                            String? email = emailcontroller.text;
                            String? password = passwordcontroller.text;
                            UserCredential? userCredential;
                            try {
                              userCredential = await FirebaseAuth.instance
                                  .signInWithCredential(
                                      EmailAuthProvider.credential(
                                          email: email, password: password));
                            } catch (e) {
                              await LoginConfirmationDialog(
                                      // Add await here
                                      context: context,
                                      content: 'ئیمێڵ یان وشەی نهێنی هەڵەیە')
                                  .show(); // Add .show() here
                              return;
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
                                      context, 'هەڵە', 'وشەی نهێنی هەڵەیە', [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('باشە',
                                          style: TextStyle(
                                              color: Material1.primaryColor)),
                                    )
                                  ]);
                                  return;
                                }
                                if (value.data()?['email'] != email) {
                                  Material1.showdialog(
                                      context, 'هەڵە', 'ئیمێڵ هەڵەیە', [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.pop(context);
                                      },
                                      child: Text('باشە',
                                          style: TextStyle(
                                              color: Material1.primaryColor)),
                                    )
                                  ]);
                                  return;
                                }
                                String deviceid = await getDeviceId();

                                if (value.data()?['deviceid'] != '' &&
                                    value.data()?['deviceid'] != deviceid) {
                                  LoginConfirmationDialog(
                                          context: context,
                                          content:
                                              'ناتوانیت لەم ئامێرە چوونەژوورەوە بکەیت')
                                      .show();
                                  return;
                                }
                                String fcm = '';
                                try {
                                  fcm = await FirebaseMessaging.instance
                                          .getToken() ??
                                      '';
                                } catch (e) {
                                  fcm = '';
                                }

                                if (deviceid != '') {
                                  value.reference.set({'deviceid': deviceid},
                                      SetOptions(merge: true));
                                }

                                value.reference.set({
                                  'token': fcm,
                                  'lat': latitude,
                                  'long': longtitude
                                }, SetOptions(merge: true));
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
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(
                                  builder: (context) {
                                    return Navigation(
                                      email: email,
                                    );
                                  },
                                ));
                              } else {
                                LoginConfirmationDialog(
                                        context: context,
                                        content: 'ئیمێڵەکە هەڵەیە')
                                    .show();
                              }
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Material1.primaryColor,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 16.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            textStyle: TextStyle(fontSize: 18.sp),
                          ),
                          child: Row(
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
                        ),
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
                          alignment:
                              PlaceholderAlignment.middle, // Add this line
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
