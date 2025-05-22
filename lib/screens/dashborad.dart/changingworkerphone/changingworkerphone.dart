import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/auth/login_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class Changingworkerphone extends StatefulWidget {
  const Changingworkerphone({super.key});

  @override
  State<Changingworkerphone> createState() => _ChangingworkerphoneState();
}

class _ChangingworkerphoneState extends State<Changingworkerphone> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('کارمەندەکان'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
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
                return GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text(
                                'دەتەوێت مۆبایلی کارمەندەکە بگۆڕیت؟'),
                            actions: [
                              TextButton(
  onPressed: () {
    FirebaseFirestore.instance
        .collection('user')
        .doc(snapshot.data!.docs[index].id)
        .update({
          'deviceid': '',
          'lat': '',
          'long': '',
        }).then((value) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text(
                  'ئێستا کارمەندەکە بە مۆبایلە نوێکە چوونەژوورەوە بکات')));
          Navigator.pop(context); // Close dialog
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Failed to reset device: $error')));
        });
  },
  child: const Text('بەڵێ')),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('نەخێر')),
                            ],
                          );
                        });
                  },
                  child: SizedBox(
                      height: 15.h,
                      width: 90.w,
                      child: Container(
                        margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
                        padding: EdgeInsets.all(1.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 5,
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${snapshot.data!.docs[index]['name']} : ناو",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "${snapshot.data!.docs[index]['phonenumber']} : ژمارەی مۆبایل",
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            Text(
                              "${snapshot.data!.docs[index]['email']} : ئیمەیل",
                              style: const TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      )),
                );
              });
        },
      ),
    );
  }
}


class UserSessionManager extends StatefulWidget {
  const UserSessionManager({super.key, required this.child, required this.email});

  final Widget child;
  final String email;

  @override
  State<UserSessionManager> createState() => _UserSessionManagerState();
}

class _UserSessionManagerState extends State<UserSessionManager> {
  @override
  void initState() {
    super.initState();
    _monitorUserSession();
  }

  void _monitorUserSession() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && widget.email.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('user')
          .doc(widget.email) // Use email as document ID
          .snapshots()
          .listen((snapshot) {
        if (snapshot.exists) {
          final data = snapshot.data()!;
          if (data['deviceid'] == '' &&
              data['lat'] == '' &&
              data['long'] == '') {
            // Device reset detected, sign out the user
            _signOut();
          }
        }
      }, onError: (error) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error monitoring session: $error')));
      });
    }
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    // Clear shared preferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Adjust based on your SharedPreferences usage
    // Update global login state
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool('logedin', false); // Update your logedin flag
    });
    if (mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}