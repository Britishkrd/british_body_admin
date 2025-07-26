import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/dashborad.dart/taskmanagement/ehsan_task/employee/send_task_details.dart';
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

  // Show dialog to edit task title and links
  // Future<void> _showEditTaskDialog({
  //   required String taskId,
  //   required String taskName,
  //   required List<String> submissionLinks,
  //   required String? submissionTitle,
  // }) async {
  //   final titleController = TextEditingController(text: submissionTitle ?? '');
  //   final List<TextEditingController> linkControllers = submissionLinks
  //       .map((link) => TextEditingController(text: link))
  //       .toList();
  //   if (linkControllers.isEmpty) {
  //     linkControllers.add(TextEditingController());
  //   }

  //   await showDialog(
  //     context: context,
  //     builder: (context) {
  //       return StatefulBuilder(
  //         builder: (context, setDialogState) {
  //           void addLinkField() {
  //             setDialogState(() {
  //               linkControllers.add(TextEditingController());
  //             });
  //           }

  //           void removeLinkField(int index) {
  //             if (linkControllers.length > 1) {
  //               setDialogState(() {
  //                 linkControllers[index].dispose();
  //                 linkControllers.removeAt(index);
  //               });
  //             }
  //           }

  //           return AlertDialog(
  //             shape: RoundedRectangleBorder(
  //               borderRadius: BorderRadius.circular(12),
  //             ),
  //             title: Text(
  //               'دەستکاریکردنی ئەرک: $taskName',
  //               style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
  //               textDirection: TextDirection.rtl,
  //             ),
  //             content: SingleChildScrollView(
  //               child: Column(
  //                 mainAxisSize: MainAxisSize.min,
  //                 children: [
  //                   TextField(
  //                     controller: titleController,
  //                     decoration: InputDecoration(
  //                       labelText: 'ناونیشان',
  //                       prefixIcon:
  //                           Icon(Icons.title, color: Material1.primaryColor),
  //                       border: OutlineInputBorder(
  //                         borderRadius: BorderRadius.circular(8),
  //                       ),
  //                     ),
  //                     textDirection: TextDirection.rtl,
  //                   ),
  //                   SizedBox(height: 2.h),
  //                   ...linkControllers.asMap().entries.map((entry) {
  //                     final index = entry.key;
  //                     final controller = entry.value;
  //                     return Padding(
  //                       padding: EdgeInsets.only(bottom: 1.h),
  //                       child: Row(
  //                         children: [
  //                           Expanded(
  //                             child: TextField(
  //                               controller: controller,
  //                               decoration: InputDecoration(
  //                                 labelText: 'لینک ${index + 1}',
  //                                 prefixIcon: Icon(Icons.link,
  //                                     color: Material1.primaryColor),
  //                                 border: OutlineInputBorder(
  //                                   borderRadius: BorderRadius.circular(8),
  //                                 ),
  //                               ),
  //                               textDirection: TextDirection.rtl,
  //                             ),
  //                           ),
  //                           if (linkControllers.length > 1)
  //                             IconButton(
  //                               icon: Icon(Icons.remove_circle,
  //                                   color: Colors.red, size: 20.sp),
  //                               onPressed: () => removeLinkField(index),
  //                             ),
  //                         ],
  //                       ),
  //                     );
  //                   }),
  //                   Align(
  //                     alignment: Alignment.centerRight,
  //                     child: TextButton.icon(
  //                       onPressed: addLinkField,
  //                       icon: Icon(Icons.add_circle,
  //                           color: Material1.primaryColor, size: 20.sp),
  //                       label: Text(
  //                         'زیادکردنی لینک',
  //                         style: TextStyle(
  //                           fontSize: 16.sp,
  //                           color: Material1.primaryColor,
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Navigator.pop(context),
  //                 child: Text(
  //                   'هەڵوەشاندنەوە',
  //                   style: TextStyle(fontSize: 16.sp, color: Colors.grey),
  //                 ),
  //               ),
  //               ElevatedButton(
  //                 onPressed: () async {
  //                   if (titleController.text.isEmpty ||
  //                       linkControllers
  //                           .any((controller) => controller.text.isEmpty)) {
  //                     ScaffoldMessenger.of(context).showSnackBar(
  //                       const SnackBar(
  //                         content:
  //                             Text('هەردوو ناونیشان و هەموو لینکەکان پڕ بکەوە'),
  //                         backgroundColor: Colors.red,
  //                       ),
  //                     );
  //                     return;
  //                   }

  //                   await FirebaseFirestore.instance
  //                       .collection('user')
  //                       .doc(widget.email)
  //                       .collection('tasks')
  //                       .doc(taskId)
  //                       .update({
  //                     'submissionTitle': titleController.text,
  //                     'submissionLinks':
  //                         linkControllers.map((c) => c.text).toList(),
  //                   });

  //                   for (var controller in linkControllers) {
  //                     controller.dispose();
  //                   }
  //                   titleController.dispose();

  //                   Navigator.pop(context);
  //                   ScaffoldMessenger.of(context).showSnackBar(
  //                     const SnackBar(
  //                       content: Text('ئەرکەکە بە سەرکەوتویی دەستکاری کرا'),
  //                       backgroundColor: Colors.green,
  //                     ),
  //                   );
  //                 },
  //                 style: ElevatedButton.styleFrom(
  //                   backgroundColor: Material1.primaryColor,
  //                   shape: RoundedRectangleBorder(
  //                     borderRadius: BorderRadius.circular(8),
  //                   ),
  //                 ),
  //                 child: Text(
  //                   'نوێکردنەوە',
  //                   style: TextStyle(fontSize: 16.sp, color: Colors.white),
  //                 ),
  //               ),
  //             ],
  //           );
  //         },
  //       );
  //     },
  //   );
  // }
  Future<void> _showEditTaskDialog({
    required String taskId,
    required String taskName,
    required List<String> submissionLinks,
    required String? submissionTitle,
  }) async {
    final titleController = TextEditingController(text: submissionTitle ?? '');
    final List<TextEditingController> linkControllers =
        submissionLinks.isNotEmpty
            ? submissionLinks
                .map((link) => TextEditingController(text: link))
                .toList()
            : [
                TextEditingController()
              ]; // Initialize with one empty field if no links

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            void addLinkField() {
              setDialogState(() {
                linkControllers.add(TextEditingController());
              });
            }

            void removeLinkField(int index) {
              if (linkControllers.length > 1) {
                setDialogState(() {
                  linkControllers[index].dispose();
                  linkControllers.removeAt(index);
                });
              }
            }

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              title: Text(
                'دەستکاریکردنی ئەرک: $taskName',
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                textDirection: TextDirection.rtl,
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'ناونیشان',
                        prefixIcon:
                            Icon(Icons.title, color: Material1.primaryColor),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      textDirection: TextDirection.rtl,
                    ),
                    SizedBox(height: 2.h),
                    ...linkControllers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final controller = entry.value;
                      return Padding(
                        padding: EdgeInsets.only(bottom: 1.h),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: controller,
                                decoration: InputDecoration(
                                  labelText: 'لینک ${index + 1}',
                                  prefixIcon: Icon(Icons.link,
                                      color: Material1.primaryColor),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                textDirection: TextDirection.rtl,
                              ),
                            ),
                            if (linkControllers.length > 1)
                              IconButton(
                                icon: Icon(Icons.remove_circle,
                                    color: Colors.red, size: 20.sp),
                                onPressed: () => removeLinkField(index),
                              ),
                          ],
                        ),
                      );
                    }),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: addLinkField,
                        icon: Icon(Icons.add_circle,
                            color: Material1.primaryColor, size: 20.sp),
                        label: Text(
                          'زیادکردنی لینک',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Material1.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'هەڵوەشاندنەوە',
                    style: TextStyle(fontSize: 16.sp, color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Require title to be non-empty, but allow links to be optional
                    if (titleController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('ناونیشان نابێت بەتاڵ بێت'),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Filter out empty links to avoid storing them
                    final updatedLinks = linkControllers
                        .map((c) => c.text.trim())
                        .where((link) => link.isNotEmpty)
                        .toList();

                    await FirebaseFirestore.instance
                        .collection('user')
                        .doc(widget.email)
                        .collection('tasks')
                        .doc(taskId)
                        .update({
                      'submissionTitle': titleController.text.trim(),
                      'submissionLinks': updatedLinks,
                    });

                    // Clean up controllers
                    for (var controller in linkControllers) {
                      controller.dispose();
                    }
                    titleController.dispose();

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('ئەرکەکە بە سەرکەوتویی دەستکاری کرا'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Material1.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text(
                    'نوێکردنەوە',
                    style: TextStyle(fontSize: 16.sp, color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
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
                          final List<String> submissionLinks = taskData !=
                                      null &&
                                  taskData.containsKey('submissionLinks')
                              ? List<String>.from(task['submissionLinks'] ?? [])
                              : [];
                          final submissionTitle = taskData != null &&
                                  taskData.containsKey('submissionTitle')
                              ? task['submissionTitle'] as String?
                              : null;

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
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        if ((status == 'completed' ||
                                                status ==
                                                    'complete after unfinished') &&
                                            submissionLinks.isNotEmpty)
                                          IconButton(
                                            icon: Icon(
                                              Icons.edit,
                                              color: Colors.white,
                                              size: 20.sp,
                                            ),
                                            onPressed: () =>
                                                _showEditTaskDialog(
                                              taskId: task['taskId'],
                                              taskName: task['taskName'],
                                              submissionLinks: submissionLinks,
                                              submissionTitle: submissionTitle,
                                            ),
                                          )
                                        else
                                          SizedBox(width: 20.sp),
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
                                    SizedBox(height: 1.h),
                                    Text(
                                      task['taskName'],
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
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
                                        submissionLinks[0],
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
