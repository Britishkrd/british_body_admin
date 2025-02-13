import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:fl_chart/fl_chart.dart';

class Viewingemployeefeedbacks extends StatefulWidget {
  final String id;
  final Map<String, int> feedbackCounts;

  const Viewingemployeefeedbacks(
      {super.key, required this.id, required this.feedbackCounts});

  @override
  State<Viewingemployeefeedbacks> createState() =>
      _ViewingemployeefeedbacksState();
}

class _ViewingemployeefeedbacksState extends State<Viewingemployeefeedbacks> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Viewing Employee Feedbacks'),
          foregroundColor: Colors.white,
          backgroundColor: Material1.primaryColor,
          centerTitle: true,
        ),
        body: ListView(
          children: [
            Container(
              height: 20.h,
              width: 100.w,
              margin: EdgeInsets.all(3.w),
              child: PieChart(
                PieChartData(
                  sections: widget.feedbackCounts.entries.map((entry) {
                    return PieChartSectionData(
                      value: entry.value.toDouble(),
                      title: '${entry.key}: ${entry.value}',
                      color: Colors.primaries[widget.feedbackCounts.keys
                              .toList()
                              .indexOf(entry.key) %
                          Colors.primaries.length],
                      radius: 50,
                      titleStyle: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    );
                  }).toList(),
                  // read about it in the PieChartData section
                ),
                duration: Duration(milliseconds: 150), // Optional
                curve: Curves.linear, // Optional
              ),
            ),
            FutureBuilder(
                future: FirebaseFirestore.instance
                    .collection('generalfeedback')
                    .doc(widget.id)
                    .collection('feedback')
                    .get(),
                builder: (context, snapshot) {
                  return SizedBox(
                    height: 80.h,
                    child: ListView.builder(
                      itemCount: snapshot.data?.docs.length ?? 0,
                      itemBuilder: (context, index) {
                        return Container(
                          color: Colors.grey[200],
                          height: (12 *
                                  ((snapshot
                                      .data?.docs[index]['questions'].length)))
                              .h,
                          margin: EdgeInsets.all(3.w),
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount:
                                snapshot.data?.docs[index]['questions'].length,
                            itemBuilder: (context, index1) => Container(
                              padding: EdgeInsets.all(5),
                              height: (6 *
                                      (snapshot.data?.docs[index]['questions']
                                          .length))
                                  .h,
                              child: Column(
                                children: [
                                  Text(
                                      "${snapshot.data?.docs[index]['questions'][index1] ?? ''} پرسیاریی :${index + 1}"),
                                  Text(
                                      "${snapshot.data?.docs[index]['options'][index1] ?? ''}  :وەڵامی ${index + 1}"),
                                  Text(
                                      "${snapshot.data?.docs[index]['notes'][index1] ?? ''}  :تێبینی ${index + 1}"),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                }),
          ],
        ));
  }
}
