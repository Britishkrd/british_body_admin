import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class EmployeeTaskDetailsView extends StatefulWidget {
  final String email;
  final String taskId;
  final String taskName;
  final Timestamp deadline;
  final String status;

  const EmployeeTaskDetailsView({
    super.key,
    required this.email,
    required this.taskId,
    required this.taskName,
    required this.deadline,
    required this.status,
  });

  @override
  State<EmployeeTaskDetailsView> createState() =>
      _EmployeeTaskDetailsViewState();
}

class _EmployeeTaskDetailsViewState extends State<EmployeeTaskDetailsView> {
  bool _isSubmitted = false;
  String? _submissionTitle;
  List<String>? _submissionLinks;
  Timestamp? _submissionDate;
  double? _rewardAmount;
  double? _deductionAmount;

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
      if (data?['submissionTitle'] != null &&
          data?['submissionLinks'] != null) {
        setState(() {
          _isSubmitted = true;
          _submissionTitle = data?['submissionTitle'];
          _submissionLinks = List<String>.from(data?['submissionLinks'] ?? []);
          _submissionDate = data?['submissionDate'];
          _rewardAmount = data?['rewardAmount']?.toDouble() ?? 0.0;
          _deductionAmount = data?['deductionAmount']?.toDouble() ?? 0.0;
        });
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'وردەکاری ئەرک',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
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
                      _isSubmitted
                          ? (_submissionTitle ?? 'Not provided')
                          : 'هیچ ناونیشانێک نەنێردراوە',
                    ),
                    SizedBox(height: 2.h),
                    if (_isSubmitted && _submissionLinks != null)
                      ..._submissionLinks!.asMap().entries.map((entry) {
                        final index = entry.key;
                        final link = entry.value;
                        return Column(
                          children: [
                            _buildClickableLinkItem(
                              Icons.link,
                              'لینک ${index + 1}',
                              link,
                            ),
                            SizedBox(height: 2.h),
                          ],
                        );
                      })
                    else
                      _buildDetailItem(
                        Icons.link,
                        'لینکەکان',
                        'هیچ لینکێک نەنێردراوە',
                      ),
                    SizedBox(height: 2.h),
                    _buildDetailItem(
                      Icons.calendar_today,
                      'بەرواری ناردن',
                      _isSubmitted && _submissionDate != null
                          ? intl.DateFormat('dd/MM/yyyy, hh:mm a')
                              .format(_submissionDate!.toDate())
                          : 'هیچ بەروارێک نەنێردراوە',
                    ),
                    SizedBox(height: 2.h),
                    _buildDetailItem(
                      Icons.monetization_on,
                      'بڕی پاداشت',
                      _rewardAmount != null ? '$_rewardAmount' : '0.0',
                    ),
                    SizedBox(height: 2.h),
                    _buildDetailItem(
                      Icons.monetization_on,
                      'بڕی سزا',
                      _deductionAmount != null ? '$_deductionAmount' : '0.0',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
