import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/dashborad.dart/rulesandguidelines/adminaddingrules.dart';
import 'package:british_body_admin/screens/dashborad.dart/rulesandguidelines/viewingrules.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'adminaddingsubdept.dart';

class Choosingdepttoaddsub extends StatefulWidget {
  final bool isaddingrule;
  final String email;
  final bool isemployee;
  const Choosingdepttoaddsub({super.key, required this.isaddingrule, required this.email, required this.isemployee});

  @override
  State<Choosingdepttoaddsub> createState() => _ChoosingdepttoaddsubState();
}

class _ChoosingdepttoaddsubState extends State<Choosingdepttoaddsub> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('هەڵبژاردنی بەش '),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('company')
              .doc('department')
              .collection('department')
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      if (widget.isaddingrule) {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return Adminaddinrules(
                            email: widget.email,
                              department: snapshot.data!.docs[index].reference);
                        }));
                      }else if(widget.isemployee){
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return Viewingrules(department: snapshot.data!.docs[index].reference);
                        }));
                      } else {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return Adminaddingsubdept(
                              department: snapshot.data!.docs[index].reference);
                        }));
                      }
                    },
                    child: Container(
                        decoration: BoxDecoration(
                          color: Material1.primaryColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        width: 100.w,
                        height: (12 +
                                (snapshot.data!.docs[index]['departments']
                                        .length *
                                    2))
                            .h,
                        margin:
                            EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
                        child: Column(children: [
                          Container(
                              alignment: Alignment.center,
                              margin: EdgeInsets.only(top: 1.h, bottom: 1.h),
                              child: Text(
                                snapshot.data!.docs[index]['name'],
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              )),
                          Container(
                            margin: EdgeInsets.only(left: 5.w),
                            child: Text(
                              'بەشەکان',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          SizedBox(
                            height: (4 +
                                    (snapshot.data!.docs[index]['departments']
                                            .length *
                                        2))
                                .h,
                            child: ListView.builder(
                                itemCount: snapshot
                                    .data!.docs[index]['departments'].length,
                                itemBuilder: (context, index1) {
                                  return Container(
                                    margin: EdgeInsets.only(left: 5.w),
                                    child: Text(
                                      "${index1 + 1}. ${snapshot.data!.docs[index]['departments'][index1]}",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  );
                                }),
                          )
                        ])),
                  );
                });
          }),
    );
  }
}
