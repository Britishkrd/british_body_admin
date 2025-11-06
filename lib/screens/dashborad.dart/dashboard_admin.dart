import 'dart:developer';

import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/auth/login_screen.dart';
import 'package:british_body_admin/screens/dashborad.dart/absentmanagement/acceptingabsence.dart';
import 'package:british_body_admin/screens/dashborad.dart/changingworkerphone/changingworkerphone.dart';
import 'package:british_body_admin/screens/dashborad.dart/feedback/adminfeedback.dart/adminfeedback.dart';
import 'package:british_body_admin/screens/dashborad.dart/holiday/holiday_management_screen.dart';
import 'package:british_body_admin/screens/dashborad.dart/loan/acceptingloan/acceptingloan.dart';
import 'package:british_body_admin/screens/dashborad.dart/loginlogout/choosinguseroforloginlogout.dart';
import 'package:british_body_admin/screens/dashborad.dart/map/map_picker.dart';
import 'package:british_body_admin/screens/dashborad.dart/map/user_map_screen.dart';
import 'package:british_body_admin/screens/dashborad.dart/reward-punishment-management/choosinguser.dart';
import 'package:british_body_admin/screens/dashborad.dart/rulesandguidelines/adminrules.dart';
import 'package:british_body_admin/screens/dashborad.dart/salary/givingsalary/choosingusertogivesalary.dart';
import 'package:british_body_admin/screens/dashborad.dart/target/admintarget/choosinguserfortarget.dart';
import 'package:british_body_admin/screens/dashborad.dart/taskmanagement/admin-task-management/choosinguserfortaskmanagement.dart';
import 'package:british_body_admin/screens/dashborad.dart/taskmanagement/ehsan_task/admin/choose_user_tasks.dart';
import 'package:british_body_admin/screens/dashborad.dart/user-status/userstatus.dart';
import 'package:british_body_admin/screens/dashborad.dart/worktime/adminacceptingchangeworktime.dart';
import 'package:british_body_admin/sharedprefrences/sharedprefernences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import 'adduser/choosinguserforusermanagement.dart';
import 'alert/choosinguserforalerts.dart';

class DashboardAdmin extends StatefulWidget {
  const DashboardAdmin({super.key});

  @override
  State<DashboardAdmin> createState() => _DashboardAdminState();
}

class _DashboardAdminState extends State<DashboardAdmin> {
  String name = '';
  String phonenumber = '';
  String gender = '';
  String city = '';
  String job = 'job';
  String email = '';
  bool chekedin = false;
  List<String> permissions = [];
  bool isLoading = true; // Add loading state

  @override
  void initState() {
    super.initState();
    getuserinfo();
  }

  Future<void> getuserinfo() async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    setState(() {
      name = preference.getString('name') ?? '';
      phonenumber = preference.getString('phonenumber') ?? '';
      email = preference.getString('email') ?? '';
      chekedin = preference.getBool('checkin') ?? false;
      permissions = preference.getStringList('permissions') ?? [];
      isLoading = false; // Set loading to false after fetching
    });
  }

  List<Color> colors = List.generate(50, (index) => const Color(0xff04839f));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getcolors();
  }

  Future<void> getcolors() async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    for (var i = 0; i < 50; i++) {
      colors[i] = Color(preference.getInt('color$i') ?? 0xff04839f);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while fetching email
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Check if email is empty
    if (email.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No user email found. Please log in again.'),
              Material1.button(
                label: 'Go to Login',
                buttoncolor: Material1.primaryColor,
                textcolor: Colors.white,
                function: () {
                  Sharedpreference.setuser('', '', '', 'aa', 0, 'aa', 0, 0, 0,
                      0, 0, 0, 0, 0, false, '', false, [], []);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (context) {
                    return const LoginScreen();
                  }));
                },
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('user')
              .doc(email)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading permissions'));
            }
            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('User data not found'));
            }

            // Update permissions from Firestore
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            permissions = List<String>.from(userData['permissions'] ?? []);

            // Optionally update SharedPreferences
            SharedPreferences.getInstance().then((prefs) {
              prefs.setStringList('permissions', permissions);
            });

            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 80.h,
                  child: GridView(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 4 / 3,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                    ),
                    children: [
                      if (permissions.contains('adding task'))
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ChoosingUserFoTaskManagement(email: email);
                            }));
                          },
                          child: controlpanelcard(Icons.note_add_outlined,
                              'زیادکردنی ئەرک بۆ کارمەندان', 16),
                        ),
                      if (permissions.contains('adding task'))
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return ChooseUserForTasks(
                                    adminEmail: email,
                                  );
                                },
                              ),
                            );
                          },
                          child: controlpanelcard(Icons.task_outlined,
                              'بینینی ئەرکی کارمەندەکان', 36),
                        ),

                      if (permissions.contains('adding rules'))
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return Adminrules(email: email);
                            }));
                          },
                          child: controlpanelcard(
                              Icons.category_sharp, 'یاساکان', 27),
                        ),

                      if (permissions.contains('accepting absence'))
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const Acceptingabsence();
                            }));
                          },
                          child: controlpanelcard(
                              Icons.more_time, 'قبوڵکردنی مۆڵەت', 14),
                        ),

                      if (permissions.contains('sending alert'))
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return Choosingforalerts(email: email);
                            }));
                          },
                          child: controlpanelcard(
                              Icons.alarm_add, 'ناردنی ئاگادارکردنەوە', 17),
                        ),
                      if (permissions.contains('accepting change time'))
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const Adminacceptingchangeworktime();
                            }));
                          },
                          child: controlpanelcard(Icons.work_history,
                              'گۆڕینی کاتی کار بۆ ئەدمین', 18),
                        ),
                      if (permissions.contains('reward and punishment'))
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return Choosinguser(email: email);
                            }));
                          },
                          child: controlpanelcard(Icons.card_giftcard_outlined,
                              'زیادکردنی پاداشت و سزا', 19),
                        ),
                      if (permissions.contains('accepting loan'))
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const AcceptingLoan();
                            }));
                          },
                          child: controlpanelcard(
                              Icons.monetization_on_outlined,
                              'قبۆڵکردنی سولفە',
                              20),
                        ),
                      if (permissions.contains('giving salary'))
                        GestureDetector(
                          onTap: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ChoosingUserForGivingSalary(
                                            email: email)));
                          },
                          child: controlpanelcard(
                              Icons.monetization_on, 'پێدانی موچە', 21),
                        ),
                      if (permissions.contains('login and logout'))
                        GestureDetector(
                          onTap: () async {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ChoosingUseroForLoginLogout(
                                            email: email)));
                          },
                          child: controlpanelcard(Icons.login_sharp,
                              'چوونەژوورەوە / دەرچوونەوە', 22),
                        ),
                      if (permissions.contains('setting feedback'))
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return Adminfeedback(email: email);
                            }));
                          },
                          child: controlpanelcard(
                              Icons.feedback, 'ڕەخنە و پێشنیار بۆ ئەدمین', 23),
                        ),
                      if (permissions.contains('setting target'))
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return Choosinguserfortarget(email: email);
                            }));
                          },
                          child: controlpanelcard(Icons.track_changes_outlined,
                              'تارگێت بۆ ئەدمین', 24),
                        ),
                      if (permissions.contains('add user'))
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return Choosinguserforusermanagement(
                                  email: email);
                            }));
                          },
                          child: controlpanelcard(
                              Icons.group_add, 'کارمەندەکان', 25),
                        ),
                      if (permissions.contains('changing worker phone'))
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return const Changingworkerphone();
                            }));
                          },
                          child: controlpanelcard(
                              Icons.phone_iphone, 'گۆڕینی مۆبایلی کارمەند', 26),
                        ),

                      if (permissions.contains('user status'))
                        GestureDetector(
                          onTap: () async {
                            Map<String, bool> haslogedintoday = {};
                            FirebaseFirestore.instance
                                .collection('user')
                                .get()
                                .then(
                              (value) async {
                                for (var element in value.docs) {
                                  await FirebaseFirestore.instance
                                      .collection('user')
                                      .doc(element['email'])
                                      .collection('checkincheckouts')
                                      .orderBy('time', descending: true)
                                      .limit(1)
                                      .get()
                                      .then((value2) {
                                    if (value2.docs.isNotEmpty) {
                                      if ((value2.docs.first.data()['time']
                                                  as Timestamp)
                                              .toDate()
                                              .day ==
                                          DateTime.now().day) {
                                        haslogedintoday[element['email']] =
                                            true;
                                      } else {
                                        haslogedintoday[element['email']] =
                                            false;
                                      }
                                    } else {
                                      haslogedintoday[element['email']] = false;
                                    }
                                  });
                                }
                              },
                            ).then((value) {
                              log(haslogedintoday.toString());
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return UsersStatus(
                                  email: email,
                                  haslogeding: haslogedintoday,
                                );
                              }));
                            });
                          },
                          child: controlpanelcard(
                              Icons.person_off_sharp, 'بارو دۆخی کارمەند', 30),
                        ),
                      if (permissions.contains('holiday management'))
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const HolidayManagementScreen();
                                },
                              ),
                            );
                          },
                          child: controlpanelcard(
                              Icons.beach_access, 'پشووە فەڕمییەکان', 32),
                        ),
                      if (permissions.contains('view user location'))
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const UsersMapView();
                                },
                              ),
                            );
                          },
                          child: controlpanelcard(Icons.location_on_outlined,
                              'شوێنی کارمەندەکان', 34),
                        ),
                      if (permissions.contains('view user location'))
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return const PlacePickerScreen();
                                },
                              ),
                            );
                          },
                          child: controlpanelcard(Icons.add_location_outlined,
                              'British Body لقەکانی', 35),
                        ),

                      // Material1.button(
                      //   label: 'View User Tasks',
                      //   buttoncolor: Material1.primaryColor,
                      //   textcolor: Colors.white,
                      //   function: () {
                      //     Navigator.push(
                      //       context,
                      //       MaterialPageRoute(
                      //         builder: (context) =>
                      //             ChooseUserForTasks(adminEmail: email),
                      //       ),
                      //     );
                      //   },
                      // ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget controlpanelcard(IconData icon, String name, int index) {
    return Stack(
      children: [
        Container(
            margin:
                EdgeInsets.only(left: 2.w, right: 2.w, top: 3.w, bottom: 0.w),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(20)),
              color: colors[index],
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
                  child: Icon(icon,
                      color: const Color.fromARGB(205, 26, 26, 26),
                      size: 30.sp),
                ),
                Container(
                  margin: EdgeInsets.only(top: 0.5.h),
                  width: 100.w,
                  height: 6.h,
                  child: Text(
                    textAlign: TextAlign.center,
                    name,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            )),
        Positioned(
          top: 2.h,
          right: 2.h,
          child: GestureDetector(
            onTap: () {
              Color pickerColor = const Color(0xff04839f);
              Color changeColor = const Color(0xff04839f);
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('ڕەنگێک دیاری بکە!'),
                      content: SingleChildScrollView(
                          child: ColorPicker(
                        pickerColor: pickerColor,
                        onColorChanged: (color) {
                          changeColor = color;
                          log(changeColor.toString());
                        },
                      )),
                      actions: [
                        Material1.button(
                            label: 'باشە',
                            buttoncolor: Material1.primaryColor,
                            textcolor: Colors.white,
                            function: () async {
                              final SharedPreferences preference =
                                  await SharedPreferences.getInstance();
                              setState(() {
                                colors[index] = changeColor;
                                preference.setInt(
                                    'color$index', changeColor.value);
                              });
                              Navigator.of(context).pop();
                            }),
                      ],
                    );
                  });
            },
            child: Container(
              width: 10.w,
              height: 10.w,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                color: Colors.white,
              ),
              child: const Icon(Icons.color_lens),
            ),
          ),
        )
      ],
    );
  }
}
