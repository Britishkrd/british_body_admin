import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/dashborad.dart/rulesandguidelines/choosingdept.dart';
import 'package:british_body_admin/screens/dashborad.dart/rulesandguidelines/adminaddingdepartment.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Adminrules extends StatefulWidget {
  final String email;
  const Adminrules({super.key, required this.email});

  @override
  State<Adminrules> createState() => _AdminrulesState();
}

class _AdminrulesState extends State<Adminrules> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('زیادکردنی یاساکان'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
              width: 100.w,
              height: 6.h,
              margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
              child: Material1.button(
                  label: 'زیادکردنی بەش',
                  buttoncolor: Material1.primaryColor,
                  textcolor: Colors.white,
                  function: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return Adminaddingdepartment();
                    }));
                  })),
          Container(
              width: 100.w,
              height: 6.h,
              margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
              child: Material1.button(
                  label: 'زیادکردنی بەشی لاوەکی',
                  buttoncolor: Material1.primaryColor,
                  textcolor: Colors.white,
                  function: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return Choosingdepttoaddsub(
                        isaddingrule: false,
                        email: widget.email,
                        isemployee: false,
                      );
                    }));
                  })),
          Container(
              width: 100.w,
              height: 6.h,
              margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
              child: Material1.button(
                  label: 'زیادکردنی یاساکان',
                  buttoncolor: Material1.primaryColor,
                  textcolor: Colors.white,
                  function: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return Choosingdepttoaddsub(
                        isaddingrule: true,
                        email: widget.email,
                        isemployee: false,
                      );
                    }));
                  })),
        ],
      ),
    );
  }
}
