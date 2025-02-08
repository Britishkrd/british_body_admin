import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Viewingselfloginlogout extends StatefulWidget {
  final String email;
  final DateTime date;
  const Viewingselfloginlogout(
      {super.key, required this.email, required this.date});

  @override
  State<Viewingselfloginlogout> createState() => _ViewingselfloginlogoutState();
}

class _ViewingselfloginlogoutState extends State<Viewingselfloginlogout> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بینینی چوونەژوورەوە / دەرچوونەوە'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('user')
                  .doc(widget.email)
                  .collection('checkincheckouts')
                  .where('time',
                      isGreaterThanOrEqualTo:
                          DateTime(widget.date.year, widget.date.month, 1))
                  .where('time',
                      isLessThanOrEqualTo: DateTime(
                          widget.date.year,
                          widget.date.month,
                          (DateTime(widget.date.year, widget.date.month + 1, 0)
                              .day)))
                  .get(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return SizedBox(
                  height: ((snapshot.data?.docs.length ?? 0) * 20).h,
                  width: 100.w,
                  child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data?.docs.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            // showDialog(
                            //     context: context,
                            //     builder: (context) {
                            //       return AlertDialog(
                            //         title: const Text(
                            //             'دەتەوێت چی لە ئەرکی ئەم کارمەندە بکەیت'),
                            //         actions: [
                            //           TextButton(
                            //               onPressed: () {
                            //                 Navigator.push(context,
                            //                     MaterialPageRoute(builder: (context) {
                            //                   return AdminAddingTask(
                            //                       adminemail: widget.email,
                            //                       email: snapshot.data!.docs[index]
                            //                           ['email']);
                            //                 }));
                            //               },
                            //               child: const Text('زیادکردنی کار')),
                            //           TextButton(
                            //               onPressed: () {
                            //                 Navigator.push(context,
                            //                     MaterialPageRoute(builder: (context) {
                            //                   return AdminTaskDeletion(
                            //                       email: snapshot.data!.docs[index]
                            //                           ['email']);
                            //                 }));
                            //               },
                            //               child: const Text('سڕینەوەی کار',
                            //                   style: TextStyle(color: Colors.red))),
                            //         ],
                            //       );
                            //     });
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
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      "جۆر : ${snapshot.data!.docs[index]['checkin'] == true ? 'چوونەژوورەوە' : 'چوونەدەرەوە'}",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "${snapshot.data!.docs[index]['time'].toDate()} : کات ",
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      "${snapshot.data!.docs[index]['note']} : تێبینی",
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        );
                      }),
                );
              }),
        ],
      ),
    );
  }
}
