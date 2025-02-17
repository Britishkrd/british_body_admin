import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:british_body_admin/screens/checkincheckout/checkinandout.dart';
import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/dashborad.dart/dashboard.dart';
import 'package:british_body_admin/screens/email/email.dart';
import 'package:british_body_admin/screens/profile/profile.dart';
import 'package:british_body_admin/screens/tasks/tasks.dart';
import 'package:flutter/material.dart';

class Navigation extends StatefulWidget {
  final String email;
  const Navigation({super.key, required this.email});

  @override
  State<Navigation> createState() => _NavigationState();
}

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

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Material1.primaryColor,
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
                    ? Checkinandout()
                    : _bottomNavIndex == 1
                        ? Tasks(
                            email: widget.email,
                          )
                        : Email(
                            email: widget.email,
                          ));
  }
}
