import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class ViewingTaskDeatsilsupdates extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> task;
  final String email;
  const ViewingTaskDeatsilsupdates({
    super.key,
    required this.task,
    required this.email,
  });

  @override
  State<ViewingTaskDeatsilsupdates> createState() =>
      _ViewingTaskDeatsilsupdatesState();
}

class _ViewingTaskDeatsilsupdatesState
    extends State<ViewingTaskDeatsilsupdates> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('وردەکاری کارەکە'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
      ),
      body: ListView(
        children: [
          SizedBox(
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
                    Text("${widget.task['name']} : ئەرک",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                            "${DateFormat('MMM d, h:mm a').format(widget.task['end'].toDate())} بۆ",
                            style: TextStyle(
                              fontSize: 16.sp,
                            )),
                        Text(
                            "${DateFormat('MMM d, h:mm a').format(widget.task['start'].toDate())}  لە",
                            style: TextStyle(
                              fontSize: 16.sp,
                            )),
                      ],
                    ),
                  ],
                ),
              )),
          Container(
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
                Text(": وردەکاری",
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.bold)),
                Text(widget.task['description'],
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          SizedBox(
            height: 40.h,
            child: StreamBuilder(
              stream: widget.task.reference.collection('updates').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                    itemCount: snapshot.data?.docs.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      return SizedBox(
                          height: 23.h,
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
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  "${snapshot.data!.docs[index]['action']} : کار",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${snapshot.data!.docs[index]['note']} : تێبینی",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${snapshot.data!.docs[index]['time'].toDate()} : کات",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${snapshot.data!.docs[index]['latitude']} : درێژایی",
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                                Text(
                                  "${snapshot.data!.docs[index]['longtitude']} : پانایی",
                                  style: const TextStyle(
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ));
                    });
              },
            ),
          )
        ],
      ),
    );
  }
}
