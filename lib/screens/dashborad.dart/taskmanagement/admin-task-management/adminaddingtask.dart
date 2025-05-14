import 'dart:developer';

import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:day_picker/day_picker.dart';

import '../../../../sendingnotification.dart';

class AdminAddingTask extends StatefulWidget {
  final String adminemail;
  final String email;
  final bool isbatch;
  final List<String> selectedUsers;
  
  const AdminAddingTask({
    super.key,
    required this.email,
    required this.adminemail,
    required this.selectedUsers,
    required this.isbatch,
  });

  @override
  State<AdminAddingTask> createState() => _AdminAddingTaskState();
}

class _AdminAddingTaskState extends State<AdminAddingTask> {
  // Constants and configurations
  static const List<String> soundList = [
    'default1', 'annoying', 'annoying1', 'arabic', 'laughing', 
    'longfart', 'mild', 'oud', 'rooster', 'salawat', 
    'shortfart', 'soft2', 'softalert', 'srusht', 'witch',
  ];
  
  final List<DayInWeek> _days = [
    DayInWeek("Mon", dayKey: "1"),
    DayInWeek("Tue", dayKey: "2"),
    DayInWeek("Wen", dayKey: "3"),
    DayInWeek("Thu", dayKey: "4"),
    DayInWeek("Fri", dayKey: "5"),
    DayInWeek("Sat", dayKey: "6"),
    DayInWeek("Sun", dayKey: "7"),
  ];

  // State variables
  String dropdownValue = 'default1';
  List<int> offdays = [];
  bool checkin = true;
  double latitude = 0.0;
  double longtitude = 0.0;
  
  // Main task controllers
  final TextEditingController descriptioncontroller = TextEditingController();
  final TextEditingController namecontroller = TextEditingController();
  final TextEditingController deductionamountcontroller = TextEditingController();
  final TextEditingController rewardamountcontroller = TextEditingController();
  final TextEditingController dayofthemontcontroller = TextEditingController();

  // Date related variables
  DateTime? start;
  DateTime? end;
  DateTime now = DateTime.now();
  DateTime eend = DateTime.now();
  DateTime scheduled = DateTime.now();
  int numm = 0;
  
  // Task recurrence options
  bool isDaily = false;
  bool isWeekly = false;
  bool isMonthly = false;
  
  // Stage related lists
  List<DateTime?> startsstagedates = [];
  List<DateTime?> endsstagedates = [];
  List<DateTime?> startsnotificationdates = [DateTime.now().subtract(const Duration(minutes: 10))];
  List<DateTime?> endsnotificationdates = [DateTime.now().subtract(const Duration(minutes: 10))];
  List<TextEditingController?> stagetitlescontrollers = [];
  List<TextEditingController?> stagecontentcontrollers = [];
  List<DateTime?> mainstartsnotificationdates = [DateTime.now().subtract(const Duration(minutes: 10))];
  List<DateTime?> mainendsnotificationdates = [DateTime.now().subtract(const Duration(minutes: 10))];

  @override
  void dispose() {
    // Clean up all controllers
    descriptioncontroller.dispose();
    namecontroller.dispose();
    deductionamountcontroller.dispose();
    rewardamountcontroller.dispose();
    dayofthemontcontroller.dispose();
    
    for (var controller in stagetitlescontrollers) {
      controller?.dispose();
    }
    
    for (var controller in stagecontentcontrollers) {
      controller?.dispose();
    }
    
    super.dispose();
  }

  String formatDate(DateTime? date) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(date ?? DateTime.now());
  }

  Future<void> _selectDateTimeRange(BuildContext context, bool isMainTask) async {
    List<DateTime>? dateTimeList = await showOmniDateTimeRangePicker(
      context: context,
      startInitialDate: DateTime.now(),
      startFirstDate: DateTime(1600).subtract(const Duration(days: 3652)),
      startLastDate: DateTime.now().add(const Duration(days: 3652)),
      endInitialDate: DateTime.now(),
      endFirstDate: DateTime(1600).subtract(const Duration(days: 3652)),
      endLastDate: DateTime.now().add(const Duration(days: 3652)),
      is24HourMode: false,
      isShowSeconds: false,
      minutesInterval: 1,
      secondsInterval: 1,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      constraints: const BoxConstraints(maxWidth: 350, maxHeight: 650),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1.drive(Tween(begin: 0, end: 1)), child: child);
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
    );

    if (dateTimeList == null) return;

    if (dateTimeList[0].isAfter(dateTimeList[1])) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تکایە کاتی دەستپێک نابێت لە دوای کاتی کۆتایی بێت')),
      );
      return;
    }

    setState(() {
      if (isMainTask) {
        start = dateTimeList[0];
        end = dateTimeList[1];
        mainstartsnotificationdates[0] = start?.subtract(const Duration(minutes: 10));
        mainendsnotificationdates[0] = end?.subtract(const Duration(minutes: 10));
      } else {
        startsstagedates.add(dateTimeList[0]);
        endsstagedates.add(dateTimeList[1]);
        startsnotificationdates.add(dateTimeList[0].subtract(const Duration(minutes: 10)));
        endsnotificationdates.add(dateTimeList[1].subtract(const Duration(minutes: 10)));
      }
    });
  }

  Future<void> _selectNotificationDateTimeRange(BuildContext context, int index, bool isMainNotification) async {
    List<DateTime>? dateTimeList = await showOmniDateTimeRangePicker(
      context: context,
      startInitialDate: DateTime.now(),
      startFirstDate: DateTime(1600).subtract(const Duration(days: 3652)),
      startLastDate: DateTime.now().add(const Duration(days: 3652)),
      endInitialDate: DateTime.now(),
      endFirstDate: DateTime(1600).subtract(const Duration(days: 3652)),
      endLastDate: DateTime.now().add(const Duration(days: 3652)),
      is24HourMode: false,
      isShowSeconds: false,
      minutesInterval: 1,
      secondsInterval: 1,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      constraints: const BoxConstraints(maxWidth: 350, maxHeight: 650),
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(opacity: anim1.drive(Tween(begin: 0, end: 1)), child: child);
      },
      transitionDuration: const Duration(milliseconds: 200),
      barrierDismissible: true,
    );

    if (dateTimeList != null) {
      setState(() {
        if (isMainNotification) {
          mainstartsnotificationdates[index] = dateTimeList[0];
          mainendsnotificationdates[index] = dateTimeList[1];
        } else {
          startsnotificationdates[index] = dateTimeList[0];
          endsnotificationdates[index] = dateTimeList[1];
        }
      });
    }
  }

  Widget _buildDateTimeSelector(String title, String timeText, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(top: 3.h, left: 5.w, right: 5.w),
        height: 10.h,
        decoration: BoxDecoration(
          color: Material1.primaryColor,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold)),
            Text(timeText,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecurrenceOptions() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'کارەکە رۆژانە بکرێت',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            Checkbox(
              checkColor: Colors.white,
              fillColor: WidgetStateProperty.resolveWith(
                (states) => Material1.primaryColor,
              ),
              value: isDaily,
              onChanged: (bool? value) {
                setState(() {
                  isDaily = value!;
                  isWeekly = false;
                  isMonthly = false;
                });
              },
            ),
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'کارەکە هەفتانە بکرێت',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            Checkbox(
              checkColor: Colors.white,
              fillColor: WidgetStateProperty.resolveWith(
                (states) => Material1.primaryColor,
              ),
              value: isWeekly,
              onChanged: (bool? value) {
                setState(() {
                  isWeekly = value!;
                  isDaily = false;
                  isMonthly = false;
                });
              },
            ),
          ],
        ),
        if (isWeekly)
          Container(
            margin: EdgeInsets.only(top: 2.h, right: 5.w, left: 5.w),
            child: SelectWeekDays(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              days: _days,
              border: false,
              width: 90.w,
              boxDecoration: BoxDecoration(
                color: Material1.primaryColor,
                borderRadius: BorderRadius.circular(30.0),
              ),
              onSelect: (values) {
                offdays = values.map((e) => int.parse(e)).toList();
                log(offdays.toString());
              },
            ),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Text(
              'کارەکە مانگانە بکرێت',
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            Checkbox(
              checkColor: Colors.white,
              fillColor: WidgetStateProperty.resolveWith(
                (states) => Material1.primaryColor,
              ),
              value: isMonthly,
              onChanged: (bool? value) {
                setState(() {
                  isMonthly = value!;
                  isDaily = false;
                  isWeekly = false;
                });
              },
            ),
          ],
        ),
        if (isMonthly)
          Container(
            margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
            width: 70.w,
            height: 8.h,
            child: Material1.textfield(
                hint: 'ڕۆژی ئەرکەکە لە مانگەکەدا',
                controller: dayofthemontcontroller,
                inputType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^(3[01]|[12][0-9]|[1-9])$')),
                ],
                textColor: Material1.primaryColor),
          ),
      ],
    );
  }

  Widget _buildStageItem(int index) {
    return Row(
      children: [
        Column(
          children: [
            _buildDateTimeSelector(
              'هەڵبژاردنی کاتی کار',
              startsstagedates[index] == null
                  ? ''
                  : "${'لە'} ${formatDate(startsstagedates[index])} ${'بۆ'} ${formatDate(endsstagedates[index])}",
              () => _selectDateTimeRange(context, false),
            ),
            _buildDateTimeSelector(
              'هەڵبژاردنی کاتی ئاگادارکردنەوە',
              startsnotificationdates[index] == null
                  ? ''
                  : "${'لە'} ${formatDate(startsnotificationdates[index])} ${'بۆ'} ${formatDate(endsnotificationdates[index])}",
              () => _selectNotificationDateTimeRange(context, index, false),
            ),
            Container(
              margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
              width: 70.w,
              height: 8.h,
              child: Material1.textfield(
                  hint: 'ناوی بەش',
                  controller: stagetitlescontrollers[index],
                  textColor: Material1.primaryColor),
            ),
            Container(
              margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
              width: 70.w,
              height: 8.h,
              child: Material1.textfield(
                  hint: 'وردەکاری بەش',
                  controller: stagecontentcontrollers[index],
                  textColor: Material1.primaryColor),
            ),
          ],
        ),
        SizedBox(
          height: 20.h,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              SizedBox(
                width: 15.w,
                child: Text(
                  'بەشی ${index + 1}',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    startsstagedates.removeAt(index);
                    endsstagedates.removeAt(index);
                    startsnotificationdates.removeAt(index);
                    endsnotificationdates.removeAt(index);
                    stagetitlescontrollers.removeAt(index)?.dispose();
                    stagecontentcontrollers.removeAt(index)?.dispose();
                  });
                },
                child: SizedBox(
                  width: 15.w,
                  child: Icon(Icons.delete, color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainNotificationItem(int index) {
    return Row(
      children: [
        if (index != 0)
          IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                setState(() {
                  mainstartsnotificationdates.removeAt(index);
                  mainendsnotificationdates.removeAt(index);
                });
              }),
        SizedBox(
          width: 85.w,
          child: _buildDateTimeSelector(
            'هەڵبژاردنی کاتی ئاگادارکردنەوە',
            start == null
                ? ''
                : "${'لە'} ${formatDate(mainstartsnotificationdates[index])} - ${'بۆ'} ${formatDate(mainendsnotificationdates[index])}",
            () => _selectNotificationDateTimeRange(context, index, true),
          ),
        ),
      ],
    );
  }

  Future<bool> _validateInputs() async {
    if (isWeekly && offdays.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تکایە ڕۆژێک لە هەفتەکەدا هەڵبژێرە')),
      );
      return false;
    }
    
    if (isMonthly && dayofthemontcontroller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تکایە ڕۆژی ئەرکەکە لە مانگەکەدا هەڵبژێرە')),
      );
      return false;
    }
    
    if (start == null || end == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تکایە کاتی کار هەڵبژێرە')),
      );
      return false;
    }
    
    if (descriptioncontroller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تکایە وردەکاری بنووسە')),
      );
      return false;
    }
    
    if (namecontroller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تکایە ناوی بنووسە')),
      );
      return false;
    }
    
    if (deductionamountcontroller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تکایە بڕی وغەرامە بنووسە')),
      );
      return false;
    }
    
    if (rewardamountcontroller.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تکایە بڕی پاداشت بنووسە')),
      );
      return false;
    }
    
    if (dropdownValue != 'default1') {
      final password = await showDialog<String>(
        context: context,
        builder: (context) {
          String password = '';
          return AlertDialog(
            title: Text('Enter Password'),
            content: TextField(
              onChanged: (value) => password = value,
              obscureText: true,
              decoration: InputDecoration(hintText: "Password"),
            ),
            actions: [
              Material1.button(
                label: 'OK',
                function: () => Navigator.pop(context, password),
                textcolor: Colors.white,
                buttoncolor: Material1.primaryColor,
              ),
            ],
          );
        },
      );
      
      if (password != '1010') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password is incorrect')),
        );
        return false;
      }
    }
    
    return true;
  }

  List<DateTime> _calculateWeeklySchedule() {
    List<DateTime> scheduledDates = [];
    if (isWeekly && start != null && end != null) {
      DateTime currentDate = start!;
      while (currentDate.isBefore(end!)) {
        for (int weekday in offdays) {
          DateTime nextDate = currentDate;
          while (nextDate.weekday != weekday) {
            nextDate = nextDate.add(Duration(days: 1));
          }
          if (nextDate.isBefore(end!)) {
            scheduledDates.add(DateTime(
              nextDate.year,
              nextDate.month,
              nextDate.day,
              start!.hour,
              start!.minute,
            ));
          }
        }
        currentDate = currentDate.add(Duration(days: 7));
      }
    }
    return scheduledDates;
  }


  Future<void> _addTasks() async {
  if (!await _validateInputs()) return;

  final taskId = '${widget.adminemail}-${DateTime.now().toString()}';

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => AlertDialog(
      title: Center(child: CircularProgressIndicator()),
    ),
  );

  try {
    if (widget.isbatch) {
      // Batch mode - add tasks to all selected users
      for (final userId in widget.selectedUsers) {
        await _addTaskToUser(
          userId,
          taskId,
          isWeekly ? _calculateWeeklySchedule() : null,
        );
      }
    } else {
      // Single user mode
      await _addTaskToUser(
        widget.email,
        taskId,
        isWeekly ? _calculateWeeklySchedule() : null,
      );
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('کارەکە بەسەرکەوتویی زیادکرا')),
    );
    
    if (mounted) {
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  } catch (error) {
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('هەڵەیەک هەیە: $error')),
      );
    }
  }
}

Future<void> _addTaskToUser(
  String userId, 
  String taskId,
  List<DateTime>? scheduledDates,
) async {
  final taskData = {
    'description': descriptioncontroller.text,
    'time': DateTime.now(),
    'start': start,
    'end': end,
    'status': 'pending',
    'name': namecontroller.text,
    'isdaily': isDaily,
    'addedby': widget.adminemail,
    'deductionamount': deductionamountcontroller.text,
    'rewardamount': rewardamountcontroller.text,
    'isowntask': false,
    'startstagedates': startsstagedates,
    'endstagedates': endsstagedates,
    'startnotificationdates': [...startsnotificationdates, ...mainstartsnotificationdates],
    'endnotificationdates': [...endsnotificationdates, ...mainendsnotificationdates],
    'isnotificationset': false,
    'startstages': List.filled(startsstagedates.length, false),
    'endstages': List.filled(endsstagedates.length, false),
    'lastsystemupdate': DateTime.now(),
    'lastupdate': DateTime.now(),
    'stagetitles': stagetitlescontrollers.map((c) => c?.text ?? '').toList(),
    'stagecontents': stagecontentcontrollers.map((c) => c?.text ?? '').toList(),
    'isweekly': isWeekly,
    'ismonthly': isMonthly,
    'weekdays': offdays,
    'dayofthemonth': dayofthemontcontroller.text,
    'scheduled_dates': scheduledDates?.map((d) => Timestamp.fromDate(d)).toList(),
    'current_occurrence': 0, // Track which occurrence we're on
    'total_occurrences': scheduledDates?.length ?? 1,
  };

  await FirebaseFirestore.instance
      .collection('user')
      .doc(userId)
      .collection('tasks')
      .doc(taskId)
      .set(taskData);
  
  // Send notification
  final userDoc = await FirebaseFirestore.instance.collection('user').doc(userId).get();
  if (userDoc.exists) {
    sendingnotification(
      'کار',
      'کارێکت بۆ زیاد کرا',
      userDoc.data()?['token'],
      dropdownValue,
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('زیادکردنی کار بۆ کارمەند'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
      ),
      body: ListView(
        children: [
          // Main task time selection
          _buildDateTimeSelector(
            'هەڵبژاردنی کاتی کار',
            start == null
                ? ''
                : "${'لە'} ${formatDate(start)} - ${'بۆ'} ${formatDate(end)}",
            () => _selectDateTimeRange(context, true),
          ),

          // Main notifications
          ...List.generate(mainstartsnotificationdates.length, 
              (index) => _buildMainNotificationItem(index)),

          // Add main notification button
          Container(
            margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
            decoration: BoxDecoration(
                color: Material1.primaryColor,
                borderRadius: BorderRadius.circular(15)),
            height: 6.h,
            width: 90.w,
            child: Material1.button(
                label: 'زیادکردنی بەش ئاگادارکردنەوە',
                buttoncolor: Material1.primaryColor,
                textcolor: Colors.white,
                function: () {
                  setState(() {
                    mainstartsnotificationdates.add(DateTime.now().subtract(const Duration(minutes: 10)));
                    mainendsnotificationdates.add(DateTime.now().subtract(const Duration(minutes: 10)));
                  });
                }),
          ),

          // Sound selection
          Container(
            margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
            height: 8.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 6.h,
                  width: 30.w,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: dropdownValue,
                    icon: const Icon(Icons.arrow_downward, color: Colors.black),
                    elevation: 16,
                    style: TextStyle(color: Material1.primaryColor),
                    underline: Container(height: 2, color: Material1.primaryColor),
                    onChanged: (String? value) {
                      setState(() => dropdownValue = value!);
                    },
                    items: soundList.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(value: value, child: Text(value));
                    }).toList(),
                  ),
                ),
                SizedBox(
                    height: 6.h,
                    width: 30.w,
                    child: Center(child: Text('هەڵبژاردنی دەنگ'))),
              ],
            ),
          ),

          // Task details
          Container(
            margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
            width: 90.w,
            height: 8.h,
            child: Material1.textfield(
                hint: 'ناوی کار',
                controller: namecontroller,
                textColor: Material1.primaryColor),
          ),
          Container(
            margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
            width: 90.w,
            height: 15.h,
            child: Material1.textfield(
                hint: 'وردەکاری',
                maxLines: 5,
                controller: descriptioncontroller,
                textColor: Material1.primaryColor),
          ),
          Container(
            margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
            width: 90.w,
            height: 8.h,
            child: Material1.textfield(
                hint: 'بڕی غەرامە',
                inputType: TextInputType.number,
                controller: deductionamountcontroller,
                textColor: Material1.primaryColor),
          ),
          Container(
            margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
            width: 90.w,
            height: 8.h,
            child: Material1.textfield(
                hint: 'بڕی پاداشت',
                inputType: TextInputType.number,
                controller: rewardamountcontroller,
                textColor: Material1.primaryColor),
          ),

          // Recurrence options
          _buildRecurrenceOptions(),

          // Add stage button
          Container(
            margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
            decoration: BoxDecoration(
                color: Material1.primaryColor,
                borderRadius: BorderRadius.circular(15)),
            height: 6.h,
            width: 90.w,
            child: Material1.button(
                label: 'زیادکردنی بەش',
                buttoncolor: Material1.primaryColor,
                textcolor: Colors.white,
                function: () {
                  setState(() {
                    startsstagedates.add(DateTime.now());
                    endsstagedates.add(DateTime.now());
                    startsnotificationdates.add(start);
                    endsnotificationdates.add(end);
                    stagetitlescontrollers.add(TextEditingController());
                    stagecontentcontrollers.add(TextEditingController());
                  });
                }),
          ),

          // Stages list
          ...List.generate(startsstagedates.length, (index) => _buildStageItem(index)),

          // Submit button
          Container(
            margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w, bottom: 5.h),
            width: 90.w,
            height: 8.h,
            child: Material1.button(
                label: 'زیادکردن',
                function: _addTasks,
                textcolor: Colors.white,
                buttoncolor: Material1.primaryColor),
          )
        ],
      ),
    );
  }
}