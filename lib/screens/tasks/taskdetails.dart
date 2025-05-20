import 'dart:developer';

import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:step_progress_indicator/step_progress_indicator.dart';

class Taskdetails extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> task;
  final String email;
  final int stages;
  const Taskdetails({
    super.key,
    required this.task,
    required this.email,
    required this.stages,
  });

  @override
  State<Taskdetails> createState() => _TaskdetailsState();
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
double listviewheight = 0;
TextEditingController notecontroller = TextEditingController();
TextEditingController linkcontroller = TextEditingController();
List<List<TextEditingController>> linkcontrollerslist = [];
List<List<TextEditingController>> notecontrollerslist = [];

List<String> weekdays = [
  'دووشەممە',
  'سێشەممە',
  'چوارشەممە',
  'پێنج شەممە',
  'هەینی شەممە',
  'شەممە',
  'یەکشەممە',
];

class _TaskdetailsState extends State<Taskdetails> {
  @override
  void initState() {
    for (var i = 0; i < widget.stages; i++) {
      notecontrollerslist.add([TextEditingController()]);
      linkcontrollerslist.add([TextEditingController()]);
    }
    try {
      listviewheight = ((widget.task['endstages']
                  .where((element) => element == false)
                  .length)
              .toDouble() *
          55);
    } catch (e) {
      listviewheight = 0;
    }
    super.initState();
  }

  @override
  void dispose() {
    for (var i = 0; i < widget.stages; i++) {
      for (var j = 0; j < notecontrollerslist[i].length; j++) {
        notecontrollerslist[i][j].dispose();
      }
      for (var j = 0; j < linkcontrollerslist[i].length; j++) {
        linkcontrollerslist[i][j].dispose();
      }
    }
    linkcontrollerslist = [];
    notecontrollerslist = [];
    notecontroller.clear();
    linkcontroller.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('وردەکاری کارەکە'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
      ),
      body: ListView(
        children: [
          SizedBox(
              height: 10.h,
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("${widget.task['name']} : ئەرک",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                            "${DateFormat('MMM d, h:mm a').format(widget.task['end'].toDate())} بۆ",
                            style: TextStyle(
                              fontSize: 16.sp,
                            )),
                        Text(
                            "${DateFormat('MMM d, h:mm a').format(widget.task['start'].toDate())}  لە",
                            style: TextStyle(
                              fontSize: 16.sp,
                            )),
                      ],
                    ),
                  ],
                ),
              )),
          Container(
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
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(": وردەکاری",
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.bold)),
                Text(widget.task['description'],
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          if (widget.task['isweekly'])
            Container(
                alignment: Alignment.topRight,
                margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
                child: Text('ڕۆژانی دووبارە بوونەوە',
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.bold))),
          if (widget.task['isweekly'])
            Container(
                height: 8.h,
                margin: EdgeInsets.only(top: 0.h, right: 1.w, left: 1.w),
                child: ListView.builder(
                  itemCount: 7,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) => Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (widget.task['weekdays'].contains(index + 1))
                        Container(
                            margin: EdgeInsets.only(left: 1.w),
                            child: Text("${weekdays[index]},",
                                style: TextStyle(fontSize: 16.sp))),
                    ],
                  ),
                )),
          widget.stages != 0
              ? Container(
                  margin: EdgeInsets.fromLTRB(5.w, 3.h, 5.w, 1.h),
                  child: StepProgressIndicator(
                    totalSteps: widget.stages,
                    currentStep: widget.task['endstages']
                        .where((element) => element == true)
                        .length,
                    selectedColor: Material1.primaryColor,
                    unselectedColor: Colors.grey,
                  ),
                )
              : const SizedBox.shrink(),
          widget.stages != 0
              ? Container(
                  alignment: Alignment.topRight,
                  margin: EdgeInsets.fromLTRB(5.w, 3.h, 5.w, 1.h),
                  child: Text('بەشەکان',
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold)),
                )
              : const SizedBox.shrink(),
          widget.stages != 0
              ? SizedBox(
                  height: listviewheight.h,
                  child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: widget.stages,
                      itemBuilder: (context, index) {
                        if (widget.task['endstages'][index] == true) {
                          return const SizedBox.shrink();
                        }
                        return Column(
                          children: [
                            SizedBox(
                              height: 5.h,
                              child: Text(
                                  "${widget.task['stagetitles']?[index] ?? 'No title'} : ناو",
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(
                              height: 5.h,
                              child: Text(
                                  "${widget.task['stagecontents'][index]} : وردەکاری",
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold)),
                            ),
                            SizedBox(
                              height:
                                  ((notecontrollerslist[index].length * 8) + 5)
                                      .h,
                              child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: notecontrollerslist[index].length,
                                  itemBuilder: (context, index1) {
                                    return Container(
                                      margin: EdgeInsets.only(
                                          top: 0.h, left: 5.w, right: 5.w),
                                      width: 90.w,
                                      height: 8.h,
                                      child: Material1.textfield(
                                          hint:
                                              'تێبینی ${index1 + 1} بۆ بەشی ${index + 1}',
                                          controller: notecontrollerslist[index]
                                              [index1],
                                          textColor: Material1.primaryColor),
                                    );
                                  }),
                            ),
                            SizedBox(
                              height:
                                  ((linkcontrollerslist[index].length * 8) + 5)
                                      .h,
                              child: ListView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: linkcontrollerslist[index].length,
                                  itemBuilder: (context, index1) {
                                    return Container(
                                      margin: EdgeInsets.only(
                                          top: 0.h, left: 5.w, right: 5.w),
                                      width: 90.w,
                                      height: 8.h,
                                      child: Material1.textfield(
                                          hint:
                                              'لینکی ${index1 + 1} بۆ بەشی ${index + 1}',
                                          controller: linkcontrollerslist[index]
                                              [index1],
                                          textColor: Material1.primaryColor),
                                    );
                                  }),
                            ),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    linkcontrollerslist[index]
                                        .add(TextEditingController());
                                    int note = 0;
                                    for (var i = 0;
                                        i < notecontrollerslist.length;
                                        i++) {
                                      note += notecontrollerslist[i].length;
                                    }
                                    int link = 0;
                                    for (var i = 0;
                                        i < linkcontrollerslist.length;
                                        i++) {
                                      link += linkcontrollerslist[i].length;
                                    }
                                    setState(() {
                                      listviewheight = ((widget
                                                      .task['endstages']
                                                      .where((element) =>
                                                          element == false)
                                                      .length)
                                                  .toDouble() *
                                              20) +
                                          (9 * link) +
                                          (9 * note);
                                    });
                                  },
                                  child: Container(
                                    width: 40.w,
                                    height: 6.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.grey[200],
                                    ),
                                    margin:
                                        EdgeInsets.only(left: 5.w, right: 5.w),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add, color: Colors.black),
                                        Text('زیادکردنی لینک',
                                            style: TextStyle(
                                                fontSize: 16.sp,
                                                color: Colors.black)),
                                      ],
                                    ),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    notecontrollerslist[index]
                                        .add(TextEditingController());
                                    int note = 0;
                                    for (var i = 0;
                                        i < notecontrollerslist.length;
                                        i++) {
                                      note += notecontrollerslist[i].length;
                                    }
                                    int link = 0;
                                    for (var i = 0;
                                        i < linkcontrollerslist.length;
                                        i++) {
                                      link += linkcontrollerslist[i].length;
                                    }
                                    setState(() {
                                      listviewheight = ((widget
                                                      .task['endstages']
                                                      .where((element) =>
                                                          element == false)
                                                      .length)
                                                  .toDouble() *
                                              20) +
                                          (9 * link) +
                                          (9 * note);
                                    });
                                  },
                                  child: Container(
                                    width: 40.w,
                                    height: 6.h,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: Colors.grey[200],
                                    ),
                                    margin:
                                        EdgeInsets.only(left: 5.w, right: 5.w),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.add, color: Colors.black),
                                        Text('زیادکردنی تێبینی',
                                            style: TextStyle(
                                                fontSize: 16.sp,
                                                color: Colors.black)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  top: 2.h, left: 5.w, right: 5.w),
                              child: Material1.button(
                                  label:
                                      widget.task['startstages'][index] == false
                                          ? 'دەستپێکردنی بەشی ${index + 1}'
                                          : 'کۆتایی پێهێنانی بەشی ${index + 1}',
                                  buttoncolor: Material1.primaryColor,
                                  textcolor: Colors.white,
                                  function: () {
                                    if (DateTime.now().isBefore(widget
                                        .task['startstagedates'][index]
                                        .toDate())) {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('هەڵە'),
                                              content: Text(
                                                  'لەکاتی دیاری کراو دەست بە کارەکە بکە'),
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
                                    if (DateTime.now().isAfter(widget
                                            .task['endstagedates'][index]
                                            .toDate()) &&
                                        widget.task['startstages'][index] ==
                                            true) {
                                      showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              title: Text('هەڵە'),
                                              content: Text(
                                                  'لەکاتی دیاری کراو کۆتایی بە کارەکە بێنە'),
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
                                            title: Text(widget
                                                            .task['startstages']
                                                        [index] ==
                                                    false
                                                ? 'دەستێکردنی بەشی ${index + 1}'
                                                : 'تەواوکردنی بەشی ${index + 1}'),
                                            content: Text(widget
                                                            .task['startstages']
                                                        [index] ==
                                                    false
                                                ? 'دڵنیایتتت لە دەستپێکردنی بەشی ${index + 1}؟'
                                                : 'دڵنیایتتت لە تەواوکردنی بەشی ${index + 1}؟'),
                                            actions: [
                                              Material1.button(
                                                  label: 'نەخێر',
                                                  function: () {
                                                    Navigator.pop(context);
                                                  },
                                                  textcolor: Colors.white,
                                                  buttoncolor:
                                                      Material1.primaryColor),
                                              Material1.button(
                                                  label: 'بەڵێ',
                                                  function: () async {
                                                    log('test ${linkcontrollerslist[index].toList()}');
                                                    List<String> links = [];
                                                    List<String> notes = [];
                                                    for (var i = 0;
                                                        i <
                                                            linkcontrollerslist[
                                                                    index]
                                                                .length;
                                                        i++) {
                                                      links.add(
                                                          linkcontrollerslist[
                                                                  index][i]
                                                              .text);
                                                    }
                                                    for (var i = 0;
                                                        i <
                                                            notecontrollerslist[
                                                                    index]
                                                                .length;
                                                        i++) {
                                                      notes.add(
                                                          notecontrollerslist[
                                                                  index][i]
                                                              .text);
                                                    }
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            title: Center(
                                                                child:
                                                                    const CircularProgressIndicator()),
                                                          );
                                                        });
                                                    await _getCurrentPosition();
                                                    if (widget.task[
                                                                'startstages']
                                                            [index] ==
                                                        false) {}
                                                    widget.task.reference
                                                        .collection('updates')
                                                        .doc(widget.task[
                                                                        'startstages']
                                                                    [index] ==
                                                                false
                                                            ? "start-stage${index + 1}"
                                                            : "end-stage${index + 1}")
                                                        .set({
                                                      'note': notes,
                                                      'time': DateTime.now(),
                                                      'latitude': latitude,
                                                      'longtitude': longtitude,
                                                      'action':
                                                          widget.task['startstages']
                                                                      [index] ==
                                                                  false
                                                              ? 'start'
                                                              : 'finish',
                                                      'stage': "${index + 1}",
                                                      'link': links
                                                    }).then((value) async {
                                                      List<bool> startstages =
                                                          List<bool>.from(widget
                                                                  .task[
                                                              'startstages']);
                                                      List<bool> endstages =
                                                          List<bool>.from(
                                                              widget.task[
                                                                  'endstages']);
                                                      if (widget.task[
                                                                  'startstages']
                                                              [index] ==
                                                          false) {
                                                        startstages[index] =
                                                            true;
                                                      } else {
                                                        endstages[index] = true;
                                                      }
                                                      widget.task.reference
                                                          .update({
                                                        'endstages': endstages,
                                                        'startstages':
                                                            startstages,
                                                      });
                                                    }).then(
                                                      (value) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          SnackBar(
                                                            content: Text(widget
                                                                            .task['startstages']
                                                                        [
                                                                        index] ==
                                                                    false
                                                                ? 'دەستکرا بە بەشی ${index + 1}'
                                                                : 'کۆتایی هات بە بەشی ${index + 1}'),
                                                          ),
                                                        );
                                                        Navigator.popUntil(
                                                            context,
                                                            (route) =>
                                                                route.isFirst);
                                                      },
                                                    ).catchError((error) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'هەڵەیەک هەیە'),
                                                        ),
                                                      );
                                                    });
                                                  },
                                                  textcolor: Colors.white,
                                                  buttoncolor:
                                                      Material1.primaryColor),
                                            ],
                                          );
                                        });
                                  }),
                            )
                          ],
                        );
                      }),
                )
              : const SizedBox.shrink(),
          widget.task['status'] != 'done'
              ? Container(
                  margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
                  width: 90.w,
                  height: 8.h,
                  child: Material1.textfield(
                      hint: 'تێبینی',
                      controller: notecontroller,
                      textColor: Material1.primaryColor),
                )
              : const SizedBox.shrink(),
          widget.task['status'] != 'done'
              ? Container(
                  margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
                  width: 90.w,
                  height: 8.h,
                  child: Material1.textfield(
                      hint: 'لینک',
                      controller: linkcontroller,
                      textColor: Material1.primaryColor),
                )
              : const SizedBox.shrink(),
          // In the Taskdetails widget, update the button function as follows:

       widget.task['status'] != 'done'
    ? Container(
        margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w, bottom: 5.h),
        width: 90.w,
        height: 8.h,
        child: Material1.button(
            label: widget.task['status'] == 'pending'
                ? 'دەستپێکردن'
                : 'کۆتایی پێهێنان',
            function: () async {
              // Check if task is being started
              if (widget.task['status'] == 'pending') {
                if (widget.task['start'].toDate().isAfter(DateTime.now())) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('هەڵە'),
                          content: Text('لەکاتی دیاری کراو دەست بە کارەکە بکە'),
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
              }
              // Task is being finished
              else {
                // Check if all stages are completed (if there are stages)
                final allStagesCompleted = widget.stages == 0 ||
                    !widget.task['endstages'].contains(false);

                if (!allStagesCompleted) {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('هەڵە'),
                          content: Text('تکایە یەکەم هەموو بەشەکان تەواو بکە'),
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
              }

              final now = DateTime.now();
              final reward = widget.task['rewardamount']?.toString() ?? '0';
              bool completedOnTime = false;

              // For weekly tasks, check if completed within the time window
              if (widget.task['isweekly']) {
                final scheduledDates = (widget.task['scheduled_dates'] as List<dynamic>?)?.map((d) => (d as Timestamp).toDate()).toList() ?? [];
                final currentOccurrence = widget.task['current_occurrence'] ?? 0;

                if (currentOccurrence < scheduledDates.length) {
                  final currentScheduledDate = scheduledDates[currentOccurrence];
                  final taskStartTime = DateTime(
                    currentScheduledDate.year,
                    currentScheduledDate.month,
                    currentScheduledDate.day,
                    widget.task['start'].toDate().hour,
                    widget.task['start'].toDate().minute,
                  );
                  final taskEndTime = DateTime(
                    currentScheduledDate.year,
                    currentScheduledDate.month,
                    currentScheduledDate.day,
                    widget.task['end'].toDate().hour,
                    widget.task['end'].toDate().minute,
                  );

                  // Check if completed within the allowed time window
                  completedOnTime = now.isAfter(taskStartTime) && now.isBefore(taskEndTime);
                }
              } else {
                // For non-weekly tasks
                completedOnTime = !now.isAfter(widget.task['end'].toDate());
              }

              // Show loading dialog
              showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: Center(child: const CircularProgressIndicator()),
                    );
                  });

              await _getCurrentPosition();

              // Record the update
              await widget.task.reference
                  .collection('updates')
                  .doc(DateTime.now().toString())
                  .set({
                'note': [notecontroller.text],
                'time': DateTime.now(),
                'latitude': latitude,
                'longtitude': longtitude,
                'action': widget.task['status'] == 'pending' ? 'start' : 'finish',
                'stage': 'main task',
                'link': [linkcontroller.text]
              });

              // Apply reward if completed on time
              if (widget.task['status'] == 'active' && completedOnTime && reward != '0') {
                await FirebaseFirestore.instance
                    .collection('user')
                    .doc(widget.email)
                    .collection('taskrewardpunishment')
                    .doc('reward-${widget.task['name']}-${now.toString()}')
                    .set({
                  'addedby': widget.email,
                  'amount': reward,
                  'date': now,
                  'reason': widget.task['isweekly']
                      ? 'for completing weekly task ${widget.task['name']} on occurrence ${widget.task['current_occurrence'] + 1}'
                      : 'for completing task ${widget.task['name']} on time',
                  'type': 'reward'
                });
              }

              // Update task status
              if (widget.task['status'] == 'pending') {
                await widget.task.reference.update({'status': 'active'});
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('دەست بە کارەکە کرا')),
                );
              } else {
                if (widget.task['isweekly']) {
                  final currentOccurrence = widget.task['current_occurrence'] ?? 0;
                  final totalOccurrences = widget.task['total_occurrences'] ?? 1;

                  if (currentOccurrence < totalOccurrences - 1) {
                    // Move to next occurrence
                    await widget.task.reference.update({
                      'current_occurrence': currentOccurrence + 1,
                      'status': 'pending', // Reset to pending for next occurrence
                    });
                  } else {
                    // Mark task as done if all occurrences are completed
                    await widget.task.reference.update({
                      'status': 'done',
                      'lastupdate': Timestamp.fromDate(DateTime.now())
                    });
                  }
                } else {
                  // Mark non-weekly task as done
                  await widget.task.reference.update({
                    'status': 'done',
                    'lastupdate': Timestamp.fromDate(DateTime.now())
                  });
                }
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('کارەکە کۆتایی پێهات')),
                );
              }

              Navigator.popUntil(context, (route) => route.isFirst);
            },
            textcolor: Colors.white,
            buttoncolor: Material1.primaryColor),
      )
    : const SizedBox.shrink(),
        ],
      ),
    );
  }
}
