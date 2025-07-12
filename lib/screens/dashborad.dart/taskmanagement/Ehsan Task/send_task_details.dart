import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

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
    if (widget.status == 'completed' ||
        widget.status == 'unfinished' ||
        widget.status == 'complete after unfinished') {
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

  Future<void> _launchURL(String url) async {
    // Ensure URL has a scheme
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

  bool _isValidURL(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  Future<void> _submitTaskDetails() async {
    if (_titleController.text.isEmpty || _linkController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('هەردوو فێڵدەکە پڕ بکەوە'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final taskDoc = await FirebaseFirestore.instance
        .collection('user')
        .doc(widget.email)
        .collection('tasks')
        .doc(widget.taskId)
        .get();

    if (!taskDoc.exists) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تاسکەکە نەدۆزرایەوە'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final taskData = taskDoc.data()!;
    final rewardAmount = taskData['rewardAmount']?.toDouble() ?? 0.0;

    String newStatus;
    if (widget.status == 'pending') {
      newStatus = 'completed';
    } else if (widget.status == 'unfinished') {
      newStatus = 'complete after unfinished';
    } else {
      newStatus = widget.status;
    }

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
      const SnackBar(
        content: Text("ئەرکەکە بە سەرکەوتویی نێردرا"),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
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
  void dispose() {
    _titleController.dispose();
    _linkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDue = _isTaskDue(widget.deadline.toDate());
    final statusColor = _getStatusGradient(widget.status).colors.first;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ناردنی ئەرک',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          foregroundColor: Colors.white,
          backgroundColor: Material1.primaryColor,
          centerTitle: true,
          elevation: 0,
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task Overview Card
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  gradient: _getStatusGradient(widget.status),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.taskName,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 1.h),
                    Row(
                      children: [
                        Icon(Icons.calendar_today,
                            size: 16.sp, color: Colors.white.withOpacity(0.8)),
                        SizedBox(width: 2.w),
                        Text(
                          intl.DateFormat('dd/MM/yyyy, hh:mm a')
                              .format(widget.deadline.toDate()),
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 1.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 3.w, vertical: 0.5.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        _getStatusDisplayText(widget.status),
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 4.h),

              if (!_isSubmitted) ...[
                // Submission Form
                Text(
                  'زانیاری ئەرکەکەت',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                SizedBox(height: 2.h),
                _buildModernTextField(
                  controller: _titleController,
                  label: 'ناونیشان',
                  icon: Icons.title,
                ),
                SizedBox(height: 2.h),
                _buildModernTextField(
                  controller: _linkController,
                  label: 'لینک',
                  icon: Icons.link,
                ),
                SizedBox(height: 4.h),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: (widget.status == 'pending' && !isDue)
                        ? null
                        : _submitTaskDetails,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: statusColor,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: Text(
                      'ناردن',
                      style: TextStyle(fontSize: 18.sp),
                    ),
                  ),
                ),
                if (widget.status == 'pending' && !isDue) ...[
                  SizedBox(height: 1.h),
                  Text(
                    'تەنها لە وادەی دیاریکراو یان دوای وادەی دیاریکراو دەتوانیت پێشکەشی بکەیت',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.deepOrangeAccent,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ] else ...[
                // Submission Details
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'وردەکاری پێشکەشکردن',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      _buildDetailItem(
                        Icons.title,
                        'ناونیشان',
                        _submissionTitle ?? 'Not provided',
                      ),
                      SizedBox(height: 2.h),
                      _buildClickableLinkItem(
                        Icons.link,
                        'لینک',
                        _submissionLink ?? 'Not provided',
                      ),
                      SizedBox(height: 2.h),
                      _buildDetailItem(
                        Icons.calendar_today,
                        'بەرواری ناردن',
                        _submissionDate != null
                            ? intl.DateFormat('dd/MM/yyyy, hh:mm a')
                                .format(_submissionDate!.toDate())
                            : 'Not available',
                      ),
                    ],
                  ),
                ),
              ],
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
  }) {
    return TextField(
      controller: controller,
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

  Widget _buildDetailItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.sp, color: Material1.primaryColor),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClickableLinkItem(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18.sp, color: Material1.primaryColor),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey.shade600,
                ),
              ),
              SizedBox(height: 0.5.h),
              GestureDetector(
                onTap: () => _launchURL(value),
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ===== UPDATED TASK VIEW DETAIL SCREEN =====
