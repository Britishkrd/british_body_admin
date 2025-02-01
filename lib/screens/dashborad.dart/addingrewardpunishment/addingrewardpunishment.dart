import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:intl/intl.dart';

class AddingRewardPunishment extends StatefulWidget {
  final String adminemail;
  final String email;
  const AddingRewardPunishment({
    super.key,
    required this.email,
    required this.adminemail,
  });

  @override
  State<AddingRewardPunishment> createState() => _AddingRewardPunishmentState();
}

bool checkin = true;
double latitude = 0.0;
double longtitude = 0.0;
TextEditingController amountcontroller = TextEditingController();
TextEditingController reasoncontroller = TextEditingController();

DateTime? start;
DateTime? end;
String formatDate(DateTime? date) {
  final DateFormat formatter = DateFormat('dd/MM/yyyy');
  return formatter.format(date ?? DateTime.now());
}

Color getColor(Set<WidgetState> states) {
  const Set<WidgetState> interactiveStates = <WidgetState>{
    WidgetState.pressed,
    WidgetState.hovered,
    WidgetState.focused,
  };
  if (states.any(interactiveStates.contains)) {
    return Colors.blue;
  }
  return Colors.red;
}

bool isreward = false;
bool ispunishment = false;

class _AddingRewardPunishmentState extends State<AddingRewardPunishment> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('زیادکردنی پاداشت و سزا'),
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
                          title: Text('هەڵبژاردنی کاتی پاداشت / سزا'),
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
                    Text('هەڵبژاردنی کاتی پاداشت / سزا',
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'پاداشت',
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    Checkbox(
                      checkColor: Colors.white,
                      fillColor: WidgetStateProperty.resolveWith(
                        (states) => Material1.primaryColor,
                      ),
                      value: isreward,
                      onChanged: (bool? value) {
                        setState(() {
                          isreward = value!;
                          ispunishment = false;
                        });
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      'سزا',
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold),
                    ),
                    Checkbox(
                      checkColor: Colors.white,
                      fillColor: WidgetStateProperty.resolveWith(
                        (states) => Material1.primaryColor,
                      ),
                      value: ispunishment,
                      onChanged: (bool? value) {
                        setState(() {
                          ispunishment = value!;
                          isreward = false;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
            width: 90.w,
            height: 8.h,
            child: Material1.textfield(
                hint: 'هۆکار',
                controller: reasoncontroller,
                textColor: Material1.primaryColor),
          ),
          Container(
            margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
            width: 90.w,
            height: 8.h,
            child: Material1.textfield(
                hint: 'بڕ',
                controller: amountcontroller,
                inputType: TextInputType.number,
                textColor: Material1.primaryColor),
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
                        content: Text('تکایە کاتی پاداشت / سزا هەڵبژێرە'),
                      ),
                    );
                    return;
                  }
                  if (reasoncontroller.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تکایە هۆکاری پاداشت / سزای بنووسە'),
                      ),
                    );
                    return;
                  }
                  if (amountcontroller.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تکایە بڕی پاداشت / سزا بنووسە'),
                      ),
                    );
                    return;
                  }
                  if (!isreward && !ispunishment) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('تکایە جۆری پاداشت / سزا هەڵبژێرە'),
                      ),
                    );
                    return;
                  }
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('زیادکردنی پاداشت / سزا'),
                          content:
                              Text('دڵنییایت لە زیادکردنی پاداشت / سزاەکە؟'),
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
                                      .collection('salary')
                                      .doc(
                                          '${isreward ? 'reward' : 'punishment'}-${widget.adminemail}-${DateTime.now().toString()}')
                                      .set({
                                    'reason': reasoncontroller.text,
                                    'date': DateTime.now(),
                                    'amount': amountcontroller.text,
                                    'type': isreward ? 'reward' : 'punishment',
                                    'addedby': widget.adminemail,
                                  }).then(
                                    (value) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                          content: Text(
                                              'پاداشت / سزاەکە بەسەرکەوتویی زیادکرا'),
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
