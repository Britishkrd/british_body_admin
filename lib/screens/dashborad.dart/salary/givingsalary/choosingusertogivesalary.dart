import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/dashborad.dart/salary/givingsalary/givingsalary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:sizer/sizer.dart';

class ChoosingUserForGivingSalary extends StatefulWidget {
  final String email;
  const ChoosingUserForGivingSalary({super.key, required this.email});

  @override
  State<ChoosingUserForGivingSalary> createState() =>
      _ChoosingUserForGivingSalaryState();
}

class _ChoosingUserForGivingSalaryState
    extends State<ChoosingUserForGivingSalary> {
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
                                'دڵنیایت لە پێدانی موچەی ئەم کارمەندە؟'),
                            actions: [
                              TextButton(
                                  onPressed: () async {
                                    Duration totalworkedtime = Duration();

                                    showMonthRangePicker(
                                      context: context,
                                      firstDate:
                                          DateTime(DateTime.now().year - 1, 1),
                                      rangeList: false,
                                    ).then((List<DateTime>? dates) {
                                      if (dates?.isNotEmpty ?? false) {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                  title: Column(
                                                children: [
                                                  Center(
                                                      child:
                                                          CircularProgressIndicator()),
                                                  Text('تکایە چاوەڕێکە...'),
                                                ],
                                              ));
                                            });
                                        FirebaseFirestore.instance
                                            .collection('user')
                                            .doc(widget.email)
                                            .collection('checkincheckouts')
                                            .where('time',
                                                isGreaterThanOrEqualTo:
                                                    DateTime(dates!.first.year,
                                                        dates.first.month, 1))
                                            .where('time',
                                                isLessThanOrEqualTo: DateTime(
                                                    dates.first.year,
                                                    dates.first.month,
                                                    (DateTime(
                                                            dates.first.year,
                                                            dates.first.month +
                                                                1,
                                                            0)
                                                        .day)))
                                            .get()
                                            .then((value) {
                                          for (var i = 0;
                                              i < value.docs.length;
                                              i = i + 2) {
                                            totalworkedtime += value.docs[i + 1]
                                                    ['time']
                                                .toDate()
                                                .difference(value.docs[i]
                                                        ['time']
                                                    .toDate());
                                          }
                                        }).then((value) {
                                          num reward = 0;
                                          num punishment = 0;
                                          FirebaseFirestore.instance
                                              .collection('user')
                                              .doc(widget.email)
                                              .collection('rewardpunishment')
                                              .where('date',
                                                  isGreaterThanOrEqualTo:
                                                      DateTime(dates.first.year,
                                                          dates.first.month, 1))
                                              .where('date',
                                                  isLessThanOrEqualTo: DateTime(
                                                      dates.first.year,
                                                      dates.first.month,
                                                      (DateTime(
                                                              dates.first.year,
                                                              dates.first
                                                                      .month +
                                                                  1,
                                                              0)
                                                          .day)))
                                              .get()
                                              .then((value) {
                                            for (var i = 0;
                                                i < value.docs.length;
                                                i++) {
                                              if (value.docs[i]
                                                      .data()['type'] ==
                                                  'punishment') {
                                                punishment += num.tryParse(value
                                                        .docs[i]
                                                        .data()['amount']) ??
                                                    0;
                                              } else {
                                                reward += num.tryParse(value
                                                        .docs[i]
                                                        .data()['amount']) ??
                                                    0;
                                              }
                                            }
                                          }).then((value) {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        Givingsalary(
                                                          name: snapshot.data
                                                                          ?.docs[
                                                                      index]
                                                                  ['name'] ??
                                                              snapshot.data!
                                                                          .docs[
                                                                      index]
                                                                  ['email'],
                                                          adminemail:
                                                              widget.email,
                                                          email: snapshot.data!
                                                                  .docs[index]
                                                              ['email'],
                                                          date: dates.first,
                                                          totalworkedtime:
                                                              totalworkedtime,
                                                          worktarget: snapshot
                                                                  .data!
                                                                  .docs[index]
                                                              ['worktarget'],
                                                          salary: int.parse(
                                                              snapshot.data!
                                                                          .docs[
                                                                      index]
                                                                  ['salary']),
                                                          loan: snapshot.data!
                                                                  .docs[index]
                                                              ['loan'],
                                                          monthlypayback: snapshot
                                                              .data!
                                                              .docs[index][
                                                                  'monthlypayback']
                                                              .toInt(),
                                                          reward: reward,
                                                          punishment:
                                                              punishment,
                                                        )));
                                          });
                                        });
                                      }
                                    });
                                  },
                                  child: const Text('پێدانی موچە')),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('پەشیمانبوونەوە')),
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
