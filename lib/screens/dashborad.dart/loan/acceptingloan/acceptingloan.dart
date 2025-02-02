import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class AcceptingLoan extends StatefulWidget {
  final String email;
  const AcceptingLoan({super.key, required this.email});

  @override
  State<AcceptingLoan> createState() => _AcceptingLoanState();
}

class _AcceptingLoanState extends State<AcceptingLoan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قبوڵکردنی سولفە'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
      ),
      body: SizedBox(
        height: 100.h,
        width: 100.w,
        child: StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection('loanmanagement')
                .snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              return ListView.builder(
                  itemCount: snapshot.data?.docs.length ?? 0,
                  itemBuilder: (BuildContext context, int index) {
                    return GestureDetector(
                      onTap: () {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title:
                                    const Text('دەتەوێت سولفەکە قبوڵ بکەیت؟'),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection('user')
                                            .doc(widget.email)
                                            .update({
                                          'loan': snapshot.data!.docs[index]
                                              ['amount'],
                                          'loanstatus': 'given',
                                          'monthlypayback': (int.parse(snapshot
                                                  .data!
                                                  .docs[index]['amount']) *
                                              0.1)
                                        }).then((value) {
                                          FirebaseFirestore.instance
                                              .collection('loanmanagement')
                                              .doc(
                                                  snapshot.data!.docs[index].id)
                                              .update({'status': 'accepted'});
                                        });
                                        Navigator.pop(context);
                                      },
                                      child: Text('قبوڵکردن',
                                          style: TextStyle(
                                              color: Material1.primaryColor))),
                                  TextButton(
                                      onPressed: () {
                                        FirebaseFirestore.instance
                                            .collection('loanmanagement')
                                            .doc(snapshot.data!.docs[index].id)
                                            .update({'status': 'rejected'});
                                        Navigator.pop(context);
                                      },
                                      child: const Text('رەتکردنەوە',
                                          style: TextStyle(color: Colors.red))),
                                ],
                              );
                            });
                      },
                      child: SizedBox(
                          height: 25.h,
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                    "${snapshot.data!.docs[index]['requestedby']} : ئیمەڵی کەسی داواکار",
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    "${snapshot.data!.docs[index]['amount']} : بڕی داواکراو",
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    "${snapshot.data!.docs[index]['note']} : تێبینی",
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold)),
                                Text(
                                    "بارودۆخ :${snapshot.data!.docs[index]['status'] == 'accepted' ? 'قبوڵکراوە' : snapshot.data!.docs[index]['status'] == 'pending' ? 'لە چاوەڕوانی دایە' : 'ڕەتکراوەتەوە'}",
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold)),
                              ],
                            ),
                          )),
                    );
                  });
            }),
      ),
    );
  }
}
