import 'dart:developer';

import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/sharedprefrences/sharedprefernences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:ntp/ntp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

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
List permissions = [];
bool checkinpage = false;
int starthour = 0;
int endhour = 0;
int startmin = 0;
int endmin = 0;
List<int> workdays = [];

class _CheckinandoutState extends State<Checkinandout> {
  @override
  void initState() {
    getuserinfo();
    super.initState();
  }

  getuserinfo() async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    email = preference.getString('email') ?? '';
    checkin = preference.getBool('checkin') ?? false;
    permissions = preference.getStringList('permissions') ?? [];
    worklatitude = preference.getDouble('worklat') ?? 0.0;
    worklongtitude = preference.getDouble('worklong') ?? 0.0;
    workdays = preference
            .getStringList('weekdays')
            ?.map((e) => int.parse(e))
            .toList() ??
        [];
    starthour = preference.getInt('starthour') ?? 0;
    endhour = preference.getInt('endhour') ?? 0;
    startmin = preference.getInt('startmin') ?? 0;
    endmin = preference.getInt('endmin') ?? 0;
    log(starthour.toString());
    log(endhour.toString());
    log(workdays.toString());
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 8.h,
          width: 90.w,
          decoration: BoxDecoration(
            color: checkin ? Colors.green : Colors.red,
            borderRadius: BorderRadius.circular(15),
          ),
          margin: EdgeInsets.only(top: 3.h),
          child: Center(
            child: Text(
              checkin
                  ? 'تۆ لە ئێستادا لەکاردایت'
                  : 'تۆ لە ئێستادا لەکاردا نیت تکایە چوونەژوورەوە بکە',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: checkin
                  ? null
                  : () {
                      setState(() {
                        checkinpage = true;
                      });
                    },
              child: Container(
                height: 8.h,
                width: 40.w,
                decoration: BoxDecoration(
                  color: checkin
                      ? Colors.grey
                      : Material1.primaryColor, // Grey out if disabled
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
              onTap: !checkin
                  ? null
                  : () {
                      setState(() {
                        checkinpage = false;
                      });
                    },
              child: Container(
                height: 8.h,
                width: 40.w,
                decoration: BoxDecoration(
                  color: !checkin
                      ? Colors.grey
                      : Material1.primaryColor, // Grey out if disabled
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
                        color: Colors
                            .white, //const Color.fromARGB(255, 205, 63, 63),
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
                        color: checkin ? Colors.grey : Material1.primaryColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              checkin ? Colors.red : Material1.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: checkin
                            ? null
                            : () async {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Center(
                                          child: Column(
                                            children: [
                                              CircularProgressIndicator(),
                                              SizedBox(height: 2.h),
                                              Text('تکایە چاوەڕێکەوە',
                                                  style: TextStyle(
                                                      fontSize: 16.sp)),
                                            ],
                                          ),
                                        ),
                                      );
                                    });

                                await _getCurrentPosition();
                                await getuserinfo();
                                double distanceInMeters =
                                    Geolocator.distanceBetween(worklatitude,
                                        worklongtitude, latitude, longtitude);

                                if (distanceInMeters > 100) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('هەڵە'),
                                          content: Text(
                                              'تکایە لە ناوچەی کاری خۆت چوونەژوورەوە بکە'),
                                          actions: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Material1.primaryColor,
                                                foregroundColor: Colors.white,
                                              ),
                                              child: Text('باشە'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                              },
                                            ),
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
                                          content:
                                              Text('تکایە چوونەدەرەووە بکە'),
                                          actions: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Material1.primaryColor,
                                                foregroundColor: Colors.white,
                                              ),
                                              child: Text('باشە'),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                            ),
                                          ],
                                        );
                                      });
                                  return;
                                }

                                bool isNewDay = false;
                                await FirebaseFirestore.instance
                                    .collection('user')
                                    .doc(email)
                                    .collection('checkincheckouts')
                                    .orderBy('time', descending: true)
                                    .limit(1)
                                    .get()
                                    .then((value2) {
                                  if ((value2.docs.first.data()['time']
                                              as Timestamp)
                                          .toDate()
                                          .day !=
                                      DateTime.now().day) {
                                    isNewDay = true;
                                  }
                                });

                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text('دڵنیاکردنەوە'),
                                        content:
                                            Text('دڵنیایت لە چوونەژوورەوە؟'),
                                        actions: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Material1.primaryColor,
                                              foregroundColor: Colors.white,
                                            ),
                                            child: Text('پەشیمان بوونەوە'),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: checkin
                                                  ? Colors.grey
                                                  : Material1.primaryColor,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: checkin
                                                ? null
                                                : () async {
                                                    DateTime startDate =
                                                        DateTime.now()
                                                            .toLocal();
                                                    int offset =
                                                        await NTP.getNtpOffset(
                                                            localTime:
                                                                startDate);
                                                    DateTime now =
                                                        startDate.add(Duration(
                                                            milliseconds:
                                                                offset));

                                                    FirebaseFirestore.instance
                                                        .collection('user')
                                                        .doc(email)
                                                        .collection(
                                                            'checkincheckouts')
                                                        .doc(now
                                                            .toIso8601String())
                                                        .set({
                                                      'latitude': latitude,
                                                      'longtitude': longtitude,
                                                      'time': now,
                                                      'note':
                                                          notecontroller.text,
                                                      'checkout': false,
                                                      'checkin': true,
                                                    }).then((value) {
                                                      FirebaseFirestore.instance
                                                          .collection('user')
                                                          .doc(email)
                                                          .get()
                                                          .then((value) {
                                                        value.reference.update({
                                                          'checkin': true
                                                        }).then((value1) {
                                                          if (isNewDay) {
                                                            DateTime?
                                                                changedworktimeend;

                                                            try {
                                                              changedworktimeend =
                                                                  (value.data()![
                                                                              'changedworkend']
                                                                          as Timestamp)
                                                                      .toDate();
                                                            } catch (e) {
                                                              changedworktimeend =
                                                                  null;
                                                            }

                                                            if (changedworktimeend
                                                                    ?.isAfter(
                                                                        now) ??
                                                                false) {
                                                              log('changedworktimeend');
                                                              starthour = int
                                                                  .parse(value
                                                                          .data()![
                                                                      'changedworkstarthour']);
                                                              startmin = int.parse(
                                                                  value.data()![
                                                                      'changedworkstartmin']);
                                                            }

                                                            if (now.hour >=
                                                                    starthour &&
                                                                ((now.hour ==
                                                                        starthour)
                                                                    ? now.minute >
                                                                        startmin
                                                                    : true)) {
                                                              Duration late = now
                                                                  .difference(DateTime(
                                                                      now.year,
                                                                      now.month,
                                                                      now.day,
                                                                      starthour,
                                                                      startmin));
                                                              FirebaseFirestore
                                                                  .instance
                                                                  .collection(
                                                                      'user')
                                                                  .doc(email)
                                                                  .collection(
                                                                      'rewardpunishment')
                                                                  .doc(
                                                                      'punishment-late-login${DateTime.now()}')
                                                                  .set({
                                                                'addedby':
                                                                    'system',
                                                                'amount': (late
                                                                            .inMinutes *
                                                                        100)
                                                                    .toString(),
                                                                'date': DateTime
                                                                    .now(),
                                                                'reason':
                                                                    'for late login ${late.inMinutes} minutes',
                                                                'type':
                                                                    'punishment'
                                                              }).then((value) {
                                                                showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (context) {
                                                                      return AlertDialog(
                                                                        title: Text(
                                                                            'ئاگاداری'),
                                                                        content:
                                                                            Text('لەکاتی خۆی درەنگتر چوونەژوورەوەت کردوە و سزا دراویت دەتوانیت لە بەشی پاداشت و سزا بیبیت '),
                                                                        actions: [
                                                                          ElevatedButton(
                                                                            style:
                                                                                ElevatedButton.styleFrom(
                                                                              backgroundColor: Material1.primaryColor,
                                                                              foregroundColor: Colors.white,
                                                                            ),
                                                                            child:
                                                                                Text('باشە'),
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.pop(context);
                                                                            },
                                                                          )
                                                                        ],
                                                                      );
                                                                    });
                                                              });
                                                            }
                                                          }

                                                          Sharedpreference
                                                              .checkin(
                                                                  now.toString(),
                                                                  latitude,
                                                                  longtitude,
                                                                  true);
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.pop(
                                                              context);
                                                          setState(() {
                                                            checkin = true;
                                                          });
                                                        });
                                                      });
                                                    });
                                                  },
                                            child: Text('چوونەژوورەوە'),
                                          ),
                                        ],
                                      );
                                    });
                              },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer, color: Colors.white),
                            SizedBox(width: 8),
                            Text('چوونەژوورەوە'),
                          ],
                        ),
                      )),
                  permissions.contains('workoutside')
                      ? Container(
                          margin: EdgeInsets.only(top: 3.h),
                          height: 8.h,
                          width: 80.w,
                          decoration: BoxDecoration(
                            color:
                                checkin ? Colors.grey : Material1.primaryColor,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Material1.primaryColor,
                              foregroundColor: Colors.white,
                            ),
                            onPressed: checkin
                                ? null
                                : () async {
                                    await getuserinfo();
                                    if (checkin) {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('هەڵە'),
                                              content: Text(
                                                  'تکایە چوونەدەرەووە بکە'),
                                              actions: [
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Material1.primaryColor,
                                                    foregroundColor:
                                                        Colors.white,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('باشە'),
                                                ),
                                              ],
                                            );
                                          });
                                      return;
                                    }

                                    bool isNewDay = false;
                                    await FirebaseFirestore.instance
                                        .collection('user')
                                        .doc(email)
                                        .collection('checkincheckouts')
                                        .orderBy('time', descending: true)
                                        .limit(1)
                                        .get()
                                        .then((value2) {
                                      if ((value2.docs.first.data()['time']
                                                  as Timestamp)
                                              .toDate()
                                              .day !=
                                          DateTime.now().day) {
                                        isNewDay = true;
                                      }
                                    });

                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text('دڵنیاکردنەوە'),
                                            content: Text(
                                                'دڵنیایت لە چوونەژوورەوە؟'),
                                            actions: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Material1.primaryColor,
                                                  foregroundColor: Colors.white,
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('پەشیمان بوونەوە'),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Material1.primaryColor,
                                                  foregroundColor: Colors.white,
                                                ),
                                                onPressed: () async {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          title: Center(
                                                            child: Column(
                                                              children: [
                                                                CircularProgressIndicator(),
                                                                SizedBox(
                                                                    height:
                                                                        2.h),
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
                                                          milliseconds:
                                                              offset));

                                                  FirebaseFirestore.instance
                                                      .collection('user')
                                                      .doc(email)
                                                      .collection(
                                                          'checkincheckouts')
                                                      .doc(
                                                          now.toIso8601String())
                                                      .set({
                                                    'latitude': latitude,
                                                    'longtitude': longtitude,
                                                    'time': now,
                                                    'note': notecontroller.text,
                                                    'checkout': false,
                                                    'checkin': true,
                                                  }).then((value) {
                                                    if (isNewDay) {
                                                      if (workdays.contains(
                                                          now.weekday)) {
                                                        if (now.hour >=
                                                                starthour &&
                                                            ((now.hour ==
                                                                    starthour)
                                                                ? now.minute >
                                                                    startmin
                                                                : true)) {
                                                          Duration late =
                                                              now.difference(
                                                                  DateTime(
                                                                      now.year,
                                                                      now.month,
                                                                      now.day,
                                                                      starthour,
                                                                      startmin));
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'user')
                                                              .doc(email)
                                                              .collection(
                                                                  'rewardpunishment')
                                                              .doc(
                                                                  'punishment-late-login${DateTime.now()}')
                                                              .set({
                                                            'addedby': 'system',
                                                            'amount':
                                                                (late.inMinutes *
                                                                        100)
                                                                    .toString(),
                                                            'date':
                                                                DateTime.now(),
                                                            'reason':
                                                                'for late login ${late.inMinutes} minutes',
                                                            'type': 'punishment'
                                                          }).then((value) {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder:
                                                                    (context) {
                                                                  return AlertDialog(
                                                                    title: Text(
                                                                        'ئاگاداری'),
                                                                    content: Text(
                                                                        'لەکاتی خۆی درەنگتر چوونەژوورەوەت کردوە و سزا دراویت دەتوانیت لە بەشی پاداشت و سزا بیبیت'),
                                                                    actions: [
                                                                      ElevatedButton(
                                                                        style: ElevatedButton
                                                                            .styleFrom(
                                                                          backgroundColor:
                                                                              Material1.primaryColor,
                                                                          foregroundColor:
                                                                              Colors.white,
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child: Text(
                                                                            'باشە'),
                                                                      )
                                                                    ],
                                                                  );
                                                                });
                                                          });
                                                        }
                                                      }
                                                    }

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
                                                      setState(() {
                                                        checkin = true;
                                                      });
                                                    });
                                                  });
                                                },
                                                child: Text('چوونەژوورەوە'),
                                              )
                                            ],
                                          );
                                        });
                                  },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.timer, color: Colors.white),
                                SizedBox(width: 8),
                                Text('چوونەژوورەوە لە دەروەی شوێنی ئیشکردن'),
                              ],
                            ),
                          ),
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
                        color: !checkin ? Colors.grey : Material1.primaryColor,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Material1.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: !checkin
                            ? null
                            : () async {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Center(
                                          child: Column(
                                            children: [
                                              CircularProgressIndicator(),
                                              SizedBox(height: 2.h),
                                              Text('تکایە چاوەڕێکەوە',
                                                  style: TextStyle(
                                                      fontSize: 16.sp)),
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
                                          content:
                                              Text('تکایە چوونەژوورەوە بکە'),
                                          actions: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    Material1.primaryColor,
                                                foregroundColor: Colors.white,
                                              ),
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: Text('باشە'),
                                            ),
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
                                            Text('دڵنیایت لە چوونەدەرەوە؟'),
                                        actions: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Material1.primaryColor,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('پەشیمان بوونەوە'),
                                          ),
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Material1.primaryColor,
                                              foregroundColor: Colors.white,
                                            ),
                                            onPressed: () async {
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
                                                  Navigator.pop(context);
                                                  setState(() {
                                                    checkin = false;
                                                  });
                                                });
                                              });
                                            },
                                            child: Text('چوونەدەرەوە'),
                                          )
                                        ],
                                      );
                                    });
                              },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer_outlined, color: Colors.red),
                            SizedBox(width: 8),
                            Text('چوونەدەرەوە'),
                          ],
                        ),
                      )),
                ],
              )
      ],
    );
  }
}
