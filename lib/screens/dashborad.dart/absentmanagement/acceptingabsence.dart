import 'package:british_body_admin/sendingnotification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

import '../../../material/materials.dart';

class Acceptingabsence extends StatefulWidget {
  const Acceptingabsence({super.key});

  @override
  State<Acceptingabsence> createState() => _AcceptingabsenceState();
}

String formatDate(DateTime? date) {
  final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
  return formatter.format(date ?? DateTime.now());
}

class _AcceptingabsenceState extends State<Acceptingabsence> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('پەسەندکردنی مۆڵەت'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('user').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
              itemCount: snapshot.data?.docs.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                String email = snapshot.data!.docs[index].data()['email'];
                return StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('user')
                      .doc(snapshot.data!.docs[index].data()['email'])
                      .collection('absentmanagement')
                      .where('status', isEqualTo: 'pending')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return SizedBox(
                      height: ((snapshot.data?.docs.length ?? 0) * 28).h,
                      child: ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: snapshot.data?.docs.length ?? 0,
                          itemBuilder: (BuildContext context, int index) {
                            return SizedBox(
                                height: 28.h,
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
                                        crossAxisAlignment:
                                            CrossAxisAlignment.end,
                                        children: [
                                          Text(email,
                                              style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.bold)),
                                         
                                          SizedBox(
                                            height: 3.h,
                                            child: Text(
                                                snapshot.data!.docs[index]
                                                            ['status'] ==
                                                        'accepted'
                                                    ? 'قبوڵکراوە'
                                                    : snapshot.data!.docs[index]
                                                                ['status'] ==
                                                            'pending'
                                                        ? 'لە چاوەڕوانی دایە'
                                                        : 'ڕەتکراوەتەوە',
                                                style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          SizedBox(
                                            height: 6.h,
                                            child: Text(
                                                "${snapshot.data!.docs[index]['note']} : تێبینی ",
                                                style: TextStyle(
                                                    fontSize: 16.sp,
                                                    fontWeight:
                                                        FontWeight.bold)),
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: [
                                              TextButton(
                                                  onPressed: () {
                                                    FirebaseFirestore.instance
                                                        .collection('user')
                                                        .doc(email)
                                                        .collection(
                                                            'absentmanagement')
                                                        .doc(snapshot.data!
                                                            .docs[index].id)
                                                        .update({
                                                      'status': 'accepted'
                                                    }).then((value) {
                                                      FirebaseFirestore.instance
                                                          .collection('user')
                                                          .doc(email)
                                                          .get()
                                                          .then((value) {
                                                        sendingnotification(
                                                            'مۆڵەت',
                                                            'مۆڵەتەکەت قبوڵکرا',
                                                            value.data()?[
                                                                'token']);
                                                      });
                                                    });
                                                  },
                                                  child: Text('قبوڵکردن',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          fontSize: 16.sp))),
                                              TextButton(
                                                  onPressed: () {
                                                    FirebaseFirestore.instance
                                                        .collection('user')
                                                        .doc(email)
                                                        .collection(
                                                            'absentmanagement')
                                                        .doc(snapshot.data!
                                                            .docs[index].id)
                                                        .update({
                                                      'status': 'rejected'
                                                    }).then((value) {
                                                      FirebaseFirestore.instance
                                                          .collection('user')
                                                          .doc(email)
                                                          .get()
                                                          .then((value) {
                                                        sendingnotification(
                                                            'مۆڵەت',
                                                            'مۆڵەتەکەت ڕەتکرایەوە',
                                                            value.data()?[
                                                                'token']);
                                                      });
                                                    });
                                                  },
                                                  child: Text('ڕەتکردنەوە',
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.red,
                                                          fontSize: 16.sp))),
                                            ],
                                          ),
                                        ])));
                          }),
                    );
                  },
                );
              });
        },
      ),
    );
  }
}
