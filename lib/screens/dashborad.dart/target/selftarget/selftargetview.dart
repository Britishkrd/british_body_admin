import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/dashborad.dart/target/selftarget/selftargetdetails.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Selftargetview extends StatefulWidget {
  final String email;
  final bool adminview;
  const Selftargetview(
      {super.key, required this.email, required this.adminview});

  @override
  State<Selftargetview> createState() => _SelftargetviewState();
}

class _SelftargetviewState extends State<Selftargetview> {
  int targettag = 0;
  List<String> targetoptions = ['هەموو', 'لە چاوەڕوانی', 'تەواو بووە'];

  Stream<QuerySnapshot<Map<String, dynamic>>> streams(String email) {
    if (targettag == 1) {
      return FirebaseFirestore.instance
          .collection('target')
          .where('email', isEqualTo: widget.email)
          .where('end', isGreaterThanOrEqualTo: DateTime.now())
          .snapshots();
    } else if (targettag == 2) {
      return FirebaseFirestore.instance
          .collection('target')
          .where('email', isEqualTo: widget.email)
          .where('end', isLessThan: DateTime.now())
          .snapshots();
    } else {
      return FirebaseFirestore.instance
          .collection('target')
          .where('email', isEqualTo: widget.email)
          .snapshots();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('تارگێتەکان'),
          foregroundColor: Colors.white,
          backgroundColor: Material1.primaryColor,
          centerTitle: true,
        ),
        body: Column(
          children: [
            SizedBox(
              height: 8.h,
              child: ChipsChoice<int>.single(
                value: targettag,
                onChanged: (val) => setState(() => targettag = val),
                choiceItems: C2Choice.listFrom<int, String>(
                  source: targetoptions,
                  value: (i, v) => i,
                  label: (i, v) => v,
                ),
              ),
            ),
            StreamBuilder(
                stream: streams(widget.email),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  return SizedBox(
                    height: 80.h,
                    child: ListView.builder(
                      itemCount: snapshot.data?.docs.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            List<String> notes = [];
                            List<String> links = [];
                            snapshot.data!.docs[index].reference
                                .collection('update')
                                .get()
                                .then((value) {
                              for (var element in value.docs) {
                                notes = List<String>.from(element['note']);
                                links = List<String>.from(element['link']);
                              }
                            });
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return Selftargetdetails(
                                title: snapshot.data!.docs[index]['title'],
                                description: snapshot.data!.docs[index]
                                    ['description'],
                                date: snapshot.data!.docs[index]['date']
                                    .toDate()
                                    .toString(),
                                email: snapshot.data!.docs[index]['email'],
                                adminemail: snapshot.data!.docs[index]
                                    ['adminemail'],
                                target: snapshot.data!.docs[index]['target'],
                                start: snapshot.data!.docs[index]['start']
                                    .toDate(),
                                end: snapshot.data!.docs[index]['end'].toDate(),
                                reward: snapshot.data!.docs[index]['reward'],
                                reference: snapshot.data!.docs[index].reference,
                                adminview: widget.adminview,
                                notes: notes,
                                links: links,
                              );
                            }));
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                                left: 5.w, right: 5.w, top: 2.h),
                            child: Card(
                              child: ListTile(
                                title:
                                    Text(snapshot.data!.docs[index]['title']),
                                subtitle:
                                    Text(snapshot.data!.docs[index]['target']),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                })
          ],
        ));
  }
}
