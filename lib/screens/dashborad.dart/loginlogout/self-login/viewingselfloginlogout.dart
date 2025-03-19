import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

import 'hoursworked.dart';

class Viewingselfloginlogout extends StatefulWidget {
  final String email;
  final DateTime date;
  const Viewingselfloginlogout(
      {super.key, required this.email, required this.date});

  @override
  State<Viewingselfloginlogout> createState() => _ViewingselfloginlogoutState();
}

class _ViewingselfloginlogoutState extends State<Viewingselfloginlogout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بینینی چوونەژوورەوە / دەرچوونەوە'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 75.h,
            child: FutureBuilder(
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
                            (DateTime(
                                    widget.date.year, widget.date.month + 1, 0)
                                .day)))
                    .get(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return SizedBox(
                    height: ((snapshot.data?.docs.length ?? 0) * 20).h,
                    width: 100.w,
                    child: ListView.builder(
                        itemCount: snapshot.data?.docs.length ?? 0,
                        itemBuilder: (BuildContext context, int index) {
                          return SizedBox(
                              height: 20.h,
                              width: 90.w,
                              child: Container(
                                margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
                                padding: EdgeInsets.all(1.h),
                                decoration: BoxDecoration(
                                  color: snapshot.data!.docs[index]
                                              ['checkin'] ==
                                          false
                                      ? Colors.redAccent
                                      : Colors.greenAccent,
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
                                      "جۆر : ${snapshot.data!.docs[index]['checkin'] == true ? 'چوونەژوورەوە' : 'چوونەدەرەوە'}",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "${snapshot.data!.docs[index]['time'].toDate()} : کات ",
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
                                                content: Text(
                                                    "دڵنییایت لە بینینی شوێن"),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      child:
                                                          const Text('نەخێر')),
                                                  TextButton(
                                                      onPressed: () async {
                                                        if (!await launchUrl(
                                                            Uri.parse(
                                                                'https://www.google.com/maps/search/?api=1&query=${snapshot.data!.docs[index]['latitude']},${snapshot.data!.docs[index]['longtitude']}'))) {
                                                          throw Exception(
                                                              'Could not launch ');
                                                        }
                                                      },
                                                      child:
                                                          const Text('بەڵێ')),
                                                ],
                                              );
                                            });
                                      },
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                            "${snapshot.data!.docs[index]['latitude']}-${snapshot.data!.docs[index]['longtitude']}",
                                            style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.blue),
                                          ),
                                          Text(
                                            " : شوێن",
                                            style:
                                                const TextStyle(fontSize: 14),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      "${snapshot.data!.docs[index]['note']} : تێبینی",
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              ));
                        }),
                  );
                }),
          ),
          SafeArea(
            child: Container(
              height: 6.h,
              width: 80.w,
              margin: EdgeInsets.all(5.w),
              child: Material1.button(
                  label: 'بینینی بڕی ئیشکردن',
                  buttoncolor: Material1.primaryColor,
                  textcolor: Colors.white,
                  function: () async {
                    int totalWorkDays = 0;
                    DateTime firstDayOfMonth =
                        DateTime(widget.date.year, widget.date.month, 1);
                    DateTime lastDayOfMonth =
                        DateTime(widget.date.year, widget.date.month + 1, 0);

                    for (DateTime day = firstDayOfMonth;
                        day.isBefore(lastDayOfMonth) ||
                            day.isAtSameMomentAs(lastDayOfMonth);
                        day = day.add(const Duration(days: 1))) {
                      if (day.weekday != DateTime.friday) {
                        totalWorkDays++;
                      }
                    }
                    final SharedPreferences preference =
                        await SharedPreferences.getInstance();

                    int starthour = 0;
                    int endhour = 0;
                    int startmin = 0;
                    int endmin = 0;
                    starthour = preference.getInt('starthour') ?? 0;
                    endhour = preference.getInt('endhour') ?? 0;
                    startmin = preference.getInt('startmin') ?? 0;
                    endmin = preference.getInt('endmin') ?? 0;
                    Duration targetWorkTime = Duration();

                    targetWorkTime = Duration(
                        hours: endhour - starthour, minutes: endmin - startmin);

                    targetWorkTime *= totalWorkDays;

                    FirebaseFirestore.instance
                        .collection('user')
                        .doc(widget.email)
                        .collection('checkincheckouts')
                        .where('time',
                            isGreaterThanOrEqualTo: DateTime(
                                widget.date.year, widget.date.month, 1))
                        .where('time',
                            isLessThanOrEqualTo: DateTime(
                                widget.date.year,
                                widget.date.month,
                                (DateTime(widget.date.year,
                                        widget.date.month + 1, 0)
                                    .day)))
                        .get()
                        .then((value) {
                      Duration totalworkedtime = Duration();

                      for (var i = 0; i < value.docs.length; i = i + 2) {
                        if (i + 1 == value.docs.length) {
                          break;
                        }
                        if (value.docs[i]['checkin'] == false) {
                          if (i + 2 == value.docs.length) {
                            break;
                          }

                          totalworkedtime += value.docs[i + 2]['time']
                              .toDate()
                              .difference(value.docs[i + 1]['time'].toDate());
                        } else {
                          totalworkedtime += value.docs[i + 1]['time']
                              .toDate()
                              .difference(value.docs[i]['time'].toDate());
                        }
                      }
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: const Text('کاتی کارکردن'),
                              content: Text(
                                  'کاتی کارکردن : ${totalworkedtime.inHours} کاتژمێر  ${totalworkedtime.inMinutes.remainder(60)} خولەک'),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Hoursworked(
                                                  totalworkedtime:
                                                      totalworkedtime,
                                                  targettime: targetWorkTime,
                                                  date: widget.date)));
                                    },
                                    child: const Text('دڵنیابوون')),
                              ],
                            );
                          });
                    });
                  }),
            ),
          )
        ],
      ),
    );
  }
}
