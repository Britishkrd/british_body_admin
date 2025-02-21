import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/sendingnotification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Sendingalerts extends StatefulWidget {
  final String adminemail;
  final List emails;
  const Sendingalerts(
      {super.key, required this.adminemail, required this.emails});

  @override
  State<Sendingalerts> createState() => _SendingalertsState();
}

class _SendingalertsState extends State<Sendingalerts> {
  TextEditingController titlecontroller = TextEditingController();
  TextEditingController bodycontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ناردنی ئاگاداری'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Container(
            width: 90.w,
            height: 8.h,
            margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
            child: Material1.textfield(
                hint: 'سەر بابەت',
                textColor: Colors.black,
                controller: titlecontroller),
          ),
          Container(
            width: 90.w,
            height: 20.h,
            margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
            child: Material1.textfield(
                hint: 'بابەتەکە',
                textColor: Colors.black,
                controller: bodycontroller,
                maxLines: 10),
          ),
          Container(
            width: 90.w,
            height: 8.h,
            margin: EdgeInsets.fromLTRB(5.w, 5.h, 5.w, 1.h),
            child: Material1.button(
                label: 'ناردن',
                buttoncolor: Material1.primaryColor,
                textcolor: Colors.white,
                function: () {
                  FirebaseFirestore.instance
                      .collection('alert')
                      .doc(DateTime.now().toIso8601String())
                      .set({
                    'title': titlecontroller.text,
                    'body': bodycontroller.text,
                    'time': DateTime.now().toIso8601String(),
                    'by': widget.adminemail,
                    'to': widget.emails,
                  }).then((value) {
                    for (var i = 0; i < widget.emails.length; i++) {
                      FirebaseFirestore.instance
                          .collection('user')
                          .doc(widget.emails[i])
                          .get()
                          .then((value) {
                        sendingnotification(titlecontroller.text,
                            bodycontroller.text, value['token']);
                      });
                    }
                  }).then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ئاگاداری نێردرا')));
                    Navigator.popUntil(context, (route) => route.isFirst);
                  });
                }),
          ),
        ],
      ),
    );
  }
}
