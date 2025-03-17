import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/sendingnotification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Sendingalerts extends StatefulWidget {
  final String adminemail;
  final List emails;
  const Sendingalerts(
      {super.key, required this.adminemail, required this.emails});

  @override
  State<Sendingalerts> createState() => _SendingalertsState();
}

const List<String> list = <String>[
  'default1',
  'annoying',
  'annoying1',
  'arabic',
  'laughing',
  'longfart',
  'mild',
  'oud',
  'rooster',
  'salawat',
  'shortfart',
  'soft2',
  'softalert',
  'srusht',
  'witch',
];
String dropdownValue = 'default1';

class _SendingalertsState extends State<Sendingalerts> {
  TextEditingController titlecontroller = TextEditingController();
  TextEditingController bodycontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('ناردنی ئاگاداری'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Container(
            width: 90.w,
            height: 8.h,
            margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
            child: Material1.textfield(
                hint: 'سەر بابەت',
                textColor: Colors.black,
                controller: titlecontroller),
          ),
          Container(
            width: 90.w,
            height: 20.h,
            margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
            child: Material1.textfield(
                hint: 'بابەتەکە',
                textColor: Colors.black,
                controller: bodycontroller,
                maxLines: 10),
          ),
          Container(
            margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
            height: 8.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 6.h,
                  width: 30.w,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: dropdownValue,
                    icon: const Icon(
                      Icons.arrow_downward,
                      color: Colors.black,
                    ),
                    elevation: 16,
                    style: TextStyle(color: Material1.primaryColor),
                    underline:
                        Container(height: 2, color: Material1.primaryColor),
                    onChanged: (String? value) {
                      setState(() {
                        dropdownValue = value!;
                      });
                    },
                    items: list.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                          value: value, child: Text(value));
                    }).toList(),
                  ),
                ),
                SizedBox(
                    height: 6.h,
                    width: 30.w,
                    child: Center(child: Text('هەڵبژاردنی دەنگ'))),
              ],
            ),
          ),
          Container(
            width: 90.w,
            height: 8.h,
            margin: EdgeInsets.fromLTRB(5.w, 5.h, 5.w, 1.h),
            child: Material1.button(
                label: 'ناردن',
                buttoncolor: Material1.primaryColor,
                textcolor: Colors.white,
                function: () async {
                  String password = '';
                  if ('default1' != dropdownValue) {
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('Enter Password'),
                          content: TextField(
                            onChanged: (value) {
                              password = value;
                            },
                            obscureText: true,
                            decoration: InputDecoration(hintText: "Password"),
                          ),
                          actions: [
                            Material1.button(
                              label: 'OK',
                              function: () {
                                Navigator.pop(context);
                              },
                              textcolor: Colors.white,
                              buttoncolor: Material1.primaryColor,
                            ),
                          ],
                        );
                      },
                    );
                  }

                  if (password != '1010' && 'default1' != dropdownValue) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Password is incorrect'),
                      ),
                    );
                    return;
                  }
                  FirebaseFirestore.instance
                      .collection('alert')
                      .doc(DateTime.now().toIso8601String())
                      .set({
                    'title': titlecontroller.text,
                    'body': bodycontroller.text,
                    'time': DateTime.now().toIso8601String(),
                    'by': widget.adminemail,
                    'to': widget.emails,
                  }).then((value) {
                    for (var i = 0; i < widget.emails.length; i++) {
                      FirebaseFirestore.instance
                          .collection('user')
                          .doc(widget.emails[i])
                          .get()
                          .then((value) {
                        sendingnotification(titlecontroller.text,
                            bodycontroller.text, value['token'], dropdownValue);
                      });
                    }
                  }).then((value) {
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('ئاگاداری نێردرا')));
                    Navigator.popUntil(context, (route) => route.isFirst);
                  });
                }),
          ),
        ],
      ),
    );
  }
}
