import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

bool checkin = true;
double worklatitude = 0.0;
double worklongtitude = 0.0;

TextEditingController notecontroller = TextEditingController();

String email = '';
String name = '';

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    getuserinfo();
    super.initState();
  }

  getuserinfo() async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    email = preference.getString('email') ?? '';
    name = preference.getString('name') ?? '';
    checkin = preference.getBool('checkin') ?? false;
    worklatitude = preference.getDouble('worklat') ?? 0.0;
    worklongtitude = preference.getDouble('worklong') ?? 0.0;
    setState(() {});
  }

  // Future<List<String>> todaysworktime() async {
  //   final SharedPreferences preference = await SharedPreferences.getInstance();
  //   String email = preference.getString('email') ?? '';
  //   Duration worktime = Duration.zero;
  //   Duration rest = Duration.zero;
  //   DateTime lastaction = DateTime.now();
  //   bool islastactionlogin = false;

  //   await FirebaseFirestore.instance
  //       .collection('user')
  //       .doc(email)
  //       .collection('checkincheckouts')
  //       .where('time',
  //           isGreaterThanOrEqualTo: DateTime(
  //               DateTime.now().year, DateTime.now().month, DateTime.now().day))
  //       .where('time',
  //           isLessThan: DateTime(DateTime.now().year, DateTime.now().month,
  //               DateTime.now().day + 1))
  //       .get()
  //       .then((value) async {
  //     if (value.docs.isNotEmpty) {
  //       log(value.docs.length.toString());
  //       log(value.docs[0].data().toString());
  //       for (var i = 0; i < value.docs.length; i = i + 2) {
  //         if (i + 1 == value.docs.length) {
  //           break;
  //         }
  //         if (value.docs[i]['checkin'] == false) {
  //           if (i + 2 == value.docs.length) {
  //             break;
  //           }

  //           worktime += value.docs[i + 2]['time']
  //               .toDate()
  //               .difference(value.docs[i + 1]['time'].toDate());
  //         } else {
  //           worktime += value.docs[i + 1]['time']
  //               .toDate()
  //               .difference(value.docs[i]['time'].toDate());
  //         }
  //       }
  //       islastactionlogin = value.docs.last.data()['checkin'];
  //       lastaction = value.docs.last.data()['time'].toDate();
  //     }
  //     if (islastactionlogin) {
  //       worktime += DateTime.now().difference(lastaction);
  //     }
  //   });
  //   await FirebaseFirestore.instance
  //       .collection('user')
  //       .doc(email)
  //       .collection('checkincheckouts')
  //       .where('time',
  //           isGreaterThanOrEqualTo: DateTime(
  //               DateTime.now().year, DateTime.now().month, DateTime.now().day))
  //       .where('time',
  //           isLessThan: DateTime(DateTime.now().year, DateTime.now().month,
  //               DateTime.now().day + 1))
  //       .get()
  //       .then((value) {
  //     if (value.docs.isNotEmpty) {
  //       log(value.docs.length.toString());
  //       log(value.docs[0].data().toString());
  //       for (var i = 0; i < value.docs.length; i = i + 2) {
  //         if (i + 1 == value.docs.length) {
  //           break;
  //         }
  //         if (value.docs[i]['checkout'] == false) {
  //           if (i + 2 == value.docs.length) {
  //             break;
  //           }

  //           rest += value.docs[i + 2]['time']
  //               .toDate()
  //               .difference(value.docs[i + 1]['time'].toDate());
  //         } else {
  //           rest += value.docs[i + 1]['time']
  //               .toDate()
  //               .difference(value.docs[i]['time'].toDate());
  //         }
  //       }
  //       islastactionlogin = value.docs.last.data()['checkin'];
  //       lastaction = value.docs.last.data()['time'].toDate();
  //     }
  //     log(value.docs.first.data().toString());
  //     log((value.docs.first.data()['time'] as Timestamp).toString());
  //     log((value.docs.first.data()['time'] as Timestamp).toString());
  //     log("rest ${rest.toString()}");
  //   });
  //   return [worktime.toString(), rest.toString()];
  // }

  Future<List<String>> todaysworktime() async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    String email = preference.getString('email') ?? '';
    Duration worktime = Duration.zero;
    Duration rest = Duration.zero;
    DateTime? lastaction; // Make lastaction nullable
    bool? islastactionlogin; // Make islastactionlogin nullable

    QuerySnapshot<Map<String, dynamic>> workTimeSnapshot =
        await FirebaseFirestore.instance
            .collection('user')
            .doc(email)
            .collection('checkincheckouts')
            .where('time',
                isGreaterThanOrEqualTo: DateTime(DateTime.now().year,
                    DateTime.now().month, DateTime.now().day))
            .where('time',
                isLessThan: DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day + 1))
            .get();

    if (workTimeSnapshot.docs.isNotEmpty) {
      log('Work Time Docs Length: ${workTimeSnapshot.docs.length}');
      for (var i = 0; i < workTimeSnapshot.docs.length; i = i + 2) {
        if (i + 1 >= workTimeSnapshot.docs.length) {
          break;
        }
        final doc1 = workTimeSnapshot.docs[i].data();
        final doc2 = workTimeSnapshot.docs[i + 1].data();

        if (doc1['time'] != null &&
            doc2['time'] != null &&
            doc1['checkin'] != null) {
          if (doc1['checkin'] == false) {
            if (i + 2 < workTimeSnapshot.docs.length) {
              final doc3 = workTimeSnapshot.docs[i + 2].data();
              if (doc3['time'] != null) {
                worktime += (doc3['time'] as Timestamp)
                    .toDate()
                    .difference((doc2['time'] as Timestamp).toDate());
              }
            }
          } else {
            worktime += (doc2['time'] as Timestamp)
                .toDate()
                .difference((doc1['time'] as Timestamp).toDate());
          }
        }
      }
      if (workTimeSnapshot.docs.isNotEmpty) {
        final lastDoc = workTimeSnapshot.docs.last.data();
        islastactionlogin = lastDoc['checkin'];
        lastaction = (lastDoc['time'] as Timestamp?)?.toDate();
      }
      if (islastactionlogin == true && lastaction != null) {
        worktime += DateTime.now().difference(lastaction);
      }
    }

    QuerySnapshot<Map<String, dynamic>> restTimeSnapshot =
        await FirebaseFirestore.instance
            .collection('user')
            .doc(email)
            .collection('checkincheckouts')
            .where('time',
                isGreaterThanOrEqualTo: DateTime(DateTime.now().year,
                    DateTime.now().month, DateTime.now().day))
            .where('time',
                isLessThan: DateTime(DateTime.now().year, DateTime.now().month,
                    DateTime.now().day + 1))
            .get();

    if (restTimeSnapshot.docs.isNotEmpty) {
      log('Rest Time Docs Length: ${restTimeSnapshot.docs.length}');
      for (var i = 0; i < restTimeSnapshot.docs.length; i = i + 2) {
        if (i + 1 >= restTimeSnapshot.docs.length) {
          break;
        }
        final doc1 = restTimeSnapshot.docs[i].data();
        final doc2 = restTimeSnapshot.docs[i + 1].data();

        if (doc1['time'] != null &&
            doc2['time'] != null &&
            doc1['checkout'] != null) {
          if (doc1['checkout'] == false) {
            if (i + 2 < restTimeSnapshot.docs.length) {
              final doc3 = restTimeSnapshot.docs[i + 2].data();
              if (doc3['time'] != null) {
                rest += (doc3['time'] as Timestamp)
                    .toDate()
                    .difference((doc2['time'] as Timestamp).toDate());
              }
            }
          } else {
            rest += (doc2['time'] as Timestamp)
                .toDate()
                .difference((doc1['time'] as Timestamp).toDate());
          }
        }
      }
      if (restTimeSnapshot.docs.isNotEmpty &&
          restTimeSnapshot.docs.first.data()['time'] != null) {
        log(restTimeSnapshot.docs.first.data().toString());
        log((restTimeSnapshot.docs.first.data()['time'] as Timestamp)
            .toString());
        log((restTimeSnapshot.docs.first.data()['time'] as Timestamp)
            .toString());
      }
      log("rest ${rest.toString()}");
    }

    return [worktime.toString(), rest.toString()];
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // SizedBox(
        //   width: 100.w,
        //   height: 20.h,
        //   child: Image.asset('lib/assets/logo.png'),
        // ),
        // Container(
        //   alignment: Alignment.centerRight,
        //   margin: EdgeInsets.only(top: 1.h, left: 5.w, right: 5.w),
        //   height: 5.h,
        //   width: 20.w,
        //   child: Text(
        //     'ژمارەی مۆبایل: ٠٧٧٠١٢٣٤٥٦٧',
        //     style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        //     textAlign: TextAlign.center,
        //   ),
        // ),
        // Container(
        //   alignment: Alignment.centerRight,
        //   margin: EdgeInsets.only(top: 1.h, left: 5.w, right: 5.w),
        //   height: 5.h,
        //   width: 20.w,
        //   child: Text(
        //     'ناونیشان: سلێمانی پردی نزیک پردی کۆبانێ',
        //     style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        //     textAlign: TextAlign.center,
        //   ),
        // ),
        // if (checkin)
        Container(
          width: 100.w,
          // margin: EdgeInsets.only(
          //   top: 1.h,
          // ),
          padding: EdgeInsets.all(2.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SizedBox(
                height: 4.h,
                child: Text(
                  "$name : بەکارهێنەر",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 4.h,
                child: Text(
                  "$email : ئیمەیل",
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                onTap: () {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('شوێن'),
                          content: Text("دڵنییایت لە بینینی شوێن"),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('نەخێر')),
                            TextButton(
                                onPressed: () async {
                                  if (!await launchUrl(Uri.parse(
                                      'https://www.google.com/maps/search/?api=1&query=$worklatitude,$worklongtitude'))) {
                                    throw Exception('Could not launch ');
                                  }
                                },
                                child: const Text('بەڵێ')),
                          ],
                        );
                      });
                },
                child: SizedBox(
                  height: 4.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "$worklatitude-$worklongtitude",
                        style: const TextStyle(
                            fontSize: 14,
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.blue),
                      ),
                      Text(
                        " : شوێن",
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                checkin
                    ? 'تۆ لە ئێستادا لەکاردایت'
                    : 'تۆ لە ئێستادا لەکاردا نیت تکایە چوونەژوورەوە بکە',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
        FutureBuilder(
            future: todaysworktime(),
            builder: (context, snapshot) {
              return SizedBox(
                  height: 6.h,
                  child: Text(
                      snapshot.connectionState == ConnectionState.waiting
                          ? 'تکایە چاوەڕوانبکە'
                          : " کاتی ئیشکرند : ${snapshot.data![0].substring(0, 8).toString()}   -  کاتی ڕێست :  ${snapshot.data![1].substring(0, 8).toString()}",
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold)));
            }),
        SizedBox(
          height: 60.h,
          width: 100.w,
          child: FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('company')
                  .doc('department')
                  .collection('department')
                  .get(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                    itemCount: snapshot.data?.docs.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      return ExpansionTile(
                        leading: Icon(Icons.add_box_outlined,
                            color: Colors.red, size: 20.sp),
                        title: Text(snapshot.data?.docs[index]['name'] ?? ''),
                        children: [
                          SizedBox(
                            height: (double.parse((snapshot
                                                .data
                                                ?.docs[index]['departments']
                                                .length ??
                                            0)
                                        .toString()) *
                                    5)
                                .h,
                            child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: snapshot.data
                                        ?.docs[index]['departments'].length ??
                                    0,
                                itemBuilder:
                                    (BuildContext context, int index2) {
                                  return Container(
                                    margin: EdgeInsets.only(
                                        left: 10.w, bottom: 1.h),
                                    child: Row(
                                      children: [
                                        Icon(Icons.add_box_outlined,
                                            color: Colors.red, size: 16.sp),
                                        Text(snapshot.data?.docs[index]
                                                ['departments'][index2] ??
                                            ''),
                                      ],
                                    ),
                                  );
                                }),
                          ),
                        ],
                      );
                    });
              }),
        ),
      ],
    );
  }
}
