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
    DateTime firstDayOfMonth = DateTime(widget.date.year, widget.date.month, 1);
    DateTime lastDayOfMonth =
        DateTime(widget.date.year, widget.date.month + 1, 0)
            .add(Duration(days: 1)); // Include the entire last day

    return Scaffold(
      appBar: AppBar(
        title: const Text('بینینی چوونەژوورەوە / دەرچوونەوە'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('user')
                    .doc(widget.email)
                    .collection('checkincheckouts')
                    .where('time', isGreaterThanOrEqualTo: firstDayOfMonth)
                    .where('time', isLessThan: lastDayOfMonth)
                    .orderBy('time', descending: true)
                    .get(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  // Error handling
                  if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  }

                  // Loading state
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // No data state
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(
                        child: Text("No records found for this month"));
                  }

                  // Data exists - build the list
                  return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (BuildContext context, int index) {
                        var doc = snapshot.data!.docs[index];
                        return Container(
                          margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
                          padding: EdgeInsets.all(1.h),
                          decoration: BoxDecoration(
                            color: doc['checkin'] == false
                                ? Colors.redAccent
                                : Colors.greenAccent,
                            borderRadius: BorderRadius.circular(5),
                            boxShadow: const [
                              BoxShadow(color: Colors.grey, blurRadius: 5)
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "جۆر : ${doc['checkin'] == true ? 'چوونەژوورەوە' : 'چوونەدەرەوە'}",
                                style: const TextStyle(
                                    fontSize: 15, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "${doc['time'].toDate()} : کات ",
                                style: const TextStyle(fontSize: 15),
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
                                                      'https://www.google.com/maps/search/?api=1&query=${snapshot.data!.docs[index]['latitude']},${snapshot.data!.docs[index]['longtitude']}'))) {
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
                                      "${snapshot.data!.docs[index]['latitude']}-${snapshot.data!.docs[index]['longtitude']}",
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.blue),
                                    ),
                                    Text(
                                      " : شوێن",
                                      style: const TextStyle(fontSize: 14),
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
                        );
                      });
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
                  // Calculate work days in month (excluding Fridays)
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

                  // Get work schedule from preferences
                  final SharedPreferences preference =
                      await SharedPreferences.getInstance();
                  int starthour = preference.getInt('starthour') ?? 0;
                  int endhour = preference.getInt('endhour') ?? 0;
                  int startmin = preference.getInt('startmin') ?? 0;
                  int endmin = preference.getInt('endmin') ?? 0;

                  // Calculate target work time for month
                  Duration targetWorkTime = Duration(
                          hours: endhour - starthour,
                          minutes: endmin - startmin) *
                      totalWorkDays;

                  // Get checkin/checkout records for the month
                  FirebaseFirestore.instance
                      .collection('user')
                      .doc(widget.email)
                      .collection('checkincheckouts')
                      .where('time', isGreaterThanOrEqualTo: firstDayOfMonth)
                      .where('time',
                          isLessThan: lastDayOfMonth
                              .add(Duration(days: 1))) // Include last day
                      .orderBy('time')
                      .get()
                      .then((querySnapshot) {
                    Duration totalworkedtime = Duration();
                    List<QueryDocumentSnapshot> docs = querySnapshot.docs;

                    // Calculate total worked time from pairs of checkin/checkout
                    for (var i = 0; i < docs.length - 1; i++) {
                      if (docs[i]['checkin'] == true &&
                          docs[i + 1]['checkin'] == false) {
                        totalworkedtime += docs[i + 1]['time']
                            .toDate()
                            .difference(docs[i]['time'].toDate());
                      }
                    }

                    // Show results dialog
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('کاتی کارکردن'),
                            content: Text(
                                'کاتی کارکردن : ${totalworkedtime.inHours} کاتژمێر ${totalworkedtime.inMinutes.remainder(60)} خولەک\n'
                                'کاتی ئامانج : ${targetWorkTime.inHours} کاتژمێر ${targetWorkTime.inMinutes.remainder(60)} خولەک'),
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
                },
              ),
            ),
          )
        ],
      ),
    );
  }
}
