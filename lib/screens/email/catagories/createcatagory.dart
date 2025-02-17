import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Createcatagory extends StatefulWidget {
  final String email;
  const Createcatagory({super.key, required this.email});

  @override
  State<Createcatagory> createState() => _CreatecatagoryState();
}

class _CreatecatagoryState extends State<Createcatagory> {
  TextEditingController catagoryController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('زیادکردنی کەتەگۆری'),
        backgroundColor: Material1.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 3.h, left: 5.w, right: 5.w),
            child: Material1.textfield(
                hint: 'ناوی کەتەگۆری',
                textColor: Colors.black,
                controller: catagoryController),
          ),
          Container(
            margin: EdgeInsets.only(top: 3.h),
            child: Material1.button(
                label: 'زیادکردن',
                buttoncolor: Material1.primaryColor,
                textcolor: Colors.white,
                width: 90.w,
                height: 8.h,
                function: () {
                  FirebaseFirestore.instance
                      .collection('user')
                      .doc(widget.email)
                      .update({
                    'catagory': FieldValue.arrayUnion([catagoryController.text])
                  }).then((value) {
                    catagoryController.clear();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('کەتەگۆری بەسەرکەوتویی زیادکرا')));
                  });
                }),
          )
        ],
      ),
    );
  }
}
