import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/checkincheckout/check_in_out_screen.dart';
import 'package:british_body_admin/screens/dashborad.dart/dashboard.dart';
import 'package:british_body_admin/screens/email/email.dart';
import 'package:british_body_admin/screens/notifications/notifications.dart';
import 'package:british_body_admin/screens/profile/profile.dart';
import 'package:british_body_admin/screens/tasks/tasks.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Navigation extends StatefulWidget {
  final String email;
  const Navigation({super.key, required this.email});

  @override
  State<Navigation> createState() => _NavigationState();
}

bool checkin = true;
double latitude = 0.0;
double longtitude = 0.0;
double worklatitude = 0.0;
double worklongtitude = 0.0;

TextEditingController notecontroller = TextEditingController();

String email = '';
List permissions = [];

class _NavigationState extends State<Navigation> {
  int _bottomNavIndex = 2;
  @override
  Widget build(BuildContext context) {
    final List<IconData> iconList = <IconData>[
      Icons.email,
      Icons.task,
      Icons.timelapse,
      Icons.person,
      Icons.dashboard,
    ];
    getuserinfo() async {
      final SharedPreferences preference =
          await SharedPreferences.getInstance();
      email = preference.getString('email') ?? '';
      checkin = preference.getBool('checkin') ?? false;
      permissions = preference.getStringList('permissions') ?? [];
      worklatitude = preference.getDouble('worklat') ?? 0.0;
      worklongtitude = preference.getDouble('worklong') ?? 0.0;
    }

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Material1.primaryColor,
          title: const Text('British Body Admin'),
          foregroundColor: Colors.white,
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: () async {
                  await getuserinfo();
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return const Notifications();
                  }));
                },
                icon: const Icon(Icons.notifications, color: Colors.white))
          ],
        ),
        bottomNavigationBar: AnimatedBottomNavigationBar(
          activeColor: Material1.primaryColor,
          icons: iconList,
          activeIndex: _bottomNavIndex,
          leftCornerRadius: 0,
          rightCornerRadius: 0,
          onTap: (index) async {
            await getuserinfo();
            setState(() {
              _bottomNavIndex = index;
            });
          },
          gapWidth: 0,
        ),
        body: _bottomNavIndex == 4
            ? Dashboard()
            : _bottomNavIndex == 3
                ? const Profile()
                : _bottomNavIndex == 2
                    ? CheckInOutScreen()
                    : _bottomNavIndex == 1
                        ? Tasks(
                            email: widget.email,
                          )
                        : Email(
                            email: widget.email,
                          ));
  }
}
