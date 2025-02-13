import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Admincreatedfeedback extends StatefulWidget {
  final String email;
  const Admincreatedfeedback({super.key, required this.email});

  @override
  State<Admincreatedfeedback> createState() => _AdmincreatedfeedbackState();
}

class _AdmincreatedfeedbackState extends State<Admincreatedfeedback> {
  List<TextEditingController> questionscontrollers = [];
  final List<List<TextEditingController>> optionControllers = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('درووست کردنی ڕەخنە و پێشنیار'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {
                List users = [];
                if (questionscontrollers.isEmpty) {
                  return;
                }
                FirebaseFirestore.instance
                    .collection('user')
                    .get()
                    .then((value) {
                  for (var element in value.docs) {
                    users.add(element['email']);
                  }
                }).then((value) {
                  FirebaseFirestore.instance
                      .collection('generalfeedback')
                      .doc(DateTime.now().toIso8601String())
                      .set({
                    'questions':
                        questionscontrollers.map((e) => e.text).toList(),
                    for (var i = 0; i < optionControllers.length; i++)
                      'options$i':
                          optionControllers[i].map((e) => e.text).toList(),
                    'email': widget.email,
                    'date': DateTime.now(),
                    'givenfeedback': users
                  }).then((value) {
                    Navigator.pop(context);
                  });
                });
              },
              icon: Icon(Icons.save))
        ],
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 75.h,
            child: ListView.builder(
              itemCount: questionscontrollers.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Container(
                  margin: index == (questionscontrollers.length - 1)
                      ? EdgeInsets.only(
                          bottom: 40.h, top: 5.w, right: 5.w, left: 5.w)
                      : EdgeInsets.all(5.w),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(color: Colors.black, width: 1)),
                  height: (((optionControllers[index].length) * 10) + 30).h,
                  child: Column(
                    children: [
                      Container(
                        width: 90.w,
                        height: 8.h,
                        margin:
                            EdgeInsets.only(top: 2.h, left: 5.w, right: 5.w),
                        child: Material1.textfield(
                            hint: 'پرسیار ${index + 1}',
                            textColor: Colors.black,
                            controller: questionscontrollers[index],
                            maxLines: 10),
                      ),
                      ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: optionControllers[index].length,
                          shrinkWrap: true,
                          itemBuilder: (context, optionindex) {
                            return Container(
                              width: 90.w,
                              height: 8.h,
                              margin: EdgeInsets.only(
                                  top: 2.h, left: 5.w, right: 5.w),
                              child: Material1.textfield(
                                  hint: 'هەڵبژاردن ${optionindex + 1}',
                                  textColor: Colors.black,
                                  controller: optionControllers[index]
                                      [optionindex],
                                  maxLines: 1),
                            );
                          }),
                      Container(
                          width: 90.w,
                          height: 8.h,
                          margin:
                              EdgeInsets.only(top: 2.h, left: 5.w, right: 5.w),
                          child: Material1.button(
                              label: 'زیادکردنی هەڵبژاردن',
                              buttoncolor: Material1.primaryColor,
                              textcolor: Colors.white,
                              function: () {
                                setState(() {
                                  optionControllers[index]
                                      .add(TextEditingController());
                                });
                              })),
                      Container(
                          width: 90.w,
                          height: 6.h,
                          margin:
                              EdgeInsets.only(top: 2.h, left: 5.w, right: 5.w),
                          child: Material1.button(
                              label: 'سڕینەوەی هەڵبژاردن',
                              buttoncolor: Colors.red,
                              textcolor: Colors.white,
                              function: () {
                                setState(() {
                                  optionControllers[index].removeLast();
                                });
                              })),
                    ],
                  ),
                );
              },
            ),
          ),
          Row(
            children: [
              Container(
                  width: 40.w,
                  height: 8.h,
                  margin: EdgeInsets.only(top: 2.h, left: 5.w, right: 5.w),
                  child: Material1.button(
                      label: 'زیادکردنی پرسیار',
                      buttoncolor: Material1.primaryColor,
                      textcolor: Colors.white,
                      function: () {
                        setState(() {
                          questionscontrollers.add(TextEditingController());
                          optionControllers.add([]);
                        });
                      })),
              Container(
                  width: 40.w,
                  height: 8.h,
                  margin: EdgeInsets.only(top: 2.h, left: 5.w, right: 5.w),
                  child: Material1.button(
                      label: 'سڕینەوەی پرسیار',
                      buttoncolor: Colors.red,
                      textcolor: Colors.white,
                      function: () {
                        setState(() {
                          questionscontrollers.removeLast();
                          optionControllers.removeLast();
                        });
                      })),
            ],
          ),
        ],
      ),
    );
  }
}
