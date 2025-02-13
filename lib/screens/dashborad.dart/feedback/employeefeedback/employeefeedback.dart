import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/dashborad.dart/feedback/employeefeedback/employeegivingfeedback.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';


class Employeefeedback extends StatefulWidget {
  final String email;
  const Employeefeedback({super.key, required this.email});

  @override
  State<Employeefeedback> createState() => _EmployeefeedbackState();
}

class _EmployeefeedbackState extends State<Employeefeedback> {
  TextEditingController feedbackController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ڕەخنە و پێشنیار'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
          FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('generalfeedback')
                  .where('givenfeedback', arrayContains: widget.email)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.data?.docs.isEmpty ?? false) {
                  return Container(
                    width: 90.w,
                    height: 15.h,
                    margin: EdgeInsets.only(top: 2.h, left: 5.w, right: 5.w),
                    child: Text('هیچ ڕەخنە و پێشنیارێکت نییە لە ئێستادا',
                        style: TextStyle(color: Colors.red)),
                  );
                }
                return SizedBox(
                  height: ((snapshot.data?.docs.length ?? 0) * 40).h,
                  width: 100.w,
                  child: ListView.builder(
                      itemCount: snapshot.data?.docs.length ?? 0,
                      itemBuilder: (context, index) {
                        return Container(
                          margin: EdgeInsets.only(
                              bottom: 5.w, top: 2.h, right: 5.w, left: 5.w),
                          height: 40.h,
                          width: 100.w,
                          child: Card(
                            child: Column(
                              children: [
                                Container(
                                  margin:
                                      EdgeInsets.only(right: 5.w, left: 5.w),
                                  alignment: Alignment.centerLeft,
                                  child: SizedBox(
                                    height: 4.h,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          snapshot.data?.docs[index]['email'],
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Material1.button(
                                            label: 'ناردنی جواب',
                                            buttoncolor: Material1.primaryColor,
                                            textcolor: Colors.white,
                                            function: () {
                                              List<List<String>>
                                                  optionControllers = [];
                                              for (var i = 0;
                                                  i <
                                                      snapshot
                                                          .data
                                                          ?.docs[index]
                                                              ['questions']
                                                          .length;
                                                  i++) {
                                                optionControllers.add(
                                                    List<String>.from(snapshot
                                                                .data
                                                                ?.docs[index]
                                                            ['options$i'] ??
                                                        []));
                                              }
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          Employeegivingfeedback(
                                                            email: widget.email,
                                                            questions: List<
                                                                String>.from(snapshot
                                                                            .data
                                                                            ?.docs[
                                                                        index][
                                                                    'questions'] ??
                                                                []),
                                                            option:
                                                                optionControllers,
                                                            id: snapshot
                                                                    .data
                                                                    ?.docs[
                                                                        index]
                                                                    .id ??
                                                                '',
                                                          )));
                                            })
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  height: 35.h,
                                  child: ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemBuilder: (context, i) {
                                        return ExpansionTile(
                                          title: Text(snapshot.data?.docs[index]
                                              ['questions'][i]),
                                          children: [
                                            SizedBox(
                                              height: 10.h,
                                              child: ListView.builder(
                                                  itemCount: snapshot
                                                      .data
                                                      ?.docs[index]['options$i']
                                                      .length,
                                                  itemBuilder: (context, j) {
                                                    return ListTile(
                                                      title: Text(snapshot
                                                              .data?.docs[index]
                                                          ['options$i'][j]),
                                                    );
                                                  }),
                                            )
                                          ],
                                        );
                                      },
                                      itemCount: snapshot.data
                                          ?.docs[index]['questions'].length),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                );
              }),
        ],
      ),
    );
  }
}
