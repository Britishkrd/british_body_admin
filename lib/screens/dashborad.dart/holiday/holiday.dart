import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/sendingnotification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class HolidayManagement extends StatefulWidget {
  const HolidayManagement({super.key});

  @override
  State<HolidayManagement> createState() => _HolidayManagementState();
}

class _HolidayManagementState extends State<HolidayManagement> {
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بەڕێوەبردنی پشووە فەرمیەکان'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(2.h),
        child: Column(
          children: [
            // Date range picker
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _startDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() => _startDate = date);
                      }
                    },
                    child: Text(
                      'ڕۆژی دەستپێکردن: ${DateFormat('yyyy-MM-dd').format(_startDate)}',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: _endDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (date != null) {
                        setState(() => _endDate = date);
                      }
                    },
                    child: Text(
                      'ڕۆژی کۆتایی: ${DateFormat('yyyy-MM-dd').format(_endDate)}',
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                ),
              ],
            ),
            
            // Description field
            Material1.textfield(
              hint: 'بیرۆکەی پشوو',
              textColor: Colors.black,
              controller: _descriptionController,
            ),
            
            // Add holiday button
            Material1.button(
              label: 'زیادکردنی پشوو',
              buttoncolor: Material1.primaryColor,
              textcolor: Colors.white,
              function: _addHoliday,
            ),
            
            // List of holidays
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('holidays')
                    .orderBy('startDate', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  
                  return ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final startDate = (doc['startDate'] as Timestamp).toDate();
                      final endDate = (doc['endDate'] as Timestamp).toDate();
                      final description = doc['description'] as String;
                      
                      return ListTile(
                        title: Text(description),
                        subtitle: Text(
                          '${DateFormat('yyyy-MM-dd').format(startDate)} - ${DateFormat('yyyy-MM-dd').format(endDate)}',
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteHoliday(doc.id),
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
    );
  }

 // In your HolidayManagement widget, update the addHoliday function:
// In your HolidayManagement widget
Future<void> _addHoliday() async {
  if (_descriptionController.text.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تکایە بیرۆکەی پشوو بنوسە')),
    );
    return;
  }
  
  if (_endDate.isBefore(_startDate)) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('ڕۆژی کۆتایی پێویستە دوای ڕۆژی دەستپێکردن بێت')),
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
      const SnackBar(content: Text('پشووەکە زیادکرا')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('هەڵە: $e')),
    );
  }
}

Future<void> _sendHolidayNotifications() async {
  try {
    // Get all users from Firestore
    final usersSnapshot = await FirebaseFirestore.instance
        .collection('user')
        .get();

    // Prepare notification details
    final title = 'پشووی فەرمی';
    final body = '${_descriptionController.text}\n'
    'لە ${DateFormat('yyyy-MM-dd').format(_startDate)} '
    'بۆ ${DateFormat('yyyy-MM-dd').format(_endDate)}';
    final notificationType = 'default1'; // You can use this to handle different notification types

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
    // You might want to show a snackbar or log this error
  }
}

  Future<void> _deleteHoliday(String id) async {
    try {
      await FirebaseFirestore.instance.collection('holidays').doc(id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('پشووەکە سڕایەوە')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('هەڵە: $e')),
      );
    }
  }
}