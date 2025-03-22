import 'package:british_body_admin/material/materials.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:omni_datetime_picker/omni_datetime_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class Selfnotification extends StatefulWidget {
  const Selfnotification({super.key});

  @override
  State<Selfnotification> createState() => _SelfnotificationState();
}

class _SelfnotificationState extends State<Selfnotification> {
  String formatDate(DateTime? date) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
    return formatter.format(date ?? DateTime.now());
  }

  DateTime? start;
  DateTime? end;
  TextEditingController textController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ئاگاداری'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          GestureDetector(
            onTap: () async {
              DateTime? selectedDate = await showOmniDateTimePicker(
                context: context,
                type: OmniDateTimePickerType.dateAndTime,
                initialDate: DateTime.now(),
                firstDate: DateTime(1600).subtract(const Duration(days: 3652)),
                lastDate: DateTime.now().add(
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

              if (selectedDate == null) {
                return;
              }

              start = selectedDate;
              setState(() {});
            },
            child: Container(
                margin: EdgeInsets.only(top: 3.h, left: 5.w, right: 5.w),
                height: 10.h,
                width: 90.w,
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
                            ? 'کلیک بکە بۆ هەڵبژاردنی کاتی کار'
                            : formatDate(start!),
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold)),
                  ],
                )),
          ),
          Container(
            width: 100.w,
            height: 6.h,
            margin: EdgeInsets.only(top: 3.h, left: 5.w, right: 5.w),
            child: Material1.textfield(
                hint: 'نووسینی نۆتیفیکەشن',
                textColor: Colors.black,
                hintcolor: Colors.grey,
                controller: textController,
                obscure: false),
          ),
          Container(
            height: 6.h,
            width: 90.w,
            margin: EdgeInsets.only(top: 3.h, left: 5.w, right: 5.w),
            decoration: BoxDecoration(
                color: Material1.primaryColor,
                borderRadius: BorderRadius.circular(15)),
            child: Material1.button(
                label: 'دانان',
                buttoncolor: Material1.primaryColor,
                textcolor: Colors.white,
                function: () {
                  if (start == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('تکایە کاتی کار هەڵبژێرە')));
                    return;
                  }
                  if (start!.isBefore(DateTime.now())) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content:
                            Text('تکایە کاتە دەبێت لە دوای کاتی ئێستا بێت')));
                    return;
                  }
                  if (textController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('تکایە نووسینی نۆتیفیکەشن بنووسە')));
                    return;
                  }
                  tz.initializeTimeZones();
                  tz.setLocalLocation(tz.getLocation('Asia/Baghdad'));
                  FlutterLocalNotificationsPlugin
                      flutterLocalNotificationsPlugin =
                      FlutterLocalNotificationsPlugin();
                  flutterLocalNotificationsPlugin
                      .zonedSchedule(
                    DateTime.now().millisecondsSinceEpoch.remainder(100000),
                    'ئاگاداری',
                    textController.text,
                    tz.TZDateTime(tz.local, start!.year, start!.month,
                        start!.day, start!.hour, start!.minute),
                    const NotificationDetails(
                        android: AndroidNotificationDetails(
                            'channel_default1', 'your channel name',
                            channelDescription: 'your channel description')),
                    androidScheduleMode:
                        AndroidScheduleMode.exactAllowWhileIdle,
                    uiLocalNotificationDateInterpretation:
                        UILocalNotificationDateInterpretation.absoluteTime,
                  )
                      .then((value) {
                    textController.clear();
                    start = null;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('نۆتیفیکەشنەکە دانرا')));
                  });
                }),
          )
        ],
      ),
    );
  }
}
