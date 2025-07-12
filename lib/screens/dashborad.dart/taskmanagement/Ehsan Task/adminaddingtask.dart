// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:sizer/sizer.dart';
// import 'package:intl/intl.dart';
// import 'package:british_body_admin/material/materials.dart';

// class AdminAddingTask extends StatefulWidget {
//   final bool isbatch;
//   final List<String> selectedUsers;
//   final String adminemail;
//   final String email;

//   const AdminAddingTask({
//     super.key,
//     required this.isbatch,
//     required this.selectedUsers,
//     required this.adminemail,
//     required this.email,
//   });

//   @override
//   State<AdminAddingTask> createState() => _AdminAddingTaskState();
// }

// class _AdminAddingTaskState extends State<AdminAddingTask> {
//   final TextEditingController _taskNameController = TextEditingController();
//   final TextEditingController _rewardAmountController = TextEditingController();
//   final TextEditingController _deductionAmountController = TextEditingController();
//   DateTime? _startDate;
//   DateTime? _endDate;
//   TimeOfDay? _taskTime;
//   final List<bool> _selectedDays = List.generate(7, (_) => false); // Sun to Sat
//   final List<String> _daysOfWeek = [
//     'Sunday', // Index 0
//     'Monday',
//     'Tuesday',
//     'Wednesday',
//     'Thursday',
//     'Friday', // Index 5
//     'Saturday'
//   ];
//   Map<String, List<int>> userWorkdays = {}; // Store workdays for each user

//   @override
//   void initState() {
//     super.initState();
//     _fetchUserWorkdays();
//   }

//   Future<void> _fetchUserWorkdays() async {
//     final users = widget.isbatch ? widget.selectedUsers : [widget.email];
//     for (String userEmail in users) {
//       final doc = await FirebaseFirestore.instance
//           .collection('user')
//           .doc(userEmail)
//           .get();
//       if (doc.exists) {
//         final List<dynamic> weekdays = doc['weekdays'] ?? [];
//         setState(() {
//           userWorkdays[userEmail] = weekdays.cast<int>();
//         });
//       }
//     }
//   }

//   Future<void> _selectDate(BuildContext context, bool isStart) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime.now(),
//       lastDate: DateTime(2100),
//     );
//     if (picked != null) {
//       setState(() {
//         if (isStart) {
//           _startDate = picked;
//         } else {
//           _endDate = picked;
//         }
//       });
//     }
//   }

//   Future<void> _selectTime(BuildContext context) async {
//     final TimeOfDay? picked = await showTimePicker(
//       context: context,
//       initialTime: TimeOfDay.now(),
//     );
//     if (picked != null) {
//       setState(() {
//         _taskTime = picked;
//       });
//     }
//   }

//   Future<void> _addTasks() async {
//   // Validate inputs
//   if (_taskNameController.text.isEmpty ||
//       _startDate == null ||
//       _endDate == null ||
//       _taskTime == null ||
//       !_selectedDays.contains(true) ||
//       _rewardAmountController.text.isEmpty ||
//       _deductionAmountController.text.isEmpty) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//           content: Text(
//               'Please fill all fields, select at least one day, and provide reward and deduction amounts')),
//     );
//     return;
//   }

//   // Validate reward and deduction amounts are valid numbers
//   final rewardAmount = double.tryParse(_rewardAmountController.text);
//   final deductionAmount = double.tryParse(_deductionAmountController.text);
//   if (rewardAmount == null || deductionAmount == null) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Please enter valid amounts for reward and deduction')),
//     );
//     return;
//   }

//   final users = widget.isbatch ? widget.selectedUsers : [widget.email];

//   for (String userEmail in users) {
//     // Get user's working days
//     final List<int> workdays = userWorkdays[userEmail] ?? [];
//     if (workdays.isEmpty) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('No workdays defined for $userEmail')),
//       );
//       continue;
//     }

//     // Track dates for which tasks have been created to avoid duplicates
//     Set<String> processedDates = {};

//     DateTime currentDate = _startDate!;
//     while (currentDate.isBefore(_endDate!.add(const Duration(days: 1)))) {
//       // Format date as a string for comparison (e.g., "2025-07-12")
//       String dateKey = DateFormat('yyyy-MM-dd').format(currentDate);

//       // Skip if a task was already created for this date
//       if (processedDates.contains(dateKey)) {
//         currentDate = currentDate.add(const Duration(days: 1));
//         continue;
//       }

//       int dayIndex = currentDate.weekday % 7; // Sunday=0, Monday=1, ..., Saturday=6
//       // Convert dayIndex to match your dayKey (1=Mon, 2=Tue, ..., 7=Sun)
//       int firestoreDayIndex = dayIndex == 0 ? 7 : dayIndex;

//       // Check if the selected day is a workday for the user and is selected for the task
//       if (_selectedDays[dayIndex] && workdays.contains(firestoreDayIndex)) {
//         final taskId = FirebaseFirestore.instance
//             .collection('user')
//             .doc(userEmail)
//             .collection('tasks')
//             .doc()
//             .id;

//         final deadline = DateTime(
//           currentDate.year,
//           currentDate.month,
//           currentDate.day,
//           _taskTime!.hour,
//           _taskTime!.minute,
//         );

//         final taskData = {
//           'taskId': taskId,
//           'taskName': _taskNameController.text,
//           'adminEmail': widget.adminemail,
//           'userEmail': userEmail,
//           'deadline': Timestamp.fromDate(deadline),
//           'status': 'pending', // pending, completed, unfinished
//           'createdAt': Timestamp.now(),
//           'rewardAmount': rewardAmount,
//           'deductionAmount': deductionAmount,
//         };

//         await FirebaseFirestore.instance
//             .collection('user')
//             .doc(userEmail)
//             .collection('tasks')
//             .doc(taskId)
//             .set(taskData);

//         // Mark this date as processed
//         processedDates.add(dateKey);
//       }
//       currentDate = currentDate.add(const Duration(days: 1));
//     }
//   }

//   Navigator.pop(context);
//   ScaffoldMessenger.of(context).showSnackBar(
//     const SnackBar(content: Text('Tasks added successfully')),
//   );
// }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add Task'),
//         foregroundColor: Colors.white,
//         backgroundColor: Material1.primaryColor,
//         centerTitle: true,
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(5.w),
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               TextField(
//                 controller: _taskNameController,
//                 decoration: const InputDecoration(labelText: 'Task Name'),
//               ),
//               SizedBox(height: 2.h),
//               TextField(
//                 controller: _rewardAmountController,
//                 decoration: const InputDecoration(labelText: 'Reward Amount'),
//                 keyboardType: TextInputType.number,
//               ),
//               SizedBox(height: 2.h),
//               TextField(
//                 controller: _deductionAmountController,
//                 decoration: const InputDecoration(labelText: 'Deduction Amount'),
//                 keyboardType: TextInputType.number,
//               ),
//               SizedBox(height: 2.h),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(_startDate == null
//                       ? 'Select Start Date'
//                       : DateFormat('dd/MM/yyyy').format(_startDate!)),
//                   ElevatedButton(
//                     onPressed: () => _selectDate(context, true),
//                     child: const Text('Pick Start Date'),
//                   ),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(_endDate == null
//                       ? 'Select End Date'
//                       : DateFormat('dd/MM/yyyy').format(_endDate!)),
//                   ElevatedButton(
//                     onPressed: () => _selectDate(context, false),
//                     child: const Text('Pick End Date'),
//                   ),
//                 ],
//               ),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(_taskTime == null
//                       ? 'Select Time'
//                       : _taskTime!.format(context)),
//                   ElevatedButton(
//                     onPressed: () => _selectTime(context),
//                     child: const Text('Pick Time'),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 2.h),
//               const Text('Select Days of the Week:'),
//               Wrap(
//                 spacing: 2.w,
//                 children: List.generate(7, (index) {
//                   return ChoiceChip(
//                     label: Text(_daysOfWeek[index]),
//                     selected: _selectedDays[index],
//                     onSelected: (selected) {
//                       setState(() {
//                         _selectedDays[index] = selected;
//                       });
//                     },
//                   );
//                 }),
//               ),
//               SizedBox(height: 2.h),
//               Center(
//                 child: Material1.button(
//                   label: 'Add Task',
//                   buttoncolor: Material1.primaryColor,
//                   textcolor: Colors.white,
//                   function: _addTasks,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:sizer/sizer.dart';

class AdminAddingTask extends StatefulWidget {
  final bool isbatch;
  final List<String> selectedUsers;
  final String adminemail;
  final String email;

  const AdminAddingTask({
    super.key,
    required this.isbatch,
    required this.selectedUsers,
    required this.adminemail,
    required this.email,
  });

  @override
  State<AdminAddingTask> createState() => _AdminAddingTaskState();
}

class _AdminAddingTaskState extends State<AdminAddingTask> {
  final TextEditingController _taskNameController = TextEditingController();
  final TextEditingController _rewardAmountController = TextEditingController();
  final TextEditingController _deductionAmountController =
      TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  TimeOfDay? _taskTime;
  final List<bool> _selectedDays = List.generate(7, (_) => false);
  final List<String> _daysOfWeek = [
    '١ شەممە',
    '٢ شەممە',
    '٣ شەممە',
    '٤ شەممە',
    '٥ شەممە',
    'هەینی',
    'شەممە'
  ];
  Map<String, List<int>> userWorkdays = {};

  @override
  void initState() {
    super.initState();
    _fetchUserWorkdays();
  }

  Future<void> _fetchUserWorkdays() async {
    final users = widget.isbatch ? widget.selectedUsers : [widget.email];
    for (String userEmail in users) {
      final doc = await FirebaseFirestore.instance
          .collection('user')
          .doc(userEmail)
          .get();
      if (doc.exists) {
        final List<dynamic> weekdays = doc['weekdays'] ?? [];
        setState(() {
          userWorkdays[userEmail] = weekdays.cast<int>();
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Material1.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Material1.primaryColor,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
            dialogTheme: DialogThemeData(backgroundColor: Colors.white),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _taskTime = picked;
      });
    }
  }

  Future<void> _addTasks() async {
    if (_taskNameController.text.isEmpty ||
        _startDate == null ||
        _endDate == null ||
        _taskTime == null ||
        !_selectedDays.contains(true) ||
        _rewardAmountController.text.isEmpty ||
        _deductionAmountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill all required fields'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final rewardAmount = double.tryParse(_rewardAmountController.text);
    final deductionAmount = double.tryParse(_deductionAmountController.text);
    if (rewardAmount == null || deductionAmount == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter valid amounts'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final users = widget.isbatch ? widget.selectedUsers : [widget.email];

    for (String userEmail in users) {
      final List<int> workdays = userWorkdays[userEmail] ?? [];
      if (workdays.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No workdays defined for $userEmail'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
        continue;
      }

      Set<String> processedDates = {};
      DateTime currentDate = _startDate!;

      while (currentDate.isBefore(_endDate!.add(const Duration(days: 1)))) {
        String dateKey = intl.DateFormat('yyyy-MM-dd').format(currentDate);
        if (processedDates.contains(dateKey)) {
          currentDate = currentDate.add(const Duration(days: 1));
          continue;
        }

        int dayIndex = currentDate.weekday % 7;
        int firestoreDayIndex = dayIndex == 0 ? 7 : dayIndex;

        if (_selectedDays[dayIndex] && workdays.contains(firestoreDayIndex)) {
          final taskId = FirebaseFirestore.instance
              .collection('user')
              .doc(userEmail)
              .collection('tasks')
              .doc()
              .id;

          final deadline = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            _taskTime!.hour,
            _taskTime!.minute,
          );

          final taskData = {
            'taskId': taskId,
            'taskName': _taskNameController.text,
            'adminEmail': widget.adminemail,
            'userEmail': userEmail,
            'deadline': Timestamp.fromDate(deadline),
            'status': 'pending',
            'createdAt': Timestamp.now(),
            'rewardAmount': rewardAmount,
            'deductionAmount': deductionAmount,
          };

          await FirebaseFirestore.instance
              .collection('user')
              .doc(userEmail)
              .collection('tasks')
              .doc(taskId)
              .set(taskData);

          processedDates.add(dateKey);
        }
        currentDate = currentDate.add(const Duration(days: 1));
      }
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('بەسەرکەوتویی ئەرکەکە زیادکرا'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('زیادکردنی ئەرکی نوێ',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          foregroundColor: Colors.white,
          backgroundColor: Material1.primaryColor,
          centerTitle: true,
          elevation: 0,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(15),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'وردەکاری تاسکەکە',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 2.h),
              _buildModernTextField(
                controller: _taskNameController,
                label: 'ناونیشان',
                icon: Icons.task,
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Expanded(
                    child: _buildModernTextField(
                      controller: _rewardAmountController,
                      label: 'بڕی پاداشت',
                      icon: Icons.monetization_on,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: _buildModernTextField(
                      controller: _deductionAmountController,
                      label: 'بڕی سزا',
                      icon: Icons.money_off,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 3.h),
              Text(
                'بەروار',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 2.h),
              _buildDateSelector(
                label: 'بەرواری دەسپێک',
                value: _startDate,
                onTap: () => _selectDate(context, true),
              ),
              SizedBox(height: 2.h),
              _buildDateSelector(
                label: 'بەرواری کۆتا',
                value: _endDate,
                onTap: () => _selectDate(context, false),
              ),
              SizedBox(height: 2.h),
              _buildDateSelector(
                label: 'کات',
                value: _taskTime?.format(context),
                onTap: () => _selectTime(context),
                isTime: true,
              ),
              SizedBox(height: 3.h),
              Text(
                'ڕۆژانی دووبارەبوونەوە',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 1.h),
              _buildDaySelector(),
              SizedBox(height: 4.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _addTasks,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Material1.primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 2.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                  child: Text(
                    widget.isbatch
                        ? 'زیادکردنی ئەرکی بەکۆمەڵ'
                        : 'زیادکردنی ئەرک',
                    style: TextStyle(fontSize: 17.sp),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Material1.primaryColor),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Material1.primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildDateSelector({
    required String label,
    required dynamic value,
    required VoidCallback onTap,
    bool isTime = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 0.5.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value == null
                      ? 'دیاریکردنی ${isTime ? 'کات' : 'بەروار'}'
                      : isTime
                          ? value
                          : intl.DateFormat('dd/MM/yyyy').format(value),
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: value == null ? Colors.grey.shade600 : Colors.black,
                  ),
                ),
                Icon(
                  isTime ? Icons.access_time : Icons.calendar_today,
                  color: Material1.primaryColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDaySelector() {
    return Container(
      padding: EdgeInsets.all(2.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Wrap(
        spacing: 3.w,
        runSpacing: 3.w,
        children: List.generate(7, (index) {
          return ChoiceChip(
            label: Text(_daysOfWeek[index]),
            selected: _selectedDays[index],
            onSelected: (selected) {
              setState(() {
                _selectedDays[index] = selected;
              });
            },
            selectedColor: Material1.primaryColor,
            labelStyle: TextStyle(
              color: _selectedDays[index] ? Colors.white : Colors.black,
              fontSize: 16.sp,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          );
        }),
      ),
    );
  }
}
