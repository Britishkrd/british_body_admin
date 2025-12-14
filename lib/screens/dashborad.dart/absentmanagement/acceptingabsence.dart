
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

// Helper function to convert Firestore Timestamp to DateTime
DateTime? getDateFromTimestamp(dynamic timestamp) {
  if (timestamp == null) return null;
  if (timestamp is Timestamp) {
    return timestamp.toDate();
  }
  return null;
}

// Helper function to get urgency text in Kurdish
String getUrgencyText(String? urgency) {
  switch (urgency) {
    case 'emergency':
      return 'زۆر گرنگ';
    case 'urgent':
      return 'گرنگ';
    case 'normal':
      return 'ئاسایی';
    default:
      return 'نادیار';
  }
}

// Helper function to get urgency color
Color getUrgencyColor(String? urgency) {
  switch (urgency) {
    case 'emergency':
      return Colors.red;
    case 'urgent':
      return Colors.orange;
    case 'normal':
      return Colors.green;
    default:
      return Colors.grey;
  }
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
      final tasksSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(email)
          .collection('tasks')
          .where('deadline',
              isGreaterThanOrEqualTo: Timestamp.fromDate(start),
              isLessThanOrEqualTo: Timestamp.fromDate(
                  end.add(Duration(days: 1)).subtract(Duration(seconds: 1))))
          .get();

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
                    height: ((snapshot.data?.docs.length ?? 0) * 50).h, // Increased height for more content
                    child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data?.docs.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        // Get the absence data
                        var absenceData = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                        
                        // Extract start and end dates
                        DateTime? startDate = getDateFromTimestamp(absenceData['start']);
                        DateTime? endDate = getDateFromTimestamp(absenceData['end']);
                        String? urgency = absenceData['urgency'];
                        
                        return SizedBox(
                          height: 48.h, // Increased height
                          width: 90.w,
                          child: Container(
                            margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
                            padding: EdgeInsets.all(1.h),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
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
                                // Email
                                Text(
                                  email,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                
                                // Status
                                SizedBox(
                                  height: 3.h,
                                  child: Text(
                                    absenceData['status'] == 'accepted'
                                        ? 'قبوڵکراوە'
                                        : absenceData['status'] == 'pending'
                                            ? 'لە چاوەڕوانی دایە'
                                            : 'ڕەتکراوەتەوە',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                      color: absenceData['status'] == 'pending' 
                                          ? Colors.orange 
                                          : absenceData['status'] == 'accepted'
                                              ? Colors.green
                                              : Colors.red,
                                    ),
                                  ),
                                ),
                                
                                // Urgency
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                                      decoration: BoxDecoration(
                                        color: getUrgencyColor(urgency),
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Text(
                                        getUrgencyText(urgency),
                                        style: TextStyle(
                                          fontSize: 12.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 2.w),
                                    Text(
                                      'گرنگی:',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                                
                                // START DATE & TIME
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 0.5.h),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        startDate != null 
                                            ? formatDate(startDate)
                                            : 'نادیار',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Material1.primaryColor,
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        'لە:',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 1.w),
                                      Icon(
                                        Icons.calendar_today,
                                        color: Material1.primaryColor,
                                        size: 16.sp,
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // END DATE & TIME
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 0.5.h),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        endDate != null 
                                            ? formatDate(endDate)
                                            : 'نادیار',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Material1.primaryColor,
                                        ),
                                      ),
                                      SizedBox(width: 2.w),
                                      Text(
                                        'بۆ:',
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(width: 1.w),
                                      Icon(
                                        Icons.calendar_today,
                                        color: Colors.red,
                                        size: 16.sp,
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Duration (Optional - shows how many days)
                                if (startDate != null && endDate != null)
                                  Container(
                                    padding: EdgeInsets.symmetric(vertical: 0.5.h),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          '${endDate.difference(startDate).inDays + 1} ڕۆژ',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            color: Colors.grey[700],
                                          ),
                                        ),
                                        SizedBox(width: 2.w),
                                        Text(
                                          'ماوە:',
                                          style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                
                                // Note
                                SizedBox(
                                  height: 6.h,
                                  child: Text(
                                    "${absenceData['note']} :تێبینی",
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.right,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                ),
                                
                                // Sound selection dropdown
                                Container(
                                  margin: EdgeInsets.only(top: 1.h),
                                  height: 6.h,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: 5.h,
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
                                          items: list.map<DropdownMenuItem<String>>((String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5.h,
                                        width: 30.w,
                                        child: Center(
                                          child: Text(
                                            'هەڵبژاردنی دەنگ',
                                            style: TextStyle(fontSize: 14.sp),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                
                                // Accept/Reject buttons
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  children: [
                                    TextButton(
                                      onPressed: () async {
                                        // ... your existing accept logic
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

                                        await FirebaseFirestore.instance
                                            .collection('user')
                                            .doc(email)
                                            .collection('absentmanagement')
                                            .doc(snapshot.data!.docs[index].id)
                                            .update({'status': 'accepted'});

                                        if (startDate != null && endDate != null) {
                                          await _deleteTasksForAbsence(email, startDate, endDate);
                                        }

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

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(
                                            content: Text('مۆڵەت قبوڵکرا و ئەرکەکان سڕانەوە'),
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
                                          color: Colors.green,
                                        ),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        // ... your existing reject logic
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

                                        await FirebaseFirestore.instance
                                            .collection('user')
                                            .doc(email)
                                            .collection('absentmanagement')
                                            .doc(snapshot.data!.docs[index].id)
                                            .update({'status': 'rejected'});

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

                                        ScaffoldMessenger.of(context).showSnackBar(
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