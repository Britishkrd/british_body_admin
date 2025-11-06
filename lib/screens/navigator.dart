import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/checkincheckout/check_in_out_screen.dart';
import 'package:british_body_admin/screens/dashborad.dart/dashboard.dart';
import 'package:british_body_admin/screens/dashborad.dart/dashboard_admin.dart';
import 'package:british_body_admin/screens/dashborad.dart/taskmanagement/ehsan_task/employee/task_view_detail.dart';
import 'package:british_body_admin/screens/email/email.dart';
import 'package:british_body_admin/screens/notifications/notifications.dart';
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
List<dynamic> permissions = [];

class _NavigationState extends State<Navigation> {
  int _bottomNavIndex = 2;

  // -----------------------------------------------------------------
  // Build the icon list – admin icon is added only for admins
  // -----------------------------------------------------------------
  List<IconData> _buildIconList() {
    final List<IconData> base = [
      Icons.email,
      Icons.task,
      Icons.timelapse,
      Icons.dashboard, // normal Dashboard
    ];
    if (permissions.contains('isAdmin')) {
      base.add(Icons.admin_panel_settings);
    }
    return base;
  }

  // -----------------------------------------------------------------
  // Return the correct page for a given index
  // -----------------------------------------------------------------
  Widget _pageForIndex(int index) {
    final bool hasAdmin = permissions.contains('isAdmin');
    final int adminIndex = hasAdmin ? _buildIconList().length - 1 : -1;

    if (hasAdmin && index == adminIndex) {
      return DashboardAdmin();
    }

    return switch (index) {
      3 => Dashboard(),
      2 => CheckInOutScreen(),
      1 => TaskViewDetail(email: email),
      _ => Email(email: widget.email), // index 0
    };
  }

  // -----------------------------------------------------------------
  // Load user info from SharedPreferences
  // -----------------------------------------------------------------
  Future<void> _loadUserInfo() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    setState(() {
      email = pref.getString('email') ?? '';
      checkin = pref.getBool('checkin') ?? false;
      permissions = pref.getStringList('permissions') ?? [];
      worklatitude = pref.getDouble('worklat') ?? 0.0;
      worklongtitude = pref.getDouble('worklong') ?? 0.0;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserInfo(); // initial load
  }

  @override
  Widget build(BuildContext context) {
    final List<IconData> iconList = _buildIconList();

    // If the currently selected index is out of range (admin tab disappeared)
    if (_bottomNavIndex >= iconList.length) {
      _bottomNavIndex = 2; // fallback to Check-In/Out
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
              await _loadUserInfo();
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const Notifications()),
              );
            },
            icon: const Icon(Icons.notifications, color: Colors.white),
          ),
        ],
      ),
      bottomNavigationBar: AnimatedBottomNavigationBar(
        activeColor: Material1.primaryColor,
        icons: iconList,
        activeIndex: _bottomNavIndex,
        leftCornerRadius: 0,
        rightCornerRadius: 0,
        gapWidth: 0,
        onTap: (index) async {
          await _loadUserInfo(); // refresh on every tap
          setState(() => _bottomNavIndex = index);
        },
      ),
      body: _pageForIndex(_bottomNavIndex),
    );
  }
}
