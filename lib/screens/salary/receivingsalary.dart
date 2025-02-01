import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class ReceivingSalary extends StatefulWidget {
  final String email;
  final DateTime date;
  const ReceivingSalary({super.key, required this.email, required this.date});

  @override
  State<ReceivingSalary> createState() => _ReceivingSalaryState();
}

int total = 0;

class _ReceivingSalaryState extends State<ReceivingSalary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Material1.primaryColor,
        foregroundColor: Colors.white,
        title: Text(
          'وەرگرتنی موچە',
          style: TextStyle(fontSize: 20.sp),
        ),
        centerTitle: true,
      ),
      body: SizedBox(
        height: 100.h,
        width: 100.w,
        child: Column(
          children: [
            SizedBox(
              height: 80.h,
              child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('user')
                      .doc(widget.email)
                      .collection('salary')
                      .where('date',
                          isGreaterThanOrEqualTo:
                              DateTime(widget.date.year, widget.date.month, 1))
                      .where('date',
                          isLessThanOrEqualTo:
                              DateTime(widget.date.year, widget.date.month, 32))
                      .snapshots(),
                  builder: (BuildContext context,
                      AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return ListView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: snapshot.data?.docs.length ?? 0,
                        itemBuilder: (BuildContext context, int index) {
                          return SizedBox(
                              height: 20.h,
                              width: 90.w,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                            "${snapshot.data!.docs[index]['type'] == 'reward' ? 'پاداشت' : snapshot.data!.docs[index]['type'] == 'punishment' ? 'سزادان' : ''} ",
                                            style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold)),
                                        Text(": جۆر",
                                            style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                            "${snapshot.data!.docs[index]['amount']} ",
                                            style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold)),
                                        Text(": بڕ",
                                            style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: SizedBox(
                                        height: 10.h,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                                "${snapshot.data!.docs[index]['reason']} ",
                                                style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            Text(": هۆکار",
                                                style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ));
                        });
                  }),
            ),
            Container(
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
                        final SharedPreferences preference =
                            await SharedPreferences.getInstance();

                        total = 0;
                        int salary = 0;
                        salary =
                            int.parse(preference.getString('salary') ?? '');

                        FirebaseFirestore.instance
                            .collection('user')
                            .doc(widget.email)
                            .collection('salary')
                            .where('date',
                                isGreaterThanOrEqualTo: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    1))
                            .where('date',
                                isLessThanOrEqualTo: DateTime(
                                    DateTime.now().year,
                                    DateTime.now().month,
                                    32))
                            .get()
                            .then((value) {
                          for (var element in value.docs) {
                            if (element['type'] == 'reward') {
                              total += int.parse(element['amount']);
                            } else {
                              total -= int.parse(element['amount']);
                            }
                          }
                        }).then((value) {
                          total = total + salary;

                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('وەرگرتنی موچە'),
                                  content: Text(
                                      '''دڵنیایت لە وەرگرتنی موچەی ${DateFormat('yyyy-MM').format(widget.date)} کە $total دینارە ؟ '''),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          FirebaseFirestore.instance
                                              .collection('user')
                                              .doc(widget.email)
                                              .collection('receiving salary')
                                              .doc(
                                                  "receiving salary ${widget.date.toString()}")
                                              .set({
                                            'salary-date': widget.date,
                                            'amount': total,
                                            'description': 'وەرگرتنی موچە',
                                            'date': DateTime.now(),
                                            'isauthenticated':
                                                didAuthenticate.toString()
                                          }).then((value) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    content: Text(
                                                        'موچەکەت بەسەرکەوتویی وەرگرت')));
                                            Navigator.popUntil(context,
                                                (route) => route.isFirst);
                                          });
                                        },
                                        child: Text('بەڵێ'))
                                  ],
                                );
                              });
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
      ),
    );
  }
}
