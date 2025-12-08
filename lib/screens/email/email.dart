import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/email/catagories/catagories.dart';
import 'package:british_body_admin/screens/email/emaildeatial.dart';
import 'package:british_body_admin/screens/email/sendingemail.dart';
import 'package:chips_choice/chips_choice.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sizer/sizer.dart';

class Email extends StatefulWidget {
  final String email;
  const Email({super.key, required this.email});

  @override
  State<Email> createState() => _EmailState();
}

class _EmailState extends State<Email> {
  bool isRead = false;
  bool isSearch = true;
  TextEditingController searchcontroller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(
          height: 10.h,
          width: 100.w,
          child: Row(
            children: [
              Container(
                margin: EdgeInsets.only(left: 5.w, top: 1.h),
                height: 10.h,
                width: 30.w,
                decoration: BoxDecoration(
                  color: Material1.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Sendingemail(
                                  email: widget.email,
                                  ccList: [],
                                  emailList: [],
                                  subject: '',
                                  content: '',
                                  from: '',
                                )));
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('send a new email',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                          )),
                      Icon(
                        Icons.email,
                        color: Colors.white,
                        size: 25.sp,
                      )
                    ],
                  ),
                ),
              ),
              Container(
                margin: EdgeInsets.only(left: 5.w, top: 1.h),
                height: 10.h,
                width: 30.w,
                decoration: BoxDecoration(
                  color: Material1.primaryColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => Catagories(
                                  email: widget.email,
                                )));
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('catagories',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                          )),
                      Icon(
                        Icons.email,
                        color: Colors.white,
                        size: 25.sp,
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: EdgeInsets.only(left: 5.w, top: 1.h, right: 5.w),
          child: Material1.textfield(
            hint: 'search',
            textColor: Colors.black,
            controller: searchcontroller,
            onchange: (p0) {
              setState(() {});
            },
          ),
        ),
        SizedBox(
          height: 8.h,
          child: ChipsChoice<int>.single(
            value: tag,
            onChanged: (val) => setState(() => tag = val),
            choiceItems: C2Choice.listFrom<int, String>(
              source: options,
              value: (i, v) => i,
              label: (i, v) => v,
            ),
          ),
        ),
        SizedBox(
          height: 55.h,
          width: 100.w,
          child: StreamBuilder(
              stream: streams(widget.email),
              builder: (BuildContext context,
                  AsyncSnapshot<List<QuerySnapshot>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No emails found'));
                }

                final combinedDocs = snapshot.data!
                    .expand((querySnapshot) => querySnapshot.docs)
                    .where((doc) => doc['date'] != null) // Add this line
                    .toList();
                combinedDocs.sort(
                    (a, b) => b['date'].toDate().compareTo(a['date'].toDate()));
                return ListView.builder(
                    itemCount: combinedDocs.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (!isRead &&
                          ((combinedDocs[index]['readlist']
                              .contains(widget.email)))) {
                        return SizedBox.shrink();
                      }
                      if (isSearch &&
                          !(combinedDocs[index]['to'].contains(widget.email) ||
                              (combinedDocs[index]['cc'])
                                  .contains(widget.email))) {
                        return SizedBox.shrink();
                      }
                      return GestureDetector(
                        onTap: () {
                          String to = '', cc = '';
                          for (int i = 0;
                              i < combinedDocs[index]['to'].length;
                              i++) {
                            to += combinedDocs[index]['to'][i] + ' ';
                          }
                          for (int i = 0;
                              i < combinedDocs[index]['cc'].length;
                              i++) {
                            cc += combinedDocs[index]['cc'][i] + ' ';
                          }
                          combinedDocs[index].reference.update({
                            'readlist': FieldValue.arrayUnion([widget.email]),
                          });
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => Emaildeatial(
                                        to: to,
                                        cc: cc,
                                        subject: combinedDocs[index]['subject'],
                                        content: combinedDocs[index]['content'],
                                        images: List<String>.from(
                                            combinedDocs[index]['images']),
                                        files: List<String>.from(
                                            combinedDocs[index]['attachments']),
                                        date: combinedDocs[index]['date']
                                            .toDate(),
                                        email: widget.email,
                                        from: combinedDocs[index]['from'],
                                        id: combinedDocs[index].reference,
                                        emailid: combinedDocs[index]['id']
                                            .toString(),
                                        toList: List<String>.from(
                                            combinedDocs[index]['to']),
                                        ccList: List<String>.from(
                                            combinedDocs[index]['cc']),
                                      )));
                        },
                        child: SizedBox(
                            height: 16.h,
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
                                    (combinedDocs[index]['readlist']
                                            .contains(widget.email))
                                        ? Icons.mark_email_read
                                        : Icons.mark_email_unread_rounded,
                                    color: Material1.primaryColor,
                                  ),
                                  Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(combinedDocs[index]['from'],
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold)),
                                      Text(combinedDocs[index]['subject'],
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          combinedDocs[index]['date']
                                              .toDate()
                                              .toString(),
                                          style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          "${combinedDocs[index]['id']} : ناسنامەی ئیمەیڵ",
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
    );
  }

  int tag = 0;
  List<String> options = [
    'هەموو',
    'نێردراوەکان',
    'هاتووەکان',
    'نەخوێندراوەکان',
  ];

  Stream<List<QuerySnapshot<Map<String, dynamic>>>> streams(String email) {
    if (searchcontroller.text.isEmpty) {
      if (tag == 1) {
        isRead = true;
        isSearch = false;
        return FirebaseFirestore.instance
            .collection('email')
            .where('from', isEqualTo: widget.email)
            .orderBy('date', descending: true)
            .snapshots()
            .map((snapshot) => [snapshot]);
      } else if (tag == 2) {
        isRead = true;
        var toemail = FirebaseFirestore.instance
            .collection('email')
            .where('to', arrayContains: widget.email)
            .orderBy('date', descending: true)
            .snapshots();
        var cceamil = FirebaseFirestore.instance
            .collection('email')
            .where('cc', arrayContains: widget.email)
            .orderBy('date', descending: true)
            .snapshots();
        return Rx.combineLatest2(
            toemail,
            cceamil,
            (QuerySnapshot<Map<String, dynamic>> toemail,
                    QuerySnapshot<Map<String, dynamic>> cceamil) =>
                [toemail, cceamil]);
      } else if (tag == 3) {
        isRead = false;
        isSearch = false;

        FirebaseFirestore.instance
            .collection('email')
            .where('from', isEqualTo: widget.email)
            .orderBy('date', descending: true)
            .snapshots()
            .map((snapshot) => [snapshot]);
      }
      if (tag == 0) {
        isSearch = false;

        isRead = true;
        var toemail = FirebaseFirestore.instance
            .collection('email')
            .where('to', arrayContains: widget.email)
            .orderBy('date', descending: true)
            .snapshots();
        var cceamil = FirebaseFirestore.instance
            .collection('email')
            .where('cc', arrayContains: widget.email)
            .orderBy('date', descending: true)
            .snapshots();
        var from = FirebaseFirestore.instance
            .collection('email')
            .where('from', isEqualTo: widget.email)
            .orderBy('date', descending: true)
            .snapshots();

        return Rx.combineLatest3(
            toemail,
            cceamil,
            from,
            (QuerySnapshot<Map<String, dynamic>> toemail,
                    QuerySnapshot<Map<String, dynamic>> cceamil,
                    QuerySnapshot<Map<String, dynamic>> from) =>
                [toemail, cceamil, from]);
      }
    } else {
      isRead = true;
      isSearch = true;
      return FirebaseFirestore.instance
          .collection('email')
          .where('subjects', arrayContains: searchcontroller.text)
          .orderBy('date', descending: true)
          .snapshots()
          .map((snapshot) => [snapshot]);
    }
    return FirebaseFirestore.instance
        .collection('email')
        .where('to', arrayContains: widget.email)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => [snapshot]);
  }
}
