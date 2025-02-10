import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import 'adminaddingtask.dart';

class BatchTaskAddition extends StatefulWidget {
  final String adminemail;
  const BatchTaskAddition({super.key, required this.adminemail});

  @override
  State<BatchTaskAddition> createState() => _BatchTaskAdditionState();
}

class _BatchTaskAdditionState extends State<BatchTaskAddition> {
  List<String> selectedUsers = [];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('زیادکردنی کاری بە کۆمەڵ'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            height: 6.h,
            margin: EdgeInsets.fromLTRB(10.w, 1.h, 10.w, 1.h),
            decoration: BoxDecoration(
              color: Material1.primaryColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5,
                )
              ],
            ),
            child: Material1.button(
                label: 'هەڵبژاردنی هەموو کارمەندەکان',
                buttoncolor: Material1.primaryColor,
                textcolor: Colors.white,
                function: () {
                  if (selectedUsers.isEmpty) {
                    FirebaseFirestore.instance
                        .collection('user')
                        .get()
                        .then((QuerySnapshot querySnapshot) {
                      for (var doc in querySnapshot.docs) {
                        selectedUsers.add(doc['email']);
                      }
                    });
                  } else {
                    selectedUsers.clear();
                  }
                  setState(() {});
                }),
          ),
          SizedBox(
            height: 70.h,
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
                          setState(() {
                            if (selectedUsers.contains(
                                snapshot.data!.docs[index]['email'])) {
                              selectedUsers
                                  .remove(snapshot.data!.docs[index]['email']);
                            } else {
                              selectedUsers
                                  .add(snapshot.data!.docs[index]['email']);
                            }
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
                              child: Row(
                                children: [
                                  Checkbox(
                                    checkColor: Colors.white,
                                    fillColor: WidgetStateProperty.resolveWith(
                                      (states) => Material1.primaryColor,
                                    ),
                                    value: selectedUsers.contains(
                                        snapshot.data!.docs[index]['email']),
                                    onChanged: (bool? value) {
                                      setState(() {
                                        if (value == true) {
                                          selectedUsers.add(snapshot
                                              .data!.docs[index]['email']);
                                        } else {
                                          selectedUsers.remove(snapshot
                                              .data!.docs[index]['email']);
                                        }
                                      });
                                    },
                                  ),
                                  Column(
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
            margin: EdgeInsets.fromLTRB(10.w, 1.h, 10.w, 1.h),
            decoration: BoxDecoration(
              color: Material1.primaryColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5,
                )
              ],
            ),
            child: Material1.button(
                label: 'زیادکردنی کار',
                buttoncolor: Material1.primaryColor,
                textcolor: Colors.white,
                function: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return AdminAddingTask(
                      isbatch: true,
                      selectedUsers: selectedUsers,
                      adminemail: widget.adminemail,
                      email: 'email',
                    );
                  }));
                }),
          ),
        ],
      ),
    );
  }
}
