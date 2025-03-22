
import 'package:british_body_admin/material/materials.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class Notifications extends StatefulWidget {
  const Notifications({super.key});

  @override
  State<Notifications> createState() => _NotificationsState();
}

class _NotificationsState extends State<Notifications> {
  List notificationTitles = [];
  List notificationDetails = [];
  List pendingnotificationtitle = [];
  List pendingnotificationbody = [];
  getnotifications() async {
    notificationTitles = [];
    notificationDetails = [];
    SharedPreferences preferences = await SharedPreferences.getInstance();
    notificationTitles = preferences.getStringList('notificationTitles') ?? [];
    notificationDetails = preferences.getStringList('notificationBodies') ?? [];
  }

  getpendingnotifications() async {
    pendingnotificationtitle = [];
    pendingnotificationbody = [];
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    final List<PendingNotificationRequest> pendingNotificationRequests =
        await flutterLocalNotificationsPlugin.pendingNotificationRequests();
    for (var i = 0; i < pendingNotificationRequests.length; i++) {
      pendingnotificationtitle.add(pendingNotificationRequests[i].title);
      pendingnotificationbody.add(pendingNotificationRequests[i].body);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ئاگاداریەکان'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          FutureBuilder(
            future: getnotifications(),
            builder: (context, snapshot) => SizedBox(
              height: (notificationDetails.length * 10).h,
              child: ListView.builder(
                itemCount: notificationDetails
                    .length, // Replace with the actual number of notifications
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.notifications,
                        color: Material1.primaryColor),
                    title: Text(notificationTitles[index]),
                    subtitle: Text(notificationDetails[index]),
                  );
                },
              ),
            ),
          ),
          FutureBuilder(
            future: getpendingnotifications(),
            builder: (context, snapshot) => SizedBox(
              height: (pendingnotificationtitle.length * 10).h,
              child: ListView.builder(
                itemCount: pendingnotificationtitle
                    .length, // Replace with the actual number of notifications
                itemBuilder: (context, index) {
                  return ListTile(
                    leading: Icon(Icons.notifications,
                        color: Material1.primaryColor),
                    title: Text(pendingnotificationtitle[index]),
                    subtitle: Text(pendingnotificationbody[index]),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
