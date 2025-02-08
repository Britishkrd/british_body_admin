import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class EditingLoginLogout extends StatefulWidget {
  final String email;
  final double latitude;
  final double longtitude;
  final String note;
  final DateTime time;
  final bool checkin;
  final bool checkout;
  final DocumentReference<Object?> reference;
  const EditingLoginLogout({
    super.key,
    required this.email,
    required this.reference,
    required this.latitude,
    required this.longtitude,
    required this.note,
    required this.time,
    required this.checkin,
    required this.checkout,
  });

  @override
  State<EditingLoginLogout> createState() => _EditingLoginLogoutState();
}

bool checkin = true;
double latitude = 0.0;
double longtitude = 0.0;
TextEditingController notecontroller = TextEditingController();
TextEditingController latcontroller = TextEditingController();
TextEditingController longcontroller = TextEditingController();

DateTime? start;
DateTime? end;
bool ischeckin = true;
bool ischeckout = false;
String formatDate(DateTime? date) {
  final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
  return formatter.format(date ?? DateTime.now());
}

class _EditingLoginLogoutState extends State<EditingLoginLogout> {
  @override
  void initState() {
    notecontroller.text = widget.note;
    latcontroller.text = widget.latitude.toString();
    longcontroller.text = widget.longtitude.toString();
    start = widget.time;
    ischeckin = widget.checkin;
    ischeckout = widget.checkout;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('دەستکاری کردنی چوونەژوورەوە / دەرچوونەوە'),
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
                    Text('هەڵبژاردنی کاتی چوونەژوورەوە / دەرچوونەوە',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold)),
                    Text(
                        start == null
                            ? ''
                            : formatDate(
                                start == DateTime.now() ? null : start),
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
                hint: 'تێبینی',
                controller: notecontroller,
                textColor: Material1.primaryColor),
          ),
          Container(
            margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
            width: 90.w,
            height: 8.h,
            child: Material1.textfield(
                hint: 'درێژایی (latitude)',
                controller: latcontroller,
                inputType: TextInputType.number,
                textColor: Material1.primaryColor),
          ),
          Container(
            margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
            width: 90.w,
            height: 8.h,
            child: Material1.textfield(
                hint: 'پانایی (longtitude)',
                controller: longcontroller,
                inputType: TextInputType.number,
                textColor: Material1.primaryColor),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'چوونەژوورەوە',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              Checkbox(
                checkColor: Colors.white,
                fillColor: WidgetStateProperty.resolveWith(
                  (states) => Material1.primaryColor,
                ),
                value: ischeckin,
                onChanged: (bool? value) {
                  setState(() {
                    ischeckin = value!;
                    ischeckout = !value;
                  });
                },
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                'چوونەژوورەوە',
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              Checkbox(
                checkColor: Colors.white,
                fillColor: WidgetStateProperty.resolveWith(
                  (states) => Material1.primaryColor,
                ),
                value: ischeckout,
                onChanged: (bool? value) {
                  setState(() {
                    ischeckout = value!;
                    ischeckin = !value;
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
                label: 'دەستکاری کردن',
                function: () async {
                  if (start == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'تکایە کاتی چوونەژوورەوە / دەرچوونەوە هەڵبژێرە'),
                      ),
                    );
                    return;
                  }
                  if (notecontroller.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تکایە تێبینی بنووسە'),
                      ),
                    );
                    return;
                  }
                  if (latcontroller.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تکایە درێژایی بنووسە'),
                      ),
                    );
                    return;
                  }
                  if (longcontroller.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تکایە پانایی بنووسە'),
                      ),
                    );
                    return;
                  }
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title:
                              Text('دەستکاری کردنی چوونەژوورەوە / دەرچوونەوە'),
                          content: Text(
                              'دڵنیایت لە دەستکاری کردنی چوونەژوورەوە / دەرچوونەوە؟'),
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
                                  widget.reference.update({
                                    'checkin': ischeckin,
                                    'checkout': ischeckout,
                                    'time': start,
                                    'note': notecontroller.text,
                                    'latitude':
                                        double.parse(latcontroller.text),
                                    'longtitude':
                                        double.parse(longcontroller.text),
                                  }).then(
                                    (value) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'چوونەژوورەوە / دەرچوونەوە بەسەرکەوتویی دەستکاری کرا'),
                                        ),
                                      );
                                      Navigator.popUntil(
                                          context, (route) => route.isFirst);
                                    },
                                  ).catchError((error) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('هەڵەیەک هەیە'),
                                      ),
                                    );
                                  });
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
