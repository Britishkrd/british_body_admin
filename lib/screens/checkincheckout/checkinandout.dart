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
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: Offset(0, 4),
              )
            ],
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
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5),
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
                      : Material1.primaryColor,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                margin: EdgeInsets.only(top: 3.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'چوونەژوورەوە',
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    Icon(Icons.login_rounded, color: Colors.white),
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
                      : Color(0xFFE53935), // Red color for logout
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    )
                  ],
                ),
                margin: EdgeInsets.only(top: 3.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'چوونەدەرەوە',
                      style: TextStyle(
                        color: Colors.white, 
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600
                      ),
                    ),
                    Icon(Icons.logout_rounded, color: Colors.white),
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Material1.textfield(
                          hint: 'تێبینی(هەڵبژاردەییە)',
                          textColor: Material1.primaryColor,
                          controller: notecontroller)),
                  SizedBox(height: 2.h),
                  Container(
                    margin: EdgeInsets.only(top: 1.h),
                    height: 8.h,
                    width: 40.w,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: checkin ? Colors.grey : Material1.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.2),
                        padding: EdgeInsets.symmetric(horizontal: 20),
                      ),
                      onPressed: checkin
                          ? null
                          : () async {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      title: Center(
                                        child: Column(
                                          children: [
                                            CircularProgressIndicator(),
                                            SizedBox(height: 2.h),
                                            Text('تکایە چاوەڕێکەوە',
                                                style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w600)),
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
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        title: Text('هەڵە',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        content: Text(
                                            'تکایە لە ناوچەی کاری خۆت چوونەژوورەوە بکە'),
                                        actions: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Material1.primaryColor,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              elevation: 2,
                                            ),
                                            child: Text('باشە',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600)),
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
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        title: Text('هەڵە',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        content: Text('تکایە چوونەدەرەووە بکە'),
                                        actions: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Material1.primaryColor,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                              elevation: 2,
                                            ),
                                            child: Text('باشە',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600)),
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
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      title: Text('دڵنیاکردنەوە',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      content: Text('دڵنیایت لە چوونەژوورەوە؟'),
                                      actions: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[200],
                                            foregroundColor: Colors.black87,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            elevation: 2,
                                          ),
                                          child: Text('پەشیمان بوونەوە',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600)),
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
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            elevation: 4,
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
                                                              'date':
                                                                  DateTime.now(),
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
                                                                      shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(
                                                                            20),
                                                                      ),
                                                                      title: Text(
                                                                          'ئاگاداری',
                                                                          style: TextStyle(
                                                                              fontWeight:
                                                                                  FontWeight.bold)),
                                                                      content: Text(
                                                                          'لەکاتی خۆی درەنگتر چوونەژوورەوەت کردوە و سزا دراویت دەتوانیت لە بەشی پاداشت و سزا بیبیت '),
                                                                      actions: [
                                                                        ElevatedButton(
                                                                          style:
                                                                              ElevatedButton.styleFrom(
                                                                            backgroundColor:
                                                                                Material1.primaryColor,
                                                                            foregroundColor:
                                                                                Colors.white,
                                                                            shape:
                                                                                RoundedRectangleBorder(
                                                                              borderRadius: BorderRadius.circular(10),
                                                                            ),
                                                                            elevation:
                                                                                2,
                                                                          ),
                                                                          child:
                                                                              Text('باشە', style: TextStyle(fontWeight: FontWeight.w600)),
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
                                          child: Text('چوونەژوورەوە',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                      ],
                                    );
                                  });
                            },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.login_rounded, color: Colors.white),
                          SizedBox(width: 8),
                          Text('چوونەژوورەوە',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )),
                  SizedBox(height: 2.h),
                  permissions.contains('workoutside')
                      ? Container(
                          height: 8.h,
                          width: 80.w,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: checkin
                                  ? Colors.grey
                                  : Material1.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              elevation: 4,
                              shadowColor: Colors.black.withOpacity(0.2),
                              padding: EdgeInsets.symmetric(horizontal: 20),
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
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(20),
                                              ),
                                              title: Text('هەڵە',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                              content:
                                                  Text('تکایە چوونەدەرەووە بکە'),
                                              actions: [
                                                ElevatedButton(
                                                  style:
                                                      ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Material1.primaryColor,
                                                    foregroundColor:
                                                        Colors.white,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10),
                                                    ),
                                                    elevation: 2,
                                                  ),
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: Text('باشە',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w600)),
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
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            title: Text('دڵنیاکردنەوە',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            content: Text(
                                                'دڵنیایت لە چوونەژوورەوە؟'),
                                            actions: [
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Colors.grey[200],
                                                  foregroundColor:
                                                      Colors.black87,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  elevation: 2,
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('پەشیمان بوونەوە',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              ),
                                              ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor:
                                                      Material1.primaryColor,
                                                  foregroundColor:
                                                      Colors.white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  elevation: 4,
                                                ),
                                                onPressed: () async {
                                                  showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return AlertDialog(
                                                          shape:
                                                              RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                          ),
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
                                                                            16.sp,
                                                                        fontWeight:
                                                                            FontWeight.w600)),
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
                                                                    shape:
                                                                        RoundedRectangleBorder(
                                                                      borderRadius:
                                                                          BorderRadius.circular(
                                                                              20),
                                                                    ),
                                                                    title: Text(
                                                                        'ئاگاداری',
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold)),
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
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(10),
                                                                          ),
                                                                          elevation:
                                                                              2,
                                                                        ),
                                                                        onPressed:
                                                                            () {
                                                                          Navigator.pop(
                                                                              context);
                                                                        },
                                                                        child: Text(
                                                                            'باشە',
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.w600)),
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
                                                child: Text('چوونەژوورەوە',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600)),
                                              )
                                            ],
                                          );
                                        });
                                  },
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.login_rounded, color: Colors.white),
                                SizedBox(width: 8),
                                Text('چوونەژوورەوە لە دەروەی شوێنی ئیشکردن',
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600)),
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
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 6,
                            offset: Offset(0, 2),
                          )
                        ],
                      ),
                      child: Material1.textfield(
                          hint: 'تێبینی(هەڵبژاردەییە)',
                          textColor: Material1.primaryColor,
                          controller: notecontroller)),
                  SizedBox(height: 2.h),
                  Container(
                    height: 8.h,
                    width: 40.w,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            !checkin ? Colors.grey : Color(0xFFE53935),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.2),
                        padding: EdgeInsets.symmetric(horizontal: 20),
                      ),
                      onPressed: !checkin
                          ? null
                          : () async {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    return AlertDialog(
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      title: Center(
                                        child: Column(
                                          children: [
                                            CircularProgressIndicator(),
                                            SizedBox(height: 2.h),
                                            Text('تکایە چاوەڕێکەوە',
                                                style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight: FontWeight.w600)),
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
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        title: Text('هەڵە',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        content:
                                            Text('تکایە چوونەژوورەوە بکە'),
                                        actions: [
                                          ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor:
                                                  Material1.primaryColor,
                                              foregroundColor: Colors.white,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                              elevation: 2,
                                            ),
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('باشە',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600)),
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
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      title: Text('دڵنیاکردنەوە',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      content: Text('دڵنیایت لە چوونەدەرەوە؟'),
                                      actions: [
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.grey[200],
                                            foregroundColor: Colors.black87,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            elevation: 2,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('پەشیمان بوونەوە',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600)),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFFE53935),
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            elevation: 4,
                                          ),
                                          onPressed: () async {
                                            DateTime startDate =
                                                DateTime.now().toLocal();
                                            int offset = await NTP.getNtpOffset(
                                                localTime: startDate);
                                            DateTime now = startDate.add(
                                                Duration(
                                                    milliseconds: offset));

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
                                                Navigator.pop(context);
                                                setState(() {
                                                  checkin = false;
                                                });
                                              });
                                            });
                                          },
                                          child: Text('چوونەدەرەوە',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w600)),
                                        )
                                      ],
                                    );
                                  });
                            },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.logout_rounded, color: Colors.white),
                          SizedBox(width: 8),
                          Text('چوونەدەرەوە',
                              style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )),
                ],
              )
      ],
    );
  }
}