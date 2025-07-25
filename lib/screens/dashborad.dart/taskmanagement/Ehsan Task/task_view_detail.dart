import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/dashborad.dart/taskmanagement/Ehsan%20Task/send_task_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class TaskViewDetail extends StatefulWidget {
  final String email;

  const TaskViewDetail({super.key, required this.email});

  @override
  State<TaskViewDetail> createState() => _TaskViewDetailState();
}

class _TaskViewDetailState extends State<TaskViewDetail> {
  DateTime? _selectedMonth;
  final List<String> _monthNames = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];

  @override
  void initState() {
    super.initState();
    _selectedMonth = DateTime.now();
  }

  Future<void> _updateTaskStatus(String taskId, String newStatus,
      {double? deductionAmount, String? taskName}) async {
    await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.email)
        .collection('tasks')
        .doc(taskId)
        .update({'status': newStatus});

    if (newStatus == 'unfinished' &&
        deductionAmount != null &&
        deductionAmount > 0 &&
        taskName != null) {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.email)
          .collection('taskrewardpunishment')
          .add({
        'addedby': widget.email,
        'amount': deductionAmount,
        'date': Timestamp.now(),
        'reason': 'for not completing task $taskName on time',
        'type': 'punishment',
      });
    }
  }

  Future<void> _checkAndUpdateUnfinishedTasks() async {
    final tasksSnapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.email)
        .collection('tasks')
        .where('status', isEqualTo: 'pending')
        .get();

    for (var doc in tasksSnapshot.docs) {
      final deadline = (doc['deadline'] as Timestamp).toDate();
      final taskData = doc.data();
      final deductionAmount = taskData['deductionAmount']?.toDouble() ?? 0.0;
      final taskName = taskData['taskName'] ?? 'Unknown Task';

      if (deadline.isBefore(DateTime.now()) && doc['status'] == 'pending') {
        await _updateTaskStatus(
          doc['taskId'],
          'unfinished',
          deductionAmount: deductionAmount,
          taskName: taskName,
        );
      }
    }
  }

  Future<void> _launchURL(String url) async {
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }

    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('نەتوانرا لینکەکە بکرێتەوە'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  bool _isTaskDue(DateTime deadline) {
    final now = DateTime.now();
    return now.year >= deadline.year &&
        now.month >= deadline.month &&
        now.day >= deadline.day;
  }

  String _getStatusDisplayText(String status) {
    switch (status) {
      case 'pending':
        return 'چاوەڕوانی';
      case 'completed':
        return 'تەواو بووە';
      case 'unfinished':
        return 'تەواوە نەبووە';
      case 'complete after unfinished':
        return 'درەنگ تەواو بووە';
      default:
        return status;
    }
  }

  LinearGradient _getStatusGradient(String status) {
    switch (status) {
      case 'completed':
        return LinearGradient(
          colors: [Colors.green.shade400, Colors.green.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'unfinished':
        return LinearGradient(
          colors: [Colors.red.shade400, Colors.red.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      case 'complete after unfinished':
        return LinearGradient(
          colors: [Colors.blue.shade400, Colors.blue.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
      default:
        return LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  Future<void> _selectMonth(BuildContext context) async {
    final DateTime? picked = await MonthYearPickerDialog.show(
      context: context,
      selectedDate: _selectedMonth ?? DateTime.now(),
      firstDate: DateTime(2025, 1, 1),
      lastDate: DateTime(2100),
      pastMonthHighlightColor: Material1.primaryColor,
    );

    if (picked != null) {
      setState(() {
        _selectedMonth = picked;
      });
    }
  }

  void _clearFilter() {
    setState(() {
      _selectedMonth = DateTime.now();
    });
  }

  List<QueryDocumentSnapshot> _filterTasksByMonth(
      List<QueryDocumentSnapshot> tasks) {
    if (_selectedMonth == null) return tasks;

    return tasks.where((task) {
      final deadline = (task['deadline'] as Timestamp).toDate();
      return deadline.year == _selectedMonth!.year &&
          deadline.month == _selectedMonth!.month;
    }).toList();
  }

  Widget _buildDateFilterButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            onTap: () => _selectMonth(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: Material1.primaryColor,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.calendar_month,
                    color: Colors.white,
                    size: 20.sp,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    _selectedMonth == null
                        ? 'دیاریکردنی مانگ'
                        : '${_monthNames[_selectedMonth!.month - 1]} ${_selectedMonth!.year}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 2.w),
          InkWell(
            onTap: () {
              setState(() {
                if (_selectedMonth == null) {
                  _selectedMonth = DateTime.now();
                } else {
                  _selectedMonth = null;
                }
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.h),
              decoration: BoxDecoration(
                color: _selectedMonth == null
                    ? Colors.deepOrange.shade800
                    : Colors.blue.shade800,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                _selectedMonth == null ? 'ئەرکی ئەم مانگە' : 'هەموو ئەرکەکان',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'kurdish',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Column(
          children: [
            _buildDateFilterButton(),
            Expanded(
              child: FutureBuilder(
                future: _checkAndUpdateUnfinishedTasks(),
                builder: (context, snapshot) {
                  return StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection('user')
                        .doc(widget.email)
                        .collection('tasks')
                        .orderBy('deadline', descending: false)
                        .snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                            child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Material1.primaryColor)));
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return Center(
                          child: Text('هیچ ئەرکێک نەدۆزرایەوە',
                              style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Colors.grey.shade600,
                                  fontFamily: 'kurdish')),
                        );
                      }

                      final filteredTasks =
                          _filterTasksByMonth(snapshot.data!.docs);

                      if (filteredTasks.isEmpty && _selectedMonth != null) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.event_busy,
                                size: 60.sp,
                                color: Colors.grey.shade400,
                              ),
                              SizedBox(height: 2.h),
                              Text(
                                'هیچ ئەرکێک لەم مانگەدا نەدۆزرایەوە',
                                style: TextStyle(
                                    fontSize: 18.sp,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 1.h),
                              Text(
                                '${_monthNames[_selectedMonth!.month - 1]} ${_selectedMonth!.year}',
                                style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding: EdgeInsets.symmetric(
                            vertical: 1.h, horizontal: 3.w),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          final deadline =
                              (task['deadline'] as Timestamp).toDate();
                          final status = task['status'];
                          final isDue = _isTaskDue(deadline);
                          final rewardAmount =
                              task['rewardAmount']?.toDouble() ?? 0.0;
                          final deductionAmount =
                              task['deductionAmount']?.toDouble() ?? 0.0;
                          final taskData = task.data() as Map<String, dynamic>?;
                          final submissionLinks = taskData != null &&
                                  taskData.containsKey('submissionLinks')
                              ? List<String>.from(task['submissionLinks'] ?? [])
                              : [];

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => SendTaskDetails(
                                    email: widget.email,
                                    taskId: task['taskId'],
                                    taskName: task['taskName'],
                                    deadline: task['deadline'],
                                    status: task['status'],
                                  ),
                                ),
                              );
                            },
                            child: Container(
                              margin: EdgeInsets.only(bottom: 2.h),
                              decoration: BoxDecoration(
                                gradient: _getStatusGradient(status),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(3.w),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 1.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            task['taskName'],
                                            style: TextStyle(
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 3.w, vertical: 0.5.h),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            _getStatusDisplayText(status),
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 2.h),
                                    _buildDetailRow(
                                      Icons.calendar_today,
                                      intl.DateFormat('dd/MM/yyyy, hh:mm a')
                                          .format(deadline),
                                    ),
                                    if ((status == 'completed' ||
                                            status ==
                                                'complete after unfinished') &&
                                        submissionLinks.isNotEmpty) ...[
                                      SizedBox(height: 1.h),
                                      _buildClickableLinkRow(
                                        Icons.link,
                                        submissionLinks[0], // Display only the first link
                                      ),
                                    ],
                                    SizedBox(height: 2.h),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        _buildAmountChip(
                                          Icons.monetization_on,
                                          '$rewardAmount',
                                          Colors.green.shade100,
                                          Colors.green.shade800,
                                        ),
                                        _buildAmountChip(
                                          Icons.money_off,
                                          '$deductionAmount',
                                          Colors.red.shade100,
                                          Colors.red.shade800,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.white.withOpacity(0.8)),
        SizedBox(width: 2.w),
        Text(
          text,
          style: TextStyle(
            fontSize: 16.sp,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildClickableLinkRow(IconData icon, String link) {
    return Row(
      children: [
        Icon(icon, size: 16.sp, color: Colors.white.withOpacity(0.8)),
        SizedBox(width: 2.w),
        Expanded(
          child: GestureDetector(
            onTap: () => _launchURL(link),
            child: Text(
              link,
              style: TextStyle(
                fontSize: 16.sp,
                color: Colors.white,
                decoration: TextDecoration.underline,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountChip(
      IconData icon, String text, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.8.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: textColor),
          SizedBox(width: 1.w),
          Text(
            text,
            style: TextStyle(
              fontSize: 16.sp,
              color: textColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Month/Year Picker Dialog
class MonthYearPickerDialog {
  static Future<DateTime?> show({
    required BuildContext context,
    required DateTime selectedDate,
    required DateTime firstDate,
    required DateTime lastDate,
    required Color pastMonthHighlightColor,
  }) async {
    return await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 16,
                spreadRadius: 0,
              ),
            ],
          ),
          height: MediaQuery.of(context).size.height * 0.5,
          child: YearMonthPicker(
            selectedDate: selectedDate,
            firstDate: firstDate,
            lastDate: lastDate,
            onChanged: (date) => Navigator.pop(context, date),
            highlightPastMonths: true,
            pastMonthHighlightColor: pastMonthHighlightColor,
          ),
        );
      },
    );
  }
}

// Custom Year/Month Picker Widget
class YearMonthPicker extends StatefulWidget {
  final DateTime selectedDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onChanged;
  final bool highlightPastMonths;
  final Color? pastMonthHighlightColor;

  const YearMonthPicker({
    super.key,
    required this.selectedDate,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
    this.highlightPastMonths = false,
    this.pastMonthHighlightColor,
  });

  @override
  State<YearMonthPicker> createState() => _YearMonthPickerState();
}

class _YearMonthPickerState extends State<YearMonthPicker> {
  late DateTime _selectedDate;
  final DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.selectedDate;
  }

  @override
  Widget build(BuildContext context) {
    final highlightColor = widget.pastMonthHighlightColor ??
        Theme.of(context).primaryColor.withOpacity(0.3);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.chevron_left, color: Colors.grey.shade700),
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime(
                      _selectedDate.year - 1,
                      _selectedDate.month,
                    );
                  });
                },
              ),
              Text(
                _selectedDate.year.toString(),
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_right, color: Colors.grey.shade700),
                onPressed: () {
                  setState(() {
                    _selectedDate = DateTime(
                      _selectedDate.year + 1,
                      _selectedDate.month,
                    );
                  });
                },
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.count(
            padding: const EdgeInsets.all(16),
            crossAxisCount: 4,
            children: List.generate(12, (index) {
              final month = index + 1;
              final date = DateTime(_selectedDate.year, month);
              final isSelected = month == _selectedDate.month;
              final isDisabled = date.isBefore(widget.firstDate) ||
                  date.isAfter(widget.lastDate);
              final isPastMonth = widget.highlightPastMonths &&
                  date.isBefore(
                      DateTime(_currentDate.year, _currentDate.month));

              return Padding(
                padding: const EdgeInsets.all(4),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: isDisabled
                      ? null
                      : () {
                          setState(() => _selectedDate = date);
                          widget.onChanged(date);
                        },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Material1.primaryColor
                          : isDisabled
                              ? Colors.grey.shade200
                              : Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: isPastMonth
                          ? Border.all(color: highlightColor, width: 1.5)
                          : null,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Stack(
                      children: [
                        Center(
                          child: Text(
                            intl.DateFormat('MMM').format(date),
                            style: TextStyle(
                              color: isSelected
                                  ? Colors.white
                                  : isDisabled
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade700,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                              fontSize: 14.sp,
                            ),
                          ),
                        ),
                        if (isPastMonth)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Icon(
                              Icons.check_circle,
                              size: 16,
                              color: highlightColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}