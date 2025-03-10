
import 'package:british_body_admin/screens/tasks/taskdetails.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class Tasks extends StatefulWidget {
  final String email;
  const Tasks({super.key, required this.email});

  @override
  State<Tasks> createState() => _TasksState();
}

int tag = 0;
List<String> options = [
  'هەموو',
  'لە چاوەڕوانی',
  'لە کارکرندایە',
  'ئەرکەکانی خۆم',
  'کارەکانی رۆژانە',
  'کارە تەواو نەکراوەکان',
  'تەواو بووە'
];

Stream<QuerySnapshot<Map<String, dynamic>>> streams(String email) {
  if (tag == 1) {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(email)
        .collection('tasks')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  } else if (tag == 2) {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(email)
        .collection('tasks')
        .where('status', isEqualTo: 'active')
        .snapshots();
  } else if (tag == 3) {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(email)
        .collection('tasks')
        .where('addedby', isEqualTo: email)
        .snapshots();
  } else if (tag == 4) {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(email)
        .collection('tasks')
        .where('isdaily', isEqualTo: true)
        .snapshots();
  } else if (tag == 5) {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(email)
        .collection('tasks')
        .where('end', isLessThan: DateTime.now())
        .snapshots();
  } else if (tag == 6) {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(email)
        .collection('tasks')
        .where('status', isEqualTo: 'done')
        .where('isdaily', isEqualTo: false)
        .snapshots();
  } else {
    return FirebaseFirestore.instance
        .collection('user')
        .doc(email)
        .collection('tasks')
        .snapshots();
  }
}

class _TasksState extends State<Tasks> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 8.h,
          child: ChipsChoice<int>.single(
            value: tag,
            onChanged: (val) => setState(() => tag = val),
            choiceItems: C2Choice.listFrom<int, String>(
              source: options,
              value: (i, v) => i,
              label: (i, v) => v,
            ),
          ),
        ),
        SizedBox(
          height: 70.h,
          width: 100.w,
          child: StreamBuilder(
              stream: streams(widget.email),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                    itemCount: snapshot.data?.docs.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      String deduction = '';
                      String reward = '';
                      try {
                        deduction = snapshot
                            .data!.docs[index]['deductionamount']
                            .toString();
                      } catch (e) {
                        deduction = '0';
                      }
                      try {
                        reward = snapshot.data!.docs[index]['rewardamount']
                            .toString();
                      } catch (e) {
                        reward = '0';
                      }
                      if (snapshot.data!.docs[index]['end']
                              .toDate()
                              .isBefore(DateTime.now()) &&
                          snapshot.data!.docs[index]['status'] != 'done') {
                        if (deduction == '0') {
                          snapshot.data!.docs[index].reference
                              .update({'status': 'incomplete'});
                        } else {
                          FirebaseFirestore.instance
                              .collection('user')
                              .doc(widget.email)
                              .collection('rewardpunishment')
                              .doc(
                                  'punishment-${snapshot.data!.docs[index]['name']}${DateTime.now()}')
                              .set({
                            'addedby': widget.email,
                            'amount': deduction,
                            'date': DateTime.now(),
                            'reason':
                                'for not doing task ${snapshot.data!.docs[index]['name']}',
                            'type': 'punishment'
                          }).then((value) {
                            snapshot.data!.docs[index].reference
                                .update({'status': 'incomplete'});
                          });
                        }
                      }
                      return GestureDetector(
                        onTap: () {
                          if (snapshot.data!.docs[index]['end']
                              .toDate()
                              .isBefore(DateTime.now())) {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text('ئاگاداری'),
                                    content: const Text(
                                        'ئەم کارە کاتەکەی تەواو بووە'),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('بەردەوام بوون'))
                                    ],
                                  );
                                });
                            return;
                          }
                          int stages = 0;
                          try {
                            stages = snapshot
                                .data!.docs[index]['endstagedates'].length;
                          } catch (e) {
                            stages = 0;
                          }
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return Taskdetails(
                                email: widget.email,
                                task: snapshot.data!.docs[index],
                                stages: stages);
                          }));
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
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
                                  Text("بڕی غەرامە : $deduction",
                                      style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold)),
                                  Text("بڕی پاداشت : $reward",
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
              }),
        ),
      ],
    );
  }
}
