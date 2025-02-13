
import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/dashborad.dart/feedback/adminfeedback.dart/admincreatedfeedback.dart';
import 'package:british_body_admin/screens/dashborad.dart/feedback/adminfeedback.dart/viewingemployeefeedbacks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'admineditfeedback.dart';

class Adminfeedback extends StatefulWidget {
  final String email;
  const Adminfeedback({super.key, required this.email});

  @override
  State<Adminfeedback> createState() => _AdminfeedbackState();
}

class _AdminfeedbackState extends State<Adminfeedback> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ڕەخنە و پێشنیار'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 75.h,
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('generalfeedback')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return SizedBox(
                    height: ((snapshot.data?.docs.length ?? 0) * 20).h,
                    width: 100.w,
                    child: ListView.builder(
                        itemCount: snapshot.data?.docs.length ?? 0,
                        itemBuilder: (context, index) {
                          return Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                    bottom: 5.w,
                                    top: 2.h,
                                    right: 5.w,
                                    left: 5.w),
                                height: 40.h,
                                width: 100.w,
                                child: Card(
                                  child: Column(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(
                                            right: 5.w, left: 5.w),
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          snapshot.data?.docs[index]['email'],
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 35.h,
                                        child: ListView.builder(
                                            itemBuilder: (context, i) {
                                              return ExpansionTile(
                                                title: Text(
                                                    snapshot.data?.docs[index]
                                                        ['questions'][i]),
                                                children: [
                                                  SizedBox(
                                                    height: 10.h,
                                                    child: ListView.builder(
                                                        itemCount: snapshot
                                                            .data
                                                            ?.docs[index]
                                                                ['options$i']
                                                            .length,
                                                        itemBuilder:
                                                            (context, j) {
                                                          return ListTile(
                                                            title: Text(snapshot
                                                                    .data
                                                                    ?.docs[index]
                                                                [
                                                                'options$i'][j]),
                                                          );
                                                        }),
                                                  )
                                                ],
                                              );
                                            },
                                            itemCount: snapshot
                                                .data
                                                ?.docs[index]['questions']
                                                .length),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 5.w,
                                top: 2.h,
                                child: IconButton(
                                  onPressed: () {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: Text(
                                                'دڵنیایت لە سڕینەوەی ئەم ڕاپرسییە؟'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Text('نەخێر'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                  FirebaseFirestore.instance
                                                      .collection(
                                                          'generalfeedback')
                                                      .doc(snapshot
                                                          .data?.docs[index].id)
                                                      .delete();
                                                },
                                                child: Text('بەڵێ'),
                                              ),
                                            ],
                                          );
                                        });
                                  },
                                  icon: Icon(Icons.delete),
                                  color: Colors.red,
                                ),
                              ),
                              Positioned(
                                right: 15.w,
                                top: 2.h,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.edit,
                                    color: Colors.green,
                                  ),
                                  onPressed: () {
                                    List<List<String>> optionControllers = [];
                                    for (var i = 0;
                                        i <
                                            snapshot
                                                .data
                                                ?.docs[index]['questions']
                                                .length;
                                        i++) {
                                      optionControllers.add(List<String>.from(
                                          snapshot.data?.docs[index]
                                                  ['options$i'] ??
                                              []));
                                    }
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                Admineditfeedback(
                                                  email: widget.email,
                                                  questionscontrollers:
                                                      List<String>.from(snapshot
                                                                  .data
                                                                  ?.docs[index]
                                                              ['questions'] ??
                                                          []),
                                                  optionControllers:
                                                      optionControllers,
                                                  id: snapshot.data?.docs[index]
                                                          .id ??
                                                      '',
                                                )));
                                  },
                                ),
                              ),
                              Positioned(
                                right: 25.w,
                                top: 2.h,
                                child: IconButton(
                                  icon: Icon(
                                    Icons.remove_red_eye,
                                    color: Colors.blue,
                                  ),
                                  onPressed: () {
                                    List questions = [];
                                    List options = [];
                                    Map<String, int> feedbackCounts = {};

                                    FirebaseFirestore.instance
                                        .collection('generalfeedback')
                                        .doc(
                                            snapshot.data?.docs[index].id ?? '')
                                        .get()
                                        .then((value) {
                                      questions = value.data()?['questions'];
                                      for (var i = 0;
                                          i < questions.length;
                                          i++) {
                                        options.add(value.data()?['options$i']);
                                      }
                                    }).then((value) {
                                      FirebaseFirestore.instance
                                          .collection('generalfeedback')
                                          .doc(snapshot.data?.docs[index].id ??
                                              '')
                                          .collection('feedback')
                                          .get()
                                          .then((value) {
                                        if (value.docs.isEmpty) {
                                          return;
                                        } else {
                                          for (var doc in value.docs) {
                                            for (var i = 0;
                                                i < questions.length;
                                                i++) {
                                              String answer = doc['options'][i];
                                              if (feedbackCounts
                                                  .containsKey(answer)) {
                                                feedbackCounts[answer] =
                                                    feedbackCounts[answer]! + 1;
                                              } else {
                                                feedbackCounts[answer] = 1;
                                              }
                                            }
                                          }
                                        }
                                      }).then((value) {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Viewingemployeefeedbacks(
                                                      id: snapshot
                                                              .data
                                                              ?.docs[index]
                                                              .id ??
                                                          '',
                                                      feedbackCounts:
                                                          feedbackCounts,
                                                    )));
                                      });
                                    });
                                  },
                                ),
                              )
                            ],
                          );
                        }),
                  );
                }),
          ),
          Container(
            width: 90.w,
            height: 6.h,
            margin: EdgeInsets.only(right: 5.w, left: 5.w),
            child: Material1.button(
                label: 'درووستکردنی فیدباک',
                buttoncolor: Material1.primaryColor,
                textcolor: Colors.white,
                function: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => Admincreatedfeedback(
                                email: widget.email,
                              )));
                }),
          )
        ],
      ),
    );
  }
}
