import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:sizer/sizer.dart';

class TasksViewingrewardpunishment extends StatefulWidget {
  final String email;
  const TasksViewingrewardpunishment({super.key, required this.email});

  @override
  State<TasksViewingrewardpunishment> createState() =>
      _TasksViewingrewardpunishmentState();
}

class _TasksViewingrewardpunishmentState
    extends State<TasksViewingrewardpunishment> {
  DateTime start = DateTime.now().subtract(const Duration(days: 365));
  DateTime end = DateTime.now().add(const Duration(days: 1));
  String formatDate(DateTime? date) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(date ?? DateTime.now());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('پاداشت و سزای ئەرکەکان'),
        backgroundColor: Material1.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () async {
              List<DateTime>? dateTimeList = await showOmniDateTimeRangePicker(
                context: context,
                startInitialDate: DateTime.now(),
                startFirstDate:
                    DateTime(1600).subtract(const Duration(days: 3652)),
                startLastDate: DateTime.now().add(
                  const Duration(days: 3652),
                ),
                endInitialDate: DateTime.now(),
                endFirstDate:
                    DateTime(1600).subtract(const Duration(days: 3652)),
                endLastDate: DateTime.now().add(
                  const Duration(days: 3652),
                ),
                is24HourMode: false,
                isShowSeconds: false,
                minutesInterval: 1,
                secondsInterval: 1,
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                constraints: const BoxConstraints(
                  maxWidth: 350,
                  maxHeight: 650,
                ),
                transitionBuilder: (context, anim1, anim2, child) {
                  return FadeTransition(
                    opacity: anim1.drive(
                      Tween(
                        begin: 0,
                        end: 1,
                      ),
                    ),
                    child: child,
                  );
                },
                transitionDuration: const Duration(milliseconds: 200),
                barrierDismissible: true,
              );
              start = dateTimeList?[0] ?? DateTime.now();
              end = dateTimeList?[1] ?? DateTime.now();
              setState(() {});
            },
            child: Container(
                margin: EdgeInsets.only(top: 2.h, left: 5.w, right: 5.w),
                height: 8.h,
                width: 100.w,
                decoration: BoxDecoration(
                    color: Material1.primaryColor,
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('هەڵبژاردنی کاتی پاداشت / سزا',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold)),
                    Text(
                        "${'لە'} ${formatDate(start == DateTime.now() ? null : start)} - ${'بۆ'} ${formatDate(end == DateTime.now() ? null : end)}",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold)),
                  ],
                )),
          ),
          SafeArea(
            child: SizedBox(
              height: 75.h,
              width: 100.w,
              child: FutureBuilder(
                  future: FirebaseFirestore.instance
                      .collection('user')
                      .doc(widget.email)
                      .collection('taskrewardpunishment')
                      .where('date', isGreaterThanOrEqualTo: start)
                      .where('date', isLessThanOrEqualTo: end)
                      .orderBy('date',
                          descending:
                              true) // Add this line to sort by date in descending order
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
                            return GestureDetector(
                              onTap: () {
                                // showDialog(
                                //     context: context,
                                //     builder: (context) {
                                //       return AlertDialog(
                                //         title: const Text(
                                //             'دەتەوێت چی لە ئەرکی ئەم کارمەندە بکەیت'),
                                //         actions: [
                                //           TextButton(
                                //               onPressed: () {
                                //                 Navigator.push(context,
                                //                     MaterialPageRoute(builder: (context) {
                                //                   return AdminAddingTask(
                                //                       adminemail: widget.email,
                                //                       email: snapshot.data!.docs[index]
                                //                           ['email']);
                                //                 }));
                                //               },
                                //               child: const Text('زیادکردنی کار')),
                                //           TextButton(
                                //               onPressed: () {
                                //                 Navigator.push(context,
                                //                     MaterialPageRoute(builder: (context) {
                                //                   return AdminTaskDeletion(
                                //                       email: snapshot.data!.docs[index]
                                //                           ['email']);
                                //                 }));
                                //               },
                                //               child: const Text('سڕینەوەی کار',
                                //                   style: TextStyle(color: Colors.red))),
                                //         ],
                                //       );
                                //     });
                              },
                              child: SizedBox(
                                  height: 20.h,
                                  width: 90.w,
                                  child: Container(
                                    margin:
                                        EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
                                    padding: EdgeInsets.all(1.h),
                                    decoration: BoxDecoration(
                                      color:
                                          '${snapshot.data!.docs[index]['type']}' ==
                                                  'punishment'
                                              ? Colors.red[100]
                                              : Colors.green[100],
                                      borderRadius: BorderRadius.circular(5),
                                      boxShadow: const [
                                        BoxShadow(
                                          color: Colors.grey,
                                          blurRadius: 5,
                                        )
                                      ],
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "${snapshot.data?.docs[index]['addedby']} : زیاد کراوە لەلایەن",
                                          style: const TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          "${snapshot.data!.docs[index]['amount']} : بڕی ${snapshot.data!.docs[index]['type'] == 'punishment' ? 'سزا' : 'پاداشت'}",
                                          style: const TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          "${snapshot.data!.docs[index]['date'].toDate()} : کات",
                                          style: const TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                        Text(
                                          "${snapshot.data!.docs[index]['reason']} : هۆکار",
                                          style: const TextStyle(
                                            fontSize: 15,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            );
                          }),
                    );
                  }),
            ),
          ),
        ],
      ),
    );
  }
}
