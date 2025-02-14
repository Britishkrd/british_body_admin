import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class AdminAddingtarget extends StatefulWidget {
  final String adminemail;
  final String email;
  const AdminAddingtarget(
      {super.key, required this.email, required this.adminemail});

  @override
  State<AdminAddingtarget> createState() => _AdminAddingtargetState();
}

bool checkin = true;
double latitude = 0.0;
double longtitude = 0.0;

DateTime? start;
DateTime? end;
TextEditingController titlescontrollers = TextEditingController();
TextEditingController descriptioncontrollers = TextEditingController();
TextEditingController rewardcontrollers = TextEditingController();
TextEditingController targetcontrollers = TextEditingController();

DateTime now = DateTime.now();
String formatDate(DateTime? date) {
  final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
  return formatter.format(date ?? DateTime.now());
}

class _AdminAddingtargetState extends State<AdminAddingtarget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('زیادکردنی تارگێت بۆ کارمەند'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Container(
            margin: EdgeInsets.only(top: 5.h),
            width: 100.w,
            child: Container(
                margin: EdgeInsets.only(top: 3.h, left: 5.w, right: 5.w),
                height: 50.h,
                decoration: BoxDecoration(
                    color: Material1.primaryColor,
                    borderRadius: BorderRadius.circular(15)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
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
                          transitionDuration: const Duration(milliseconds: 200),
                          barrierDismissible: true,
                        );

                        start = dateTimeList?[0] ?? now;
                        end = dateTimeList?[1] ?? now;
                        setState(() {});
                      },
                      child: Text('هەڵبژاردنی کاتی تارگێت',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold)),
                    ),
                    Text(
                        end == null
                            ? ''
                            : "${'لە'} ${formatDate(start)} ${'بۆ'} ${formatDate(end)}",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold)),
                    SizedBox(
                      width: 80.w,
                      child: Material1.textfield(
                          hint: 'ناوی تارگێت',
                          hintcolor: Colors.white,
                          textColor: Colors.white,
                          controller: titlescontrollers),
                    ),
                    SizedBox(
                      height: 10.h,
                      width: 80.w,
                      child: Material1.textfield(
                          hint: 'وردەکاری',
                          hintcolor: Colors.white,
                          textColor: Colors.white,
                          maxLines: 5,
                          controller: descriptioncontrollers),
                    ),
                    SizedBox(
                      width: 80.w,
                      child: Material1.textfield(
                          hint: 'پاداشت',
                          hintcolor: Colors.white,
                          textColor: Colors.white,
                          inputType: TextInputType.number,
                          controller: rewardcontrollers),
                    ),
                    SizedBox(
                      width: 80.w,
                      child: Material1.textfield(
                          hint: 'بڕی تارگێت',
                          hintcolor: Colors.white,
                          textColor: Colors.white,
                          inputType: TextInputType.number,
                          controller: targetcontrollers),
                    ),
                  ],
                )),
          ),
          Container(
            margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
            width: 90.w,
            height: 8.h,
            child: Material1.button(
                label: 'زیادکردنی تارگێت',
                function: () async {
                  if (start == null ||
                      end == null ||
                      titlescontrollers.text.isEmpty ||
                      descriptioncontrollers.text.isEmpty ||
                      rewardcontrollers.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تکایە هەموو خانەکان پڕبکەوە'),
                      ),
                    );
                    return;
                  }
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('زیادکردنی کار'),
                          content: Text('دڵنییایت لە زیادکردنی تارگێتەکە؟'),
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
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Center(
                                              child:
                                                  const CircularProgressIndicator()),
                                        );
                                      });
                                  await FirebaseFirestore.instance
                                      .collection('target')
                                      .doc(DateTime.now().toIso8601String())
                                      .set({
                                    'title': titlescontrollers.text,
                                    'description': descriptioncontrollers.text,
                                    'reward': rewardcontrollers.text,
                                    'start': start,
                                    'end': end,
                                    'adminemail': widget.adminemail,
                                    'email': widget.email,
                                    'target': targetcontrollers.text,
                                    'date': DateTime.now() 
                                  });
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('کارەکە بەسەرکەوتویی زیادکرا'),
                                    ),
                                  );
                                  Navigator.popUntil(
                                      context, (route) => route.isFirst);
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
