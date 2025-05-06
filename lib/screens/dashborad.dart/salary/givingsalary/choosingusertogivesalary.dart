import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/dashborad.dart/salary/givingsalary/givingsalary.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
              
              // Safely get all fields with defaults
              final name = data['name'] as String? ?? 'No Name';
              final phone = data['phonenumber'] as String? ?? 'No Phone';
              final email = data['email'] as String? ?? 'No Email';
              final salary = (data['salary'] as int? ?? 0);
              
              // Handle potentially missing fields
              final loan = data.containsKey('loan') 
                  ? data['loan'] as String? ?? '0'
                  : '0';
                  
              final num monthlyPayback = data.containsKey('monthlypayback')
                  ? (data['monthlypayback'] as num? ?? 0)
                  : 0;

              return GestureDetector(
                onTap: () {
                  _handleEmployeeTap(
                    context: context,
                    name: name,
                    email: email,
                    salary: salary,
                    loan: loan,
                    monthlyPayback: monthlyPayback,
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

  void _handleEmployeeTap({
    required BuildContext context,
    required String name,
    required String email,
    required int salary,
    required String loan,
    required num monthlyPayback,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('دڵنیایت لە پێدانی موچەی ئەم کارمەندە؟'),
        actions: [
          TextButton(
            onPressed: () => _proceedWithSalary(
              context,
              name,
              email,
              salary,
              loan,
              monthlyPayback,
            ),
            child: const Text('پێدانی موچە'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('پەشیمانبوونەوە'),
          ),
        ],
      ),
    );
  }


// In your ChoosingUserForGivingSalary widget
Future<void> _proceedWithSalary(
  BuildContext context,
  String name,
  String email,
  int salary,
  String loan,
  num monthlyPayback,
) async {
  final userDoc = await FirebaseFirestore.instance
      .collection('user')
      .doc(email)
      .get();
  
  final dailyWorkHours = userDoc['worktarget'] as int? ?? 8;
  
  // Get the user's selected work days
  List<int> workDays = [];
  final dynamicWeekdays = userDoc['weekdays'];
  
  if (dynamicWeekdays is List) {
    workDays = dynamicWeekdays.whereType<int>()
      .where((day) => day >= 1 && day <= 7)
      .toList();
  }
  
  if (workDays.isEmpty) {
    workDays = [6, 7, 1, 2, 3, 4]; // Sat, Sun, Mon, Tue, Wed, Thu
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
    final monthlyTarget = dailyWorkHours * workingDays;
    final (reward, punishment) = await _calculateRewardAndPunishment(email, dates[0]);

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
          loan: loan,
          monthlypayback: monthlyPayback,
          reward: reward,
          punishment: punishment,
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
Future<int> calculateWorkingDays(DateTime month, List<int> workDays) async {
  final firstDay = DateTime(month.year, month.month, 1);
  final lastDay = DateTime(month.year, month.month + 1, 0);
  
  // Get all holidays that overlap with this month
  final holidaysSnapshot = await FirebaseFirestore.instance
      .collection('holidays')
      .where('endDate', isGreaterThanOrEqualTo: Timestamp.fromDate(firstDay))
      .where('startDate', isLessThanOrEqualTo: Timestamp.fromDate(lastDay))
      .get();

  int workingDays = 0;
  
  for (DateTime day = firstDay; 
      day.isBefore(lastDay) || day.isAtSameMomentAs(lastDay); 
      day = day.add(const Duration(days: 1))) {
    
    // Check if day is a working day according to employee's schedule
    if (workDays.contains(day.weekday)) {
      bool isHoliday = false;
      
      // Check if this day falls within any holiday period
      for (var holidayDoc in holidaysSnapshot.docs) {
        final holidayStart = (holidayDoc['startDate'] as Timestamp).toDate();
        final holidayEnd = (holidayDoc['endDate'] as Timestamp).toDate();
        
        if ((day.isAfter(holidayStart) || day.isAtSameMomentAs(holidayStart)) &&
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

Future<int> _calculateMonthlyTarget(DateTime date, int dailyWorkHours, List<int> workDays) async {
  final daysInMonth = DateTime(date.year, date.month + 1, 0).day;
  int workDaysCount = 0;

  // Get all holidays for this month
  final holidays = await FirebaseFirestore.instance
      .collection('holidays')
      .where('endDate', isGreaterThanOrEqualTo: DateTime(date.year, date.month, 1))
      .where('startDate', isLessThanOrEqualTo: DateTime(date.year, date.month + 1, 0))
      .get();

  for (int day = 1; day <= daysInMonth; day++) {
    final currentDate = DateTime(date.year, date.month, day);
    final weekday = currentDate.weekday; // 1=Monday, 7=Sunday
    
    // Check if this is a work day
    if (workDays.contains(weekday)) {
      // Check if this day is in any holiday range
      bool isHoliday = holidays.docs.any((holiday) {
        final holidayStart = holiday['startDate'].toDate();
        final holidayEnd = holiday['endDate'].toDate();
        return isDateInRange(currentDate, holidayStart, holidayEnd);
      });
      
      if (!isHoliday) {
        workDaysCount++;
      }
    }
  }

  return dailyWorkHours * workDaysCount;
}

  Future<Duration> _calculateTotalWorkedTime(String email, DateTime date) async {
  Duration totalWorkedTime = Duration.zero;

  // Get all holidays that overlap with this month
  final holidays = await FirebaseFirestore.instance
      .collection('holidays')
      .where('endDate', isGreaterThanOrEqualTo: DateTime(date.year, date.month, 1))
      .where('startDate', isLessThanOrEqualTo: DateTime(date.year, date.month + 1, 0))
      .get();

  final checkinCheckouts = await FirebaseFirestore.instance
      .collection('user')
      .doc(email)
      .collection('checkincheckouts')
      .where('time', isGreaterThanOrEqualTo: DateTime(date.year, date.month, 1))
      .where('time', isLessThanOrEqualTo: DateTime(date.year, date.month + 1, 0))
      .orderBy('time')
      .get();

  for (var i = 0; i < checkinCheckouts.docs.length; i += 2) {
    if (i + 1 >= checkinCheckouts.docs.length) break;
    
    final checkinTime = checkinCheckouts.docs[i]['time'].toDate();
    final checkoutTime = checkinCheckouts.docs[i + 1]['time'].toDate();
    
    // Skip if this day is a holiday
    bool isHoliday = holidays.docs.any((holiday) {
      final holidayStart = holiday['startDate'].toDate();
      final holidayEnd = holiday['endDate'].toDate();
      return isDateInRange(checkinTime, holidayStart, holidayEnd);
    });
    
    if (!isHoliday) {
      totalWorkedTime += checkoutTime.difference(checkinTime);
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
        .where('date', isGreaterThanOrEqualTo: DateTime(date.year, date.month, 1))
        .where('date', isLessThanOrEqualTo: DateTime(date.year, date.month + 1, 0))
        .get();

    for (var doc in rewardPunishment.docs) {
      final type = doc['type'] as String?;
      final amount = num.tryParse(doc['amount'] as String? ?? '0') ?? 0;
      
      if (type == 'punishment') {
        punishment += amount;
      } else {
        reward += amount;
      }
    }
    
    return (reward, punishment);
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
            Text("$name : ناو", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            Text("$phone : ژمارەی مۆبایل", style: const TextStyle(fontSize: 15)),
            Text("$email : ئیمەیل", style: const TextStyle(fontSize: 15)),
          ],
        ),
      ),
    );
  }
}