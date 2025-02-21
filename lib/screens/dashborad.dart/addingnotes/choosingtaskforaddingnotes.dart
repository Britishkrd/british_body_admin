import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

import 'addingnotes.dart';

class Choosingtaskforaddingnotes extends StatefulWidget {
  final String email;
  const Choosingtaskforaddingnotes({super.key, required this.email});

  @override
  State<Choosingtaskforaddingnotes> createState() =>
      _ChoosingtaskforaddingnotesState();
}

class _ChoosingtaskforaddingnotesState
    extends State<Choosingtaskforaddingnotes> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('کارەکان'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: SizedBox(
        height: 80.h,
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('user')
              .doc(widget.email)
              .collection('tasks')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
                itemCount: snapshot.data?.docs.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Addingnotes(
                                email:widget.email,
                                reference: snapshot.data!.docs[index].reference,

                              )));
                    },
                    child: SizedBox(
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                  "${snapshot.data!.docs[index]['name']} : ئەرک",
                                  style: TextStyle(
                                      decoration: snapshot
                                              .data!.docs[index]['end']
                                              .toDate()
                                              .isBefore(DateTime.now())
                                          ? TextDecoration.lineThrough
                                          : null,
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  "بڕی غەرامە : ${snapshot.data!.docs[index]['deductionamount']}",
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold)),
                              Text(
                                  "بڕی پاداشت : ${snapshot.data!.docs[index]['rewardamount']}",
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold)),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                      "${DateFormat('MMM d, h:mm a').format(snapshot.data!.docs[index]['end'].toDate())}   بۆ",
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                      )),
                                  Text(
                                      "${DateFormat('MMM d, h:mm a').format(snapshot.data!.docs[index]['start'].toDate())}   لە",
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                      )),
                                ],
                              ),
                            ],
                          ),
                        )),
                  );
                });
          },
        ),
      ),
    );
  }
}
