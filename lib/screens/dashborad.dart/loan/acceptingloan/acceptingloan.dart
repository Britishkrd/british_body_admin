import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/sendingnotification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:chips_choice/chips_choice.dart';

class AcceptingLoan extends StatefulWidget {
  const AcceptingLoan({super.key});

  @override
  State<AcceptingLoan> createState() => _AcceptingLoanState();
}

int tag = 1;
List<String> options = ['لە چاوەڕوانی', 'قبوڵکراو', 'ڕەتکراو'];

List<Stream<QuerySnapshot<Map<String, dynamic>>>> streams = [
  FirebaseFirestore.instance
      .collection('loanmanagement')
      .where('status', isEqualTo: 'pending')
      .snapshots(),
  FirebaseFirestore.instance
      .collection('loanmanagement')
      .where('status', isEqualTo: 'accepted')
      .snapshots(),
  FirebaseFirestore.instance
      .collection('loanmanagement')
      .where('status', isEqualTo: 'rejected')
      .snapshots()
];
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

class _AcceptingLoanState extends State<AcceptingLoan> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('قبوڵکردنی سولفە'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 8.h,
            child: ChipsChoice<int>.single(
              value: tag,
              onChanged: (val) => setState(() => tag = val),
              choiceItems: C2Choice.listFrom<int, String>(
                source: options,
                value: (i, v) => i,
                label: (i, v) => v,
              ),
            ),
          ),
          SizedBox(
            height: 80.h,
            width: 100.w,
            child: StreamBuilder(
              stream: streams[tag],
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
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
                              title: const Text('دەتەوێت سولفەکە قبوڵ بکەیت؟'),
                              actions: [
                                TextButton(
                                  onPressed: () async {
                                    String password = '';
                                    if (dropdownValue != 'default1') {
                                      await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text('Enter Password'),
                                            content: TextField(
                                              onChanged: (value) {
                                                password = value;
                                              },
                                              obscureText: true,
                                              decoration: const InputDecoration(hintText: "Password"),
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

                                    if (password != '1010' && dropdownValue != 'default1') {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Password is incorrect'),
                                        ),
                                      );
                                      return;
                                    }
                                    final loanAmount = int.parse(snapshot.data!.docs[index]['amount'].toString());
                                    FirebaseFirestore.instance
                                        .collection('user')
                                        .doc(snapshot.data!.docs[index]['requestedby'])
                                        .update({
                                      'loan': loanAmount,
                                      'loanstatus': 'given',
                                      'monthlypayback': (loanAmount * 0.1).toInt(), // Store as integer
                                    }).then((value) {
                                      FirebaseFirestore.instance
                                          .collection('loanmanagement')
                                          .doc(snapshot.data!.docs[index].id)
                                          .update({
                                        'status': 'accepted'
                                      }).then((value) {
                                        FirebaseFirestore.instance
                                            .collection('user')
                                            .doc(snapshot.data!.docs[index]['requestedby'])
                                            .get()
                                            .then((value) {
                                          sendingnotification(
                                            'سولفە',
                                            'سولفەکەت قبوڵکرا',
                                            value.data()?['token'],
                                            dropdownValue,
                                          );
                                        });
                                      });
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'قبوڵکردن',
                                    style: TextStyle(color: Material1.primaryColor),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    String password = '';
                                    if (dropdownValue != 'default1') {
                                      await showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text('Enter Password'),
                                            content: TextField(
                                              onChanged: (value) {
                                                password = value;
                                              },
                                              obscureText: true,
                                              decoration: const InputDecoration(hintText: "Password"),
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

                                    if (password != '1010' && dropdownValue != 'default1') {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Password is incorrect'),
                                        ),
                                      );
                                      return;
                                    }
                                    FirebaseFirestore.instance
                                        .collection('loanmanagement')
                                        .doc(snapshot.data!.docs[index].id)
                                        .update({
                                      'status': 'rejected'
                                    }).then((value) {
                                      FirebaseFirestore.instance
                                          .collection('user')
                                          .doc(snapshot.data!.docs[index]['requestedby'])
                                          .get()
                                          .then((value) {
                                        sendingnotification(
                                          'سولفە',
                                          'سولفەکەت رەتکرایەوە',
                                          value.data()?['token'],
                                          dropdownValue,
                                        );
                                      });
                                    });
                                    Navigator.pop(context);
                                  },
                                  child: const Text(
                                    'رەتکردنەوە',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      child: SizedBox(
                        height: 35.h,
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
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "${snapshot.data!.docs[index]['requestedby']} : ئیمەڵی کەسی داواکار",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${snapshot.data!.docs[index]['amount']} : بڕی داواکراو",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${snapshot.data!.docs[index]['note']} : تێبینی",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "بارودۆخ :${snapshot.data!.docs[index]['status'] == 'accepted' ? 'قبوڵکراوە' : snapshot.data!.docs[index]['status'] == 'pending' ? 'لە چاوەڕوانی دایە' : 'ڕەتکراوەتەوە'}",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.bold,
                                ),
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
                                        underline: Container(
                                          height: 2,
                                          color: Material1.primaryColor,
                                        ),
                                        onChanged: (String? value) {
                                          setState(() {
                                            dropdownValue = value!;
                                          });
                                        },
                                        items: list.map<DropdownMenuItem<String>>((String value) {
                                          return DropdownMenuItem<String>(
                                            value: value,
                                            child: Text(value),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 6.h,
                                      width: 30.w,
                                      child: const Center(child: Text('هەڵبژاردنی دەنگ')),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}