import 'package:british_body_admin/material/materials.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Hoursworked extends StatefulWidget {
  final Duration totalworkedtime;
  final Duration targettime;
  final DateTime date;
  const Hoursworked(
      {super.key,
      required this.totalworkedtime,
      required this.targettime,
      required this.date});

  @override
  State<Hoursworked> createState() => _HoursworkedState();
}

class _HoursworkedState extends State<Hoursworked> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('کاتی کارکردن بۆ مانگی ${widget.date.month}'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: 100.w,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h),
            child: Text(
              'کۆی کاتی کارکردن :  ${widget.totalworkedtime.inHours} کاتژمێر و ${widget.totalworkedtime.inMinutes.remainder(60)} خولەک',
              textAlign: TextAlign.end,
              style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            width: 100.w,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h),
            child: Text(
              'ئامانجی کارکردن :  ${widget.targettime.inHours} کاتژمێر و ${widget.targettime.inMinutes.remainder(60)} خولەک',
              textAlign: TextAlign.end,
              style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
          widget.targettime.inHours - widget.totalworkedtime.inHours > 0
              ? Container(
                  width: 100.w,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h),
                  child: Text(
                    'کاتی ماوەی کارکردنی بۆ مانگی ${widget.date.month} :  ${(widget.targettime.inHours - widget.totalworkedtime.inHours)} کاتژمێر و ${widget.targettime.inMinutes.remainder(60) - widget.totalworkedtime.inMinutes.remainder(60)} خولەک',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                )
              : const SizedBox.shrink(),
          widget.totalworkedtime.inHours - widget.targettime.inHours > 0
              ? Container(
                  width: 100.w,
                  alignment: Alignment.centerRight,
                  margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h),
                  child: Text(
                    'بڕی کاری زیادە بۆ مانگی  ${widget.date.month} :  ${widget.totalworkedtime.inHours - widget.targettime.inHours} کاتژمێر و ${widget.totalworkedtime.inMinutes.remainder(60) - widget.targettime.inMinutes.remainder(60)} خولەک',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                )
              : const SizedBox.shrink(),
          Container(
              width: 100.w,
              height: 6.h,
              margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h),
              child: Material1.button(
                  label: 'داواکردنی ئۆڤەر تایم',
                  buttoncolor: Material1.primaryColor,
                  textcolor: Colors.white,
                  function: () {
                    
                  }))
        ],
      ),
    );
  }
}
