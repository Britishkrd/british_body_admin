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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('user').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No employees found'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              final doc = snapshot.data!.docs[index];
              final data = doc.data() as Map<String, dynamic>;

              final name = data['name'] as String? ?? 'No Name';
              final phone = data['phonenumber'] as String? ?? 'No Phone';
              final email = data['email'] as String? ?? 'No Email';
              final salary = (data['salary'] as num? ?? 0).toInt();
              final loan = data.containsKey('loan')
                  ? (data['loan'] is String
                      ? (num.tryParse(data['loan'] as String) ?? 0).toInt()
                      : (data['loan'] as num? ?? 0).toInt())
                  : 0;
              final monthlyPayback = data.containsKey('monthlypayback')
                  ? (data['monthlypayback'] is String
                      ? (num.tryParse(data['monthlypayback'] as String) ?? 0).toInt()
                      : (data['monthlypayback'] as num? ?? 0).toInt())
                  : 0;

              return GestureDetector(
                onTap: () {
                  _proceedWithSalary(
                    context,
                    name,
                    email,
                    salary,
                    loan,
                    monthlyPayback,
                  );
                },
                child: _buildEmployeeCard(name, phone, email),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _proceedWithSalary(
    BuildContext context,
    String name,
    String email,
    int salary,
    int loan,
    int monthlyPayback, // Changed to int
  ) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('user').doc(email).get();

    final dailyWorkHours = userDoc['worktarget'] as int? ?? 8;

    List<int> workDays = [];
    final dynamicWeekdays = userDoc['weekdays'];

    if (dynamicWeekdays is List) {
      workDays = dynamicWeekdays
          .whereType<int>()
          .where((day) => day >= 1 && day <= 7)
          .toList();
    }

    if (workDays.isEmpty) {
      workDays = [6, 7, 1, 2, 3, 4];
    }

    final dates = await showMonthRangePicker(
      context: context,
      firstDate: DateTime(DateTime.now().year - 1, 1),
      rangeList: false,
    );

    if (dates == null || dates.isEmpty) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        title: Column(
          children: [
            Center(child: CircularProgressIndicator()),
            Text('تکایە چاوەڕێکە...'),
          ],
        ),
      ),
    );

    try {
      final totalWorkedTime = await _calculateTotalWorkedTime(email, dates[0]);
      final workingDays = await calculateWorkingDays(dates[0], workDays);
      final absenceDays = await _calculateAbsenceDays(email, dates[0]);
      final monthlyTarget = dailyWorkHours * (workingDays - absenceDays);
      final (reward, punishment) =
          await _calculateRewardAndPunishment(email, dates[0]);
      final (taskReward, taskPunishment) =
          await _calculateTaskRewardAndPunishment(email, dates[0]);

      if (!mounted) return;
      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Givingsalary(
            name: name,
            adminemail: widget.email,
            email: email,
            date: dates[0],
            totalworkedtime: totalWorkedTime,
            worktarget: monthlyTarget,
            salary: salary,
            loan: loan.toString(),
            monthlypayback: monthlyPayback,
            reward: reward,
            punishment: punishment,
            taskreward: taskReward,
            taskpunishment: taskPunishment,
            absenceDays: absenceDays,
            dailyWorkHours: dailyWorkHours,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Rest of the methods remain unchanged
  Future<int> calculateWorkingDays(DateTime month, List<int> workDays) async {
    final firstDay = DateTime(month.year, month.month, 1);
    final lastDay = DateTime(month.year, month.month + 1, 0);

    final holidaysSnapshot = await FirebaseFirestore.instance
        .collection('holidays')
        .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDay))
        .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(lastDay))
        .get();

    int workingDays = 0;

    for (DateTime day = firstDay;
        day.isBefore(lastDay) || day.isAtSameMomentAs(lastDay);
        day = day.add(const Duration(days: 1))) {
      if (workDays.contains(day.weekday)) {
        bool isHoliday = false;

        for (var holidayDoc in holidaysSnapshot.docs) {
          final holidayStart = (holidayDoc['startDate'] as Timestamp).toDate();
          final holidayEnd = (holidayDoc['endDate'] as Timestamp).toDate();

          if ((day.isAfter(holidayStart) ||
                  day.isAtSameMomentAs(holidayStart)) &&
              (day.isBefore(holidayEnd) || day.isAtSameMomentAs(holidayEnd))) {
            isHoliday = true;
            break;
          }
        }

        if (!isHoliday) {
          workingDays++;
        }
      }
    }

    return workingDays;
  }

  Future<int> _calculateAbsenceDays(String email, DateTime date) async {
    final firstDay = DateTime(date.year, date.month, 1);
    final lastDay = DateTime(date.year, date.month + 1, 0);

    final absenceSnapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(email)
        .collection('absentmanagement')
        .where('status', isEqualTo: 'accepted')
        .where('start', isLessThanOrEqualTo: Timestamp.fromDate(lastDay))
        .where('end', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDay))
        .get();

    int totalAbsenceDays = 0;

    for (var doc in absenceSnapshot.docs) {
      final start = doc['start'].toDate();
      final end = doc['end'].toDate();

      final effectiveStart = start.isBefore(firstDay) ? firstDay : start;
      final effectiveEnd = end.isAfter(lastDay) ? lastDay : end;

      int days = effectiveEnd.difference(effectiveStart).inDays + 1;
      totalAbsenceDays += days;
    }

    return totalAbsenceDays;
  }



  // Future<Duration> _calculateTotalWorkedTime(String email, DateTime date) async {
  //   Duration totalWorkedTime = Duration.zero;

  //   final holidays = await FirebaseFirestore.instance
  //       .collection('holidays')
  //       .where('endDate',
  //           isGreaterThanOrEqualTo: DateTime(date.year, date.month, 1))
  //       .where('startDate',
  //           isLessThanOrEqualTo: DateTime(date.year, date.month + 1, 0))
  //       .get();

  //   final checkinCheckouts = await FirebaseFirestore.instance
  //       .collection('user')
  //       .doc(email)
  //       .collection('checkincheckouts')
  //       .where('time',
  //           isGreaterThanOrEqualTo: DateTime(date.year, date.month, 1))
  //       .where('time',
  //           isLessThanOrEqualTo: DateTime(date.year, date.month + 1, 0))
  //       .orderBy('time')
  //       .get();

  //   for (var i = 0; i < checkinCheckouts.docs.length; i += 2) {
  //     if (i + 1 >= checkinCheckouts.docs.length) break;

  //     final checkinTime = checkinCheckouts.docs[i]['time'].toDate();
  //     final checkoutTime = checkinCheckouts.docs[i + 1]['time'].toDate();

  //     bool isHoliday = holidays.docs.any((holiday) {
  //       final holidayStart = holiday['startDate'].toDate();
  //       final holidayEnd = holiday['endDate'].toDate();
  //       return isDateInRange(checkinTime, holidayStart, holidayEnd);
  //     });

  //     if (!isHoliday) {
  //       totalWorkedTime += checkoutTime.difference(checkinTime);
  //     }
  //   }

  //   return totalWorkedTime;
  // }
  Future<Duration> _calculateTotalWorkedTime(String email, DateTime date) async {
  Duration totalWorkedTime = Duration.zero;

  final firstDay = DateTime(date.year, date.month, 1);
  final lastDay = DateTime(date.year, date.month + 1, 0);

  // Fetch holidays
  final holidays = await FirebaseFirestore.instance
      .collection('holidays')
      .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDay))
      .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(lastDay))
      .get();

  // Fetch check-in/check-out records
  final checkinCheckouts = await FirebaseFirestore.instance
      .collection('user')
      .doc(email)
      .collection('checkincheckouts')
      .where('time', isGreaterThanOrEqualTo: firstDay)
      .where('time', isLessThanOrEqualTo: lastDay)
      .orderBy('time')
      .get();

  DateTime? lastCheckInTime;
  for (var doc in checkinCheckouts.docs) {
    final data = doc.data();
    final timestamp = data['time'] as Timestamp;
    final time = timestamp.toDate();
    final isCheckIn = data['checkin'] == true;

    if (isCheckIn) {
      lastCheckInTime = time;
    } else if (!isCheckIn && lastCheckInTime != null) {
      // Check if this period overlaps with any holiday
      bool isHolidayPeriod = holidays.docs.any((holiday) {
        final holidayStart = (holiday['startDate'] as Timestamp).toDate();
        final holidayEnd = (holiday['endDate'] as Timestamp).toDate();
        return isDateInRange(lastCheckInTime!, holidayStart, holidayEnd) ||
               isDateInRange(time, holidayStart, holidayEnd);
      });

      if (!isHolidayPeriod) {
        totalWorkedTime += time.difference(lastCheckInTime!);
      }
      lastCheckInTime = null; // Reset after processing a pair
    }
  }

  // If currently checked in (last entry is check-in), add time up to now
  if (lastCheckInTime != null) {
    final now = DateTime.now();
    bool isHolidayPeriod = holidays.docs.any((holiday) {
      final holidayStart = (holiday['startDate'] as Timestamp).toDate();
      final holidayEnd = (holiday['endDate'] as Timestamp).toDate();
      return isDateInRange(lastCheckInTime!, holidayStart, holidayEnd) ||
             isDateInRange(now, holidayStart, holidayEnd);
    });
    if (!isHolidayPeriod) {
      totalWorkedTime += now.difference(lastCheckInTime!);
    }
  }

  return totalWorkedTime;
}

  bool isDateInRange(DateTime date, DateTime rangeStart, DateTime rangeEnd) {
    return date.isAfter(rangeStart.subtract(const Duration(days: 1))) &&
        date.isBefore(rangeEnd.add(const Duration(days: 1)));
  }

  Future<(num, num)> _calculateRewardAndPunishment(String email, DateTime date) async {
    num reward = 0;
    num punishment = 0;

    final rewardPunishment = await FirebaseFirestore.instance
        .collection('user')
        .doc(email)
        .collection('rewardpunishment')
        .where('date',
            isGreaterThanOrEqualTo: DateTime(date.year, date.month, 1))
        .where('date',
            isLessThanOrEqualTo: DateTime(date.year, date.month + 1, 0))
        .get();

    for (var doc in rewardPunishment.docs) {
      final type = doc['type'] as String?;
      final amount = doc['amount'] is String
          ? num.tryParse(doc['amount'] as String? ?? '0') ?? 0
          : (doc['amount'] as num? ?? 0);

      if (type == 'punishment') {
        punishment += amount;
      } else {
        reward += amount;
      }
    }

    return (reward, punishment);
  }

  Future<(num, num)> _calculateTaskRewardAndPunishment(String email, DateTime date) async {
    num taskReward = 0;
    num taskPunishment = 0;

    final taskRewardPunishment = await FirebaseFirestore.instance
        .collection('user')
        .doc(email)
        .collection('taskrewardpunishment')
        .where('date',
            isGreaterThanOrEqualTo: DateTime(date.year, date.month, 1))
        .where('date',
            isLessThanOrEqualTo: DateTime(date.year, date.month + 1, 0))
        .get();

    for (var doc in taskRewardPunishment.docs) {
      final type = doc['type'] as String?;
      final amount = doc['amount'] is String
          ? num.tryParse(doc['amount'] as String? ?? '0') ?? 0
          : (doc['amount'] as num? ?? 0);

      if (type == 'punishment') {
        taskPunishment += amount;
      } else {
        taskReward += amount;
      }
    }

    return (taskReward, taskPunishment);
  }

  Widget _buildEmployeeCard(String name, String phone, String email) {
    return SizedBox(
      height: 15.h,
      width: 90.w,
      child: Container(
        margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
        padding: EdgeInsets.all(1.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5),
          boxShadow: const [
            BoxShadow(color: Colors.grey, blurRadius: 5),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              "$name : ناو",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Text("$phone : ژمارەی مۆبایل", style: const TextStyle(fontSize: 15)),
            Text("$email : ئیمەیل", style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}