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

  /// This is the month you selected (for example: Jan 2025).
  final DateTime date;

  final Duration totalworkedtime;

  /// Monthly target after subtracting approved leave (in Duration).
  final Duration workTarget;

  final num salary;
  final String loan;
  final int monthlypayback;

  final num reward;
  final num punishment;
  final num taskreward;
  final num taskpunishment;

  /// Total approved leave time within salary period (Duration, hours/minutes).
  final Duration absenceDuration;

  final int dailyWorkHours;

  const Givingsalary({
    super.key,
    required this.email,
    required this.date,
    required this.adminemail,
    required this.name,
    required this.totalworkedtime,
    required this.workTarget,
    required this.salary,
    required this.loan,
    required this.monthlypayback,
    required this.reward,
    required this.punishment,
    required this.taskreward,
    required this.taskpunishment,
    required this.absenceDuration,
    required this.dailyWorkHours,
  });

  @override
  State<Givingsalary> createState() => _GivingsalaryState();
}

class _GivingsalaryState extends State<Givingsalary> {
  final TextEditingController punishmentamountcontroller =
      TextEditingController();
  final TextEditingController monthlypaymentcontroller = TextEditingController();

  int _parseIntController(TextEditingController c) {
    return int.tryParse(c.text.trim()) ?? 0;
  }

  String _formatHM(Duration d) {
    if (d.inMinutes <= 0) return '0 کاتژمێر و 0 خولەک';
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    return '$h کاتژمێر و $m خولەک';
  }

  String _formatRemainingTime(Duration workTarget, Duration totalWorkedTime) {
    final remainingMinutes = workTarget.inMinutes - totalWorkedTime.inMinutes;

    if (remainingMinutes <= 0) {
      return '0 کاتژمێر و 0 خولەک';
    }

    final hours = remainingMinutes ~/ 60;
    final minutes = remainingMinutes % 60;

    return '$hours کاتژمێر و $minutes خولەک';
  }

  int _missedMinutes() {
    final v = widget.workTarget.inMinutes - widget.totalworkedtime.inMinutes;
    return v <= 0 ? 0 : v;
  }

  /// Punishment per missed hour, but calculated دقیقە-بە-دقیقە (pro-rated).
  /// Example: perHour=500, missed=120 minutes => 1000.
  int _calculatePunishment() {
    final missedMinutes = _missedMinutes();
    if (missedMinutes <= 0) return 0;

    final perHour = _parseIntController(punishmentamountcontroller);
    if (perHour <= 0) return 0;

    final value = (missedMinutes * perHour) / 60.0;

    // pick rounding style you want:
    return value.ceil();
  }

  int _givenSalary() {
    final monthlyPayback = _parseIntController(monthlypaymentcontroller);
    final missingPunishment = _calculatePunishment();

    final result = widget.salary -
        missingPunishment -
        monthlyPayback +
        widget.reward -
        widget.punishment +
        (widget.taskreward - widget.taskpunishment);

    // Dinar usually integer:
    return result.round();
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
      return adminEmail;
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching admin name: $e');
      return adminEmail;
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

      final adminName = await _fetchAdminName(widget.adminemail);

      final invoiceGenerator = InvoiceGenerator();

      // IMPORTANT:
      // If your InvoiceGenerator still expects `workTarget` as int hours and `absenceDays`,
      // we keep it compatible here by sending hours/days approximations.
      final workTargetHoursForInvoice = (widget.workTarget.inMinutes / 60).ceil();
      final absenceDaysForInvoice = widget.dailyWorkHours <= 0
          ? 0
          : (widget.absenceDuration.inMinutes /
                  (widget.dailyWorkHours * 60.0))
              .floor();

      final file = await invoiceGenerator.generateInvoice(
        employeeName: widget.name,
        employeeEmail: widget.email,
        paymentDate: widget.date,
        salary: widget.salary,
        totalWorkedTime: widget.totalworkedtime,
        workTarget: workTargetHoursForInvoice,
        absenceDays: absenceDaysForInvoice,
        dailyWorkHours: widget.dailyWorkHours,
        reward: widget.reward,
        punishment: widget.punishment,
        taskReward: widget.taskreward,
        taskPunishment: widget.taskpunishment,
        adminEmail: widget.adminemail,
        adminName: adminName,
        monthlyPayback: _parseIntController(monthlypaymentcontroller),
        punishmentPerHour: _parseIntController(punishmentamountcontroller),
        givenSalary: _givenSalary(),
        loan: widget.loan,
      );

      Navigator.of(context).pop();

      final result = await OpenFile.open(file.path);
      // ignore: avoid_print
      print('OpenFile result: ${result.message}');

      await Share.shareXFiles([XFile(file.path)],
          text: 'Invoice for ${widget.name}');

      // ignore: avoid_print
      print('Invoice generated successfully at: ${file.path}');
    } catch (e) {
      Navigator.of(context, rootNavigator: true).pop();
      // ignore: avoid_print
      print('Error generating invoice: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating invoice: $e')),
      );
    }
  }

  @override
  void initState() {
    punishmentamountcontroller.text = '500';
    monthlypaymentcontroller.text = widget.monthlypayback.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final leaveText = _formatHM(widget.absenceDuration);

    final targetHours = widget.workTarget.inMinutes / 60.0;
    final daysEq = widget.dailyWorkHours <= 0
        ? 0.0
        : targetHours / widget.dailyWorkHours;

    final missedMinutes = _missedMinutes();
    final missedDuration = Duration(minutes: missedMinutes);

    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.date.year} / ${widget.date.month} بەروار'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () async => _generateAndPrintInvoice(),
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

          // Leave in hours/minutes (NOT days)
          Container(
            width: 100.w,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h),
            child: Text(
              'کۆی کاتی مۆڵەت : $leaveText',
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

          // Worked time
          Container(
            width: 100.w,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h),
            child: Text(
              'کۆی کاتی کارکردن : ${_formatHM(widget.totalworkedtime)}',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Remaining time
          Container(
            width: 100.w,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h),
            child: Text(
              'کاتی کارکردنی ماوە : ${_formatRemainingTime(widget.workTarget, widget.totalworkedtime)}',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Target time
          Container(
            width: 100.w,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h),
            child: Text(
              'ئامانجی کارکردن : ${targetHours.toStringAsFixed(2)} کاتژمێر (~${daysEq.toStringAsFixed(1)} ڕۆژ)',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Missed time (hours/minutes)
          Container(
            width: 100.w,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h),
            child: Text(
              'کاتی دواکەوتن : ${_formatHM(missedDuration)}',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Missing punishment
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

          // Salary
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

          // Loan
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

          // Monthly payback display
          Container(
            width: 100.w,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 1.h),
            child: Text(
              'بڕی پارەدانەوەی مانگانە : ${NumberFormat("#,###").format(_parseIntController(monthlypaymentcontroller))} دینار',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Monthly payback input
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
              onchange: (p0) => setState(() {}),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.isEmpty) {
                    return const TextEditingValue(text: '0');
                  }
                  final v = int.tryParse(newValue.text) ?? 0;
                  if (v < 0) return const TextEditingValue(text: '0');
                  return newValue;
                }),
              ],
              inputType: TextInputType.number,
              controller: monthlypaymentcontroller,
            ),
          ),

          // Punishment per hour input
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
              onchange: (p0) => setState(() {}),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                TextInputFormatter.withFunction((oldValue, newValue) {
                  if (newValue.text.isEmpty) {
                    return const TextEditingValue(text: '0');
                  }
                  final v = int.tryParse(newValue.text) ?? 0;
                  if (v < 0) return const TextEditingValue(text: '0');
                  return newValue;
                }),
              ],
              inputType: TextInputType.number,
              textColor: Colors.black,
              controller: punishmentamountcontroller,
            ),
          ),

          // Given salary
          Container(
            width: 100.w,
            alignment: Alignment.centerRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 5.h),
            child: Text(
              'بڕی موچەی پێدراو : ${NumberFormat("#,###").format(_givenSalary())} دینار',
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 18.sp,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // Pay button
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
                        'دڵنیایت لە پێدانی موچەی مانگی ${widget.date.month} بە بڕی ${NumberFormat("#,###").format(_givenSalary())} دینار',
                      ),
                      actions: [
                        Material1.button(
                          label: 'بەڵێ',
                          buttoncolor: Material1.primaryColor,
                          textcolor: Colors.white,
                          function: () async {
                            try {
                              final missedMinutes = _missedMinutes();
                              final missedHoursDouble = missedMinutes / 60.0;

                              await FirebaseFirestore.instance
                                  .collection('user')
                                  .doc(widget.email)
                                  .collection('salary')
                                  .doc('${widget.date.year}-${widget.date.month}')
                                  .set({
                                // Worked
                                'totalworkedminutes':
                                    widget.totalworkedtime.inMinutes,
                                'totalworkedhours':
                                    widget.totalworkedtime.inMinutes / 60.0,

                                // Target (after leave)
                                'worktargetminutes': widget.workTarget.inMinutes,
                                'worktargethours': widget.workTarget.inMinutes / 60.0,

                                // Leave (approved)
                                'approvedleaveminutes':
                                    widget.absenceDuration.inMinutes,
                                'approvedleavehours':
                                    widget.absenceDuration.inMinutes / 60.0,

                                // Missing
                                'totalmissedworkminutes': missedMinutes,
                                'totalmissedworkhours': missedHoursDouble,

                                // Old keys (keep if you have old UI reading them)
                                'missedhoursofwork': missedHoursDouble,
                                'totalmissedworkhours_legacyInt':
                                    missedMinutes ~/ 60,

                                // Meta
                                'givenby': widget.adminemail,
                                'date': widget.date,

                                // Punishment
                                'punishmentformissingwork': _calculatePunishment(),
                                'punishmentpermissedworkinghour':
                                    _parseIntController(punishmentamountcontroller),
                                'totalpunishment':
                                    _calculatePunishment() + widget.punishment,

                                // Loan payback
                                'monthlypayback':
                                    _parseIntController(monthlypaymentcontroller),

                                // Salary and reward/punishment
                                'salary': widget.salary,
                                'reward': widget.reward,
                                'punishmentgiven': widget.punishment,
                                'taskreward': widget.taskreward,
                                'taskpunishment': widget.taskpunishment,

                                'isreceived': false,
                                'givensalary': _givenSalary(),
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
                              // ignore: avoid_print
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
                          function: () => Navigator.pop(context),
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
}