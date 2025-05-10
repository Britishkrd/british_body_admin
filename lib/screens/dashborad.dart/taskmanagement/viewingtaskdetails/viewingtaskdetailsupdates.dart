import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

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
  int heightfunction(int length, int height) {
    return length * height;
  }

  int sizedboxheight(int lengthlinks, int lengthnotes, int height) {
    return (lengthlinks * 6) + (lengthnotes * 6) + height;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('وردەکاری کارەکە'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
      ),
      body: SizedBox(
        height: 100.h,
        child: StreamBuilder(
          stream: widget.task.reference
              .collection('updates')
              .orderBy('time', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No updates available'));
            }
            return ListView.builder(
                itemCount: snapshot.data?.docs.length ?? 0,
                itemBuilder: (BuildContext context, int index) {
                  return Column(
                    children: [
                      index == 0
                          ? Column(
                              children: [
                                SizedBox(
                                    height: 10.h,
                                    width: 100.w,
                                    child: Container(
                                      margin: EdgeInsets.fromLTRB(
                                          5.w, 1.h, 5.w, 1.h),
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
                                          Text("${widget.task['name']} : ئەرک",
                                              style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.bold)),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
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
                                  width: 100.w,
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
                                      Text(": وردەکاری",
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold)),
                                      Text(widget.task['description'],
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                                Container(
                                  alignment: Alignment.centerRight,
                                  height: 4.h,
                                  width: 100.w,
                                  margin:
                                      EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
                                  child: Text(
                                      'دەستپێکرند و کۆتایی پێهێنانەکان ',
                                      style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ],
                            )
                          : const SizedBox(),
                      SizedBox(
                          height: sizedboxheight(
                                  snapshot.data?.docs[index]['note'].length ??
                                      0,
                                  snapshot.data?.docs[index]['link'].length ??
                                      0,
                                  30)
                              .h,
                          width: 100.w,
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
                                  "${snapshot.data!.docs[index]['stage']} : بەشی",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${snapshot.data!.docs[index]['action']} : کار",
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
                                GestureDetector(
                                  onTap: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text('شوێن'),
                                            content:
                                                Text("دڵنییایت لە بینینی شوێن"),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('نەخێر')),
                                              TextButton(
                                                  onPressed: () async {
                                                    if (!await launchUrl(Uri.parse(
                                                        'https://www.google.com/maps/search/?api=1&query=${snapshot.data!.docs[index]['latitude']},${snapshot.data!.docs[index]['longtitude']}'))) {
                                                      throw Exception(
                                                          'Could not launch ');
                                                    }
                                                  },
                                                  child: const Text('بەڵێ')),
                                            ],
                                          );
                                        });
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "${snapshot.data!.docs[index]['latitude']}-${snapshot.data!.docs[index]['longtitude']}",
                                        style: const TextStyle(
                                            fontSize: 14, color: Colors.blue),
                                      ),
                                      Text(
                                        " : شوێن",
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text('لینک'),
                                            content: Text(
                                                "دڵنییایت لە کردنەوەی لینکەکە"),
                                            actions: [
                                              TextButton(
                                                  onPressed: () {
                                                    Navigator.pop(context);
                                                  },
                                                  child: const Text('نەخێر')),
                                              TextButton(
                                                  onPressed: () async {
                                                    if (!await launchUrl(Uri.parse(
                                                        "${snapshot.data?.docs[index]['link'][index]}"))) {
                                                      throw Exception(
                                                          'Could not launch ');
                                                    }
                                                  },
                                                  child: const Text('بەڵێ')),
                                            ],
                                          );
                                        });
                                  },
                                  child: SizedBox(
                                    width: 100.w,
                                    height: (heightfunction(
                                                ((snapshot
                                                    .data
                                                    ?.docs[index]['link']
                                                    .length)),
                                                6) +
                                            heightfunction(
                                                ((snapshot
                                                    .data
                                                    ?.docs[index]['note']
                                                    .length)),
                                                6))
                                        .h,
                                    child: ListView.builder(
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount: ((snapshot
                                                        .data
                                                        ?.docs[index]['link']
                                                        .length ??
                                                    0) >
                                                (snapshot
                                                        .data
                                                        ?.docs[index]['note']
                                                        .length ??
                                                    0)
                                            ? (snapshot
                                                    .data
                                                    ?.docs[index]['link']
                                                    .length ??
                                                0)
                                            : (snapshot
                                                    .data
                                                    ?.docs[index]['note']
                                                    .length ??
                                                0)),
                                        itemBuilder: (context, index1) {
                                          return Column(
                                            children: [
                                              if (index1 <
                                                  (snapshot
                                                          .data
                                                          ?.docs[index]['link']
                                                          .length ??
                                                      0))
                                                SizedBox(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Text(
                                                        (snapshot.data?.docs[index]['link'][index1] ??
                                                                        '')
                                                                    .toString()
                                                                    .length >
                                                                39
                                                            ? (snapshot.data?.docs[index]
                                                                            ['link']
                                                                        [
                                                                        index1] ??
                                                                    '')
                                                                .toString()
                                                                .substring(
                                                                    0, 40)
                                                            : (snapshot.data?.docs[index]
                                                                            ['link']
                                                                        [index1] ??
                                                                    '')
                                                                .toString(),
                                                        style: TextStyle(
                                                          color: Colors.blue,
                                                          fontSize: 16.sp,
                                                        ),
                                                      ),
                                                      Text(
                                                        ": لینک ${index1 + 1}",
                                                        style: TextStyle(
                                                          fontSize: 16.sp,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              if (index1 <
                                                  (snapshot
                                                          .data
                                                          ?.docs[index]['note']
                                                          .length ??
                                                      0))
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
                                                  children: [
                                                    Text(
                                                      "${(snapshot.data?.docs[index]['note'][index1] ?? '')}",
                                                      style: TextStyle(
                                                        fontSize: 16.sp,
                                                      ),
                                                    ),
                                                    Text(
                                                      ": تێبینی ${index1 + 1}",
                                                      style: TextStyle(
                                                        fontSize: 16.sp,
                                                      ),
                                                    ),
                                                  ],
                                                )
                                            ],
                                          );
                                        }),
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  );
                });
          },
        ),
      ),
    );
  }
}
