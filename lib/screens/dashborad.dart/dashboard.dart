// ignore_for_file: use_build_context_synchronously

import 'package:british_body_admin/screens/auth/login.dart';
import 'package:british_body_admin/screens/dashborad.dart/absentmanagement/absentmanagement.dart';
import 'package:british_body_admin/screens/dashborad.dart/absentmanagement/acceptingabsence.dart';
import 'package:british_body_admin/screens/dashborad.dart/adding-reward-punishment/choosinguser.dart';
import 'package:british_body_admin/screens/dashborad.dart/loan/acceptingloan/acceptingloan.dart';
import 'package:british_body_admin/screens/dashborad.dart/taskmanagement/addingowntask.dart';
import 'package:british_body_admin/screens/dashborad.dart/taskmanagement/admin-task-management/choosinguserfortaskmanagement.dart';
import 'package:british_body_admin/sharedprefrences/sharedprefernences.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

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

  getuserinfo() async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    setState(() {
      name = preference.getString('name') ?? '';
      phonenumber = preference.getString('phonenumber') ?? '';
      email = preference.getString('email') ?? '';
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
              height: 75.h,
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
                    onTap: () {
                      Sharedpreference.setuser('', '', '', 'aa', 'aa', 'aa', 0,
                          0, 0, 0, false, '', false, []);
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (context) {
                        return Login();
                      }));
                    },
                    child: controlpanelcard(Icons.logout, 'دەرچوون'),
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
          children: [
            SizedBox(
              height: 10.h,
              child: Icon(icon, color: Material1.secondary, size: 30.sp),
            ),
            Text(
              name,
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
            ),
          ],
        ));
  }
}
