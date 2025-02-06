import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/dashborad.dart/givingsalary/receivingsalary/receivingsalary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ChoosingMonthToReceiveSalary extends StatefulWidget {
  final String email;
  const ChoosingMonthToReceiveSalary({super.key, required this.email});

  @override
  State<ChoosingMonthToReceiveSalary> createState() =>
      _ChoosingMonthToReceiveSalaryState();
}

int total = 0;

class _ChoosingMonthToReceiveSalaryState
    extends State<ChoosingMonthToReceiveSalary> {
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
                          return GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) {
                                    if (snapshot.data!.docs[index]
                                        ['isreceived']) {
                                      return AlertDialog(
                                        title: Text(
                                            'موچەی ${snapshot.data!.docs[index]['date'].toDate().month} وەرگیراوە'),
                                        actions: [
                                          Material1.button(
                                              label: 'گەڕانەوە',
                                              buttoncolor:
                                                  Material1.primaryColor,
                                              textcolor: Colors.white,
                                              function: (() {
                                                Navigator.pop(context);
                                              }))
                                        ],
                                      );
                                    }
                                    return AlertDialog(
                                      title: Text(
                                          'دڵنیاییت لە وەرگرتنی موچەی مانگی ${snapshot.data!.docs[index]['date'].toDate().month}'),
                                      actions: [
                                        Material1.button(
                                            label: 'بەڵێ',
                                            buttoncolor: Material1.primaryColor,
                                            textcolor: Colors.white,
                                            function: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          ReceivingSalary(
                                                              salary: snapshot
                                                                  .data!
                                                                  .docs[index],
                                                              email: widget
                                                                  .email)));
                                            }),
                                        Material1.button(
                                            label: 'نەخێر',
                                            buttoncolor: Material1.primaryColor,
                                            textcolor: Colors.white,
                                            function: () {
                                              Navigator.pop(context);
                                            }),
                                      ],
                                    );
                                  });
                            },
                            child: SizedBox(
                                height: 15.h,
                                width: 90.w,
                                child: Container(
                                  margin:
                                      EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
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
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                              "${snapshot.data!.docs[index]['date'].toDate().year}-${snapshot.data!.docs[index]['date'].toDate().month} ",
                                              style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.bold)),
                                          Text(": موچەی",
                                              style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        children: [
                                          Text(
                                              "${snapshot.data!.docs[index]['isreceived'] == false ? 'وەرنەگیراوە' : 'وەرگیراوە'} ",
                                              style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.bold)),
                                          Text(": موچەکە",
                                              style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.bold)),
                                        ],
                                      ),
                                    ],
                                  ),
                                )),
                          );
                        });
                  }),
            ),
          ],
        ),
      ),
    );
  }
}
