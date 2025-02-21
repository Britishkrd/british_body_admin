import 'package:british_body_admin/material/materials.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Adminacceptingchangeworktime extends StatefulWidget {
  const Adminacceptingchangeworktime({super.key});

  @override
  State<Adminacceptingchangeworktime> createState() =>
      _AdminacceptingchangeworktimeState();
}

class _AdminacceptingchangeworktimeState
    extends State<Adminacceptingchangeworktime> {
  int tag = 0;
  List<String> options = ['هەموو', 'لە چاوەڕوانی', 'قبووڵ کراو', 'ڕەفز کراو'];
  Stream<QuerySnapshot<Map<String, dynamic>>> streams() {
    if (tag == 1) {
      return FirebaseFirestore.instance
          .collection('worktime')
          .where('status', isEqualTo: 'pending')
          .snapshots();
    } else if (tag == 2) {
      return FirebaseFirestore.instance
          .collection('worktime')
          .where('status', isEqualTo: 'accepted')
          .snapshots();
    } else if (tag == 3) {
      return FirebaseFirestore.instance
          .collection('worktime')
          .where('status', isEqualTo: 'rejected')
          .snapshots();
    }
    return FirebaseFirestore.instance.collection('worktime').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('پەسەندکردنی گۆڕینی کاتی کار'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
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
            height: 75.h,
            width: 100.w,
            child: StreamBuilder(
              stream: streams(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                    itemCount: snapshot.data?.docs.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      return SizedBox(
                          height: 25.h,
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  "${snapshot.data!.docs[index]['email']}",
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "${snapshot.data!.docs[index]['start']} - ${snapshot.data!.docs[index]['end']}",
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    Text(
                                      "${snapshot.data!.docs[index]['starthour']} : دەستپێکردن",
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      "${snapshot.data!.docs[index]['endhour']}  : کۆتایی ",
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                                Center(
                                  child:
                                      snapshot.data!.docs[index]['status'] ==
                                              'pending'
                                          ? Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                SizedBox(
                                                  height: 4.h,
                                                  width: 30.w,
                                                  child: Material1.button(
                                                    label: 'پەسەندکردن',
                                                    fontsize: 15.sp,
                                                    buttoncolor:
                                                        Material1.primaryColor,
                                                    textcolor: Colors.white,
                                                    function: () {
                                                      showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              title: Text(
                                                                  'پەسەندکردن'),
                                                              content: Text(
                                                                  'دڵنیایت لە پەسەندکردنی ئەم داواکاری؟'),
                                                              actions: [
                                                                TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'worktime')
                                                                          .doc(snapshot
                                                                              .data!
                                                                              .docs[
                                                                                  index]
                                                                              .id)
                                                                          .update({
                                                                        'status':
                                                                            'accepted'
                                                                      }).then((value) {
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(const SnackBar(
                                                                          content:
                                                                              Text('داواکاری پەسەندکرا'),
                                                                        ));
                                                                        Navigator.popUntil(
                                                                            context,
                                                                            (route) =>
                                                                                route.isFirst);
                                                                      });
                                                                    },
                                                                    child: Text(
                                                                        'پەسەند کردن')),
                                                                TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child: Text(
                                                                        'نەخێر')),
                                                              ],
                                                            );
                                                          });
                                                    },
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 4.h,
                                                  width: 30.w,
                                                  child: Material1.button(
                                                    label: 'ڕەتکردنەوە',
                                                    fontsize: 15.sp,
                                                    buttoncolor: Colors.red,
                                                    textcolor: Colors.white,
                                                    function: () {
                                                      showDialog(
                                                          context: context,
                                                          builder: (context) {
                                                            return AlertDialog(
                                                              title: Text(
                                                                  'ڕەتکردنەوە'),
                                                              content: Text(
                                                                  'دڵنیایت لە ڕەتکردنەوەی ئەم داواکاری؟'),
                                                              actions: [
                                                                TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      FirebaseFirestore
                                                                          .instance
                                                                          .collection(
                                                                              'worktime')
                                                                          .doc(snapshot
                                                                              .data!
                                                                              .docs[
                                                                                  index]
                                                                              .id)
                                                                          .update({
                                                                        'status':
                                                                            'rejected'
                                                                      }).then((value) {
                                                                        ScaffoldMessenger.of(context)
                                                                            .showSnackBar(const SnackBar(
                                                                          content:
                                                                              Text('داواکاری ڕەتکرایەوە'),
                                                                        ));
                                                                        Navigator.popUntil(
                                                                            context,
                                                                            (route) =>
                                                                                route.isFirst);
                                                                      });
                                                                    },
                                                                    child: Text(
                                                                      'ڕەتکردنەوە',
                                                                      style: TextStyle(
                                                                          color:
                                                                              Colors.red),
                                                                    )),
                                                                TextButton(
                                                                    onPressed:
                                                                        () {
                                                                      Navigator.pop(
                                                                          context);
                                                                    },
                                                                    child: Text(
                                                                        'نەخێر')),
                                                              ],
                                                            );
                                                          });
                                                    },
                                                  ),
                                                ),
                                              ],
                                            )
                                          : Text(
                                              snapshot.data!.docs[index]
                                                          ['status'] ==
                                                      'accepted'
                                                  ? 'پەسەندکرا'
                                                  : 'ڕەتکرایەوە',
                                              style: const TextStyle(
                                                fontSize: 15,
                                              ),
                                            ),
                                ),
                              ],
                            ),
                          ));
                    });
              },
            ),
          ),
        ],
      ),
    );
  }
}
