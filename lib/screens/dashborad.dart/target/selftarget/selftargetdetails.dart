import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

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
  final bool adminview;
  final List<String> notes;
  final List<String> links;
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
      required this.reward,
      required this.reference,
      required this.adminview,
      required this.notes,
      required this.links});

  @override
  State<Selftargetdetails> createState() => _SelftargetdetailsState();
}

class _SelftargetdetailsState extends State<Selftargetdetails> {
  List<TextEditingController> linkcontrollerslist = [TextEditingController()];
  List<TextEditingController> notecontrollerslist = [TextEditingController()];
  double listviewheight = 35;
  int heightfunction(int length, int height) {
    return length * height;
  }

  int sizedboxheight(int lengthlinks, int lengthnotes, int height) {
    return (lengthlinks * 2) + (lengthnotes * 2) + height;
  }

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
          widget.adminview
              ? const SizedBox.shrink()
              : SizedBox(
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
                                          fontSize: 16.sp,
                                          color: Colors.black)),
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
                                          fontSize: 16.sp,
                                          color: Colors.black)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  )),
          widget.adminview
              ? const SizedBox.shrink()
              : Container(
                  margin: EdgeInsets.fromLTRB(10.w, 1.h, 10.w, 4.h),
                  height: 8.h,
                  width: 100.w,
                  child: Material1.button(
                      label: 'زیادکردن',
                      buttoncolor: Material1.primaryColor,
                      textcolor: Colors.white,
                      function: () {
                        if (notecontrollerslist[0].text.isEmpty &&
                            linkcontrollerslist[0].text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content:
                                      Text('تکایە تێبینی یان لینکەکە بنووسە')));
                          return;
                        }
                        widget.reference
                            .collection('update')
                            .doc(DateTime.now().toIso8601String())
                            .set({
                          'note':
                              notecontrollerslist.map((e) => e.text).toList(),
                          'link':
                              linkcontrollerslist.map((e) => e.text).toList(),
                          'date': DateTime.now().toIso8601String(),
                          'adminemail': widget.adminemail,
                          'email': widget.email
                        }).then((value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('تێبینی و لینکەکە زیاد کرا')));
                          Navigator.popUntil(context, (route) => route.isFirst);
                        });
                      }),
                ),
          widget.adminview
              ? SizedBox(
                  height: sizedboxheight(
                          widget.notes.length, widget.links.length, 30)
                      .h,
                  width: 100.w,
                  child: Container(
                    margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
                    padding: EdgeInsets.all(1.h),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('لینک'),
                                    content:
                                        Text("دڵنییایت لە کردنەوەی لینکەکە"),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('نەخێر')),
                                      TextButton(
                                          onPressed: () async {
                                            if (!await launchUrl(
                                                Uri.parse("${widget.links}"))) {
                                              throw Exception(
                                                  'Could not launch ');
                                            }
                                          },
                                          child: const Text('بەڵێ')),
                                    ],
                                  );
                                });
                          },
                          child: SizedBox(
                            width: 100.w,
                            height:
                                heightfunction(((widget.links.length)), 4).h,
                            child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: widget.links.length,
                                itemBuilder: (context, index1) {
                                  return Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        (widget.links[index1])
                                                    .toString()
                                                    .length >
                                                39
                                            ? (widget.links[index1])
                                                .toString()
                                                .substring(0, 40)
                                            : (widget.links[index1]).toString(),
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 14.sp,
                                        ),
                                      ),
                                      Text(
                                        ": لینک ${index1 + 1}",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                          ),
                        ),
                        SizedBox(
                          height: heightfunction(((widget.notes.length)), 4).h,
                          child: ListView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: widget.notes.length,
                              itemBuilder: (context, index1) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      widget.notes[index1],
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                    Text(
                                      ": تێبینی ${index1 + 1}",
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                      ),
                                    ),
                                  ],
                                );
                              }),
                        ),
                      ],
                    ),
                  ))
              : const SizedBox.shrink()
        ],
      ),
    );
  }
}
