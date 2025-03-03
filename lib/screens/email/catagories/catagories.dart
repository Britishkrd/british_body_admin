import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/email/catagories/createcatagory.dart';
import 'package:british_body_admin/screens/email/emaildeatial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Catagories extends StatefulWidget {
  final String email;
  const Catagories({super.key, required this.email});

  @override
  State<Catagories> createState() => _CatagoriesState();
}

class _CatagoriesState extends State<Catagories> {
  String selectedCatagory = '';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('کەتەگۆریەکان'),
        backgroundColor: Material1.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return Createcatagory(
                  email: widget.email,
                );
              }));
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            height: 5.h,
            width: 100.w,
            margin: EdgeInsets.only(top: 3.h, left: 1.w, right: 1.w),
            child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('user')
                    .doc(widget.email)
                    .snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  List catagories = snapshot.data?.get('catagory') ?? [];
                  if (snapshot.hasData) {
                    return ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: catagories.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedCatagory = catagories[index];
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(1.w),
                            decoration: BoxDecoration(
                              color: selectedCatagory == catagories[index]
                                  ? Material1.primaryColor
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(10.sp),
                            ),
                            margin: EdgeInsets.only(
                                top: 1.h, right: 1.w, left: 5.w),
                            child: Text(
                              catagories[index],
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return Container();
                  }
                }),
          ),
          SizedBox(
            height: 70.h,
            width: 100.w,
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('email')
                    .where('catagory',
                        arrayContains: "${widget.email}-$selectedCatagory")
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>>
                        snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(child: Text('No emails found'));
                  }

                  return ListView.builder(
                      itemCount: snapshot.data?.docs.length ?? 0,
                      itemBuilder: (BuildContext context, int index) {
                        return GestureDetector(
                          onTap: () {
                            String to = '', cc = '';
                            for (int i = 0;
                                i < snapshot.data?.docs[index]['to'].length;
                                i++) {
                              to += snapshot.data?.docs[index]['to'][i] + ' ';
                            }
                            for (int i = 0;
                                i < snapshot.data?.docs[index]['cc'].length;
                                i++) {
                              cc += snapshot.data?.docs[index]['cc'][i] + ' ';
                            }
                            snapshot.data?.docs[index].reference.update({
                              'readlist': FieldValue.arrayUnion([widget.email]),
                            });
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Emaildeatial(
                                          to: to,
                                          cc: cc,
                                          subject: snapshot.data?.docs[index]
                                              ['subject'],
                                          content: snapshot.data?.docs[index]
                                              ['content'],
                                          images: List<String>.from(snapshot
                                              .data?.docs[index]['images']),
                                          files: List<String>.from(snapshot.data
                                              ?.docs[index]['attachments']),
                                          date: snapshot
                                              .data?.docs[index]['date']
                                              .toDate(),
                                          email: widget.email,
                                          from: snapshot.data?.docs[index]
                                              ['from'],
                                          id: snapshot
                                              .data!.docs[index].reference,
                                          emailid: snapshot.data!.docs[index]
                                              ['id'],
                                          toList: List<String>.from(
                                              snapshot.data?.docs[index]['to']),
                                          ccList: List<String>.from(
                                              snapshot.data?.docs[index]['cc']),
                                        )));
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
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(
                                      (snapshot.data?.docs[index]['readlist']
                                              .contains(widget.email))
                                          ? Icons.mark_email_read
                                          : Icons.mark_email_unread_rounded,
                                      color: Material1.primaryColor,
                                    ),
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(snapshot.data?.docs[index]['from'],
                                            style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            snapshot.data?.docs[index]
                                                ['subject'],
                                            style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            snapshot.data?.docs[index]['date']
                                                    .toDate()
                                                    .toString() ??
                                                '',
                                            style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold)),
                                        Text(
                                            "${snapshot.data?.docs[index]['id']} : ناسنامەی ئیمەیڵ",
                                            style: TextStyle(
                                                fontSize: 16.sp,
                                                fontWeight: FontWeight.bold)),
                                      ],
                                    )
                                  ],
                                ),
                              )),
                        );
                      });
                }),
          ),
        ],
      ),
    );
  }
}
