import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';

import 'package:british_body_admin/material/materials.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:device_info_plus/device_info_plus.dart';

class Forgetpassword extends StatefulWidget {
  const Forgetpassword({super.key});

  @override
  State<Forgetpassword> createState() => _ForgetpasswordState();
}

class _ForgetpasswordState extends State<Forgetpassword> {
  TextEditingController emailcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Forget Password'),
          backgroundColor: Material1.primaryColor,
          foregroundColor: Colors.white,
        ),
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
                    Icons.email,
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
                      inputType: TextInputType.number,
                      textColor: Material1.primaryColor),
                ),
                Container(
                    margin: EdgeInsets.only(top: 2.h),
                    width: 90.w,
                    height: 8.h,
                    child: Material1.button(
                        label: 'send password reset email',
                        buttoncolor: Material1.primaryColor,
                        textcolor: Colors.white,
                        function: () async {
                          String email = emailcontroller.text;
                          try {
                            await FirebaseAuth.instance
                                .sendPasswordResetEmail(email: email)
                                .then((value) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('email sent to $email')));
                              Navigator.pop(context);
                            });
                          } catch (e) {
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
                        })),
              ],
            ),
          ),
        ));
  }

  Future<String> getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return androidInfo.id;
    } else {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.identifierForVendor ?? iosInfo.localizedModel;
    }
  }
}
