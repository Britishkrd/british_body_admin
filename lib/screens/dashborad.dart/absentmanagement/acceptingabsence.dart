// import 'package:british_body_admin/sendingnotification.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
// import 'package:intl/intl.dart';

// import '../../../material/materials.dart';

// class Acceptingabsence extends StatefulWidget {
//   const Acceptingabsence({super.key});

//   @override
//   State<Acceptingabsence> createState() => _AcceptingabsenceState();
// }

// String formatDate(DateTime? date) {
//   final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
//   return formatter.format(date ?? DateTime.now());
// }

// const List<String> list = <String>[
//   'default1',
//   'annoying',
//   'annoying1',
//   'arabic',
//   'laughing',
//   'longfart',
//   'mild',
//   'oud',
//   'rooster',
//   'salawat',
//   'shortfart',
//   'soft2',
//   'softalert',
//   'srusht',
//   'witch',
// ];
// String dropdownValue = 'default1';

// class _AcceptingabsenceState extends State<Acceptingabsence> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('پەسەندکردنی مۆڵەت'),
//         foregroundColor: Colors.white,
//         backgroundColor: Material1.primaryColor,
//       ),
//       body: StreamBuilder(
//         stream: FirebaseFirestore.instance.collection('user').snapshots(),
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           }
//           return ListView.builder(
//               itemCount: snapshot.data?.docs.length ?? 0,
//               itemBuilder: (BuildContext context, int index) {
//                 String email = snapshot.data!.docs[index].data()['email'];
//                 return StreamBuilder(
//                   stream: FirebaseFirestore.instance
//                       .collection('user')
//                       .doc(snapshot.data!.docs[index].data()['email'])
//                       .collection('absentmanagement')
//                       .where('status', isEqualTo: 'pending')
//                       .snapshots(),
//                   builder: (context, snapshot) {
//                     if (snapshot.connectionState == ConnectionState.waiting) {
//                       return const Center(child: CircularProgressIndicator());
//                     }
//                     return SizedBox(
//                       height: ((snapshot.data?.docs.length ?? 0) * 38).h,
//                       child: ListView.builder(
//                           physics: const NeverScrollableScrollPhysics(),
//                           itemCount: snapshot.data?.docs.length ?? 0,
//                           itemBuilder: (BuildContext context, int index) {
//                             return SizedBox(
//                                 height: 38.h,
//                                 width: 90.w,
//                                 child: Container(
//                                     margin:
//                                         EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
//                                     padding: EdgeInsets.all(1.h),
//                                     decoration: BoxDecoration(
//                                       color: Colors.white,
//                                       borderRadius: BorderRadius.circular(5),
//                                       boxShadow: const [
//                                         BoxShadow(
//                                           color: Colors.grey,
//                                           blurRadius: 5,
//                                         )
//                                       ],
//                                     ),
//                                     child: Column(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.spaceEvenly,
//                                         crossAxisAlignment:
//                                             CrossAxisAlignment.end,
//                                         children: [
//                                           Text(email,
//                                               style: TextStyle(
//                                                   fontSize: 16.sp,
//                                                   fontWeight: FontWeight.bold)),
//                                           SizedBox(
//                                             height: 3.h,
//                                             child: Text(
//                                                 snapshot.data!.docs[index]
//                                                             ['status'] ==
//                                                         'accepted'
//                                                     ? 'قبوڵکراوە'
//                                                     : snapshot.data!.docs[index]
//                                                                 ['status'] ==
//                                                             'pending'
//                                                         ? 'لە چاوەڕوانی دایە'
//                                                         : 'ڕەتکراوەتەوە',
//                                                 style: TextStyle(
//                                                     fontSize: 16.sp,
//                                                     fontWeight:
//                                                         FontWeight.bold)),
//                                           ),
//                                           SizedBox(
//                                             height: 6.h,
//                                             child: Text(
//                                                 "${snapshot.data!.docs[index]['note']} : تێبینی ",
//                                                 style: TextStyle(
//                                                     fontSize: 16.sp,
//                                                     fontWeight:
//                                                         FontWeight.bold)),
//                                           ),
//                                           Container(
//                                             margin: EdgeInsets.only(
//                                                 top: 5.h,
//                                                 left: 5.w,
//                                                 right: 5.w),
//                                             height: 8.h,
//                                             child: Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               crossAxisAlignment:
//                                                   CrossAxisAlignment.center,
//                                               children: [
//                                                 SizedBox(
//                                                   height: 6.h,
//                                                   width: 30.w,
//                                                   child: DropdownButton<String>(
//                                                     isExpanded: true,
//                                                     value: dropdownValue,
//                                                     icon: const Icon(
//                                                       Icons.arrow_downward,
//                                                       color: Colors.black,
//                                                     ),
//                                                     elevation: 16,
//                                                     style: TextStyle(
//                                                         color: Material1
//                                                             .primaryColor),
//                                                     underline: Container(
//                                                         height: 2,
//                                                         color: Material1
//                                                             .primaryColor),
//                                                     onChanged: (String? value) {
//                                                       setState(() {
//                                                         dropdownValue = value!;
//                                                       });
//                                                     },
//                                                     items: list.map<
//                                                             DropdownMenuItem<
//                                                                 String>>(
//                                                         (String value) {
//                                                       return DropdownMenuItem<
//                                                               String>(
//                                                           value: value,
//                                                           child: Text(value));
//                                                     }).toList(),
//                                                   ),
//                                                 ),
//                                                 SizedBox(
//                                                     height: 6.h,
//                                                     width: 30.w,
//                                                     child: Center(
//                                                         child: Text(
//                                                             'هەڵبژاردنی دەنگ'))),
//                                               ],
//                                             ),
//                                           ),
//                                           Row(
//                                             mainAxisAlignment:
//                                                 MainAxisAlignment.spaceAround,
//                                             children: [
//                                               TextButton(
//                                                   onPressed: () async {
//                                                     String password = '';
//                                                     if ('default1' !=
//                                                         dropdownValue) {
//                                                       await showDialog(
//                                                         context: context,
//                                                         builder: (context) {
//                                                           return AlertDialog(
//                                                             title: Text(
//                                                                 'Enter Password'),
//                                                             content: TextField(
//                                                               onChanged:
//                                                                   (value) {
//                                                                 password =
//                                                                     value;
//                                                               },
//                                                               obscureText: true,
//                                                               decoration:
//                                                                   InputDecoration(
//                                                                       hintText:
//                                                                           "Password"),
//                                                             ),
//                                                             actions: [
//                                                               Material1.button(
//                                                                 label: 'OK',
//                                                                 function: () {
//                                                                   Navigator.pop(
//                                                                       context);
//                                                                 },
//                                                                 textcolor:
//                                                                     Colors
//                                                                         .white,
//                                                                 buttoncolor:
//                                                                     Material1
//                                                                         .primaryColor,
//                                                               ),
//                                                             ],
//                                                           );
//                                                         },
//                                                       );
//                                                     }

//                                                     if (password != '1010' &&
//                                                         'default1' !=
//                                                             dropdownValue) {
//                                                       ScaffoldMessenger.of(
//                                                               context)
//                                                           .showSnackBar(
//                                                         const SnackBar(
//                                                           content: Text(
//                                                               'Password is incorrect'),
//                                                         ),
//                                                       );
//                                                       return;
//                                                     }
//                                                     FirebaseFirestore.instance
//                                                         .collection('user')
//                                                         .doc(email)
//                                                         .collection(
//                                                             'absentmanagement')
//                                                         .doc(snapshot.data!
//                                                             .docs[index].id)
//                                                         .update({
//                                                       'status': 'accepted'
//                                                     }).then((value) {
//                                                       FirebaseFirestore.instance
//                                                           .collection('user')
//                                                           .doc(email)
//                                                           .get()
//                                                           .then((value) {
//                                                         sendingnotification(
//                                                             'مۆڵەت',
//                                                             'مۆڵەتەکەت قبوڵکرا',
//                                                             value.data()?[
//                                                                 'token'],
//                                                             dropdownValue);
//                                                       });
//                                                     });
//                                                   },
//                                                   child: Text('قبوڵکردن',
//                                                       style: TextStyle(
//                                                           fontWeight:
//                                                               FontWeight.bold,
//                                                           fontSize: 16.sp))),
//                                               TextButton(
//                                                   onPressed: () async {
//                                                     String password = '';
//                                                     if ('default1' !=
//                                                         dropdownValue) {
//                                                       await showDialog(
//                                                         context: context,
//                                                         builder: (context) {
//                                                           return AlertDialog(
//                                                             title: Text(
//                                                                 'Enter Password'),
//                                                             content: TextField(
//                                                               onChanged:
//                                                                   (value) {
//                                                                 password =
//                                                                     value;
//                                                               },
//                                                               obscureText: true,
//                                                               decoration:
//                                                                   InputDecoration(
//                                                                       hintText:
//                                                                           "Password"),
//                                                             ),
//                                                             actions: [
//                                                               Material1.button(
//                                                                 label: 'OK',
//                                                                 function: () {
//                                                                   Navigator.pop(
//                                                                       context);
//                                                                 },
//                                                                 textcolor:
//                                                                     Colors
//                                                                         .white,
//                                                                 buttoncolor:
//                                                                     Material1
//                                                                         .primaryColor,
//                                                               ),
//                                                             ],
//                                                           );
//                                                         },
//                                                       );
//                                                     }

//                                                     if (password != '1010' &&
//                                                         'default1' !=
//                                                             dropdownValue) {
//                                                       ScaffoldMessenger.of(
//                                                               context)
//                                                           .showSnackBar(
//                                                         const SnackBar(
//                                                           content: Text(
//                                                               'Password is incorrect'),
//                                                         ),
//                                                       );
//                                                       return;
//                                                     }
//                                                     FirebaseFirestore.instance
//                                                         .collection('user')
//                                                         .doc(email)
//                                                         .collection(
//                                                             'absentmanagement')
//                                                         .doc(snapshot.data!
//                                                             .docs[index].id)
//                                                         .update({
//                                                       'status': 'rejected'
//                                                     }).then((value) {
//                                                       FirebaseFirestore.instance
//                                                           .collection('user')
//                                                           .doc(email)
//                                                           .get()
//                                                           .then((value) {
//                                                         sendingnotification(
//                                                             'مۆڵەت',
//                                                             'مۆڵەتەکەت ڕەتکرایەوە',
//                                                             value.data()?[
//                                                                 'token'],
//                                                             dropdownValue);
//                                                       });
//                                                     });
//                                                   },
//                                                   child: Text('ڕەتکردنەوە',
//                                                       style: TextStyle(
//                                                           fontWeight:
//                                                               FontWeight.bold,
//                                                           color: Colors.red,
//                                                           fontSize: 16.sp))),
//                                             ],
//                                           ),
//                                         ])));
//                           }),
//                     );
//                   },
//                 );
//               });
//         },
//       ),
//     );
//   }
// }

import 'package:british_body_admin/sendingnotification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

import '../../../material/materials.dart';

class Acceptingabsence extends StatefulWidget {
  const Acceptingabsence({super.key});

  @override
  State<Acceptingabsence> createState() => _AcceptingabsenceState();
}

String formatDate(DateTime? date) {
  final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
  return formatter.format(date ?? DateTime.now());
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

class _AcceptingabsenceState extends State<Acceptingabsence> {
  Future<void> _deleteTasksForAbsence(
      String email, DateTime start, DateTime end) async {
    try {
      // Query tasks where the deadline falls within the absence period
      final tasksSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(email)
          .collection('tasks')
          .where('deadline',
              isGreaterThanOrEqualTo: Timestamp.fromDate(start),
              isLessThanOrEqualTo: Timestamp.fromDate(
                  end.add(Duration(days: 1)).subtract(Duration(seconds: 1))))
          .get();

      // Delete each matching task
      for (var task in tasksSnapshot.docs) {
        await FirebaseFirestore.instance
            .collection('user')
            .doc(email)
            .collection('tasks')
            .doc(task.id)
            .delete();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting tasks: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('پەسەندکردنی مۆڵەت'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance.collection('user').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
            itemCount: snapshot.data?.docs.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              String email = snapshot.data!.docs[index].data()['email'];
              return StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('user')
                    .doc(email)
                    .collection('absentmanagement')
                    .where('status', isEqualTo: 'pending')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return SizedBox(
                    height: ((snapshot.data?.docs.length ?? 0) * 38).h,
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data?.docs.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        return SizedBox(
                          height: 38.h,
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
                                  email,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(
                                  height: 3.h,
                                  child: Text(
                                    snapshot.data!.docs[index]['status'] ==
                                            'accepted'
                                        ? 'قبوڵکراوە'
                                        : snapshot.data!.docs[index]['status'] ==
                                                'pending'
                                            ? 'لە چاوەڕوانی دایە'
                                            : 'ڕەتکراوەتەوە',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 6.h,
                                  child: Text(
                                    "${snapshot.data!.docs[index]['note']} : تێبینی ",
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin:
                                      EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
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
                                          style: TextStyle(
                                            color: Material1.primaryColor,
                                          ),
                                          underline: Container(
                                            height: 2,
                                            color: Material1.primaryColor,
                                          ),
                                          onChanged: (String? value) {
                                            setState(() {
                                              dropdownValue = value!;
                                            });
                                          },
                                          items: list
                                              .map<DropdownMenuItem<String>>(
                                                  (String value) {
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
                                        child: Center(
                                          child: Text(
                                            'هەڵبژاردنی دەنگ',
                                            style: TextStyle(fontSize: 16.sp),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                  children: [
                                    TextButton(
                                      onPressed: () async {
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
                                                  decoration: InputDecoration(
                                                    hintText: "Password",
                                                  ),
                                                ),
                                                actions: [
                                                  Material1.button(
                                                    label: 'OK',
                                                    function: () {
                                                      Navigator.pop(context);
                                                    },
                                                    textcolor: Colors.white,
                                                    buttoncolor:
                                                        Material1.primaryColor,
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }

                                        if (password != '1010' &&
                                            'default1' != dropdownValue) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Password is incorrect'),
                                            ),
                                          );
                                          return;
                                        }

                                        // Update absence status to accepted
                                        await FirebaseFirestore.instance
                                            .collection('user')
                                            .doc(email)
                                            .collection('absentmanagement')
                                            .doc(snapshot.data!.docs[index].id)
                                            .update({'status': 'accepted'});

                                        // Get absence start and end dates
                                        DateTime start = snapshot
                                            .data!.docs[index]['start']
                                            .toDate();
                                        DateTime end = snapshot
                                            .data!.docs[index]['end']
                                            .toDate();

                                        // Delete tasks within the absence period
                                        await _deleteTasksForAbsence(
                                            email, start, end);

                                        // Send notification
                                        await FirebaseFirestore.instance
                                            .collection('user')
                                            .doc(email)
                                            .get()
                                            .then((value) {
                                          sendingnotification(
                                            'مۆڵەت',
                                            'مۆڵەتەکەت قبوڵکرا و ئەرکەکانت سڕانەوە',
                                            value.data()?['token'],
                                            dropdownValue,
                                          );
                                        });

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'مۆڵەت قبوڵکرا و ئەرکەکان سڕانەوە'),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: Colors.green,
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'قبوڵکردن',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
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
                                                  decoration: InputDecoration(
                                                    hintText: "Password",
                                                  ),
                                                ),
                                                actions: [
                                                  Material1.button(
                                                    label: 'OK',
                                                    function: () {
                                                      Navigator.pop(context);
                                                    },
                                                    textcolor: Colors.white,
                                                    buttoncolor:
                                                        Material1.primaryColor,
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                        }

                                        if (password != '1010' &&
                                            'default1' != dropdownValue) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                  'Password is incorrect'),
                                            ),
                                          );
                                          return;
                                        }

                                        // Update absence status to rejected
                                        await FirebaseFirestore.instance
                                            .collection('user')
                                            .doc(email)
                                            .collection('absentmanagement')
                                            .doc(snapshot.data!.docs[index].id)
                                            .update({'status': 'rejected'});

                                        // Send notification
                                        await FirebaseFirestore.instance
                                            .collection('user')
                                            .doc(email)
                                            .get()
                                            .then((value) {
                                          sendingnotification(
                                            'مۆڵەت',
                                            'مۆڵەتەکەت ڕەتکرایەوە',
                                            value.data()?['token'],
                                            dropdownValue,
                                          );
                                        });

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text('مۆڵەت ڕەتکرایەوە'),
                                            behavior: SnackBarBehavior.floating,
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      },
                                      child: Text(
                                        'ڕەتکردنەوە',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                          fontSize: 16.sp,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}