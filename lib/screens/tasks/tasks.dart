import 'package:british_body_admin/screens/tasks/taskdetails.dart';
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

class _TasksState extends State<Tasks> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80.h,
      width: 100.w,
      child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('user')
              .doc(widget.email)
              .collection('tasks')
              .where('status', isNotEqualTo: 'done')
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
                physics: NeverScrollableScrollPhysics(),
                itemCount: snapshot.data?.docs.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Taskdetails(task: snapshot.data!.docs[index]);
                      }));
                    },
                    child: SizedBox(
                        height: 10.h,
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
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold)),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: [
                                  Text(
                                      "${DateFormat('MMM d, h:mm a').format(snapshot.data!.docs[index]['end'].toDate())} بۆ",
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                      )),
                                  Text(
                                      "${DateFormat('MMM d, h:mm a').format(snapshot.data!.docs[index]['start'].toDate())}  لە",
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
    );
  }
}
