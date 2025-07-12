import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class SendTaskDetails extends StatefulWidget {
  final String email;
  final String taskId;
  final String taskName;
  final Timestamp deadline;
  final String status;

  const SendTaskDetails({
    super.key,
    required this.email,
    required this.taskId,
    required this.taskName,
    required this.deadline,
    required this.status,
  });

  @override
  State<SendTaskDetails> createState() => _SendTaskDetailsState();
}

class _SendTaskDetailsState extends State<SendTaskDetails> {
  final _titleController = TextEditingController();
  final _linkController = TextEditingController();
  bool _isSubmitted = false;
  String? _submissionTitle;
  String? _submissionLink;
  Timestamp? _submissionDate;

  @override
  void initState() {
    super.initState();
    if (widget.status == 'completed' || widget.status == 'unfinished') {
      _loadSubmissionDetails();
    }
  }

  Future<void> _loadSubmissionDetails() async {
    final doc = await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.email)
        .collection('tasks')
        .doc(widget.taskId)
        .get();

    if (doc.exists) {
      final data = doc.data();
      if (data?['submissionTitle'] != null && data?['submissionLink'] != null) {
        setState(() {
          _isSubmitted = true;
          _submissionTitle = data?['submissionTitle'];
          _submissionLink = data?['submissionLink'];
          _submissionDate = data?['submissionDate'];
        });
      }
    }
  }

  Future<void> _submitTaskDetails() async {
    if (_titleController.text.isEmpty || _linkController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in both fields')),
      );
      return;
    }

    // Fetch task data to get rewardAmount
    final taskDoc = await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.email)
        .collection('tasks')
        .doc(widget.taskId)
        .get();

    if (!taskDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task not found')),
      );
      return;
    }

    final taskData = taskDoc.data()!;
    final rewardAmount = taskData['rewardAmount']?.toDouble() ?? 0.0;

    // Determine new status based on current status
    String newStatus = widget.status == 'pending' ? 'completed' : 'unfinished';

    // Update task with submission details and new status
    await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.email)
        .collection('tasks')
        .doc(widget.taskId)
        .update({
      'submissionTitle': _titleController.text,
      'submissionLink': _linkController.text,
      'submissionDate': Timestamp.now(),
      'status': newStatus,
    });

    // Only insert reward for completed tasks
    if (newStatus == 'completed') {
      await FirebaseFirestore.instance
          .collection('user')
          .doc(widget.email)
          .collection('taskrewardpunishment')
          .add({
        'addedby': widget.email,
        'amount': rewardAmount,
        'date': Timestamp.now(),
        'reason': 'for completing task ${widget.taskName} on time',
        'type': 'reward',
      });
    }

    setState(() {
      _isSubmitted = true;
      _submissionTitle = _titleController.text;
      _submissionLink = _linkController.text;
      _submissionDate = Timestamp.now();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(newStatus == 'completed'
            ? 'Task details submitted successfully'
            : 'Unfinished task details submitted successfully'),
      ),
    );
  }

  bool _isTaskDue(DateTime deadline) {
    final now = DateTime.now();
    return now.year >= deadline.year &&
        now.month >= deadline.month &&
        now.day >= deadline.day;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDue = _isTaskDue(widget.deadline.toDate());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Task Details'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Task: ${widget.taskName}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 2.h),
            Text(
              'Deadline: ${DateFormat('dd/MM/yyyy HH:mm a').format(widget.deadline.toDate())}',
              style: const TextStyle(fontSize: 15),
            ),
            SizedBox(height: 1.h),
            if (widget.status == 'unfinished')
              Text(
                'UNFINISHED TASK',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            SizedBox(height: 4.h),
            if (!_isSubmitted) ...[
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: _linkController,
                decoration: const InputDecoration(
                  labelText: 'Link',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 4.h),
              if (widget.status == 'pending') ...[
                Center(
                  child: ElevatedButton(
                    onPressed: isDue ? _submitTaskDetails : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Material1.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Submit'),
                  ),
                ),
              ] else if (widget.status == 'unfinished') ...[
                Center(
                  child: ElevatedButton(
                    onPressed: _submitTaskDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Submit Unfinished Task'),
                  ),
                ),
              ],
            ] else ...[
              const Text(
                'Submission Details:',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 2.h),
              Text('Title: $_submissionTitle'),
              SizedBox(height: 1.h),
              Text('Link: $_submissionLink'),
              SizedBox(height: 1.h),
              if (_submissionDate != null)
                Text(
                  'Submitted on: ${DateFormat('dd/MM/yyyy HH:mm a').format(_submissionDate!.toDate())}',
                ),
              SizedBox(height: 2.h),
              Text(
                'Status: ${widget.status}',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: widget.status == 'completed'
                      ? Colors.green
                      : widget.status == 'unfinished'
                          ? Colors.red
                          : Colors.orange,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
