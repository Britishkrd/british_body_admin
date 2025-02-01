import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/salary/receivingsalary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';

class Salary extends StatefulWidget {
  final String email;
  const Salary({super.key, required this.email});

  @override
  State<Salary> createState() => _SalaryState();
}

int total = 0;

DateTime start = DateTime.now();

class _SalaryState extends State<Salary> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.h,
      width: 100.w,
      child: Column(
        children: [
          SizedBox(
            height: 72.h,
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
                                                  fontWeight: FontWeight.bold)),
                                          Text(": هۆکار",
                                              style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.bold)),
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
                  showMonthRangePicker(
                    context: context,
                    firstDate: DateTime(DateTime.now().year - 1, 1),
                    rangeList: false,
                  ).then((List<DateTime>? dates) {
                    if (dates?.isNotEmpty ?? false) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ReceivingSalary(
                                  email: widget.email, date: dates!.first)));
                    }
                  });
                }),
          )
        ],
      ),
    );
  }
}
