import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/dashborad.dart/loginlogout/editingloginlogout.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginLogoutManagement extends StatefulWidget {
  final String email;
  final DateTime date;
  final String name;
  const LoginLogoutManagement(
      {super.key, required this.email, required this.date, required this.name});

  @override
  State<LoginLogoutManagement> createState() => _LoginLogoutManagementState();
}

class _LoginLogoutManagementState extends State<LoginLogoutManagement> {
  Future<List<String>> todaysworktime(int day) async {
    Duration worktime = Duration.zero;
    Duration rest = Duration.zero;

    await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.email)
        .collection('checkincheckouts')
        .where('time',
            isGreaterThanOrEqualTo:
                DateTime(widget.date.year, widget.date.month, day))
        .where('time',
            isLessThan: DateTime(widget.date.year, widget.date.month, day + 1))
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        for (var i = 0; i < value.docs.length; i = i + 2) {
          if (i + 1 == value.docs.length) {
            break;
          }
          if (value.docs[i]['checkin'] == false) {
            if (i + 2 == value.docs.length) {
              break;
            }

            worktime += value.docs[i + 2]['time']
                .toDate()
                .difference(value.docs[i + 1]['time'].toDate());
          } else {
            worktime += value.docs[i + 1]['time']
                .toDate()
                .difference(value.docs[i]['time'].toDate());
          }
        }
      }
      // if (islastactionlogin) {
      //   worktime += DateTime.now().difference(lastaction);
      // }
    });
    await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.email)
        .collection('checkincheckouts')
        .where('time',
            isGreaterThanOrEqualTo:
                DateTime(widget.date.year, widget.date.month, day))
        .where('time',
            isLessThan: DateTime(widget.date.year, widget.date.month, day + 1))
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        for (var i = 0; i < value.docs.length; i = i + 2) {
          if (i + 1 == value.docs.length) {
            break;
          }
          if (value.docs[i]['checkout'] == false) {
            if (i + 2 == value.docs.length) {
              break;
            }

            rest += value.docs[i + 2]['time']
                .toDate()
                .difference(value.docs[i + 1]['time'].toDate());
          } else {
            rest += value.docs[i + 1]['time']
                .toDate()
                .difference(value.docs[i]['time'].toDate());
          }
        }
      }
    });
    return [worktime.toString(), rest.toString()];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.name),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('user')
            .doc(widget.email)
            .collection('checkincheckouts')
            .where('time',
                isGreaterThanOrEqualTo:
                    DateTime(widget.date.year, widget.date.month, 1))
            .where('time',
                isLessThanOrEqualTo: DateTime(
                    widget.date.year,
                    widget.date.month,
                    (DateTime(widget.date.year, widget.date.month + 1, 0).day)))
            .get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Group data by day
          Map<int, List<QueryDocumentSnapshot>> groupedData = {};
          for (var doc in snapshot.data?.docs ?? []) {
            DateTime time = (doc['time'] as Timestamp).toDate();
            int day = time.day;

            if (!groupedData.containsKey(day)) {
              groupedData[day] = [];
            }
            groupedData[day]!.add(doc);
          }

          return ListView(
            children: groupedData.entries.map((entry) {
              int day = entry.key;
              List<QueryDocumentSnapshot> records = entry.value;

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Add a widget for the day header
                  FutureBuilder(
                      future: todaysworktime(day),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                        return Text(
                          "ڕۆژی: $day - کاتی ئیشکرند : ${snapshot.data![0].substring(0, 8).toString()}   -  کاتی ڕێست :  ${snapshot.data![1].substring(0, 8).toString()}",
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }),
                  const Divider(), // Add a divider between days

                  // Display the records for the day
                  ...records.map((doc) {
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: const Text(
                                    'دەتەوێت چی لە چوونەژوورەوە / دەرچوونەوەی ئەم کارمەندە بکەیت'),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.push(context,
                                            MaterialPageRoute(
                                                builder: (context) {
                                          return EditingLoginLogout(
                                            reference: doc.reference,
                                            email: widget.email,
                                            time: (doc['time'] as Timestamp)
                                                .toDate(),
                                            checkin: doc['checkin'],
                                            note: doc['note'],
                                            checkout: doc['checkout'],
                                            latitude: doc['latitude'],
                                            longtitude: doc['longtitude'],
                                          );
                                        }));
                                      },
                                      child: const Text(
                                          'دەستکاری کردنی چوونەژوورەوە / دەرچوونەوە')),
                                  TextButton(
                                      onPressed: () {
                                        showdeletdialog(context, doc.reference);
                                      },
                                      child: const Text(
                                          'سڕینەوەی چوونەژوورەوە / چوونەدەرەوە',
                                          style: TextStyle(color: Colors.red))),
                                ],
                              );
                            });
                      },
                      child: SizedBox(
                        height: 20.h,
                        width: 90.w,
                        child: Container(
                          margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
                          padding: EdgeInsets.all(1.h),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.grey,
                                blurRadius: 5,
                              )
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "جۆر : ${doc['checkin'] == true ? 'چوونەژوورەوە' : 'چوونەدەرەوە'}",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${(doc['time'] as Timestamp).toDate()} : کات ",
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: const Text('شوێن'),
                                          content:
                                              Text("دڵنییایت لە بینینی شوێن"),
                                          actions: [
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('نەخێر')),
                                            TextButton(
                                                onPressed: () async {
                                                  if (!await launchUrl(Uri.parse(
                                                      'https://www.google.com/maps/search/?api=1&query=${doc['latitude']},${doc['longtitude']}'))) {
                                                    throw Exception(
                                                        'Could not launch ');
                                                  }
                                                },
                                                child: const Text('بەڵێ')),
                                          ],
                                        );
                                      });
                                },
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      "${doc['latitude']}-${doc['longtitude']}",
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.blue),
                                    ),
                                    const Text(
                                      " : شوێن",
                                      style: TextStyle(fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                "${doc['note']} : تێبینی",
                                style: const TextStyle(
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }

  showdeletdialog(BuildContext context, DocumentReference referece) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
                'دڵنییایت لە سڕینەوەی ئەم چوونەژوورەوە / چوونەدەرەوە؟'),
            content: Text(
              'تکایە ئاگاداربە کە دەبێت چوونەژوورەوەیەک و چوونەدەرەوەیەک بە دوای یەکدا بن!',
              style: TextStyle(color: Colors.red),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    referece.delete();
                  },
                  child:
                      const Text('بەڵێ', style: TextStyle(color: Colors.red))),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('نەخێر')),
            ],
          );
        });
  }
}
