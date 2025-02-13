import 'dart:developer';

import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Employeegivingfeedback extends StatefulWidget {
  final List<String> questions;
  final List<List<String>> option;
  final String email;
  final String id;
  const Employeegivingfeedback(
      {super.key,
      required this.questions,
      required this.option,
      required this.email,
      required this.id});

  @override
  State<Employeegivingfeedback> createState() => _EmployeegivingfeedbackState();
}

class _EmployeegivingfeedbackState extends State<Employeegivingfeedback> {
  List<TextEditingController> questionscontrollers = [];
  List<String> selectedOptions = [];
  List<String> optionsvalues = [];

  @override
  void initState() {
    for (var i = 0; i < widget.questions.length; i++) {
      questionscontrollers.add(TextEditingController(text: ''));
      selectedOptions.add('');
      optionsvalues.add('${widget.option[i]}');
    }
    log(questionscontrollers.toString());

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('جوابدانەوی ڕاپرسی'),
          foregroundColor: Colors.white,
          backgroundColor: Material1.primaryColor,
          centerTitle: true,
        ),
        body: ListView(
          children: [
            SizedBox(
              height: 80.h,
              child: ListView.builder(
                itemCount: widget.questions.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.all(8.0),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Text(widget.questions[index]),
                          SizedBox(
                            height: ((4 * widget.option[index].length) + 10).h,
                            child: ListView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: widget.option[index].length,
                                itemBuilder: (context, index1) {
                                  return ListTile(
                                    title: Text(widget.option[index][index1]),
                                    leading: Radio<String>(
                                      value: widget.option[index][index1],
                                      groupValue: selectedOptions[index],
                                      onChanged: (String? value) {
                                        setState(() {
                                          selectedOptions[index] = value!;
                                        });
                                      },
                                    ),
                                  );
                                }),
                          ),
                          SizedBox(
                            height: 6.h,
                            width: 90.w,
                            child: Material1.textfield(
                                controller: questionscontrollers[index],
                                hint: 'تێبینی(ئارەزومەندانەیە)',
                                textColor: Colors.black),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            SafeArea(
              child: Container(
                width: 90.w,
                height: 6.h,
                margin: EdgeInsets.only(left: 10.w, right: 10.w),
                decoration: BoxDecoration(
                  color: Material1.primaryColor,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                child: Material1.button(
                    label: 'دڵنیاکردنەوە',
                    buttoncolor: Material1.primaryColor,
                    textcolor: Colors.white,
                    function: () {
                      if (selectedOptions.contains('')) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('تکایە هەموو خانەکان پڕبکەوە')));
                        return;
                      }

                      FirebaseFirestore.instance
                          .collection('generalfeedback')
                          .doc(widget.id)
                          .get()
                          .then((value) {
                        if (value.exists) {
                          log(value.data()!.toString());
                          FirebaseFirestore.instance
                              .collection('generalfeedback')
                              .doc(widget.id)
                              .update({
                            'givenfeedback':
                                FieldValue.arrayRemove([widget.email])
                          }).then((value) {
                            FirebaseFirestore.instance
                                .collection('generalfeedback')
                                .doc(widget.id)
                                .collection('feedback')
                                .doc(widget.email)
                                .set({
                              'email': widget.email,
                              'notes': questionscontrollers
                                  .map((e) => e.text)
                                  .toList(),
                              'options': selectedOptions,
                              'optionsvalues': optionsvalues,
                              'date': DateTime.now(),
                              'questions': widget.questions
                            }).then((value) {
                              Navigator.popUntil(
                                  context, (route) => route.isFirst);
                            });
                          });
                        }
                      });
                    }),
              ),
            )
          ],
        ));
  }
}
