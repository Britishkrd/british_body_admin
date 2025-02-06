import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Deleterewardpunishments extends StatefulWidget {
  final String email;
  const Deleterewardpunishments({super.key, required this.email});

  @override
  State<Deleterewardpunishments> createState() =>
      _DeleterewardpunishmentsState();
}

class _DeleterewardpunishmentsState extends State<Deleterewardpunishments> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('سڕینەوەی پاداشت / سزا'),
      ),
      body: ListView(
        children: [
          FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('user')
                  .doc(widget.email)
                  .collection('rewardpunishment')
                  .get(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return SizedBox(
                  height: ((snapshot.data?.docs.length ?? 0) * 20).h,
                  width: 100.w,
                  child: ListView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data?.docs.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    title: const Text(
                                        'دڵنیاییت لە سڕینەوەی ئەم سزا / پاداشتە'),
                                    actions: [
                                      TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text('پەشیمان بوونەوە')),
                                      TextButton(
                                          onPressed: () {
                                            snapshot.data!.docs[index].reference
                                                .delete()
                                                .then((value) {
                                              Navigator.popUntil(context,
                                                  (route) => route.isFirst);
                                            });
                                          },
                                          child: const Text(
                                              'سڕینەوەی سزا / پاداشت',
                                              style: TextStyle(
                                                  color: Colors.red))),
                                    ],
                                  );
                                });
                          },
                          child: SizedBox(
                              height: 20.h,
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
                                      "${snapshot.data!.docs[index]['addedby']} : زیاد کراوە لەلایەن",
                                      style: const TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      "${snapshot.data!.docs[index]['amount']} : بڕی ${snapshot.data!.docs[index]['type'] == 'punishment' ? 'سزا' : 'پاداشت'}",
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      "${snapshot.data!.docs[index]['date'].toDate()} : کات",
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                    Text(
                                      "${snapshot.data!.docs[index]['reason']} : هۆکار",
                                      style: const TextStyle(
                                        fontSize: 15,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        );
                      }),
                );
              }),
        ],
      ),
    );
  }
}
