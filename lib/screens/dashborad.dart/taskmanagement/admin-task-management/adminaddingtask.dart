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

const List<String> list = <String>[
  'default1',
  'annoying',
  'annoying1',
  'arabic',
  'laughing',
  'longfart',
  'mild',
  'oud',
  'rooster',
  'salawat',
  'shortfart',
  'soft2',
  'softalert',
  'srusht',
  'witch',
];
String dropdownValue = 'default1';

final List<DayInWeek> _days = [
  DayInWeek("Mon", dayKey: "1"),
  DayInWeek("Tue", dayKey: "2"),
  DayInWeek("Wen", dayKey: "3"),
  DayInWeek("Thu", dayKey: "4"),
  DayInWeek("Fri", dayKey: "5"),
  DayInWeek("Sat", dayKey: "6"),
  DayInWeek("Sun", dayKey: "7"),
];
List<int> offdays = [];

bool checkin = true;
double latitude = 0.0;
double longtitude = 0.0;
TextEditingController descriptioncontroller = TextEditingController();
TextEditingController namecontroller = TextEditingController();
TextEditingController deductionamountcontroller = TextEditingController();
TextEditingController rewardamountcontroller = TextEditingController();
TextEditingController dayofthemontcontroller = TextEditingController();

DateTime? start;
DateTime? end;
List<DateTime?> startsstagedates = [];
List<DateTime?> endsstagedates = [];
List<DateTime?> startsnotificationdates = [
  now.subtract(const Duration(minutes: 10))
];
List<DateTime?> endsnotificationdates = [
  now.subtract(const Duration(minutes: 10))
];
List<TextEditingController?> stagetitlescontrollers = [];
List<TextEditingController?> stagecontentcontrollers = [];
List<DateTime?> mainstartsnotificationdates = [
  now.subtract(const Duration(minutes: 10))
];
List<DateTime?> mainendsnotificationdates = [
  now.subtract(const Duration(minutes: 10))
];
bool isDaily = false;
bool isWeekly = false;
bool isMonthly = false;
DateTime now = DateTime.now();
String formatDate(DateTime? date) {
  final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
  return formatter.format(date ?? DateTime.now());
}

class _AdminAddingTaskState extends State<AdminAddingTask> {
  @override
  void dispose() {
    descriptioncontroller.clear();
    namecontroller.clear();
    deductionamountcontroller.clear();
    rewardamountcontroller.clear();

    super.dispose();
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
              if ((dateTimeList?[0] ?? DateTime.now())
                  .isAfter(dateTimeList?[1] ?? DateTime.now())) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'تکایە کاتی دەستپێک نابێت لە دوای کاتی کۆتایی بێت'),
                  ),
                );
                return;
              }
              start = dateTimeList?[0] ?? DateTime.now();
              end = dateTimeList?[1] ?? DateTime.now();
              mainstartsnotificationdates[0] = ((start ?? DateTime.now())
                  .subtract(const Duration(minutes: 10)));
              mainendsnotificationdates[0] = ((end ?? DateTime.now())
                  .subtract(const Duration(minutes: 10)));
              setState(() {});
            },
            child: Container(
                margin: EdgeInsets.only(top: 3.h, left: 5.w, right: 5.w),
                height: 10.h,
                decoration: BoxDecoration(
                    color: Material1.primaryColor,
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('هەڵبژاردنی کاتی کار',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold)),
                    Text(
                        start == null
                            ? ''
                            : "${'لە'} ${formatDate(start == DateTime.now() ? null : start)} - ${'بۆ'} ${formatDate(end == DateTime.now() ? null : end)}",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold)),
                  ],
                )),
          ),
          ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: mainstartsnotificationdates.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
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
                      child: GestureDetector(
                        onTap: () async {
                          List<DateTime>? dateTimeList =
                              await showOmniDateTimeRangePicker(
                            context: context,
                            startInitialDate: DateTime.now(),
                            startFirstDate: DateTime(1600)
                                .subtract(const Duration(days: 3652)),
                            startLastDate: DateTime.now().add(
                              const Duration(days: 3652),
                            ),
                            endInitialDate: DateTime.now(),
                            endFirstDate: DateTime(1600)
                                .subtract(const Duration(days: 3652)),
                            endLastDate: DateTime.now().add(
                              const Duration(days: 3652),
                            ),
                            is24HourMode: false,
                            isShowSeconds: false,
                            minutesInterval: 1,
                            secondsInterval: 1,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(16)),
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
                            transitionDuration:
                                const Duration(milliseconds: 200),
                            barrierDismissible: true,
                          );
                          mainstartsnotificationdates[index] =
                              dateTimeList?[0] ?? DateTime.now();
                          mainendsnotificationdates[index] =
                              dateTimeList?[1] ?? DateTime.now();
                          setState(() {});
                        },
                        child: Container(
                            margin: EdgeInsets.only(
                                top: 3.h, left: 5.w, right: 5.w),
                            height: 10.h,
                            decoration: BoxDecoration(
                                color: Material1.primaryColor,
                                borderRadius: BorderRadius.circular(15)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('هەڵبژاردنی کاتی ئاگادارکردنەوە',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    start == null
                                        ? ''
                                        : "${'لە'} ${formatDate(mainstartsnotificationdates.isEmpty ? null : mainstartsnotificationdates[index])} - ${'بۆ'} ${formatDate(mainendsnotificationdates.isEmpty ? null : mainendsnotificationdates[index])}",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold)),
                              ],
                            )),
                      ),
                    ),
                  ],
                );
              }),
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
                    mainstartsnotificationdates
                        .add(now.subtract(const Duration(minutes: 10)));
                    mainendsnotificationdates
                        .add(now.subtract(const Duration(minutes: 10)));
                  });
                }),
          ),
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
                    icon: const Icon(
                      Icons.arrow_downward,
                      color: Colors.black,
                    ),
                    elevation: 16,
                    style: TextStyle(color: Material1.primaryColor),
                    underline:
                        Container(height: 2, color: Material1.primaryColor),
                    onChanged: (String? value) {
                      setState(() {
                        dropdownValue = value!;
                      });
                    },
                    items: list.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                          value: value, child: Text(value));
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
                  List daysoff = values;
                  log(daysoff.toString());
                  offdays = [];
                  for (int i = 0; i < values.length; i++) {
                    offdays.add(int.parse(daysoff[i]));
                  }
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
                    FilteringTextInputFormatter.allow(
                        RegExp(r'^(3[01]|[12][0-9]|[1-9])$')),
                  ],
                  textColor: Material1.primaryColor),
            ),
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
                    startsstagedates.add(now);
                    endsstagedates.add(now);
                    startsnotificationdates.add(start);
                    endsnotificationdates.add(end);
                    stagecontentcontrollers.add(TextEditingController());
                    stagetitlescontrollers.add(TextEditingController());
                  });
                }),
          ),
          ListView.builder(
            itemCount: startsstagedates.length,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => Row(
              children: [
                Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: 5.h),
                      width: 85.w,
                      child: GestureDetector(
                        onTap: () async {
                          List<DateTime>? dateTimeList =
                              await showOmniDateTimeRangePicker(
                            context: context,
                            startInitialDate: DateTime.now(),
                            startFirstDate: DateTime(1600)
                                .subtract(const Duration(days: 3652)),
                            startLastDate: DateTime.now().add(
                              const Duration(days: 3652),
                            ),
                            endInitialDate: DateTime.now(),
                            endFirstDate: DateTime(1600)
                                .subtract(const Duration(days: 3652)),
                            endLastDate: DateTime.now().add(
                              const Duration(days: 3652),
                            ),
                            is24HourMode: false,
                            isShowSeconds: false,
                            minutesInterval: 1,
                            secondsInterval: 1,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(16)),
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
                            transitionDuration:
                                const Duration(milliseconds: 200),
                            barrierDismissible: true,
                          );
                          startsstagedates[index] = dateTimeList?[0] ?? now;
                          endsstagedates[index] = dateTimeList?[1] ?? now;
                          startsnotificationdates[index] = dateTimeList?[0]
                                  .subtract(const Duration(minutes: 10)) ??
                              now;
                          endsnotificationdates[index] = dateTimeList?[1]
                                  .subtract(const Duration(minutes: 10)) ??
                              now;
                          setState(() {});
                        },
                        child: Container(
                            margin: EdgeInsets.only(
                                top: 3.h, left: 5.w, right: 5.w),
                            height: 10.h,
                            decoration: BoxDecoration(
                                color: Material1.primaryColor,
                                borderRadius: BorderRadius.circular(15)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('هەڵبژاردنی کاتی کار',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    startsstagedates[index] == null
                                        ? ''
                                        : "${'لە'} ${formatDate(startsstagedates[index] == now ? null : startsstagedates[index])} ${'بۆ'} ${formatDate(endsstagedates[index] == now ? null : endsstagedates[index])}",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold)),
                              ],
                            )),
                      ),
                    ),
                    SizedBox(
                      width: 85.w,
                      child: GestureDetector(
                        onTap: () async {
                          List<DateTime>? dateTimeList =
                              await showOmniDateTimeRangePicker(
                            context: context,
                            startInitialDate: DateTime.now(),
                            startFirstDate: DateTime(1600)
                                .subtract(const Duration(days: 3652)),
                            startLastDate: DateTime.now().add(
                              const Duration(days: 3652),
                            ),
                            endInitialDate: DateTime.now(),
                            endFirstDate: DateTime(1600)
                                .subtract(const Duration(days: 3652)),
                            endLastDate: DateTime.now().add(
                              const Duration(days: 3652),
                            ),
                            is24HourMode: false,
                            isShowSeconds: false,
                            minutesInterval: 1,
                            secondsInterval: 1,
                            borderRadius:
                                const BorderRadius.all(Radius.circular(16)),
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
                            transitionDuration:
                                const Duration(milliseconds: 200),
                            barrierDismissible: true,
                          );
                          startsnotificationdates[index] =
                              dateTimeList?[0] ?? now;
                          endsnotificationdates[index] =
                              dateTimeList?[1] ?? now;
                          setState(() {});
                        },
                        child: Container(
                            margin: EdgeInsets.only(
                                top: 3.h, left: 5.w, right: 5.w),
                            height: 10.h,
                            decoration: BoxDecoration(
                                color: Material1.primaryColor,
                                borderRadius: BorderRadius.circular(15)),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text('هەڵبژاردنی کاتی ئاگادارکردنەوە',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    startsstagedates[index] == null
                                        ? ''
                                        : "${'لە'} ${formatDate(startsnotificationdates[index] == now ? null : startsnotificationdates[index])} ${'بۆ'} ${formatDate(endsnotificationdates[index] == now ? null : endsnotificationdates[index])}",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold)),
                              ],
                            )),
                      ),
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
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.bold),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            startsstagedates.removeAt(index);
                            endsstagedates.removeAt(index);
                            startsnotificationdates.removeAt(index);
                            endsnotificationdates.removeAt(index);
                            stagetitlescontrollers.removeAt(index);
                            stagecontentcontrollers.removeAt(index);
                          });
                        },
                        child: SizedBox(
                          width: 15.w,
                          child: Icon(
                            Icons.delete,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin:
                EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w, bottom: 5.h),
            width: 90.w,
            height: 8.h,
            child: Material1.button(
                label: 'زیادکردن',
                function: () async {
                  if (isWeekly && offdays.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تکایە ڕۆژێک لە هەفتەکەدا هەڵبژێرە'),
                      ),
                    );
                    return;
                  }
                  if (isMonthly && dayofthemontcontroller.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                            Text('تکایە ڕۆژی ئەرکەکە لە مانگەکەدا هەڵبژێرە'),
                      ),
                    );
                    return;
                  }
                  if (start == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تکایە کاتی کار هەڵبژێرە'),
                      ),
                    );
                    return;
                  }
                  if (end == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تکایە کاتی کار هەڵبژێرە'),
                      ),
                    );
                    return;
                  }
                  if (descriptioncontroller.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تکایە وردەکاری بنووسە'),
                      ),
                    );
                    return;
                  }
                  if (namecontroller.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تکایە ناوی بنووسە'),
                      ),
                    );
                    return;
                  }
                  if (deductionamountcontroller.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تکایە بڕی وغەرامە بنووسە'),
                      ),
                    );
                    return;
                  }
                  if (rewardamountcontroller.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تکایە بڕی پاداشت بنووسە'),
                      ),
                    );
                    return;
                  }
                  List<String> stagetitles = [];
                  List<String> stagecontents = [];
                  for (int i = 0; i < stagetitlescontrollers.length; i++) {
                    stagetitles.add(stagetitlescontrollers[i]?.text ?? '');
                    stagecontents.add(stagecontentcontrollers[i]?.text ?? '');
                  }
                  List<bool> startstages = [];
                  List<bool> endstages = [];

                  for (int i = 0; i < startsstagedates.length; i++) {
                    startstages.add(false);
                    endstages.add(false);
                  }
                  startsnotificationdates.addAll(mainstartsnotificationdates);
                  endsnotificationdates.addAll(mainendsnotificationdates);
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('زیادکردنی کار'),
                          content: Text('دڵنییایت لە زیادکردنی کارەکە؟'),
                          actions: [
                            Material1.button(
                                label: 'نەخێر',
                                function: () {
                                  Navigator.pop(context);
                                },
                                textcolor: Colors.white,
                                buttoncolor: Material1.primaryColor),
                            Material1.button(
                                label: 'بەڵێ',
                                function: () async {
                                  String password = '';
                                  if ('default1' != dropdownValue) {
                                    await showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text('Enter Password'),
                                          content: TextField(
                                            onChanged: (value) {
                                              password = value;
                                            },
                                            obscureText: true,
                                            decoration: InputDecoration(
                                                hintText: "Password"),
                                          ),
                                          actions: [
                                            Material1.button(
                                              label: 'OK',
                                              function: () {
                                                Navigator.pop(context);
                                              },
                                              textcolor: Colors.white,
                                              buttoncolor:
                                                  Material1.primaryColor,
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  }

                                  if (password != '1010' &&
                                      'default1' != dropdownValue) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Password is incorrect'),
                                      ),
                                    );
                                    return;
                                  }
                                  if (widget.isbatch) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Center(
                                                child:
                                                    const CircularProgressIndicator()),
                                          );
                                        });
                                    for (int i = 0;
                                        i < widget.selectedUsers.length;
                                        i++) {
                                      FirebaseFirestore.instance
                                          .collection('user')
                                          .doc(widget.selectedUsers[i])
                                          .collection('tasks')
                                          .doc(
                                              '${widget.adminemail}-${DateTime.now().toString()}')
                                          .set({
                                        'description':
                                            descriptioncontroller.text,
                                        'time': DateTime.now(),
                                        'start': start,
                                        'end': end,
                                        'status': 'pending',
                                        'name': namecontroller.text,
                                        'isdaily': isDaily,
                                        'addedby': widget.adminemail,
                                        'deductionamount':
                                            deductionamountcontroller.text,
                                        'rewardamount':
                                            rewardamountcontroller.text,
                                        'isowntask': false,
                                        'startstagedates': startsstagedates,
                                        'endstagedates': endsstagedates,
                                        'startnotificationdates':
                                            startsnotificationdates,
                                        'endnotificationdates':
                                            endsnotificationdates,
                                        'isnotificationset': false,
                                        'startstages': startstages,
                                        'endstages': endstages,
                                        'lastsystemupdate': DateTime.now(),
                                        'lastupdate': DateTime.now(),
                                        'stagetitles': stagetitles,
                                        'stagecontents': stagecontents,
                                        'isweekly': isWeekly,
                                        'ismonthly': isMonthly,
                                        'weekdays': offdays,
                                        'dayofthemonth':
                                            dayofthemontcontroller.text
                                      }).then((value) {
                                        FirebaseFirestore.instance
                                            .collection('user')
                                            .doc(widget.selectedUsers[i])
                                            .get()
                                            .then((value) {
                                          log(value.data()?['token']);
                                          sendingnotification(
                                              'کار ',
                                              'کارێکت بۆ زیاد کرا',
                                              value.data()?['token'],
                                              dropdownValue);
                                        });
                                      });
                                    }
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content:
                                            Text('کارەکە بەسەرکەوتویی زیادکرا'),
                                      ),
                                    );
                                    Navigator.popUntil(
                                        context, (route) => route.isFirst);
                                  } else {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Center(
                                                child:
                                                    const CircularProgressIndicator()),
                                          );
                                        });
                                    FirebaseFirestore.instance
                                        .collection('user')
                                        .doc(widget.email)
                                        .collection('tasks')
                                        .doc(
                                            '${widget.adminemail}-${DateTime.now().toString()}')
                                        .set({
                                      'description': descriptioncontroller.text,
                                      'time': DateTime.now(),
                                      'start': start,
                                      'end': end,
                                      'status': 'pending',
                                      'name': namecontroller.text,
                                      'isdaily': isDaily,
                                      'addedby': widget.adminemail,
                                      'deductionamount':
                                          deductionamountcontroller.text,
                                      'rewardamount':
                                          rewardamountcontroller.text,
                                      'isowntask': false,
                                      'startstagedates': startsstagedates,
                                      'endstagedates': endsstagedates,
                                      'startnotificationdates':
                                          startsnotificationdates,
                                      'endnotificationdates':
                                          endsnotificationdates,
                                      'isnotificationset': false,
                                      'startstages': startstages,
                                      'endstages': endstages,
                                      'lastsystemupdate': DateTime.now(),
                                      'lastupdate': DateTime.now(),
                                      'stagetitles': stagetitles,
                                      'stagecontents': stagecontents,
                                      'isweekly': isWeekly,
                                      'ismonthly': isMonthly,
                                      'weekdays': offdays,
                                      'dayofthemonth':
                                          dayofthemontcontroller.text
                                    }).then((value) {
                                      FirebaseFirestore.instance
                                          .collection('user')
                                          .doc(widget.email)
                                          .get()
                                          .then((value) {
                                        log(value.data()?['token']);

                                        sendingnotification(
                                            'کار ',
                                            'کارێکت بۆ زیاد کرا',
                                            value.data()?['token'],
                                            dropdownValue);
                                      });
                                    }).then(
                                      (value) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                'کارەکە بەسەرکەوتویی زیادکرا'),
                                          ),
                                        );
                                        Navigator.popUntil(
                                            context, (route) => route.isFirst);
                                      },
                                    ).catchError((error) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text('هەڵەیەک هەیە'),
                                        ),
                                      );
                                    });
                                  }
                                },
                                textcolor: Colors.white,
                                buttoncolor: Material1.primaryColor),
                          ],
                        );
                      });
                },
                textcolor: Colors.white,
                buttoncolor: Material1.primaryColor),
          )
        ],
      ),
    );
  }
}
