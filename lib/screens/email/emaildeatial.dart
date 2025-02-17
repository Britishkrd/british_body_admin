import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/email/pdf.dart';
import 'package:british_body_admin/screens/email/sendingemail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Emaildeatial extends StatefulWidget {
  final String to;
  final String cc;
  final String subject;
  final String content;
  final List<String> images;
  final List<String> files;
  final DateTime date;
  final String email;
  final String from;
  final String emailid;
  final DocumentReference id;
  final List<String> toList;
  final List<String> ccList;
  const Emaildeatial(
      {super.key,
      required this.to,
      required this.cc,
      required this.subject,
      required this.content,
      required this.images,
      required this.files,
      required this.date,
      required this.email,
      required this.from,
      required this.id,
      required this.emailid,
      required this.toList,
      required this.ccList});

  @override
  State<Emaildeatial> createState() => _EmaildeatialState();
}

class _EmaildeatialState extends State<Emaildeatial> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('وردەکاری ئیمەیل'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Container(
            alignment: Alignment.topRight,
            width: 100.w,
            margin: EdgeInsets.only(top: 2.h, left: 2.w, right: 2.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('${widget.to} :بۆ',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                )),
          ),
          Container(
            alignment: Alignment.topRight,
            width: 100.w,
            margin: EdgeInsets.only(top: 2.h, left: 2.w, right: 2.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('${widget.cc} :کەسانی ئاگادار',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                )),
          ),
          Container(
            alignment: Alignment.topRight,
            width: 100.w,
            margin: EdgeInsets.only(top: 2.h, left: 2.w, right: 2.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('${widget.subject} :ناونیشانی ئیمەیل',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                )),
          ),
          Container(
            alignment: Alignment.topRight,
            width: 100.w,
            margin: EdgeInsets.only(top: 2.h, left: 2.w, right: 2.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(widget.content),
          ),
          Container(
            alignment: Alignment.topRight,
            width: 100.w,
            margin: EdgeInsets.only(top: 2.h, left: 2.w, right: 2.w),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(widget.date.toIso8601String()),
          ),
          SizedBox(
            height: 5.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                height: 6.h,
                width: 45.w,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  color: Material1.primaryColor,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: Material1.button(
                  fontsize: 16.sp,
                  label: 'وەڵامدانەوە',
                  buttoncolor: Material1.primaryColor,
                  function: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return Sendingemail(
                        from: widget.from,
                        ccList: [],
                        email: widget.email,
                        emailList: widget.to.split(' '),
                        subject: widget.subject,
                        content: widget.content,
                      );
                    }));
                  },
                  textcolor: Colors.white,
                ),
              ),
              Container(
                height: 6.h,
                width: 45.w,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  color: Material1.primaryColor,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: Material1.button(
                  fontsize: 16.sp,
                  label: 'وەڵامدانەوی هەموو',
                  buttoncolor: Material1.primaryColor,
                  function: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return Sendingemail(
                        from: widget.from,
                        ccList: widget.cc.split(' '),
                        email: widget.email,
                        emailList: widget.to.split(' '),
                        subject: widget.subject,
                        content: widget.content,
                      );
                    }));
                  },
                  textcolor: Colors.white,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                margin: EdgeInsets.only(top: 2.h, left: 2.w, right: 2.w),
                height: 6.h,
                width: 45.w,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  color: Material1.primaryColor,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: Material1.button(
                  fontsize: 16.sp,
                  label: 'زیاد کردن بۆ کەتەگۆری',
                  buttoncolor: Material1.primaryColor,
                  function: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: CircularProgressIndicator(),
                          );
                        });
                    FirebaseFirestore.instance
                        .collection('user')
                        .doc(widget.email)
                        .get()
                        .then((value) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('کەتەگۆری هەڵبژێرە'),
                              content: SizedBox(
                                  height: 80.h,
                                  width: 90.w,
                                  child: ListView.builder(
                                      itemCount: value['catagory'].length,
                                      itemBuilder: (context, index) {
                                        return ListTile(
                                          title: Text(value['catagory'][index]),
                                          onTap: () {
                                            widget.id.update({
                                              'catagory':
                                                  FieldValue.arrayUnion([
                                                "${widget.email}-${value['catagory'][index]}"
                                              ])
                                            }).then((value) {
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            });
                                          },
                                        );
                                      })),
                            );
                          });
                    });
                  },
                  textcolor: Colors.white,
                ),
              ),
              Container(
                margin: EdgeInsets.only(top: 2.h, left: 2.w, right: 2.w),
                height: 6.h,
                width: 45.w,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  color: Material1.primaryColor,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: Material1.button(
                  fontsize: 16.sp,
                  label: 'pdf',
                  buttoncolor: Material1.primaryColor,
                  function: () {
                    PDF.createPDF(
                        widget.toList,
                        widget.ccList,
                        widget.subject,
                        widget.content,
                        [],
                        [],
                        widget.date,
                        widget.email,
                        widget.from,
                        int.parse(widget.emailid));
                  },
                  textcolor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
