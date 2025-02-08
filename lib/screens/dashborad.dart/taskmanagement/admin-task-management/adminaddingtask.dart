import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

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

bool checkin = true;
double latitude = 0.0;
double longtitude = 0.0;
TextEditingController descriptioncontroller = TextEditingController();
TextEditingController namecontroller = TextEditingController();
TextEditingController deductionamountcontroller = TextEditingController();
TextEditingController rewardamountcontroller = TextEditingController();

DateTime? start;
DateTime? end;
bool isDaily = false;
String formatDate(DateTime? date) {
  final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
  return formatter.format(date ?? DateTime.now());
}

class _AdminAddingTaskState extends State<AdminAddingTask> {
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
              start = dateTimeList?[0] ?? DateTime.now();
              end = dateTimeList?[1] ?? DateTime.now();
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
            height: 8.h,
            child: Material1.textfield(
                hint: 'وردەکاری',
                controller: descriptioncontroller,
                textColor: Material1.primaryColor),
          ),
          Container(
            margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
            width: 90.w,
            height: 8.h,
            child: Material1.textfield(
                hint: 'بڕی وغەرامە',
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
                  });
                },
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
            width: 90.w,
            height: 8.h,
            child: Material1.button(
                label: 'زیادکردن',
                function: () async {
                  if (start == null) {
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
                                        'isowntask': false
                                      }).then((value) {
                                        FirebaseFirestore.instance
                                            .collection('user')
                                            .doc(widget.selectedUsers[i])
                                            .get()
                                            .then((value) {
                                          sendingnotification(
                                              'کار ',
                                              'کارێکت بۆ زیاد کرا',
                                              value.data()?['token']);
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
                                      'isowntask': false
                                    }).then((value) {
                                      FirebaseFirestore.instance
                                          .collection('user')
                                          .doc(widget.email)
                                          .get()
                                          .then((value) {
                                        sendingnotification(
                                            'کار ',
                                            'کارێکت بۆ زیاد کرا',
                                            value.data()?['token']);
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
