import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Employeesendfeedback extends StatefulWidget {
  final String email;
  const Employeesendfeedback({super.key, required this.email});

  @override
  State<Employeesendfeedback> createState() => _EmployeesendfeedbackState();
}

class _EmployeesendfeedbackState extends State<Employeesendfeedback> {
  TextEditingController feedbackController = TextEditingController();
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
          Container(
            width: 90.w,
            height: 15.h,
            margin: EdgeInsets.only(top: 2.h, left: 5.w, right: 5.w),
            child: Material1.textfield(
                hint: 'ڕەخنە و پێشنیار',
                textColor: Colors.black,
                controller: feedbackController,
                maxLines: 10),
          ),
          Container(
            width: 90.w,
            height: 8.h,
            margin: EdgeInsets.only(top: 2.h, left: 5.w, right: 5.w),
            child: Material1.button(
                label: 'ناردن',
                buttoncolor: Material1.primaryColor,
                textcolor: Colors.white,
                function: () {
                  if (feedbackController.text.isNotEmpty) {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Center(child: CircularProgressIndicator()),
                          );
                        });
                    FirebaseFirestore.instance.collection('feedback').add({
                      'feedback': feedbackController.text,
                      'time': DateTime.now(),
                      'employee': widget.email
                    }).then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text('ڕەخنە / پێشنیارەکەت بەسەرکەوتویی ناردرا')));
                      Navigator.popUntil(context, (route) => route.isFirst);
                      feedbackController.clear();
                    });
                  }
                }),
          )
        ],
      ),
    );
  }
}
