import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/dashborad.dart/adding-reward-punishment/addingrewardpunishment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Choosinguser extends StatefulWidget {
  final String email;
  const Choosinguser({super.key, required this.email});

  @override
  State<Choosinguser> createState() => _ChoosinguserState();
}

class _ChoosinguserState extends State<Choosinguser> {
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
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                      return AddingRewardPunishment(
                          adminemail: widget.email,
                          email: snapshot.data!.docs[index]['email']);
                    }));
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
