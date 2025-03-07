import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Adminaddingdepartment extends StatefulWidget {
  const Adminaddingdepartment({super.key});

  @override
  State<Adminaddingdepartment> createState() => _AdminaddingdepartmentState();
}

class _AdminaddingdepartmentState extends State<Adminaddingdepartment> {
  TextEditingController departmentcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('زیادکردنی بەش'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
              margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
              child: Material1.textfield(
                  hint: 'ناوی بەش',
                  textColor: Colors.black,
                  controller: departmentcontroller)),
          Container(
              margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
              child: Material1.button(
                  label: 'زیادکردنی بەش',
                  buttoncolor: Material1.primaryColor,
                  textcolor: Colors.white,
                  function: () {
                    if (departmentcontroller.text.isNotEmpty) {
                      FirebaseFirestore.instance
                          .collection('company')
                          .doc('department')
                          .collection('department')
                          .doc(departmentcontroller.text)
                          .set({'name': departmentcontroller.text},
                              SetOptions(merge: true));
                      Navigator.pop(context);
                    }
                  }))
        ],
      ),
    );
  }
}
