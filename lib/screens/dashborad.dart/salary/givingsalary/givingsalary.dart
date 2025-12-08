import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/dashborad.dart/salary/invoice/widgets/invoice_generator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

class Givingsalary extends StatefulWidget {
  final String email;
  final String name;
  final String adminemail;
  final DateTime date;
  final Duration totalworkedtime;
  final int worktarget;
  final num salary;
  final String loan;
  final int monthlypayback;
  final num reward;
  final num punishment;
  final num taskreward;
  final num taskpunishment;
  final int absenceDays;
  final int dailyWorkHours;

  const Givingsalary({
    super.key,
    required this.email,
    required this.date,
    required this.adminemail,
    required this.name,
    required this.totalworkedtime,
    required this.worktarget,
    required this.salary,
    required this.loan,
    required this.monthlypayback,
    required this.reward,
    required this.punishment,
    required this.taskreward,
    required this.taskpunishment,
    required this.absenceDays,
    required this.dailyWorkHours,
  });

  @override
  State<Givingsalary> createState() => _GivingsalaryState();
}

class _GivingsalaryState extends State<Givingsalary> {
  TextEditingController punishmentamountcontroller = TextEditingController();
  TextEditingController monthlypaymentcontroller = TextEditingController();

  int calculateMonthlyTarget(int dailyHours, DateTime date) {
    final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
    return dailyHours * daysInMonth;
  }

  String _formatRemainingTime(int workTargetHours, Duration totalWorkedTime) {
    final targetMinutes = workTargetHours * 60;
    final workedMinutes = totalWorkedTime.inMinutes;
    final remainingMinutes = targetMinutes - workedMinutes;

    if (remainingMinutes <= 0) {
      return '0 کاتژمێر و 0 خولەک';
    }

    final hours = remainingMinutes ~/ 60;
    final minutes = remainingMinutes % 60;

    return '$hours کاتژمێر و $minutes خولەک';
  }

  Future<String> _fetchAdminName(String adminEmail) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('user')
          .doc(adminEmail)
          .get();
      if (userDoc.exists) {
        return userDoc.data()?['name'] as String? ?? adminEmail;
      }
      return adminEmail; // Fallback to email if name not found
    } catch (e) {
      print('Error fetching admin name: $e');
      return adminEmail; // Fallback to email on error
    }
  }

  Future<void> _generateAndPrintInvoice() async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Generating invoice...'),
              ],
            ),
          );
        },
      );

      // Fetch admin name
      final adminName = await _fetchAdminName(widget.adminemail);

      final invoiceGenerator = InvoiceGenerator();
      final file = await invoiceGenerator.generateInvoice(
        employeeName: widget.name,
        employeeEmail: widget.email,
        paymentDate: widget.date,
        salary: widget.salary,
        totalWorkedTime: widget.totalworkedtime,
        workTarget: widget.worktarget,
        absenceDays: widget.absenceDays,
        dailyWorkHours: widget.dailyWorkHours,
        reward: widget.reward,
        punishment: widget.punishment,
        taskReward: widget.taskreward,
        taskPunishment: widget.taskpunishment,
        adminEmail: widget.adminemail,
        adminName: adminName, // Pass admin name
        monthlyPayback: int.parse(monthlypaymentcontroller.text.isNotEmpty
            ? monthlypaymentcontroller.text
            : '0'),
        punishmentPerHour: int.parse(punishmentamountcontroller.text.isNotEmpty
            ? punishmentamountcontroller.text
            : '0'),
        givenSalary: widget.salary -
            _calculatePunishment() -
            int.parse(monthlypaymentcontroller.text.isNotEmpty
                ? monthlypaymentcontroller.text
                : '0') +
            widget.reward -
            widget.punishment +
            (widget.taskreward - widget.taskpunishment),
        loan: widget.loan,
      );

      Navigator.of(context).pop();

      final result = await OpenFile.open(file.path);
      print('OpenFile result: ${result.message}');

      await Share.shareXFiles([XFile(file.path)],
          text: 'Invoice for ${widget.name}');

      print('Invoice generated successfully at: ${file.path}');
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      print('Error generating invoice: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating invoice: $e')),
      );
    }
  }

  @override
  void initState() {
    punishmentamountcontroller.text = 500.toString();
    monthlypaymentcontroller.text = widget.monthlypayback.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final loanAmount = num.tryParse(widget.loan) ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.date.year} / ${widget.date.month} بەروار',
        ),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async {
              await _generateAndPrintInvoice();
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          Container(
            width: 100.w,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 3.h),
            child: Text(
              '${widget.name} : ناوی کارمەند',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: 100.w,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h),
            child: Text(
              'ژمارەی ڕۆژانی مۆڵەت : ${widget.absenceDays} ڕۆژ واتە ${widget.absenceDays * widget.dailyWorkHours} کاتژمێر',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: 100.w,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h),
            child: Text(
              'کۆی پاداشتی ئەرکەکان : ${NumberFormat("#,###").format(widget.taskreward)} دینار',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: 100.w,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h),
            child: Text(
              'کۆی سزای ئەرکەکان : ${NumberFormat("#,###").format(widget.taskpunishment)} دینار',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: 100.w,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h),
            child: Text(
              'کۆی پاداشتی پێدراو : ${NumberFormat("#,###").format(widget.reward)} دینار',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: 100.w,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h),
            child: Text(
              'سزا پێدراو : ${NumberFormat("#,###").format(widget.punishment)} دینار',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: 100.w,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h),
            child: Text(
              'کۆی کاتی کارکردن : ${widget.totalworkedtime.inHours} کاتژمێر و ${widget.totalworkedtime.inMinutes.remainder(60)} خولەک',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: 100.w,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h),
            child: Text(
              'کاتی کارکردنی ماوە : ${_formatRemainingTime(widget.worktarget, widget.totalworkedtime)}',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: 100.w,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h),
            child: Text(
              'ئامانجی کارکردن : ${widget.worktarget} کاتژمێر (${(widget.worktarget / 8).toStringAsFixed(0)} ڕۆژ)',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: 100.w,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h),
            child: Text(
              'بڕی سزای کەمی کاتی کارکردن : ${NumberFormat("#,###").format(_calculatePunishment())} دینار',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: 100.w,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h),
            child: Text(
              'بڕی موچە : ${NumberFormat("#,###").format(widget.salary)} دینار',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: 100.w,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h),
            child: Text(
              'بڕی سولفەی وەرگیراو : ${NumberFormat("#,###").format((num.tryParse(widget.loan) ?? 0).toInt())} دینار',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: 100.w,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h),
            child: Text(
              'بڕی پارەدانەوەی مانگانە : ${NumberFormat("#,###").format(num.parse(monthlypaymentcontroller.text.isNotEmpty ? monthlypaymentcontroller.text : '0').toInt())} دینار',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: 100.w,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 5.h),
            child: Text(
              'بڕی پارەدانەوەی مانگانە',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: 100.w,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h),
            child: Material1.textfield(
              hint: 'بڕی پارەدانەوەی مانگانە',
              textColor: Colors.black,
              onchange: (p0) {
                setState(() {});
              },
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                TextInputFormatter.withFunction(
                  (oldValue, newValue) {
                    if (newValue.text.isEmpty) {
                      return const TextEditingValue(text: '0');
                    }
                    if (int.parse(newValue.text) < 0 &&
                        int.tryParse(newValue.text) != null) {
                      return const TextEditingValue(text: '0');
                    }
                    return newValue;
                  },
                ),
              ],
              inputType: TextInputType.number,
              controller: monthlypaymentcontroller,
            ),
          ),
          Container(
            width: 100.w,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 5.h),
            child: Text(
              'بڕی سزا',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: 100.w,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h),
            child: Material1.textfield(
              hint: 'بڕی سزا بۆ هەموو کاتژمێرێک کارنەکردن',
              onchange: (p0) {
                setState(() {});
              },
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                TextInputFormatter.withFunction(
                  (oldValue, newValue) {
                    if (newValue.text.isEmpty) {
                      return const TextEditingValue(text: '0');
                    }
                    if (int.parse(newValue.text) < 0 &&
                        int.tryParse(newValue.text) != null) {
                      return const TextEditingValue(text: '0');
                    }
                    return newValue;
                  },
                ),
              ],
              inputType: TextInputType.number,
              textColor: Colors.black,
              controller: punishmentamountcontroller,
            ),
          ),
          Container(
            width: 100.w,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 5.h),
            child: Text(
              'بڕی موچەی پێدراو : ${NumberFormat("#,###").format(widget.salary - _calculatePunishment() - (num.parse(monthlypaymentcontroller.text.isNotEmpty ? monthlypaymentcontroller.text : '0').toInt()) + widget.reward - widget.punishment + (widget.taskreward - widget.taskpunishment))} دینار',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            width: 80.w,
            height: 6.h,
            margin: EdgeInsets.fromLTRB(10.w, 3.h, 10.w, 3.h),
            decoration: BoxDecoration(
              color: Material1.primaryColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Material1.button(
              label: 'پێدانی موچە',
              buttoncolor: Material1.primaryColor,
              textcolor: Colors.white,
              function: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('پێدانی موچە'),
                      content: Text(
                        'دڵنیایت لە پێدانی موچەی مانگی ${widget.date.month} بە بڕی ${NumberFormat("#,###").format(widget.salary - (_calculatePunishment() + (num.parse(monthlypaymentcontroller.text.isNotEmpty ? monthlypaymentcontroller.text : '0').toInt())) + widget.reward - widget.punishment + (widget.taskreward - widget.taskpunishment))} دینار',
                      ),
                      actions: [
                        Material1.button(
                          label: 'بەڵێ',
                          buttoncolor: Material1.primaryColor,
                          textcolor: Colors.white,
                          function: () async {
                            try {
                              await FirebaseFirestore.instance
                                  .collection('user')
                                  .doc(widget.email)
                                  .collection('salary')
                                  .doc('${widget.date.year}-${widget.date.month}')
                                  .set({
                                'totalworkedhours': widget.totalworkedtime.inHours,
                                'givenby': widget.adminemail,
                                'date': widget.date,
                                'totalmissedworkhours':
                                    (widget.worktarget - widget.totalworkedtime.inHours),
                                'punishmentformissingwork': _calculatePunishment(),
                                'punishmentpermissedworkinghour': int.parse(
                                  punishmentamountcontroller.text.isNotEmpty
                                      ? punishmentamountcontroller.text
                                      : '0',
                                ),
                                'totalpunishment': _calculatePunishment() + widget.punishment,
                                'monthlypayback': int.parse(
                                  monthlypaymentcontroller.text.isNotEmpty
                                      ? monthlypaymentcontroller.text
                                      : '0',
                                ),
                                'salary': widget.salary,
                                'reward': widget.reward,
                                'punishmentgiven': widget.punishment,
                                'taskreward': widget.taskreward,
                                'taskpunishment': widget.taskpunishment,
                                'missedhoursofwork':
                                    (widget.worktarget - widget.totalworkedtime.inHours),
                                'isreceived': false,
                                'givensalary': (widget.salary -
                                    _calculatePunishment() -
                                    int.parse(monthlypaymentcontroller.text.isNotEmpty
                                        ? monthlypaymentcontroller.text
                                        : '0') +
                                    widget.reward -
                                    widget.punishment +
                                    (widget.taskreward - widget.taskpunishment)),
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'موچەی مانگی ${widget.date.month} بەسەرکەوتووی درا بە ${widget.name}',
                                  ),
                                ),
                              );

                              Navigator.popUntil(context, (route) => route.isFirst);
                            } catch (e) {
                              print('Error in button action: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Error: $e')),
                              );
                            }
                          },
                        ),
                        Material1.button(
                          label: 'نەخێر',
                          buttoncolor: Material1.primaryColor,
                          textcolor: Colors.white,
                          function: () {
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  num _calculatePunishment() {
    final missedHours = widget.worktarget - widget.totalworkedtime.inHours;
    if (missedHours <= 0) return 0;
    return missedHours * int.parse(punishmentamountcontroller.text.isNotEmpty
        ? punishmentamountcontroller.text
        : '0');
  }
}