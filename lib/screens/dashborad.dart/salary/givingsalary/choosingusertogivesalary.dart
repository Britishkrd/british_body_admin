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
  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  bool _dayOverlapsRange(DateTime dayStart, DateTime rangeStart, DateTime rangeEnd) {
    final dayEnd = dayStart.add(const Duration(days: 1));
    return dayEnd.isAfter(rangeStart) && dayStart.isBefore(rangeEnd);
  }

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
                      ? (num.tryParse(data['monthlypayback'] as String) ?? 0)
                          .toInt()
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
    int monthlyPayback,
  ) async {
    final userDoc =
        await FirebaseFirestore.instance.collection('user').doc(email).get();

    final userData = (userDoc.data() as Map<String, dynamic>?) ?? {};

    final dailyWorkHours = (userData['worktarget'] as num?)?.toInt() ?? 8;

    List<int> workDays = [];
    final dynamicWeekdays = userData['weekdays'];

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
      final selectedMonth = dates[0];

      final totalWorkedTime = await _calculateTotalWorkedTime(email, selectedMonth);

      // Working days in salary period (only workDays, excluding holidays)
      final workingDays = await calculateWorkingDays(selectedMonth, workDays);

      // Approved leave duration in salary period (hours/minutes)
      final absenceDuration = await _calculateAbsenceDuration(
        email: email,
        selectedMonth: selectedMonth,
        workDays: workDays,
        dailyWorkHours: dailyWorkHours,
      );

      // Monthly target (minutes): workDays * dailyWorkHours minus approved leave minutes
      final totalTargetMinutes = workingDays * dailyWorkHours * 60;
      final targetAfterLeaveMinutes =
          totalTargetMinutes - absenceDuration.inMinutes;
      final monthlyTargetDuration = Duration(
        minutes: targetAfterLeaveMinutes < 0 ? 0 : targetAfterLeaveMinutes,
      );

      final (reward, punishment) =
          await _calculateRewardAndPunishment(email, selectedMonth);
      final (taskReward, taskPunishment) =
          await _calculateTaskRewardAndPunishment(email, selectedMonth);

      if (!mounted) return;
      Navigator.pop(context);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Givingsalary(
            name: name,
            adminemail: widget.email,
            email: email,
            date: selectedMonth,
            totalworkedtime: totalWorkedTime,
            workTarget: monthlyTargetDuration,
            salary: salary,
            loan: loan.toString(),
            monthlypayback: monthlyPayback,
            reward: reward,
            punishment: punishment,
            taskreward: taskReward,
            taskpunishment: taskPunishment,
            absenceDuration: absenceDuration,
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

  // Salary period: 26th of previous month to 25th of selected month
  (DateTime start, DateTime end) _getSalaryPeriod(DateTime selectedMonth) {
    final startDate = DateTime(selectedMonth.year, selectedMonth.month - 1, 26);
    final endDate =
        DateTime(selectedMonth.year, selectedMonth.month, 25, 23, 59, 59);
    return (startDate, endDate);
  }

  Future<int> calculateWorkingDays(DateTime month, List<int> workDays) async {
    final (firstDay, lastDay) = _getSalaryPeriod(month);

    final holidaysSnapshot = await FirebaseFirestore.instance
        .collection('holidays')
        .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDay))
        .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(lastDay))
        .get();

    final holidayRanges = holidaysSnapshot.docs.map((d) {
      final s = (d['startDate'] as Timestamp).toDate();
      final e = (d['endDate'] as Timestamp).toDate();
      return (s, e);
    }).toList();

    bool isHolidayDay(DateTime dayStart) {
      final dayEnd = dayStart.add(const Duration(days: 1));
      return holidayRanges.any((r) => dayEnd.isAfter(r.$1) && dayStart.isBefore(r.$2));
    }

    int workingDaysCount = 0;
    DateTime day = _dateOnly(firstDay);
    final last = _dateOnly(lastDay);

    while (!day.isAfter(last)) {
      if (workDays.contains(day.weekday)) {
        if (!isHolidayDay(day)) {
          workingDaysCount++;
        }
      }
      day = day.add(const Duration(days: 1));
    }

    return workingDaysCount;
  }

  Future<Duration> _calculateAbsenceDuration({
    required String email,
    required DateTime selectedMonth,
    required List<int> workDays,
    required int dailyWorkHours,
  }) async {
    final (periodStart, periodEnd) = _getSalaryPeriod(selectedMonth);

    // Holidays in the salary period
    final holidaysSnapshot = await FirebaseFirestore.instance
        .collection('holidays')
        .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(periodStart))
        .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(periodEnd))
        .get();

    final holidayRanges = holidaysSnapshot.docs.map((d) {
      final s = (d['startDate'] as Timestamp).toDate();
      final e = (d['endDate'] as Timestamp).toDate();
      return (s, e);
    }).toList();

    bool isHolidayDay(DateTime dayStart) {
      final dayEnd = dayStart.add(const Duration(days: 1));
      return holidayRanges.any((r) => dayEnd.isAfter(r.$1) && dayStart.isBefore(r.$2));
    }

    // Approved absences overlapping the salary period
    final absenceSnapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(email)
        .collection('absentmanagement')
        .where('status', isEqualTo: 'accepted')
        .where('start', isLessThanOrEqualTo: Timestamp.fromDate(periodEnd))
        .where('end', isGreaterThanOrEqualTo: Timestamp.fromDate(periodStart))
        .get();

    // Collect intervals per day (to merge overlaps)
    final Map<DateTime, List<(DateTime, DateTime)>> intervalsByDay = {};

    for (final doc in absenceSnapshot.docs) {
      final start = (doc['start'] as Timestamp).toDate();
      final end = (doc['end'] as Timestamp).toDate();

      // clamp to salary period
      final aStart = start.isBefore(periodStart) ? periodStart : start;
      final aEnd = end.isAfter(periodEnd) ? periodEnd : end;
      if (!aEnd.isAfter(aStart)) continue;

      DateTime day = _dateOnly(aStart);
      final lastDay = _dateOnly(aEnd);

      while (!day.isAfter(lastDay)) {
        final dayStart = day;
        final dayEnd = dayStart.add(const Duration(days: 1));

        final segStart = aStart.isAfter(dayStart) ? aStart : dayStart;
        final segEnd = aEnd.isBefore(dayEnd) ? aEnd : dayEnd;

        if (segEnd.isAfter(segStart)) {
          intervalsByDay.putIfAbsent(dayStart, () => []).add((segStart, segEnd));
        }

        day = day.add(const Duration(days: 1));
      }
    }

    final maxMinutesPerDay = dailyWorkHours * 60;
    int totalMinutes = 0;

    for (final entry in intervalsByDay.entries) {
      final dayStart = entry.key;

      // only count on workdays and not holidays
      if (!workDays.contains(dayStart.weekday)) continue;
      if (isHolidayDay(dayStart)) continue;

      final intervals = entry.value..sort((a, b) => a.$1.compareTo(b.$1));

      // merge intervals to avoid double counting
      DateTime curStart = intervals.first.$1;
      DateTime curEnd = intervals.first.$2;

      int dayMinutes = 0;

      for (final interval in intervals.skip(1)) {
        final s = interval.$1;
        final e = interval.$2;

        if (s.isAfter(curEnd)) {
          dayMinutes += curEnd.difference(curStart).inMinutes;
          curStart = s;
          curEnd = e;
        } else {
          if (e.isAfter(curEnd)) curEnd = e;
        }
      }
      dayMinutes += curEnd.difference(curStart).inMinutes;

      // cap to dailyWorkHours per day
      if (dayMinutes > maxMinutesPerDay) dayMinutes = maxMinutesPerDay;

      totalMinutes += dayMinutes;
    }

    return Duration(minutes: totalMinutes);
  }

  Future<Duration> _calculateTotalWorkedTime(String email, DateTime date) async {
    Duration totalWorkedTime = Duration.zero;

    final (firstDay, lastDay) = _getSalaryPeriod(date);

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
        bool isHolidayPeriod = holidays.docs.any((holiday) {
          final holidayStart = (holiday['startDate'] as Timestamp).toDate();
          final holidayEnd = (holiday['endDate'] as Timestamp).toDate();
          return _dayOverlapsRange(
                _dateOnly(lastCheckInTime!),
                holidayStart,
                holidayEnd,
              ) ||
              _dayOverlapsRange(
                _dateOnly(time),
                holidayStart,
                holidayEnd,
              );
        });

        if (!isHolidayPeriod) {
          totalWorkedTime += time.difference(lastCheckInTime!);
        }
        lastCheckInTime = null;
      }
    }

    // If currently checked in
    if (lastCheckInTime != null) {
      final now = DateTime.now();
      bool isHolidayPeriod = holidays.docs.any((holiday) {
        final holidayStart = (holiday['startDate'] as Timestamp).toDate();
        final holidayEnd = (holiday['endDate'] as Timestamp).toDate();
        return _dayOverlapsRange(_dateOnly(lastCheckInTime!), holidayStart, holidayEnd) ||
            _dayOverlapsRange(_dateOnly(now), holidayStart, holidayEnd);
      });
      if (!isHolidayPeriod) {
        totalWorkedTime += now.difference(lastCheckInTime!);
      }
    }

    return totalWorkedTime;
  }

  Future<(num, num)> _calculateRewardAndPunishment(
      String email, DateTime date) async {
    num reward = 0;
    num punishment = 0;

    final (firstDay, lastDay) = _getSalaryPeriod(date);

    final rewardPunishment = await FirebaseFirestore.instance
        .collection('user')
        .doc(email)
        .collection('rewardpunishment')
        .where('date', isGreaterThanOrEqualTo: firstDay)
        .where('date', isLessThanOrEqualTo: lastDay)
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

  Future<(num, num)> _calculateTaskRewardAndPunishment(
      String email, DateTime date) async {
    num taskReward = 0;
    num taskPunishment = 0;

    final (firstDay, lastDay) = _getSalaryPeriod(date);

    final taskRewardPunishment = await FirebaseFirestore.instance
        .collection('user')
        .doc(email)
        .collection('taskrewardpunishment')
        .where('date', isGreaterThanOrEqualTo: firstDay)
        .where('date', isLessThanOrEqualTo: lastDay)
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
            Text("$phone : ژمارەی مۆبایل",
                style: const TextStyle(fontSize: 15)),
            Text("$email : ئیمەیل", style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}