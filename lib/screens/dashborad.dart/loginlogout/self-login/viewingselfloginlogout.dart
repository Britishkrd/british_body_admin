import 'dart:developer';

import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

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
                  function: () {
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
                    Duration targetWorkTime =
                        Duration(hours: totalWorkDays * 8);
                    log(targetWorkTime.toString());

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
                        totalworkedtime += value.docs[i + 1]['time']
                            .toDate()
                            .difference(value.docs[i]['time'].toDate());
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
