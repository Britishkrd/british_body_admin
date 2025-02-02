import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class AdminTaskDeletion extends StatefulWidget {
  final String email;
  const AdminTaskDeletion({super.key, required this.email});

  @override
  State<AdminTaskDeletion> createState() => _AdminTaskDeletionState();
}

class _AdminTaskDeletionState extends State<AdminTaskDeletion> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('کارەکان'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: StreamBuilder(
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
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('دەتەوێت کارەکە بسڕیتەوە؟'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    FirebaseFirestore.instance
                                        .collection('user')
                                        .doc(widget.email)
                                        .collection('tasks')
                                        .doc(snapshot.data!.docs[index].id)
                                        .delete();
                                    Navigator.pop(context);
                                  },
                                  child: const Text('سڕینەوە',
                                      style: TextStyle(color: Colors.red))),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('پاشگەزبوونەوە')),
                            ],
                          );
                        });
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
                            Text("${snapshot.data!.docs[index]['name']} : ئەرک",
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
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
        },
      ),
    );
  }
}
