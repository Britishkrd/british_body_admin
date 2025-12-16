import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class Viewingselfloginlogout extends StatefulWidget {
  final String email;
  final DateTime date;
  const Viewingselfloginlogout(
      {super.key, required this.email, required this.date});

  @override
  State<Viewingselfloginlogout> createState() => _ViewingselfloginlogoutState();
}

class _ViewingselfloginlogoutState extends State<Viewingselfloginlogout> {
  // ✅ بەدەستهێنانی ماوەی مووچە (٢٦ی مانگی پێشوو تا ٢٥ی ئەم مانگە)
  (DateTime start, DateTime end) _getSalaryPeriod(DateTime selectedMonth) {
    final startDate = DateTime(selectedMonth.year, selectedMonth.month - 1, 26);
    final endDate =
        DateTime(selectedMonth.year, selectedMonth.month, 25, 23, 59, 59);
    return (startDate, endDate);
  }

  // ✅ فۆرماتکردنی ماوە بۆ پشاندانی جوان
  String formatDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    int seconds = duration.inSeconds.remainder(60);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  // ✅ بەدەستهێنانی کۆی گشتی کاتی ئیشکردن بۆ تەواوی ماوەکە
  Future<Map<String, Duration>> getTotalWorkTimeForPeriod(
      DateTime startDate, DateTime endDate) async {
    Duration totalWork = Duration.zero;
    Duration totalRest = Duration.zero;

    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.email)
        .collection('checkincheckouts')
        .where('time', isGreaterThanOrEqualTo: startDate)
        .where('time', isLessThanOrEqualTo: endDate)
        .orderBy('time')
        .get();

    // گروپکردن بە ڕۆژ
    Map<String, List<QueryDocumentSnapshot>> groupedData = {};
    for (var doc in snapshot.docs) {
      DateTime time = (doc['time'] as Timestamp).toDate();
      String dateKey = '${time.year}-${time.month}-${time.day}';
      if (!groupedData.containsKey(dateKey)) {
        groupedData[dateKey] = [];
      }
      groupedData[dateKey]!.add(doc);
    }

    // حیسابکردنی کاتی ئیشکردن بۆ هەر ڕۆژێک
    for (var dateKey in groupedData.keys) {
      var records = groupedData[dateKey]!;

      // حیسابکردنی کاتی ئیشکردن
      for (var i = 0; i < records.length; i = i + 2) {
        if (i + 1 == records.length) break;
        if (records[i]['checkin'] == false) {
          if (i + 2 == records.length) break;
          totalWork += records[i + 2]['time']
              .toDate()
              .difference(records[i + 1]['time'].toDate());
        } else {
          totalWork += records[i + 1]['time']
              .toDate()
              .difference(records[i]['time'].toDate());
        }
      }

      // حیسابکردنی کاتی پشوو
      for (var i = 0; i < records.length; i = i + 2) {
        if (i + 1 == records.length) break;
        if (records[i]['checkout'] == false) {
          if (i + 2 == records.length) break;
          totalRest += records[i + 2]['time']
              .toDate()
              .difference(records[i + 1]['time'].toDate());
        } else {
          totalRest += records[i + 1]['time']
              .toDate()
              .difference(records[i]['time'].toDate());
        }
      }
    }

    return {'work': totalWork, 'rest': totalRest};
  }

  // ✅ بەدەستهێنانی کاتی ئیشکردن بۆ ڕۆژێکی دیاریکراو
  Future<List<String>> todaysworktime(DateTime dayDate) async {
    Duration worktime = Duration.zero;
    Duration rest = Duration.zero;

    final dayStart = DateTime(dayDate.year, dayDate.month, dayDate.day);
    final dayEnd = DateTime(dayDate.year, dayDate.month, dayDate.day + 1);

    await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.email)
        .collection('checkincheckouts')
        .where('time', isGreaterThanOrEqualTo: dayStart)
        .where('time', isLessThan: dayEnd)
        .orderBy('time')
        .get()
        .then((value) async {
      if (value.docs.isNotEmpty) {
        for (var i = 0; i < value.docs.length; i = i + 2) {
          if (i + 1 == value.docs.length) break;
          if (value.docs[i]['checkin'] == false) {
            if (i + 2 == value.docs.length) break;
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
    });

    await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.email)
        .collection('checkincheckouts')
        .where('time', isGreaterThanOrEqualTo: dayStart)
        .where('time', isLessThan: dayEnd)
        .orderBy('time')
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        for (var i = 0; i < value.docs.length; i = i + 2) {
          if (i + 1 == value.docs.length) break;
          if (value.docs[i]['checkout'] == false) {
            if (i + 2 == value.docs.length) break;
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

  // ✅ حیسابکردنی ڕۆژەکانی کار لە ماوەی مووچە (بەبێ هەینی)
  int _getWorkDaysInPeriod(DateTime startDate, DateTime endDate) {
    int totalWorkDays = 0;
    for (DateTime day = startDate;
        day.isBefore(endDate) || day.isAtSameMomentAs(endDate);
        day = day.add(const Duration(days: 1))) {
      if (day.weekday != DateTime.friday) {
        totalWorkDays++;
      }
    }
    return totalWorkDays;
  }

  @override
  Widget build(BuildContext context) {
    // ✅ بەکارهێنانی ماوەی مووچە
    final (startDate, endDate) = _getSalaryPeriod(widget.date);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'چوونەژوورەوە / دەرچوونەوە\n${startDate.month}/${startDate.day} - ${endDate.month}/${endDate.day}',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14),
        ),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: FirebaseFirestore.instance
            .collection('user')
            .doc(widget.email)
            .collection('checkincheckouts')
            .where('time', isGreaterThanOrEqualTo: startDate)
            .where('time', isLessThanOrEqualTo: endDate)
            .orderBy('time')
            .get(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("هیچ تۆمارێک نییە بۆ ئەم ماوەیە"));
          }

          // گروپکردن بە بەروار
          Map<String, List<QueryDocumentSnapshot>> groupedData = {};
          for (var doc in snapshot.data?.docs ?? []) {
            DateTime time = (doc['time'] as Timestamp).toDate();
            String dateKey = '${time.year}-${time.month}-${time.day}';

            if (!groupedData.containsKey(dateKey)) {
              groupedData[dateKey] = [];
            }
            groupedData[dateKey]!.add(doc);
          }

          var sortedKeys = groupedData.keys.toList()
            ..sort((a, b) {
              var partsA = a.split('-').map(int.parse).toList();
              var partsB = b.split('-').map(int.parse).toList();
              var dateA = DateTime(partsA[0], partsA[1], partsA[2]);
              var dateB = DateTime(partsB[0], partsB[1], partsB[2]);
              return dateA.compareTo(dateB);
            });

          return Column(
            children: [
              // ✅ کارتی کۆی گشتی لە سەرەوە
              FutureBuilder<Map<String, Duration>>(
                future: getTotalWorkTimeForPeriod(startDate, endDate),
                builder: (context, totalSnapshot) {
                  if (totalSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Container(
                      margin: EdgeInsets.all(3.w),
                      padding: EdgeInsets.all(2.h),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Material1.primaryColor,
                            Material1.primaryColor.withOpacity(0.7),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      ),
                    );
                  }

                  Duration totalWork =
                      totalSnapshot.data?['work'] ?? Duration.zero;
                  Duration totalRest =
                      totalSnapshot.data?['rest'] ?? Duration.zero;

                  return Container(
                    margin: EdgeInsets.all(3.w),
                    padding: EdgeInsets.all(2.h),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Material1.primaryColor,
                          Material1.primaryColor.withOpacity(0.7),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Material1.primaryColor.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          'کۆی گشتی ئەم ماوەیە',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 1.5.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // کۆی کاتی ئیشکردن
                            Column(
                              children: [
                                Icon(Icons.work_history,
                                    color: Colors.white, size: 30.sp),
                                SizedBox(height: 0.5.h),
                                Text(
                                  'کاتی ئیشکردن',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.white70,
                                  ),
                                ),
                                SizedBox(height: 0.3.h),
                                Text(
                                  formatDuration(totalWork),
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: 8.h,
                              width: 1,
                              color: Colors.white30,
                            ),
                            // کۆی کاتی پشوو
                            Column(
                              children: [
                                Icon(Icons.coffee,
                                    color: Colors.white, size: 30.sp),
                                SizedBox(height: 0.5.h),
                                Text(
                                  'کاتی پشوو',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    color: Colors.white70,
                                  ),
                                ),
                                SizedBox(height: 0.3.h),
                                Text(
                                  formatDuration(totalRest),
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: 1.h),
                        // ژمارەی ڕۆژەکان
                        Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 3.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'ژمارەی ڕۆژەکانی ئیش: ${sortedKeys.length} ڕۆژ',
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // ✅ لیستی ڕۆژەکان
              Expanded(
                child: ListView(
                  children: sortedKeys.map((dateKey) {
                    List<QueryDocumentSnapshot> records = groupedData[dateKey]!;
                    var parts = dateKey.split('-').map(int.parse).toList();
                    DateTime fullDate = DateTime(parts[0], parts[1], parts[2]);

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FutureBuilder(
                          future: todaysworktime(fullDate),
                          builder: (context, workTimeSnapshot) {
                            if (workTimeSnapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Container(
                                margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
                                padding: EdgeInsets.all(2.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              );
                            }

                            List<String> times =
                                workTimeSnapshot.data ?? ['0:00:00', '0:00:00'];

                            return GestureDetector(
                              onTap: () {
                                showAllRecordsDialog(
                                    context, records, fullDate);
                              },
                              child: Container(
                                margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
                                padding: EdgeInsets.all(2.h),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.grey,
                                      blurRadius: 5,
                                      offset: Offset(0, 2),
                                    )
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.all(1.h),
                                      decoration: BoxDecoration(
                                        color: Material1.primaryColor
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(
                                            "${fullDate.year}/${fullDate.month}/${fullDate.day} :بەروار",
                                            style: TextStyle(
                                              fontSize: 17.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Material1.primaryColor,
                                            ),
                                          ),
                                          SizedBox(height: 0.5.h),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                times[0].length >= 8
                                                    ? times[0].substring(0, 8)
                                                    : times[0],
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                " : کاتی ئیشکردن",
                                                style:
                                                    TextStyle(fontSize: 14.sp),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Text(
                                                times[1].length >= 8
                                                    ? times[1].substring(0, 8)
                                                    : times[1],
                                                style: TextStyle(
                                                  fontSize: 14.sp,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              Text(
                                                " : کاتی ڕێست",
                                                style:
                                                    TextStyle(fontSize: 14.sp),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(),
                                    if (records.isNotEmpty)
                                      Center(
                                        child: Text(
                                          "بینینی هەموو (${records.length})",
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Material1.primaryColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    else
                                      Center(
                                        child: Text(
                                          "هیچ تۆمارێک نییە",
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              color: Colors.grey),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ✅ دایالۆگی پشاندانی هەموو تۆمارەکان
  void showAllRecordsDialog(BuildContext context,
      List<QueryDocumentSnapshot> records, DateTime fullDate) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
              'هەموو تۆمارەکانی ${fullDate.year}/${fullDate.month}/${fullDate.day}'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: records.length,
              itemBuilder: (context, index) {
                var doc = records[index];
                return Card(
                  color: doc['checkin'] == true
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  margin: EdgeInsets.symmetric(vertical: 0.5.h),
                  child: Padding(
                    padding: EdgeInsets.all(1.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Type row - safe
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Icon(
                              doc['checkin'] == true
                                  ? Icons.login
                                  : Icons.logout,
                              color: doc['checkin'] == true
                                  ? Colors.green
                                  : Colors.red,
                              size: 20,
                            ),
                            SizedBox(width: 1.w),
                            Flexible(
                              child: Text(
                                "جۆر : ${doc['checkin'] == true ? 'چوونەژوورەوە' : 'چوونەدەرەوە'}",
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 0.5.h),

                        // Time - safe
                        Text(
                          "${(doc['time'] as Timestamp).toDate()} : کات ",
                          style: const TextStyle(fontSize: 14),
                          textDirection: TextDirection.ltr,
                        ),
                        SizedBox(height: 0.5.h),

                        // Location - THIS WAS THE MAIN PROBLEM
                        GestureDetector(
                          onTap: () {
                            showLocationDialog(
                                context, doc['latitude'], doc['longtitude']);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Expanded(
                                // Important: allows text to take available space
                                child: Text(
                                  "${doc['latitude']}-${doc['longtitude']}",
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                  textAlign: TextAlign.end,
                                  overflow: TextOverflow
                                      .ellipsis, // Prevents overflow
                                  maxLines: 1,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                ": شوێن",
                                style: TextStyle(fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 0.5.h),

                        // Note
                        Text(
                          "${doc['note'] ?? ''} : تێبینی",
                          style: const TextStyle(fontSize: 14),
                          textAlign: TextAlign.end,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('داخستن'),
            ),
          ],
        );
      },
    );
  }

  // ✅ دایالۆگی پشاندانی شوێن
  void showLocationDialog(
      BuildContext context, dynamic latitude, dynamic longtitude) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('شوێن'),
          content: const Text("دڵنییایت لە بینینی شوێن"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('نەخێر'),
            ),
            TextButton(
              onPressed: () async {
                if (!await launchUrl(Uri.parse(
                    'https://www.google.com/maps/search/?api=1&query=$latitude,$longtitude'))) {
                  throw Exception('Could not launch ');
                }
              },
              child: const Text('بەڵێ'),
            ),
          ],
        );
      },
    );
  }
}
