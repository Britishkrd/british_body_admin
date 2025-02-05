import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/sharedprefrences/sharedprefernences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ntp/ntp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:map_location_picker/map_location_picker.dart';

class Checkinandout extends StatefulWidget {
  const Checkinandout({super.key});

  @override
  State<Checkinandout> createState() => _CheckinandoutState();
}

Future<void> _getCurrentPosition() async {
  final position = await _geolocatorPlatform.getCurrentPosition();
  latitude = position.latitude;
  longtitude = position.longitude;
  return;
}

final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

bool checkin = true;
double latitude = 0.0;
double longtitude = 0.0;
double worklatitude = 0.0;
double worklongtitude = 0.0;

TextEditingController notecontroller = TextEditingController();

String email = '';
bool checkinpage = false;
List permissions = [];

getuserinfo() async {
  final SharedPreferences preference = await SharedPreferences.getInstance();
  email = preference.getString('email') ?? '';
  checkin = preference.getBool('checkin') ?? false;
  permissions = preference.getStringList('permissions') ?? [];
  worklatitude = preference.getDouble('worklat') ?? 0.0;
  worklongtitude = preference.getDouble('worklong') ?? 0.0;
}

class _CheckinandoutState extends State<Checkinandout> {
  @override
  void initState() {
    getuserinfo();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  checkinpage = true;
                });
              },
              child: Container(
                height: 8.h,
                width: 40.w,
                decoration: BoxDecoration(
                  color: Material1.primaryColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: EdgeInsets.only(top: 3.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'چوونەژوورەوە',
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
                    const Icon(Icons.timer, color: Colors.white),
                  ],
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  checkinpage = false;
                });
              },
              child: Container(
                height: 8.h,
                width: 40.w,
                decoration: BoxDecoration(
                  color: Material1.primaryColor,
                  borderRadius: BorderRadius.circular(15),
                ),
                margin: EdgeInsets.only(top: 3.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'چوونەدەرەوە',
                      style: TextStyle(color: Colors.white, fontSize: 16.sp),
                    ),
                    const Icon(Icons.timer_outlined, color: Colors.red),
                  ],
                ),
              ),
            ),
          ],
        ),
        checkinpage
            ? Column(
                children: [
                  Container(
                      margin: EdgeInsets.only(top: 3.h),
                      height: 8.h,
                      width: 90.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Material1.textfield(
                          hint: 'تێبینی(هەڵبژاردەییە)',
                          textColor: Material1.primaryColor,
                          controller: notecontroller)),
                  Container(
                    margin: EdgeInsets.only(top: 3.h),
                    height: 8.h,
                    width: 40.w,
                    decoration: BoxDecoration(
                      color: Material1.primaryColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Material1.button(
                        label: 'چوونەژوورەوە ',
                        child: Icon(Icons.timer, color: Colors.white),
                        buttoncolor: Material1.primaryColor,
                        textcolor: Colors.white,
                        function: () async {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Center(
                                    child: Column(
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(
                                          height: 2.h,
                                        ),
                                        Text('تکایە چاوەڕێکەوە',
                                            style: TextStyle(fontSize: 16.sp)),
                                      ],
                                    ),
                                  ),
                                );
                              });
                          await _getCurrentPosition();
                          await getuserinfo();
                          double distanceInMeters = Geolocator.distanceBetween(
                              worklatitude,
                              worklongtitude,
                              latitude,
                              longtitude);
                          if (distanceInMeters > 100) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('هەڵە'),
                                    content: Text(
                                        'تکایە لە ناوچەی کاری خۆت چوونەژوورەوە بکە'),
                                    actions: [
                                      Material1.button(
                                          label: 'باشە',
                                          buttoncolor: Material1.primaryColor,
                                          textcolor: Colors.white,
                                          function: () {
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          }),
                                    ],
                                  );
                                });
                            return;
                          }
                          if (checkin) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('هەڵە'),
                                    content: Text('تکایە چوونەدەرەووە بکە'),
                                    actions: [
                                      Material1.button(
                                          label: 'باشە',
                                          buttoncolor: Material1.primaryColor,
                                          textcolor: Colors.white,
                                          function: () {
                                            Navigator.pop(context);
                                          }),
                                    ],
                                  );
                                });
                            return;
                          }
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('دڵنیاکردنەوە'),
                                  content: Text('دڵنیایت لە چوونەژوورەوە؟'),
                                  actions: [
                                    Material1.button(
                                        label: 'پەشیمان بوونەوە',
                                        buttoncolor: Material1.primaryColor,
                                        textcolor: Colors.white,
                                        function: () {
                                          Navigator.pop(context);
                                        }),
                                    Material1.button(
                                        label: 'چوونەژوورەوە',
                                        buttoncolor: Material1.primaryColor,
                                        textcolor: Colors.white,
                                        function: () async {
                                          DateTime startDate =
                                              DateTime.now().toLocal();
                                          int offset = await NTP.getNtpOffset(
                                              localTime: startDate);
                                          DateTime now = startDate.add(
                                              Duration(milliseconds: offset));
                                          FirebaseFirestore.instance
                                              .collection('user')
                                              .doc(email)
                                              .collection('checkincheckouts')
                                              .doc(now.toIso8601String())
                                              .set({
                                            'latitude': latitude,
                                            'longtitude': longtitude,
                                            'time': now,
                                            'note': notecontroller.text,
                                            'checkout': false,
                                            'checkin': true,
                                          }).then((value) {
                                            FirebaseFirestore.instance
                                                .collection('user')
                                                .doc(email)
                                                .update({'checkin': true}).then(
                                                    (value) {
                                              Sharedpreference.checkin(
                                                  now.toString(),
                                                  latitude,
                                                  longtitude,
                                                  true);
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            });
                                          });
                                        }),
                                  ],
                                );
                              });
                        }),
                  ),
                  permissions.contains('workoutside')
                      ? Container(
                          margin: EdgeInsets.only(top: 3.h),
                          height: 8.h,
                          width: 80.w,
                          decoration: BoxDecoration(
                            color: Material1.primaryColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Material1.button(
                              label: 'چوونەژوورەوە لە دەروەی شوێنی ئیشکردن ',
                              child: Icon(Icons.timer, color: Colors.white),
                              buttoncolor: Material1.primaryColor,
                              textcolor: Colors.white,
                              function: () async {
                                await getuserinfo();
                                if (checkin) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('هەڵە'),
                                          content:
                                              Text('تکایە چوونەدەرەووە بکە'),
                                          actions: [
                                            Material1.button(
                                                label: 'باشە',
                                                buttoncolor:
                                                    Material1.primaryColor,
                                                textcolor: Colors.white,
                                                function: () {
                                                  Navigator.pop(context);
                                                }),
                                          ],
                                        );
                                      });
                                  return;
                                }
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('دڵنیاکردنەوە'),
                                        content:
                                            Text('دڵنیایت لە چوونەژوورەوە؟'),
                                        actions: [
                                          Material1.button(
                                              label: 'پەشیمان بوونەوە',
                                              buttoncolor:
                                                  Material1.primaryColor,
                                              textcolor: Colors.white,
                                              function: () {
                                                Navigator.pop(context);
                                              }),
                                          Material1.button(
                                              label: 'چوونەژوورەوە',
                                              buttoncolor:
                                                  Material1.primaryColor,
                                              textcolor: Colors.white,
                                              function: () async {
                                                showDialog(
                                                    context: context,
                                                    builder: (context) {
                                                      return AlertDialog(
                                                        title: Center(
                                                          child: Column(
                                                            children: [
                                                              CircularProgressIndicator(),
                                                              SizedBox(
                                                                height: 2.h,
                                                              ),
                                                              Text(
                                                                  'تکایە چاوەڕێکەوە',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16.sp)),
                                                            ],
                                                          ),
                                                        ),
                                                      );
                                                    });
                                                await _getCurrentPosition();
                                                await getuserinfo();
                                                DateTime startDate =
                                                    DateTime.now().toLocal();
                                                int offset =
                                                    await NTP.getNtpOffset(
                                                        localTime: startDate);
                                                DateTime now = startDate.add(
                                                    Duration(
                                                        milliseconds: offset));
                                                FirebaseFirestore.instance
                                                    .collection('user')
                                                    .doc(email)
                                                    .collection(
                                                        'checkincheckouts')
                                                    .doc(now.toIso8601String())
                                                    .set({
                                                  'latitude': latitude,
                                                  'longtitude': longtitude,
                                                  'time': now,
                                                  'note': notecontroller.text,
                                                  'checkout': false,
                                                  'checkin': true,
                                                }).then((value) {
                                                  FirebaseFirestore.instance
                                                      .collection('user')
                                                      .doc(email)
                                                      .update({
                                                    'checkin': true
                                                  }).then((value) {
                                                    Sharedpreference.checkin(
                                                        now.toString(),
                                                        latitude,
                                                        longtitude,
                                                        true);
                                                    Navigator.pop(context);
                                                    Navigator.pop(context);
                                                  });
                                                });
                                              })
                                        ],
                                      );
                                    });
                              }),
                        )
                      : const SizedBox.shrink(),
                ],
              )
            : Column(
                children: [
                  Container(
                      margin: EdgeInsets.only(top: 3.h),
                      height: 8.h,
                      width: 90.w,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Material1.textfield(
                          hint: 'تێبینی(هەڵبژاردەییە)',
                          textColor: Material1.primaryColor,
                          controller: notecontroller)),
                  Container(
                    margin: EdgeInsets.only(top: 3.h),
                    height: 8.h,
                    width: 40.w,
                    decoration: BoxDecoration(
                      color: Material1.primaryColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Material1.button(
                        label: 'چوونەدەرەوە  ',
                        child: Icon(Icons.timer_outlined, color: Colors.red),
                        buttoncolor: Material1.primaryColor,
                        textcolor: Colors.white,
                        function: () async {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Center(
                                    child: Column(
                                      children: [
                                        CircularProgressIndicator(),
                                        SizedBox(
                                          height: 2.h,
                                        ),
                                        Text('تکایە چاوەڕێکەوە',
                                            style: TextStyle(fontSize: 16.sp)),
                                      ],
                                    ),
                                  ),
                                );
                              });
                          await getuserinfo();
                          await _getCurrentPosition();
                          if (!checkin) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: Text('هەڵە'),
                                    content: Text('تکایە چوونەژوورەوە بکە'),
                                    actions: [
                                      Material1.button(
                                          label: 'باشە',
                                          buttoncolor: Material1.primaryColor,
                                          textcolor: Colors.white,
                                          function: () {
                                            Navigator.pop(context);
                                          }),
                                    ],
                                  );
                                });
                            return;
                          }
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('دڵنیاکردنەوە'),
                                  content: Text('دڵنیایت لە چوونەدەرەوە؟'),
                                  actions: [
                                    Material1.button(
                                        label: 'پەشیمان بوونەوە',
                                        buttoncolor: Material1.primaryColor,
                                        textcolor: Colors.white,
                                        function: () {
                                          Navigator.pop(context);
                                        }),
                                    Material1.button(
                                        label: 'چوونەدەرەوە',
                                        buttoncolor: Material1.primaryColor,
                                        textcolor: Colors.white,
                                        function: () async {
                                          DateTime startDate =
                                              DateTime.now().toLocal();
                                          int offset = await NTP.getNtpOffset(
                                              localTime: startDate);
                                          DateTime now = startDate.add(
                                              Duration(milliseconds: offset));
                                          FirebaseFirestore.instance
                                              .collection('user')
                                              .doc(email)
                                              .collection('checkincheckouts')
                                              .doc(now.toIso8601String())
                                              .set({
                                            'latitude': latitude,
                                            'longtitude': longtitude,
                                            'time': now,
                                            'note': notecontroller.text,
                                            'checkout': true,
                                            'checkin': false,
                                          }).then((value) {
                                            FirebaseFirestore.instance
                                                .collection('user')
                                                .doc(email)
                                                .update({
                                              'checkin': false
                                            }).then((value) {
                                              Sharedpreference.checkin(
                                                  now.toString(),
                                                  latitude,
                                                  longtitude,
                                                  false);
                                              Navigator.pop(context);
                                            });
                                          });
                                        })
                                  ],
                                );
                              });
                        }),
                  ),
                ],
              )
      ],
    );
  }
}
