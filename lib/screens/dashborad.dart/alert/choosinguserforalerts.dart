import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/dashborad.dart/alert/batchalertsending.dart';
import 'package:british_body_admin/screens/dashborad.dart/alert/sendingalerts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Choosingforalerts extends StatefulWidget {
  final String email;
  const Choosingforalerts({super.key, required this.email});

  @override
  State<Choosingforalerts> createState() => _ChoosingforalertsState();
}

class _ChoosingforalertsState extends State<Choosingforalerts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('کارمەندەکان'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(10.w, 2.h, 10.w, 2.h),
            decoration: BoxDecoration(
              color: Material1.primaryColor,
              borderRadius: BorderRadius.circular(15),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5,
                )
              ],
            ),
            child: Material1.button(
                label: 'ناردنی ئاگاداری بە کۆمەڵ',
                buttoncolor: Material1.primaryColor,
                textcolor: Colors.white,
                function: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return BatchAlertSending(
                      adminemail: widget.email,
                    );
                  }));
                }),
          ),
          SizedBox(
            height: 80.h,
            child: StreamBuilder(
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
                            return Sendingalerts(adminemail: widget.email,emails: [snapshot.data!.docs[index]['email']],);
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
          ),
        ],
      ),
    );
  }
}
