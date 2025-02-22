import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Edituserr extends StatefulWidget {
  final String email;
  final String name;
  final String location;
  final String phonenumber;
  final String salary;
  final String age;
  final String workhourtarget;
  final String worklat;
  final String worklong;
  final String password;
  final List<String> permissions;
  const Edituserr(
      {super.key,
      required this.email,
      required this.name,
      required this.location,
      required this.phonenumber,
      required this.salary,
      required this.age,
      required this.workhourtarget,
      required this.worklat,
      required this.worklong,
      required this.password,
      required this.permissions});

  @override
  State<Edituserr> createState() => _EdituserrState();
}

class _EdituserrState extends State<Edituserr> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController locationcontroller = TextEditingController();
  TextEditingController phonenumbercontroller = TextEditingController();
  TextEditingController salarycontroller = TextEditingController();
  TextEditingController agecontroller = TextEditingController();
  TextEditingController workhourtargetcontroller = TextEditingController();
  TextEditingController worklatcontroller = TextEditingController();
  TextEditingController worklongcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  List<String> permissions = [
    'accepting absence',
    'adding task',
    'sending alert',
    'viewing task detail',
    'accepting change time',
    'reward and punishment',
    'accepting loan',
    'giving salary',
    'setting feedback',
    'login and logout',
    'setting target',
    'add user',
    'changing worker phone'
  ];
  List<String> selectedpermissions = [];

  @override
  void initState() {
    emailcontroller.text = widget.email;
    namecontroller.text = widget.name;
    locationcontroller.text = widget.location;
    phonenumbercontroller.text = widget.phonenumber;
    salarycontroller.text = widget.salary;
    agecontroller.text = widget.age;
    workhourtargetcontroller.text = widget.workhourtarget;
    worklatcontroller.text = widget.worklat;
    worklongcontroller.text = widget.worklong;
    passwordcontroller.text = widget.password;
    selectedpermissions = widget.permissions;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('زیادکردنی کارمەند'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Container(
            width: 100.w,
            height: 6.h,
            margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
            child: Material1.textfield(
                hint: 'ئیمەیل',
                textColor: Colors.black,
                controller: emailcontroller),
          ),
          Container(
            width: 100.w,
            height: 6.h,
            margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
            child: Material1.textfield(
                hint: 'پاسوورد',
                textColor: Colors.black,
                controller: passwordcontroller),
          ),
          Container(
            width: 100.w,
            height: 6.h,
            margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
            child: Material1.textfield(
                hint: 'ناو',
                textColor: Colors.black,
                controller: namecontroller),
          ),
          Container(
            width: 100.w,
            height: 6.h,
            margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
            child: Material1.textfield(
                hint: 'تەمەن',
                inputType: TextInputType.number,
                textColor: Colors.black,
                controller: agecontroller),
          ),
          Container(
            width: 100.w,
            height: 6.h,
            margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
            child: Material1.textfield(
                hint: 'تارگێتی کاتژمێری کار',
                textColor: Colors.black,
                inputType: TextInputType.number,
                controller: workhourtargetcontroller),
          ),
          Container(
            width: 100.w,
            height: 6.h,
            margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
            child: Material1.textfield(
                hint: 'ناونیشان',
                textColor: Colors.black,
                controller: locationcontroller),
          ),
          Container(
            width: 100.w,
            height: 6.h,
            margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
            child: Material1.textfield(
                hint: 'ژمارەی مۆبایل',
                textColor: Colors.black,
                inputType: TextInputType.number,
                controller: phonenumbercontroller),
          ),
          Container(
            width: 100.w,
            height: 6.h,
            margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
            child: Material1.textfield(
                hint: 'مووچە',
                textColor: Colors.black,
                inputType: TextInputType.number,
                controller: salarycontroller),
          ),
          Container(
            width: 100.w,
            height: 6.h,
            margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
            child: Material1.textfield(
                hint: 'درێژایی کارکەی',
                textColor: Colors.black,
                inputType: TextInputType.number,
                controller: worklatcontroller),
          ),
          Container(
            width: 100.w,
            height: 6.h,
            margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
            child: Material1.textfield(
                hint: 'پانایی کارکەی',
                textColor: Colors.black,
                inputType: TextInputType.number,
                controller: worklongcontroller),
          ),
          SizedBox(
            height: 70.h,
            child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                itemCount: permissions.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(permissions[index]),
                    value: selectedpermissions.contains(permissions[index]),
                    onChanged: (value) {
                      if (selectedpermissions.contains(permissions[index])) {
                        selectedpermissions.remove(permissions[index]);
                      } else {
                        selectedpermissions.add(permissions[index]);
                      }
                      setState(() {});
                    },
                  );
                }),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
            height: 8.h,
            width: 100.w,
            child: Material1.button(
                label: 'دروستکردنی بەکار هێنەر',
                buttoncolor: Material1.primaryColor,
                textcolor: Colors.white,
                function: () {
                  if (emailcontroller.text.isEmpty ||
                      namecontroller.text.isEmpty ||
                      locationcontroller.text.isEmpty ||
                      phonenumbercontroller.text.isEmpty ||
                      salarycontroller.text.isEmpty ||
                      worklatcontroller.text.isEmpty ||
                      worklongcontroller.text.isEmpty ||
                      agecontroller.text.isEmpty ||
                      workhourtargetcontroller.text.isEmpty ||
                      passwordcontroller.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('تکایە هەموو خانەکان پڕبکەوە')));
                  } else {
                    
                      FirebaseFirestore.instance
                          .collection('user')
                          .doc(emailcontroller.text)
                          .update({
                        'email': emailcontroller.text,
                        'name': namecontroller.text,
                        'location': locationcontroller.text,
                        'phonenumber': phonenumbercontroller.text.toString(),
                        'salary': salarycontroller.text.toString(),
                        'worklat': double.parse(worklatcontroller.text),
                        'worklong': double.parse(worklongcontroller.text),
                        'permissions': selectedpermissions,
                        'age': agecontroller.text.toString(),
                        'worktarget': workhourtargetcontroller.text,
                        'password': passwordcontroller.text,
                      }).then((value) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('بە سەرکەوتویی دەسکاری کرا')));
                        Navigator.pop(context);
                      });
                   
                  }
                }),
          )
        ],
      ),
    );
  }
}
