import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/dashborad.dart/adduser/adduser.dart';
import 'package:british_body_admin/screens/dashborad.dart/adduser/edituser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Choosinguserforusermanagement extends StatefulWidget {
  final String email;
  const Choosinguserforusermanagement({super.key, required this.email});

  @override
  State<Choosinguserforusermanagement> createState() =>
      _ChoosinguserforusermanagementState();
}

class _ChoosinguserforusermanagementState
    extends State<Choosinguserforusermanagement> {
  TextEditingController passwordcontroller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('کارمەندەکان'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 75.h,
            width: 100.w,
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection('user').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                    itemCount: snapshot.data?.docs.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text(
                                      'دەتەوێت چی لەم کارمەندە بکەیت؟'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          String password = '';
                                          try {
                                            password = snapshot.data
                                                    ?.docs[index]['password'] ??
                                                '';
                                          } catch (e) {
                                            password = '';
                                          }

                                          Navigator.push(context,
                                              MaterialPageRoute(
                                                  builder: (context) {
                                            return Edituserr(
                                                email: snapshot.data!.docs[index]
                                                    ['email'],
                                                name: snapshot.data!.docs[index]
                                                    ['name'],
                                                location: snapshot.data!.docs[index]
                                                    ['location'],
                                                phonenumber: snapshot.data!.docs[index]
                                                    ['phonenumber'],
                                                salary: snapshot.data!.docs[index]
                                                    ['salary'],
                                                age: snapshot.data!.docs[index]
                                                    ['age'],
                                                workhourtarget: snapshot.data!
                                                    .docs[index]['worktarget']
                                                    .toString(),
                                                worklat: snapshot.data!
                                                    .docs[index]['worklat']
                                                    .toString(),
                                                worklong: snapshot.data!
                                                    .docs[index]['worklong']
                                                    .toString(),
                                                password: password,
                                                permissions: List<String>.from(snapshot.data!.docs[index]['permissions']
                                                
                                                ), starthour: snapshot.data!.docs[index]['starthour'],
                                                endhour: snapshot.data!.docs[index]['endhour'],
                                                startmin: snapshot.data!.docs[index]['startmin'],
                                                endmin: snapshot.data!.docs[index]['endmin'],
                                                weekdays: snapshot.data!.docs[index]['weekdays'],
                                                
                                                );
                                          }));
                                        },
                                        child: const Text('دەستکاری کردن')),
                                    TextButton(
                                        onPressed: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return AlertDialog(
                                                  title: const Text(
                                                      'دڵنیایت لە سڕینەوەی کارمەندەکە؟'),
                                                  actions: [
                                                    Material1.textfield(
                                                      textColor: Colors.black,
                                                      controller:
                                                          passwordcontroller,
                                                      hint: 'پاسوورد',
                                                    ),
                                                    TextButton(
                                                        onPressed: () {
                                                          if (passwordcontroller
                                                                  .text ==
                                                              'admin123456') {
                                                            FirebaseFirestore
                                                                .instance
                                                                .collection(
                                                                    'user')
                                                                .doc(snapshot
                                                                    .data!
                                                                    .docs[index]
                                                                    .id)
                                                                .delete()
                                                                .then((value) {
                                                              ScaffoldMessenger
                                                                      .of(
                                                                          context)
                                                                  .showSnackBar(
                                                                      const SnackBar(
                                                                          content:
                                                                              Text('کارمەندەکە سڕایەوە')));
                                                              Navigator.popUntil(
                                                                  context,
                                                                  (route) => route
                                                                      .isFirst);
                                                            });
                                                          } else {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    const SnackBar(
                                                                        content:
                                                                            Text('پاسوورد هەلەیە')));
                                                          }
                                                        },
                                                        child:
                                                            const Text('بەڵێ')),
                                                    TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                              context);
                                                        },
                                                        child: const Text(
                                                            'نەخێر')),
                                                  ],
                                                );
                                              });
                                        },
                                        child: const Text('سڕینەوەی ',
                                            style:
                                                TextStyle(color: Colors.red))),
                                  ],
                                );
                              });
                        },
                        child: SizedBox(
                            height: 15.h,
                            width: 90.w,
                            child: Container(
                              margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
                              padding: EdgeInsets.all(1.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(5),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 5,
                                  )
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    "${snapshot.data!.docs[index]['name']} : ناو",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    "${snapshot.data!.docs[index]['phonenumber']} : ژمارەی مۆبایل",
                                    style: const TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                  Text(
                                    "${snapshot.data!.docs[index]['email']} : ئیمەیل",
                                    style: const TextStyle(
                                      fontSize: 15,
                                    ),
                                  ),
                                ],
                              ),
                            )),
                      );
                    });
              },
            ),
          ),
          Container(
            height: 6.h,
            width: 60.w,
            margin: EdgeInsets.fromLTRB(20.w, 1.h, 20.w, 1.h),
            child: Material1.button(
                label: 'زیاد کردنی کارمەند',
                buttoncolor: Material1.primaryColor,
                textcolor: Colors.white,
                function: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return Adduser();
                  }));
                }),
          )
        ],
      ),
    );
  }
}
