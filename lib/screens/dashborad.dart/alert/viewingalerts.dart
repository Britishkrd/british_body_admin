import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Viewingalerts extends StatefulWidget {
  final String email;
  const Viewingalerts({super.key, required this.email});

  @override
  State<Viewingalerts> createState() => _ViewingalertsState();
}

class _ViewingalertsState extends State<Viewingalerts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ئاگاداریەکان'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('alert')
            .where('to', arrayContains: widget.email)
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView.builder(
              itemCount: snapshot.data?.docs.length ?? 0,
              itemBuilder: (BuildContext context, int index) {
                return SizedBox(
                    height: 25.h,
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
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            "${snapshot.data!.docs[index]['title']}",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "${snapshot.data!.docs[index]['body']}",
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            snapshot.data!.docs[index]['time'],
                            style: const TextStyle(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ));
              });
        },
      ),
    );
  }
}
