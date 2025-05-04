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

  Future<void> _proceedWithSalary(
    BuildContext context,
    String name,
    String email,
    int salary,
    String loan,
    num monthlyPayback,
  ) async {
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
      final workTarget = await _calculateWorkTarget();
      final (reward, punishment) = await _calculateRewardAndPunishment(email, dates[0]);

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Givingsalary(
            name: name,
            adminemail: widget.email,
            email: email,
            date: dates[0],
            totalworkedtime: totalWorkedTime,
            worktarget: workTarget.inHours,
            salary:salary,
            loan: loan,
            monthlypayback:monthlyPayback,
            reward: reward,
            punishment: punishment,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<Duration> _calculateTotalWorkedTime(String email, DateTime date) async {
    Duration totalWorkedTime = Duration.zero;
    
    final checkinCheckouts = await FirebaseFirestore.instance
        .collection('user')
        .doc(email)
        .collection('checkincheckouts')
        .where('time', isGreaterThanOrEqualTo: DateTime(date.year, date.month, 1))
        .where('time', isLessThanOrEqualTo: DateTime(date.year, date.month + 1, 0))
        .get();

    for (var i = 0; i < checkinCheckouts.docs.length; i += 2) {
      if (i + 1 >= checkinCheckouts.docs.length) break;
      
      if (checkinCheckouts.docs[i]['checkin'] == false) {
        if (i + 2 >= checkinCheckouts.docs.length) break;
        totalWorkedTime += checkinCheckouts.docs[i + 2]['time'].toDate()
            .difference(checkinCheckouts.docs[i + 1]['time'].toDate());
      } else {
        totalWorkedTime += checkinCheckouts.docs[i + 1]['time'].toDate()
            .difference(checkinCheckouts.docs[i]['time'].toDate());
      }
    }
    
    return totalWorkedTime;
  }

  Future<Duration> _calculateWorkTarget() async {
    final prefs = await SharedPreferences.getInstance();
    final starthour = prefs.getInt('starthour') ?? 0;
    final endhour = prefs.getInt('endhour') ?? 0;
    final startmin = prefs.getInt('startmin') ?? 0;
    final endmin = prefs.getInt('endmin') ?? 0;
    
    return Duration(
      hours: endhour - starthour,
      minutes: endmin - startmin,
    );
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