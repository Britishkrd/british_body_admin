import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/dashborad.dart/taskmanagement/Ehsan%20Task/send_task_details.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
    // Update task status
    await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.email)
        .collection('tasks')
        .doc(taskId)
        .update({'status': newStatus});

    // If status is 'unfinished', add punishment to taskrewardpunishment
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
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
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(child: Text('No tasks found'));
              }

              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final task = snapshot.data!.docs[index];
                  final deadline = (task['deadline'] as Timestamp).toDate();
                  final status = task['status'];
                  final isDue = _isTaskDue(deadline);
                  final rewardAmount = task['rewardAmount']?.toDouble() ?? 0.0;
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
                      margin:
                          EdgeInsets.symmetric(horizontal: 5.w, vertical: 1.h),
                      padding: EdgeInsets.all(2.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                        boxShadow: const [
                          BoxShadow(color: Colors.grey, blurRadius: 5),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Task: ${task['taskName']}',
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Status: $status',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: status == 'completed'
                                      ? Colors.green
                                      : status == 'unfinished'
                                          ? Colors.red
                                          : Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            'Deadline: ${DateFormat('dd/MM/yyyy HH:mm a').format(deadline)}',
                            style: const TextStyle(fontSize: 15),
                          ),
                          Text(
                            'Reward Amount: $rewardAmount',
                            style: const TextStyle(fontSize: 15),
                          ),
                          Text(
                            'Deduction Amount: $deductionAmount',
                            style: const TextStyle(fontSize: 15),
                          ),
                         
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
