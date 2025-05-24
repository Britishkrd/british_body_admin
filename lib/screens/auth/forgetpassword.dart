import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/shared/confirm_dialog.dart';
import 'package:british_body_admin/shared/custom_email.dart';
import 'package:british_body_admin/utils/color.dart';
import 'package:british_body_admin/utils/textstyle.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Forgetpassword extends StatefulWidget {
  const Forgetpassword({super.key});

  @override
  State<Forgetpassword> createState() => _ForgetpasswordState();
}

class _ForgetpasswordState extends State<Forgetpassword> {
  final TextEditingController _emailcontroller = TextEditingController();

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
                    'وشەی نهێنیت لەبیرکردووە؟',
                    textAlign: TextAlign.center,
                    style: kurdishTextStyle(
                      18,
                      blackColor,
                    ),
                  ),
                  SizedBox(height: 1.h),
                  Text(
                    'ئیمێڵەکەت بنووسە بۆ ناردنی بەستەری گۆڕینی وشەی نهێنی',
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
                        CustomEmailField(
                          controller: _emailcontroller,
                        ),
                        SizedBox(height: 4.h),
                        ElevatedButton(
                          onPressed: () async {
                            String email = _emailcontroller.text.toLowerCase();
                            try {
                              await FirebaseAuth.instance
                                  .sendPasswordResetEmail(email: email)
                                  .then((value) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      ' $email ئیمێڵ نێردرا بۆ',
                                      textAlign: TextAlign.center,
                                      style: kurdishTextStyle(14, whiteColor),
                                    ),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                                Navigator.pop(context);
                              });
                            } catch (e) {
                              LoginConfirmationDialog(
                                      context: context,
                                      content: 'ئیمێڵەکە هەڵەیە')
                                  .show();
                            }
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
                                'ناردنی ئیمێڵ',
                                style: kurdishTextStyle(14, whiteColor),
                              ),
                              SizedBox(width: 1.w),
                              Icon(Icons.send),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 5.h),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      'گەڕانەوە بۆ پەڕەی چوونەژوورەوە',
                      style: kurdishTextStyle(14, Material1.primaryColor),
                      textAlign: TextAlign.center,
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
}
