// ignore_for_file: use_build_context_synchronously

import 'package:british_body_admin/screens/auth/login.dart';
import 'package:british_body_admin/screens/dashborad.dart/absentmanagement/absentmanagement.dart';
import 'package:british_body_admin/sharedprefrences/sharedprefernences.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../../material/materials.dart';

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
                    child:
                        controlpanelcard(Icons.more_time, 'absent management'),
                  ),
                  GestureDetector(
                    onTap: () {},
                    child:
                        controlpanelcard(Icons.done_all_outlined, 'donejobs'),
                  ),
                  GestureDetector(
                    onTap: () {
                      Sharedpreference.setuser(
                          '', '', '', 'aa', 'aa', 'aa', 0, 0, false, '', false);
                      Navigator.push(context,
                          MaterialPageRoute(builder: (context) {
                        return Login();
                      }));
                    },
                    child: controlpanelcard(Icons.logout, 'logout'),
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
              color: Colors.grey.withAlpha(50),
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
