import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/sendingnotification.dart';
import 'package:british_body_admin/shared/confirm_dialog.dart';
import 'package:british_body_admin/utils/color.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class HolidayManagementScreen extends StatefulWidget {
  const HolidayManagementScreen({super.key});

  @override
  State<HolidayManagementScreen> createState() =>
      _HolidayManagementScreenState();
}

class _HolidayManagementScreenState extends State<HolidayManagementScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('پشووە فەڕمییکان'),
          foregroundColor: Colors.white,
          backgroundColor: Material1.primaryColor,
          centerTitle: true,
          elevation: 0,
        ),
        body: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Form Card
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsets.all(3.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Date range picker
                        Row(
                          children: [
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _endDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: Material1.primaryColor,
                                            onPrimary: Colors.white,
                                            onSurface: Colors.black,
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  Material1.primaryColor,
                                            ),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (date != null) {
                                    setState(() => _endDate = date);
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(2.w),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Icon(Icons.calendar_today, size: 18),
                                      Text(
                                        DateFormat('yyyy-MM-dd').format(_endDate),
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 2.w),
                              child: Text(
                                'بۆ',
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () async {
                                  final date = await showDatePicker(
                                    context: context,
                                    initialDate: _startDate,
                                    firstDate: DateTime(2000),
                                    lastDate: DateTime(2100),
                                    builder: (context, child) {
                                      return Theme(
                                        data: Theme.of(context).copyWith(
                                          colorScheme: ColorScheme.light(
                                            primary: Material1.primaryColor,
                                            onPrimary: Colors.white,
                                            onSurface: Colors.black,
                                          ),
                                          textButtonTheme: TextButtonThemeData(
                                            style: TextButton.styleFrom(
                                              foregroundColor:
                                                  Material1.primaryColor,
                                            ),
                                          ),
                                        ),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (date != null) {
                                    setState(() => _startDate = date);
                                  }
                                },
                                child: Container(
                                  padding: EdgeInsets.all(2.w),
                                  decoration: BoxDecoration(
                                    border:
                                        Border.all(color: Colors.grey.shade300),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Icon(Icons.calendar_today, size: 18),
                                      Text(
                                        DateFormat('yyyy-MM-dd')
                                            .format(_startDate),
                                        style: TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
      
                        // Description field
                        Directionality(
                          textDirection: material.TextDirection.rtl,
                          child: TextFormField(
                            controller: _descriptionController,
                            decoration: InputDecoration(
                              labelText: 'ناونیشانی پشوو',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Colors.grey.shade300),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide:
                                    BorderSide(color: Material1.primaryColor),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 3.w,
                                vertical: 2.h,
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'تکایە ناونیشانی پشوو بنوسە';
                              }
                              return null;
                            },
                            maxLines: 3,
                          ),
                        ),
                        SizedBox(height: 2.h),
      
                        // Add holiday button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              await ConfirmationDialog(
                                context: context,
                                content: 'ئایا دڵنیایت لە زیادکردنی پشووکە؟',
                                onConfirm: _addHoliday,
                                showCheckInForm:
                                    true, //labar rangakay true m danawa
                              ).show();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Material1.primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 1.5.h),
                            ),
                            child: Text(
                              'زیادکردنی پشوو',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
      
              // List header
              Padding(
                padding: EdgeInsets.symmetric(vertical: 1.h),
                child: Text(
                  textDirection: material.TextDirection.rtl,
                  'پشووە فەرمییەکان:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
      
              // List of holidays
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('holidays')
                      .orderBy('startDate', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
      
                    if (snapshot.hasError) {
                      return Center(child: Text('هەڵە: ${snapshot.error}'));
                    }
      
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return Center(
                        child: Text(
                          'هیچ پشوویەک نییە',
                          style: TextStyle(fontSize: 16),
                        ),
                      );
                    }
      
                    return ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final doc = snapshot.data!.docs[index];
                        final startDate =
                            (doc['startDate'] as Timestamp).toDate();
                        final endDate = (doc['endDate'] as Timestamp).toDate();
                        final description = doc['description'] as String;
      
                        return Directionality(
                          textDirection: material.TextDirection.rtl,
                          child: Card(
                            margin: EdgeInsets.only(bottom: 1.5.h),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 4.w,
                                vertical: 1.h,
                              ),
                              title: Text(
                                description,
                                style: TextStyle(
                                  // fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Padding(
                                padding: EdgeInsets.only(top: 0.5.h),
                                child: Text(
                                  '${DateFormat('yyyy-MM-dd').format(startDate)} - ${DateFormat('yyyy-MM-dd').format(endDate)}',
                                  style: TextStyle(
                                    // fontSize: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ),
                              trailing: IconButton(
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Colors.red.shade400,
                                  // size: 18,
                                ),
                                onPressed: () => _showDeleteDialog(doc.id),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteDialog(String id) async {
    if (!mounted) return;
    await ConfirmationDialog(
      context: context,
      content: 'دڵنیای لە سڕینەوەی ئەم پشووە ؟',
      // okOnPressed: () async => onConfirm(),
      onConfirm: () {
        _deleteHoliday(id);
      },
      // showCheckInForm: CheckInState.showCheckInForm,
    ).show();
  }

  Future<void> _addHoliday() async {
    if (!_formKey.currentState!.validate()) return;

    if (_endDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('ڕۆژی کۆتایی پێویستە دوای ڕۆژی دەستپێکردن بێت')),
      );
      return;
    }

    try {
      // First add the holiday to Firestore
      await FirebaseFirestore.instance.collection('holidays').add({
        'startDate': Timestamp.fromDate(_startDate),
        'endDate': Timestamp.fromDate(_endDate),
        'description': _descriptionController.text,
        'createdAt': Timestamp.now(),
      });

      // Then send notifications to all users
      await _sendHolidayNotifications();

      _descriptionController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: foregroundColor,
          content: const Text('پشووەکە زیادکرا'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('هەڵە: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }

  Future<void> _sendHolidayNotifications() async {
    try {
      // Get all users from Firestore
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('user').get();

      // Prepare notification details
      final title = 'پشووی فەڕمی';
      final body = '${_descriptionController.text}\n'
          'لە ${DateFormat('yyyy-MM-dd').format(_startDate)} '
          'بۆ ${DateFormat('yyyy-MM-dd').format(_endDate)}';
      final notificationType = 'default1';

      // Send notification to each user
      for (final userDoc in usersSnapshot.docs) {
        final token = userDoc.data()['token'] ?? '';
        if (token.isNotEmpty) {
          await sendingnotification(
            title,
            body,
            token,
            notificationType,
          );
        }
      }
    } catch (e) {
      debugPrint('Error sending holiday notifications: $e');
    }
  }

  Future<void> _deleteHoliday(String id) async {
    try {
      // Check if widget is still mounted before proceeding
      if (!mounted) return;

      await FirebaseFirestore.instance.collection('holidays').doc(id).delete();
      // Check again before showing SnackBar
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red,
          content: const Text('پشووەکە سڕایەوە'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      // Check again before showing error SnackBar
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('هەڵە: $e'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}
