import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'changeworktimerequest.dart';

class Viewchangeworktimerequest extends StatefulWidget {
  final String email;
  const Viewchangeworktimerequest({super.key, required this.email});

  @override
  State<Viewchangeworktimerequest> createState() =>
      _ViewchangeworktimerequestState();
}

class _ViewchangeworktimerequestState extends State<Viewchangeworktimerequest> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('داواکایەکانی گۆڕینی کاتی کار'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 75.h,
            width: 100.w,
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection('worktime')
                  .where('email', isEqualTo: widget.email)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                    itemCount: snapshot.data?.docs.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      return SizedBox(
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
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  "${snapshot.data!.docs[index]['start']} - ${snapshot.data!.docs[index]['end']}",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      "${snapshot.data!.docs[index]['starthour']} : دەستپێکردن",
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      "${snapshot.data!.docs[index]['endhour']}  : کۆتایی ",
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  snapshot.data!.docs[index]['status'] ==
                                          'pending'
                                      ? 'لەچاوەڕوانییە'
                                      : snapshot.data!.docs[index]['status'] ==
                                              'accepted'
                                          ? 'پەسەندکرا'
                                          : 'ڕەتکرایەوە',
                                  style: const TextStyle(
                                    fontSize: 15,
                                  ),
                                ),
                              ],
                            ),
                          ));
                    });
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 10.w, right: 10.w),
            width: 100.w,
            height: 8.h,
            child: Material1.button(
                label: 'ناردنی داواکاری',
                buttoncolor: Material1.primaryColor,
                textcolor: Colors.white,
                function: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Changeworktimerequest(email: widget.email);
                  }));
                }),
          )
        ],
      ),
    );
  }
}
