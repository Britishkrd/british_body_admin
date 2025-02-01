import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

class AddingTask extends StatefulWidget {
  final String email;
  const AddingTask({
    super.key,
    required this.email,
  });

  @override
  State<AddingTask> createState() => _AddingTaskState();
}

bool checkin = true;
double latitude = 0.0;
double longtitude = 0.0;
TextEditingController descriptioncontroller = TextEditingController();
TextEditingController namecontroller = TextEditingController();

DateTime? start;
DateTime? end;
String formatDate(DateTime? date) {
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  return formatter.format(date ?? DateTime.now());
}

class _AddingTaskState extends State<AddingTask> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('زیادکردنی کار'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
      ),
      body: ListView(
        children: [
          GestureDetector(
            onTap: () {
              showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                          title: Text('هەڵبژاردنی کاتی کار'),
                          content: SizedBox(
                            height: 60.h,
                            width: 100.w,
                            child: SfDateRangePicker(
                              view: DateRangePickerView.month,
                              selectionMode: DateRangePickerSelectionMode.range,
                              enablePastDates: false,
                              onSelectionChanged: (args) {
                                if (args.value.startDate != null &&
                                    args.value.endDate == null) {
                                  start = args.value.startDate;
                                  end = args.value.startDate;
                                  setState(() {});
                                } else if (args.value.startDate != null &&
                                    args.value.endDate != null) {
                                  start = args.value.startDate;
                                  end = args.value.endDate;
                                  setState(() {});
                                }
                              },
                              selectionColor: Material1.primaryColor,
                              endRangeSelectionColor: Material1.primaryColor,
                              rangeSelectionColor: Colors.blue[200],
                              startRangeSelectionColor: Material1.primaryColor,
                              todayHighlightColor: Colors.blue[200],
                            ),
                          ),
                          actions: <Widget>[
                            Material1.button(
                              fontsize: 16.sp,
                              label: 'هەڵبژاردن',
                              buttoncolor: Material1.primaryColor,
                              function: () async {
                                Navigator.pop(context);
                              },
                              textcolor: Colors.white,
                            ),
                          ]));
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
            child: Material1.button(
                label: 'داواکردن',
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
                                          '${widget.email}-${DateTime.now().toString()}')
                                      .set({
                                    'description': descriptioncontroller.text,
                                    'time': DateTime.now(),
                                    'start': start,
                                    'end': end,
                                    'status': 'pending',
                                    'name': namecontroller.text,
                                    'isdaily': false
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
