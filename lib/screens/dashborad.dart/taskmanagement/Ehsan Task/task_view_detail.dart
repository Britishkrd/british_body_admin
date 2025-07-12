// import 'package:british_body_admin/material/materials.dart';
// import 'package:british_body_admin/screens/dashborad.dart/taskmanagement/Ehsan%20Task/send_task_details.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:sizer/sizer.dart';

// class TaskViewDetail extends StatefulWidget {
//   final String email;

//   const TaskViewDetail({super.key, required this.email});

//   @override
//   State<TaskViewDetail> createState() => _TaskViewDetailState();
// }

// class _TaskViewDetailState extends State<TaskViewDetail> {
//   Future<void> _updateTaskStatus(String taskId, String newStatus,
//       {double? deductionAmount, String? taskName}) async {
//     // Update task status
//     await FirebaseFirestore.instance
//         .collection('user')
//         .doc(widget.email)
//         .collection('tasks')
//         .doc(taskId)
//         .update({'status': newStatus});

//     // If status is 'unfinished', add punishment to taskrewardpunishment
//     if (newStatus == 'unfinished' &&
//         deductionAmount != null &&
//         taskName != null) {
//       await FirebaseFirestore.instance
//           .collection('user')
//           .doc(widget.email)
//           .collection('taskrewardpunishment')
//           .add({
//         'addedby': widget.email,
//         'amount': deductionAmount,
//         'date': Timestamp.now(),
//         'reason': 'for not completing task $taskName on time',
//         'type': 'punishment',
//       });
//     }
//   }

//   Future<void> _checkAndUpdateUnfinishedTasks() async {
//     final tasksSnapshot = await FirebaseFirestore.instance
//         .collection('user')
//         .doc(widget.email)
//         .collection('tasks')
//         .where('status', isEqualTo: 'pending')
//         .get();

//     for (var doc in tasksSnapshot.docs) {
//       final deadline = (doc['deadline'] as Timestamp).toDate();
//       final taskData = doc.data();
//       final deductionAmount = taskData['deductionAmount']?.toDouble() ?? 0.0;
//       final taskName = taskData['taskName'] ?? 'Unknown Task';

//       if (deadline.isBefore(DateTime.now()) && doc['status'] == 'pending') {
//         await _updateTaskStatus(
//           doc['taskId'],
//           'unfinished',
//           deductionAmount: deductionAmount,
//           taskName: taskName,
//         );
//       }
//     }
//   }

//   bool _isTaskDue(DateTime deadline) {
//     final now = DateTime.now();
//     return now.year >= deadline.year &&
//         now.month >= deadline.month &&
//         now.day >= deadline.day;
//   }

//   String _getStatusDisplayText(String status) {
//     switch (status) {
//       case 'pending':
//         return 'چاوەڕوانی';
//       case 'completed':
//         return 'تەواو بووە';
//       case 'unfinished':
//         return 'تەواو نەبووە';
//       case 'complete after unfinished':
//         return 'تەواو بووە لە کاتی دیاری نەکراو';
//       default:
//         return status;
//     }
//   }

//   Color _getStatusColor(String status) {
//     switch (status) {
//       case 'completed':
//         return Colors.green;
//       case 'unfinished':
//         return Colors.red;
//       case 'complete after unfinished':
//         return Colors.blue;
//       default:
//         return Colors.orange;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Task Details'),
//         foregroundColor: Colors.white,
//         backgroundColor: Material1.primaryColor,
//         centerTitle: true,
//       ),
//       body: FutureBuilder(
//         future: _checkAndUpdateUnfinishedTasks(),
//         builder: (context, snapshot) {
//           return StreamBuilder(
//             stream: FirebaseFirestore.instance
//                 .collection('user')
//                 .doc(widget.email)
//                 .collection('tasks')
//                 .orderBy('deadline', descending: false)
//                 .snapshots(),
//             builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
//               if (snapshot.connectionState == ConnectionState.waiting) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
//                 return const Center(child: Text('No tasks found'));
//               }

//               return ListView.builder(
//                 itemCount: snapshot.data!.docs.length,
//                 itemBuilder: (context, index) {
//                   final task = snapshot.data!.docs[index];
//                   final deadline = (task['deadline'] as Timestamp).toDate();
//                   final status = task['status'];
//                   final isDue = _isTaskDue(deadline);
//                   final rewardAmount = task['rewardAmount']?.toDouble() ?? 0.0;
//                   final deductionAmount =
//                       task['deductionAmount']?.toDouble() ?? 0.0;

//                   return GestureDetector(
//                     onTap: () {
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (context) => SendTaskDetails(
//                             email: widget.email,
//                             taskId: task['taskId'],
//                             taskName: task['taskName'],
//                             deadline: task['deadline'],
//                             status: task['status'],
//                           ),
//                         ),
//                       );
//                     },
//                     child: Container(
//                       margin:
//                           EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
//                       padding: EdgeInsets.all(2.h),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(5),
//                         boxShadow: const [
//                           BoxShadow(color: Colors.grey, blurRadius: 5),
//                         ],
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text(
//                                 'Task: ${task['taskName']}',
//                                 style: const TextStyle(
//                                     fontSize: 18, fontWeight: FontWeight.bold),
//                               ),
//                               Text(
//                                 _getStatusDisplayText(status),
//                                 style: TextStyle(
//                                   fontSize: 15,
//                                   color: _getStatusColor(status),
//                                 ),
//                               ),
//                             ],
//                           ),
//                           Text(
//                             'Deadline: ${DateFormat('dd/MM/yyyy HH:mm a').format(deadline)}',
//                             style: const TextStyle(fontSize: 15),
//                           ),
//                           Text(
//                             'Reward Amount: $rewardAmount',
//                             style: const TextStyle(fontSize: 15),
//                           ),
//                           Text(
//                             'Deduction Amount: $deductionAmount',
//                             style: const TextStyle(fontSize: 15),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//               );
//             },
//           );
//         },
//       ),
//     );
//   }
// }

import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/dashborad.dart/taskmanagement/Ehsan%20Task/send_task_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:sizer/sizer.dart';

class TaskViewDetail extends StatefulWidget {
  final String email;

  const TaskViewDetail({super.key, required this.email});

  @override
  State<TaskViewDetail> createState() => _TaskViewDetailState();
}

class _TaskViewDetailState extends State<TaskViewDetail> {
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
      default: // pending
        return LinearGradient(
          colors: [Colors.orange.shade400, Colors.orange.shade700],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Task Details',
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
        body: FutureBuilder(
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
                    child: Text('هیچ تاسکێک نادۆزرایەوە',
                        style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey.shade600,
                            fontFamily: 'kurdish')),
                  );
                }

                return ListView.builder(
                  padding: EdgeInsets.symmetric(vertical: 2.h, horizontal: 3.w),
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    final task = snapshot.data!.docs[index];
                    final deadline = (task['deadline'] as Timestamp).toDate();
                    final status = task['status'];
                    final isDue = _isTaskDue(deadline);
                    final rewardAmount =
                        task['rewardAmount']?.toDouble() ?? 0.0;
                    final deductionAmount =
                        task['deductionAmount']?.toDouble() ?? 0.0;

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
                        height: 20.h,
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
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
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
