import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/dashborad.dart/loan/requestingloan.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class LoanManagement extends StatefulWidget {
  final String email;
  const LoanManagement({super.key, required this.email});

  @override
  State<LoanManagement> createState() => _LoanManagementState();
}

class _LoanManagementState extends State<LoanManagement> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('سولفە'),
        centerTitle: true,
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 80.h,
            width: 100.w,
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('loanmanagement')
                    .where('requestedby', isEqualTo: widget.email)
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
                                  Text(
                                      "${snapshot.data!.docs[index]['amount']} : بڕ",
                                      style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold)),
                                  SizedBox(
                                    height: 3.h,
                                    child: Text(
                                        snapshot.data!.docs[index]['status'] ==
                                                'accepted'
                                            ? 'قبوڵکراوە'
                                            : snapshot.data!.docs[index]
                                                        ['status'] ==
                                                    'pending'
                                                ? 'لە چاوەڕوانی دایە'
                                                : 'ڕەتکراوەتەوە',
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                  SizedBox(
                                    height: 6.h,
                                    child: Text(
                                        "${snapshot.data!.docs[index]['note']} : تێبینی ",
                                        style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold)),
                                  ),
                                ],
                              ),
                            ));
                      });
                }),
          ),
          SafeArea(
            child: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return RequestingLoan(email: widget.email);
                }));
              },
              child: Container(
                height: 6.h,
                width: 60.w,
                margin: EdgeInsets.only(
                    left: 2.w, right: 2.w, top: 3.w, bottom: 0.w),
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  color: Material1.primaryColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withAlpha(50),
                      spreadRadius: 1,
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'داواکردنی سولفە',
                    style: TextStyle(color: Colors.white, fontSize: 16.sp),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
