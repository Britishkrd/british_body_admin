// ignore_for_file: use_build_context_synchronously

import 'dart:developer';

import 'package:british_body_admin/screens/auth/login.dart';
import 'package:british_body_admin/screens/dashborad.dart/absentmanagement/absentmanagement.dart';
import 'package:british_body_admin/screens/dashborad.dart/absentmanagement/acceptingabsence.dart';
import 'package:british_body_admin/screens/dashborad.dart/addingnotes/choosingtaskforaddingnotes.dart';
import 'package:british_body_admin/screens/dashborad.dart/alert/viewingalerts.dart';
import 'package:british_body_admin/screens/dashborad.dart/changingworkerphone/changingworkerphone.dart';
import 'package:british_body_admin/screens/dashborad.dart/feedback/adminfeedback.dart/adminfeedback.dart';
import 'package:british_body_admin/screens/dashborad.dart/feedback/employeefeedback/employeefeedback.dart';
import 'package:british_body_admin/screens/dashborad.dart/loginlogout/choosinguseroforloginlogout.dart';
import 'package:british_body_admin/screens/dashborad.dart/loginlogout/self-login/viewingselfloginlogout.dart';
import 'package:british_body_admin/screens/dashborad.dart/reward-punishment-management/choosinguser.dart';
import 'package:british_body_admin/screens/dashborad.dart/reward-punishment-management/viewingrewardpunishment.dart';
import 'package:british_body_admin/screens/dashborad.dart/rulesandguidelines/adminrules.dart';
import 'package:british_body_admin/screens/dashborad.dart/rulesandguidelines/choosingdept.dart';
import 'package:british_body_admin/screens/dashborad.dart/salary/givingsalary/choosingusertogivesalary.dart';
import 'package:british_body_admin/screens/dashborad.dart/salary/receivingsalary/choosingmonthtoreceiversalary.dart';
import 'package:british_body_admin/screens/dashborad.dart/loan/acceptingloan/acceptingloan.dart';
import 'package:british_body_admin/screens/dashborad.dart/selftaskview/selftaskview.dart';
import 'package:british_body_admin/screens/dashborad.dart/sound-preview/soundpreview.dart';
import 'package:british_body_admin/screens/dashborad.dart/target/admintarget/choosinguserfortarget.dart';
import 'package:british_body_admin/screens/dashborad.dart/target/selftarget/selftargetview.dart';
import 'package:british_body_admin/screens/dashborad.dart/taskmanagement/addingowntask.dart';
import 'package:british_body_admin/screens/dashborad.dart/taskmanagement/admin-task-management/choosinguserfortaskmanagement.dart';
import 'package:british_body_admin/screens/dashborad.dart/taskmanagement/viewingtaskdetails/choosinguserfortaskdetails.dart';
import 'package:british_body_admin/screens/dashborad.dart/worktime/adminacceptingchangeworktime.dart';
import 'package:british_body_admin/screens/dashborad.dart/worktime/viewchangeworktimerequest.dart';
import 'package:british_body_admin/sharedprefrences/sharedprefernences.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../../material/materials.dart';
import 'adduser/choosinguserforusermanagement.dart';
import 'alert/choosinguserforalerts.dart';
import 'emplyeetracking/emplyeetacking.dart';
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
  List permissions = [];

  getuserinfo() async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    setState(() {
      name = preference.getString('name') ?? '';
      phonenumber = preference.getString('phonenumber') ?? '';
      email = preference.getString('email') ?? '';
      chekedin = preference.getBool('checkin') ?? false;
      permissions = preference.getStringList('permissions') ?? [];
    });
  }

  List<Color> colors = List.generate(50, (index) => Color(0xff04839f));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getcolors();
  }

  getcolors() async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    for (var i = 0; i < 50; i++) {
      colors[i] = Color(preference.getInt('color$i') ?? 0xff04839f);
    }
    setState(() {
      colors = colors;
    });
  }

// TODO: use 30 for the index of new widget
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
                        return Emplyeetacking(
                          email: email,
                        );
                      }));
                    },
                    child: controlpanelcard(
                        Icons.keyboard_voice, 'ناردنی ڤۆیس', 0),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return AbsentManagement(email: email);
                      }));
                    },
                    child: controlpanelcard(Icons.more_time, 'مۆڵەت', 1),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return AddingOwnTask(email: email);
                      }));
                    },
                    child: controlpanelcard(
                        Icons.task_outlined, 'زیادکردنی ئەرک بۆ خۆم', 2),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Choosingtaskforaddingnotes(email: email);
                      }));
                    },
                    child: controlpanelcard(
                        Icons.note_add, 'زیادکردنی تێبینی بۆ ئەرکەکانی خۆم', 3),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Viewingalerts(email: email);
                      }));
                    },
                    child: controlpanelcard(Icons.alarm_add, 'ئاگاداریەکان', 4),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Viewchangeworktimerequest(email: email);
                      }));
                    },
                    child: controlpanelcard(
                        Icons.work_history, 'گۆڕینی کارتی کار', 5),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Viewingrewardpunishment(email: email);
                      }));
                    },
                    child: controlpanelcard(Icons.card_giftcard_sharp,
                        'بینینی پاداشت و سزاکانت', 6),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return LoanManagement(email: email);
                      }));
                    },
                    child: controlpanelcard(Icons.money, 'سولفە', 7),
                  ),
                  GestureDetector(
                    onTap: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  ChoosingMonthToReceiveSalary(email: email)));
                    },
                    child: controlpanelcard(
                        Icons.attach_money, 'وەرگرتنی موچە', 8),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Selftargetview(
                          email: email,
                          adminview: false,
                        );
                      }));
                    },
                    child: controlpanelcard(
                        Icons.track_changes_outlined, 'تارگێتەکان', 9),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Selftaskview(email: email);
                      }));
                    },
                    child: controlpanelcard(Icons.add_task_outlined,
                        'بینینی وەردەکاری کارەکان', 29),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Choosingdepttoaddsub(
                          isaddingrule: false,
                          email: email,
                          isemployee: true,
                          isdelete: false,
                          isdeprtmentdelete: false,
                          isaddingsubdeptrule: false,
                          isviewingrules: true,
                          issubdeptdelete: false,
                        );
                      }));
                    },
                    child: controlpanelcard(Icons.rule, 'یاسا و ڕێساکان', 10),
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
                        Icons.login, 'بینینی چوونەژوورەوە / دەرچوونەوە', 11),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Employeefeedback(email: email);
                      }));
                    },
                    child:
                        controlpanelcard(Icons.feedback, 'ڕەخنە و پێشنیار', 12),
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
                          0, 0, 0, 0, 0, 0, 0, false, '', false, [], []);
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return Login();
                      }));
                    },
                    child: controlpanelcard(Icons.logout, 'دەرچوون', 13),
                  ),
                  if (permissions.contains('accepting absence'))
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return Acceptingabsence();
                        }));
                      },
                      child: controlpanelcard(
                          Icons.more_time, 'قبوڵکردنی مۆڵەت', 14),
                    ),
                  if (permissions.contains('viewing task detail'))
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return ChoosingUserToViewTaskDetails(email: email);
                        }));
                      },
                      child: controlpanelcard(
                          Icons.task_alt, 'بینینی وردەکاری کارەکان', 15),
                    ),
                  if (permissions.contains('adding task'))
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return ChoosingUserFoTaskManagement(email: email);
                        }));
                      },
                      child: controlpanelcard(
                          Icons.task_alt, 'زیادکردنی ئەرک وەک ئەدمین', 16),
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
                          return Adminacceptingchangeworktime();
                        }));
                      },
                      child: controlpanelcard(
                          Icons.work_history, 'گۆڕینی کارتی کار بۆ ئەدمین', 18),
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
                          return AcceptingLoan();
                        }));
                      },
                      child: controlpanelcard(Icons.monetization_on_outlined,
                          'قبۆڵکردنی سولفە', 20),
                    ),
                  if (permissions.contains('giving salary'))
                    GestureDetector(
                      onTap: () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    ChoosingUserForGivingSalary(email: email)));
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
                                    ChoosingUseroForLoginLogout(email: email)));
                      },
                      child: controlpanelcard(
                          Icons.login_sharp, 'چوونەژوورەوە / دەرچوونەوە', 22),
                    ),
                  if (permissions.contains('setting feedback'))
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
                          Icons.feedback, 'ڕەخنە و پێشنیار بۆ ئەدمین', 23),
                    ),
                  if (permissions.contains('setting target'))
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
                          Icons.track_changes_outlined, 'تارگێت بۆ ئەدمین', 24),
                    ),
                  if (permissions.contains('add user'))
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return Choosinguserforusermanagement(
                            email: email,
                          );
                        }));
                      },
                      child: controlpanelcard(
                          Icons.group_add, 'زیاد کردنی بەکار هێنەر', 25),
                    ),
                  if (permissions.contains('changing worker phone'))
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return Changingworkerphone();
                        }));
                      },
                      child: controlpanelcard(
                          Icons.phone_iphone, 'گۆڕینی مۆبایلی کارمەند', 26),
                    ),
                  if (permissions.contains('adding rules'))
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return Adminrules(
                            email: email,
                          );
                        }));
                      },
                      child:
                          controlpanelcard(Icons.category_sharp, 'یاساکان', 27),
                    ),
                  if (permissions.contains('testing sounds'))
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) {
                          return Soundpreview();
                        }));
                      },
                      child: controlpanelcard(Icons.music_note, 'دەنگەکان', 28),
                    ),
                ],
              ),
            ),
          ],
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
                    style: TextStyle(
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
              Color pickerColor = Color(0xff04839f);
              Color changeColor = Color(0xff04839f);
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: const Text('Pick a color!'),
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
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(10)),
                color: Colors.white,
              ),
              child: Icon(Icons.color_lens),
            ),
          ),
        )
      ],
    );
  }
}
