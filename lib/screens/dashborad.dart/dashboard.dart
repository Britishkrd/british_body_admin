// ignore_for_file: use_build_context_synchronously

import 'dart:math';

import 'package:british_body_admin/screens/auth/login.dart';
import 'package:british_body_admin/screens/dashborad.dart/absentmanagement/absentmanagement.dart';
import 'package:british_body_admin/screens/dashborad.dart/absentmanagement/acceptingabsence.dart';
import 'package:british_body_admin/screens/dashborad.dart/feedback/adminfeedback.dart/admincreatedfeedback.dart';
import 'package:british_body_admin/screens/dashborad.dart/feedback/adminfeedback.dart/adminfeedback.dart';
import 'package:british_body_admin/screens/dashborad.dart/feedback/employeefeedback/employeefeedback.dart';
import 'package:british_body_admin/screens/dashborad.dart/loginlogout/choosinguseroforloginlogout.dart';
import 'package:british_body_admin/screens/dashborad.dart/loginlogout/self-login/viewingselfloginlogout.dart';
import 'package:british_body_admin/screens/dashborad.dart/reward-punishment-management/choosinguser.dart';
import 'package:british_body_admin/screens/dashborad.dart/reward-punishment-management/viewingrewardpunishment.dart';
import 'package:british_body_admin/screens/dashborad.dart/salary/givingsalary/choosingusertogivesalary.dart';
import 'package:british_body_admin/screens/dashborad.dart/salary/receivingsalary/choosingmonthtoreceiversalary.dart';
import 'package:british_body_admin/screens/dashborad.dart/loan/acceptingloan/acceptingloan.dart';
import 'package:british_body_admin/screens/dashborad.dart/target/admintarget/choosinguserfortarget.dart';
import 'package:british_body_admin/screens/dashborad.dart/target/selftarget/selftargetview.dart';
import 'package:british_body_admin/screens/dashborad.dart/taskmanagement/addingowntask.dart';
import 'package:british_body_admin/screens/dashborad.dart/taskmanagement/admin-task-management/choosinguserfortaskmanagement.dart';
import 'package:british_body_admin/screens/dashborad.dart/taskmanagement/viewingtaskdetails/choosinguserfortaskdetails.dart';
import 'package:british_body_admin/sharedprefrences/sharedprefernences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../../material/materials.dart';
import 'loan/loan.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  @override
  void initState() {
    getuserinfo();
    super.initState();
  }

  String name = '';
  String phonenumber = '';
  String gender = '';
  String city = '';
  String job = 'job';
  String email = '';
  bool chekedin = false;

  getuserinfo() async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    setState(() {
      name = preference.getString('name') ?? '';
      phonenumber = preference.getString('phonenumber') ?? '';
      email = preference.getString('email') ?? '';
      chekedin = preference.getBool('checkin') ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 80.h,
              child: GridView(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 4 / 3,
                  crossAxisSpacing: 0,
                  mainAxisSpacing: 0,
                ),
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return AbsentManagement(email: email);
                      }));
                    },
                    child: controlpanelcard(Icons.more_time, 'مۆڵەت'),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Acceptingabsence();
                      }));
                    },
                    child: controlpanelcard(Icons.more_time, 'قبوڵکردنی مۆڵەت'),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return AddingOwnTask(email: email);
                      }));
                    },
                    child: controlpanelcard(
                        Icons.task_outlined, 'زیادکردنی ئەرک بۆ خۆم'),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ChoosingUserFoTaskManagement(email: email);
                      }));
                    },
                    child: controlpanelcard(
                        Icons.task_alt, 'زیادکردنی ئەرک وەک ئەدمین'),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return ChoosingUserToViewTaskDetails(email: email);
                      }));
                    },
                    child: controlpanelcard(
                        Icons.task_alt, 'بینینی وردەکاری کارەکان'),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Choosinguser(email: email);
                      }));
                    },
                    child: controlpanelcard(
                        Icons.card_giftcard_outlined, 'زیادکردنی پاداشت و سزا'),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Viewingrewardpunishment(email: email);
                      }));
                    },
                    child: controlpanelcard(
                        Icons.card_giftcard_sharp, 'بینینی پاداشت و سزاکانت'),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return LoanManagement(email: email);
                      }));
                    },
                    child: controlpanelcard(Icons.money, 'سولفە'),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return AcceptingLoan();
                      }));
                    },
                    child: controlpanelcard(
                        Icons.monetization_on_outlined, 'قبۆڵکردنی سولفە'),
                  ),
                  GestureDetector(
                    onTap: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ChoosingUserForGivingSalary(email: email)));
                    },
                    child:
                        controlpanelcard(Icons.monetization_on, 'پێدانی موچە'),
                  ),
                  GestureDetector(
                    onTap: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ChoosingMonthToReceiveSalary(email: email)));
                    },
                    child:
                        controlpanelcard(Icons.attach_money, 'وەرگرتنی موچە'),
                  ),
                  GestureDetector(
                    onTap: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ChoosingUseroForLoginLogout(email: email)));
                    },
                    child: controlpanelcard(
                        Icons.login_sharp, 'چوونەژوورەوە / دەرچوونەوە'),
                  ),
                  GestureDetector(
                    onTap: () async {
                      showMonthRangePicker(
                        context: context,
                        firstDate: DateTime(DateTime.now().year - 1, 1),
                        rangeList: false,
                      ).then((List<DateTime>? dates) {
                        if (dates == null) {
                          return;
                        }
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return Viewingselfloginlogout(
                            date: dates[0],
                            email: email,
                          );
                        }));
                      });
                    },
                    child: controlpanelcard(
                        Icons.login, 'بینینی چوونەژوورەوە / دەرچوونەوە'),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Employeefeedback(email: email);
                      }));
                    },
                    child: controlpanelcard(Icons.feedback, 'ڕەخنە و پێشنیار'),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Adminfeedback(
                          email: email,
                        );
                      }));
                    },
                    child: controlpanelcard(
                        Icons.feedback, 'ڕەخنە و پێشنیار بۆ ئەدمین'),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Selftargetview(
                          email: email,
                        );
                      }));
                    },
                    child: controlpanelcard(
                        Icons.track_changes_outlined, 'تارگێتەکان'),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Choosinguserfortarget(
                          email: email,
                        );
                      }));
                    },
                    child: controlpanelcard(
                        Icons.track_changes_outlined, 'تارگێت بۆ ئەدمین'),
                  ),
                  GestureDetector(
                    onTap: () async {
                      await getuserinfo();
                      if (chekedin) {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('هەڵە'),
                                content: Text('تکایە چوونەدەرەووە بکە'),
                                actions: [
                                  Material1.button(
                                      label: 'باشە',
                                      buttoncolor: Material1.primaryColor,
                                      textcolor: Colors.white,
                                      function: () {
                                        Navigator.pop(context);
                                      }),
                                ],
                              );
                            });
                        return;
                      }
                      Sharedpreference.setuser('', '', '', 'aa', 'aa', 'aa', 0,
                          0, 0, 0, false, '', false, []);
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return Login();
                      }));
                    },
                    child: controlpanelcard(Icons.logout, 'دەرچوون'),
                  ),
                  GestureDetector(
                    onTap: () async {
                      // final FirebaseFirestore firestore =
                      //     FirebaseFirestore.instance;
                      // final CollectionReference checkinCheckouts = firestore
                      //     .collection('user')
                      //     .doc(email)
                      //     .collection('checkincheckouts');

                      // final DateTime startDate =
                      //     DateTime(2024, 8, 1); // Start date (6 months ago)
                      // final DateTime endDate =
                      //     DateTime(2025, 2, 1); // End date (current date)
                      // final Duration oneDay = Duration(days: 1);
                      // final Duration workDayDuration =
                      //     Duration(hours: 8); // 8-hour workday

                      // DateTime currentDate = startDate;

                      // while (currentDate.isBefore(endDate)) {
                      //   if (currentDate.weekday != DateTime.friday) {
                      //     // Simulate check-in
                      //     await checkinCheckouts
                      //         .doc(currentDate.toIso8601String())
                      //         .set({
                      //       'checkin': true,
                      //       'checkout': false,
                      //       'latitude': 35.5830867,
                      //       'longtitude': 45.4259767,
                      //       'note': 'test',
                      //       'time': Timestamp.fromDate(currentDate),
                      //     });

                      //     // Simulate check-out
                      //     await checkinCheckouts
                      //         .doc((currentDate.add(workDayDuration))
                      //             .toIso8601String())
                      //         .set({
                      //       'checkin': false,
                      //       'checkout': true,
                      //       'latitude': 35.5830867,
                      //       'longtitude': 45.4259767,
                      //       'note': 'test',
                      //       'time': Timestamp.fromDate(
                      //           currentDate.add(workDayDuration)),
                      //     });
                      //   }

                      //   currentDate = currentDate.add(oneDay);
                      // }
                    },
//                       tz.initializeTimeZones();
//                       tz.setLocalLocation(tz.getLocation('Asia/Baghdad'));
//                       FlutterLocalNotificationsPlugin
//                           flutterLocalNotificationsPlugin =
//                           FlutterLocalNotificationsPlugin();
//                       await flutterLocalNotificationsPlugin.zonedSchedule(
//                           0,
//                           'scheduled title',
//                           'scheduled body',
//                           tz.TZDateTime(
//                               tz.local,
//                               DateTime.now().year,
//                               DateTime.now().month,
//                               DateTime.now().day,
//                               DateTime.now().hour,
//                               DateTime.now().minute,
//                               DateTime.now().second + 10),
//                           const NotificationDetails(
//                               android: AndroidNotificationDetails(
//                                   'your channel id', 'your channel name',
//                                   channelDescription:
//                                       'your channel description')),
//                           androidScheduleMode:
//                               AndroidScheduleMode.exactAllowWhileIdle,
//                           uiLocalNotificationDateInterpretation:
//                               UILocalNotificationDateInterpretation
//                                   .absoluteTime);
// // Schedule a notification that specifies a different schedule time than the default

//                       const AndroidNotificationDetails androidDetails =
//                           AndroidNotificationDetails(
//                         'daily_channel_id',
//                         'Daily Notifications',
//                         channelDescription:
//                             'Sends notifications at a fixed time every day',
//                         importance: Importance.high,
//                         priority: Priority.high,
//                       );

//                       const NotificationDetails notificationDetails =
//                           NotificationDetails(android: androidDetails);

//                       // Set the time for 1:00 AM
//                       final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
//                       tz.TZDateTime scheduledDate = tz.TZDateTime(
//                           tz.local, now.year, now.month, now.day, 21, 22);

//                       if (scheduledDate.isBefore(now)) {
//                         scheduledDate = scheduledDate.add(Duration(days: 1));
//                       }

//                       await flutterLocalNotificationsPlugin.zonedSchedule(
//                         5, // Notification ID
//                         'Daily Reminder',
//                         'This is your scheduled notification!',
//                         scheduledDate,
//                         notificationDetails,
//                         androidScheduleMode:
//                             AndroidScheduleMode.exactAllowWhileIdle,
//                         uiLocalNotificationDateInterpretation:
//                             UILocalNotificationDateInterpretation.absoluteTime,
//                         matchDateTimeComponents: DateTimeComponents.time,
//                       );
                    // },
                    child: controlpanelcard(Icons.logout, 'notification'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget controlpanelcard(IconData icon, String name) {
    return Container(
        margin: EdgeInsets.only(left: 2.w, right: 2.w, top: 3.w, bottom: 0.w),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(20)),
          color: Material1.primaryColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha(150),
              spreadRadius: 1,
              blurRadius: 3,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 10.h,
              child: Icon(icon, color: Material1.secondary, size: 30.sp),
            ),
            Container(
              alignment: Alignment.center,
              width: 100.w,
              height: 6.h,
              child: Text(
                name,
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ));
  }
}
