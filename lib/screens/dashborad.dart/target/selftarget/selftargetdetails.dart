import 'package:british_body_admin/material/materials.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Selftargetdetails extends StatefulWidget {
  final String title;
  final String description;
  final String date;
  final String email;
  final String adminemail;
  final String target;
  final DateTime start;
  final DateTime end;
  final String reward;
  const Selftargetdetails(
      {super.key,
      required this.title,
      required this.description,
      required this.date,
      required this.email,
      required this.adminemail,
      required this.target,
      required this.start,
      required this.end,
      required this.reward});

  @override
  State<Selftargetdetails> createState() => _SelftargetdetailsState();
}

class _SelftargetdetailsState extends State<Selftargetdetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('زانیاری تارگێت'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: 90.w,
            height: 8.h,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
            child: Text(
              widget.title,
              style: TextStyle(
                  fontSize: 20.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            width: 90.w,
            height: 20.h,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
            child: Text(
              widget.description,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
              ),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            width: 90.w,
            height: 4.h,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
            child: Text(
              "پاداشت: ${widget.reward}",
              style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            width: 90.w,
            height: 4.h,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
            child: Text(
              "ئامانج: ${widget.target}",
              style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            width: 90.w,
            height: 4.h,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
            child: Text(
              "کاتی دەستپێکردن: ${widget.start}",
              style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            width: 90.w,
            height: 4.h,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
            child: Text(
              "کاتی کۆتایی هێنان: ${widget.end}",
              style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
