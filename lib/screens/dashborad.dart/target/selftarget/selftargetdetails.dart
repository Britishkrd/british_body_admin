import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  final DocumentReference reference;
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
      required this.reward, required this.reference});

  @override
  State<Selftargetdetails> createState() => _SelftargetdetailsState();
}

class _SelftargetdetailsState extends State<Selftargetdetails> {
  List<TextEditingController> linkcontrollerslist = [TextEditingController()];
  List<TextEditingController> notecontrollerslist = [TextEditingController()];
  double listviewheight = 35;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('زانیاری تارگێت'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: ListView(
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
          SizedBox(
              height: listviewheight.h,
              child: Column(
                children: [
                  SizedBox(
                    height: ((notecontrollerslist.length * 8) + 5).h,
                    child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: notecontrollerslist.length,
                        itemBuilder: (context, index1) {
                          return Container(
                            margin: EdgeInsets.only(
                                top: 0.h, left: 5.w, right: 5.w),
                            width: 90.w,
                            height: 8.h,
                            child: Material1.textfield(
                                hint: 'تێبینی ${index1 + 1}',
                                controller: notecontrollerslist[index1],
                                textColor: Material1.primaryColor),
                          );
                        }),
                  ),
                  SizedBox(
                    height: ((linkcontrollerslist.length * 8) + 5).h,
                    child: ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: linkcontrollerslist.length,
                        itemBuilder: (context, index1) {
                          return Container(
                            margin: EdgeInsets.only(
                                top: 0.h, left: 5.w, right: 5.w),
                            width: 90.w,
                            height: 6.h,
                            child: Material1.textfield(
                                hint: 'لینکی ${index1 + 1}',
                                controller: linkcontrollerslist[index1],
                                textColor: Material1.primaryColor),
                          );
                        }),
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          linkcontrollerslist.add(TextEditingController());
                          int note = notecontrollerslist.length;

                          int link = linkcontrollerslist.length;
                          setState(() {
                            listviewheight =
                                (20 + (8 * link) + (8 * note)).toDouble();
                          });
                        },
                        child: Container(
                          width: 40.w,
                          height: 6.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[200],
                          ),
                          margin: EdgeInsets.only(left: 5.w, right: 5.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: Colors.black),
                              Text('زیادکردنی لینک',
                                  style: TextStyle(
                                      fontSize: 16.sp, color: Colors.black)),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          notecontrollerslist.add(TextEditingController());
                          int note = notecontrollerslist.length;

                          int link = linkcontrollerslist.length;
                          setState(() {
                            listviewheight =
                                (20 + (8 * link) + (8 * note)).toDouble();
                          });
                        },
                        child: Container(
                          width: 40.w,
                          height: 6.h,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[200],
                          ),
                          margin: EdgeInsets.only(left: 5.w, right: 5.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add, color: Colors.black),
                              Text('زیادکردنی تێبینی',
                                  style: TextStyle(
                                      fontSize: 16.sp, color: Colors.black)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              )),
          Container(
            margin: EdgeInsets.fromLTRB(10.w, 1.h, 10.w, 4.h),
            height: 8.h,
            width: 100.w,
            child: Material1.button(
                label: 'زیادکردن',
                buttoncolor: Material1.primaryColor,
                textcolor: Colors.white,
                function: () {}),
          )
        ],
      ),
    );
  }
}
