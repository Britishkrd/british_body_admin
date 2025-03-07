import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Adminaddingsubdept extends StatefulWidget {
  final DocumentReference<Map<String, dynamic>> department;
  const Adminaddingsubdept({super.key, required this.department});

  @override
  State<Adminaddingsubdept> createState() => _AdminaddingsubdeptState();
}

class _AdminaddingsubdeptState extends State<Adminaddingsubdept> {
  TextEditingController departmentcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('زیادکردنی بەشی لاوەکی'),
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
                  label: 'زیادکردنی بەشی لاوەکی',
                  buttoncolor: Material1.primaryColor,
                  textcolor: Colors.white,
                  function: () {
                    if (departmentcontroller.text.isNotEmpty) {
                      widget.department.set({
                        'departments':
                            FieldValue.arrayUnion([departmentcontroller.text]),
                      }, SetOptions(merge: true));
                      Navigator.pop(context);
                    }
                  }))
        ],
      ),
    );
  }
}
