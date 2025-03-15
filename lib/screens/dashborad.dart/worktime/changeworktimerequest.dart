import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:day_night_time_picker/day_night_time_picker.dart';

class Changeworktimerequest extends StatefulWidget {
  final String email;
  const Changeworktimerequest({super.key, required this.email});

  @override
  State<Changeworktimerequest> createState() => _ChangeworktimerequestState();
}

class _ChangeworktimerequestState extends State<Changeworktimerequest> {
  Time starthour =
      Time(hour: DateTime.now().hour, minute: DateTime.now().minute);
  Time endhour = Time(hour: DateTime.now().hour, minute: DateTime.now().minute);
  DateTime start = DateTime.now();
  DateTime end = DateTime.now();
  DateTime now = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('داواکاری گۆڕینی کاتی کار'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
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

              start = dateTimeList?[0] ?? now;
              end = dateTimeList?[1] ?? now;
              setState(() {});
            },
            child: Container(
              alignment: Alignment.centerRight,
              width: 90.w,
              height: 8.h,
              margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
              child: Center(
                child: Text('هەڵبژاردنی کاتی گۆڕانکاری',
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold)),
              ),
            ),
          ),
          SizedBox(
            width: 100.w,
            height: 8.h,
            child: Center(
              child: Text(
                'لە:   ${start.year}-${start.month}-${start.day}    -  بۆ:   ${end.year}-${end.month}-${end.day}',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                showPicker(
                  context: context,
                  value: starthour,
                  sunrise: TimeOfDay(hour: 6, minute: 0),
                  sunset: TimeOfDay(hour: 18, minute: 0),
                  duskSpanInMinutes: 120,
                  onChange: (value) {
                    setState(() {
                      starthour = value;
                    });
                  },
                ),
              );
            },
            child: Text(
              "هەڵبژاردنی کاتی دەستپێکردن",
              style: TextStyle(color: Colors.black),
            ),
          ),
          SizedBox(
            width: 100.w,
            height: 8.h,
            child: Center(
              child: Text(
                'کاتی دەستپێکردن: ${starthour.hour}:${starthour.minute}',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                showPicker(
                  context: context,
                  value: endhour,
                  sunrise: TimeOfDay(hour: 6, minute: 0),
                  sunset: TimeOfDay(hour: 18, minute: 0),
                  duskSpanInMinutes: 120,
                  onChange: (value) {
                    setState(() {
                      endhour = value;
                    });
                  },
                ),
              );
            },
            child: Text(
              "هەڵبژاردنی کاتی کۆتایی",
              style: TextStyle(color: Colors.black),
            ),
          ),
          SizedBox(
            width: 100.w,
            height: 8.h,
            child: Center(
              child: Text(
                'کاتی کۆتایی: ${endhour.hour}:${endhour.minute}',
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Container(
            width: 60.w,
            height: 8.h,
            margin: EdgeInsets.fromLTRB(20.w, 1.h, 20.w, 1.h),
            child: Material1.button(
                label: 'ناردنی داواکاری',
                buttoncolor: Material1.primaryColor,
                textcolor: Colors.white,
                function: () {
                  if (end.isBefore(start)) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text('کاتی کۆتایی نابێت پێش کاتی دەستپێکردن بێت')));
                  }
                  FirebaseFirestore.instance
                      .collection('worktime')
                      .doc(DateTime.now().toIso8601String())
                      .set({
                    'email': widget.email,
                    'start': "${start.year}-${start.month}-${start.day}",
                    'end': "${end.year}-${end.month}-${end.day}",
                    'starthour': "${starthour.hour}:${starthour.minute}",
                    'endhour': "${endhour.hour}:${endhour.minute}",
                    'status': 'pending',
                    'time': DateTime.now().toIso8601String(),
                  }).then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('داواکاری گۆڕینی کاتی کار نێردرا')));
                    Navigator.pop(context);
                  });
                }),
          )
        ],
      ),
    );
  }
}
