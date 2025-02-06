import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class ReceivingSalary extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> salary;
  final String email;
  const ReceivingSalary({super.key, required this.salary, required this.email});

  @override
  State<ReceivingSalary> createState() => _ReceivingSalaryState();
}

class _ReceivingSalaryState extends State<ReceivingSalary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('وەرگرتنی موچە'),
        foregroundColor: Material1.primaryColor,
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
              height: 40.h,
              width: 100.w,
              child: Container(
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
                            "${NumberFormat("#,###").format(int.parse(widget.salary['monthlypayback']))} ",
                            style: TextStyle(
                                fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        Text(": بڕی پارەی دراوەی سولفە",
                            style: TextStyle(
                                fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                            "${NumberFormat("#,###").format(widget.salary['punishmentgiven'])} ",
                            style: TextStyle(
                                fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        Text(": بڕی سزای پارەی",
                            style: TextStyle(
                                fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                            "${NumberFormat("#,###").format(widget.salary['reward'])} ",
                            style: TextStyle(
                                fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        Text(": بڕی پاداشتی پارەی",
                            style: TextStyle(
                                fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                            "${NumberFormat("#,###").format(widget.salary['missedhoursofwork'])} ",
                            style: TextStyle(
                                fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        Text(": بڕی کاتژمێری لەدەست چوو",
                            style: TextStyle(
                                fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                            "${NumberFormat("#,###").format(widget.salary['punishmentformissingwork'])} ",
                            style: TextStyle(
                                fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        Text(": بڕی سزای پارەی لەبەر کەمی ئیشکردن",
                            style: TextStyle(
                                fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                            "${NumberFormat("#,###").format(widget.salary['givensalary'])} ",
                            style: TextStyle(
                                fontSize: 16.sp, fontWeight: FontWeight.bold)),
                        Text(": موچەی دراو",
                            style: TextStyle(
                                fontSize: 16.sp, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              )),
          Container(
            margin: EdgeInsets.only(top: 5.h),
            height: 6.h,
            width: 90.w,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5,
                )
              ],
            ),
            child: Material1.button(
                label: 'وەرگرتنی موچەی مانگ',
                buttoncolor: Material1.primaryColor,
                textcolor: Colors.white,
                function: () async {
                  try {
                    final LocalAuthentication auth = LocalAuthentication();
                    final bool didAuthenticate = await auth.authenticate(
                        localizedReason:
                            'تکایە ناسنامەت دڵنیا بەکەرەوە بۆ وەرگرتنی مووچەکەت',
                        options: const AuthenticationOptions(
                          biometricOnly: true,
                        ));

                    if (didAuthenticate) {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('وەرگرتنی موچە'),
                              content: Text(
                                  '''دڵنیایت لە وەرگرتنی موچەی مانگی ${widget.salary['date'].toDate().month} کە ${NumberFormat("#,###").format(widget.salary['givensalary'])}دینارە ؟  '''),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      widget.salary.reference.update({
                                        'isauthenticated':
                                            didAuthenticate.toString(),
                                        'receivingdate': DateTime.now(),
                                        'isreceived': true
                                      }).then((value) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                content: Text(
                                                    'موچەکەت بەسەرکەوتویی وەرگرت')));
                                        Navigator.popUntil(
                                            context, (route) => route.isFirst);
                                      });
                                    },
                                    child: Text('بەڵێ'))
                              ],
                            );
                          });
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(
                            'هیچ ڕێگەیەک نییە بۆ دڵنیاکردنەوەی ناسنامەت')));
                  }
                }),
          )
        ],
      ),
    );
  }
}
