import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:local_auth/local_auth.dart';
import 'package:sizer/sizer.dart';

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
    // Safely access salary data with fallback values
    final salaryData = widget.salary.data() as Map<String, dynamic>? ?? {};
    final monthlyPayback = salaryData['monthlypayback'] is num
        ? (salaryData['monthlypayback'] as num).toInt()
        : int.tryParse(salaryData['monthlypayback']?.toString() ?? '0') ?? 0;
    final punishmentGiven = salaryData['punishmentgiven'] is num
        ? (salaryData['punishmentgiven'] as num).toInt()
        : int.tryParse(salaryData['punishmentgiven']?.toString() ?? '0') ?? 0;
    final reward = salaryData['reward'] is num
        ? (salaryData['reward'] as num).toInt()
        : int.tryParse(salaryData['reward']?.toString() ?? '0') ?? 0;
    final missedHours = salaryData['missedhoursofwork'] is num
        ? (salaryData['missedhoursofwork'] as num).toInt()
        : int.tryParse(salaryData['missedhoursofwork']?.toString() ?? '0') ?? 0;
    final punishmentForMissingWork = salaryData['punishmentformissingwork']
            is num
        ? (salaryData['punishmentformissingwork'] as num).toInt()
        : int.tryParse(
                salaryData['punishmentformissingwork']?.toString() ?? '0') ??
            0;
    final givenSalary = salaryData['givensalary'] is num
        ? (salaryData['givensalary'] as num).toInt()
        : int.tryParse(salaryData['givensalary']?.toString() ?? '0') ?? 0;
    final date = salaryData['date'] is Timestamp
        ? (salaryData['date'] as Timestamp).toDate()
        : DateTime.now(); // Fallback to current date if invalid

    return Scaffold(
      appBar: AppBar(
        title: const Text('وەرگرتنی موچە'),
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
                        "${NumberFormat("#,###").format(monthlyPayback)} ",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                      Text(": بڕی پارەی دراوەی سولفە",
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "${NumberFormat("#,###").format(punishmentGiven)} ",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                      Text(": بڕی سزای پارەی",
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "${NumberFormat("#,###").format(reward)} ",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                      Text(": بڕی پاداشتی پارەی",
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "${NumberFormat("#,###").format(missedHours)} ",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                      Text(": بڕی کاتژمێری لەدەست چوو",
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "${NumberFormat("#,###").format(punishmentForMissingWork)} ",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                      Text(": بڕی سزای پارەی لەبەر کەمی ئیشکردن",
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        "${NumberFormat("#,###").format(givenSalary)} ",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                      Text(": موچەی دراو",
                          style: TextStyle(
                              fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
                      stickyAuth: true, // Keeps authentication active
                    ),
                  );

                  if (didAuthenticate) {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: const Text('وەرگرتنی موچە'),
                          content: Text(
                            '''دڵنیایت لە وەرگرتنی موچەی مانگی ${date.month} کە ${NumberFormat("#,###").format(givenSalary)} دینارە ؟  ''',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                widget.salary.reference.update({
                                  'isauthenticated': didAuthenticate.toString(),
                                  'receivingdate': DateTime.now(),
                                  'isreceived': true,
                                }).then((value) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content:
                                          Text('موچەکەت بەسەرکەوتویی وەرگرت'),
                                    ),
                                  );
                                  Navigator.popUntil(
                                      context, (route) => route.isFirst);
                                }).catchError((error) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text('Error updating salary: $error'),
                                    ),
                                  );
                                });
                              },
                              child: const Text('بەڵێ'),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: const Text('نەخێر'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('دڵنیاکردنەوەی ناسنامە سەرنەکەوت.'),
                      ),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'هەڵە لە کاتی دڵنیاکردنەوەی ناسنامە: $e. تکایە چاوەڕوان بە ئامرازێکی دیکە.'),
                    ),
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
