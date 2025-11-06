import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/sendingnotification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

class RequestingLoan extends StatefulWidget {
  final String email;
  const RequestingLoan({
    super.key,
    required this.email,
  });

  @override
  State<RequestingLoan> createState() => _RequestingLoanState();
}

TextEditingController notecontroller = TextEditingController();
TextEditingController amountcontroller = TextEditingController();

String formatDate(DateTime? date) {
  final DateFormat formatter = DateFormat('dd/MM/yyyy HH:mm');
  return formatter.format(date ?? DateTime.now());
}

class _RequestingLoanState extends State<RequestingLoan> {
  // --------------------------------------------------------------
  //  Notify every admin that a new loan request has been created
  // --------------------------------------------------------------
  Future<void> _notifyAdminsAboutNewLoan({
    required String requesterEmail,
    required int amount,
    required String note,
  }) async {
    try {
      final usersSnapshot =
          await FirebaseFirestore.instance.collection('user').get();

      for (var userDoc in usersSnapshot.docs) {
        final data = userDoc.data();
        final permissions = data['permissions'] as List<dynamic>? ?? [];

        if (permissions.contains('isAdmin')) {
          final token = data['token'] as String?;
          if (token != null && token.isNotEmpty) {
            await sendingnotification(
              'داواکاری سولفەی نوێ',
              'بەکارهێنەر ($requesterEmail) داوای سولفەی $amount کردووە\nتێبینی: $note',
              token,
              'default1',
            );
          }
        }
      }
    } catch (e) {
      debugPrint('Error notifying admins about loan: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('داواکردنی سولفە'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
      ),
      body: ListView(
        children: [
          // ----- Amount field -----
          Container(
            margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
            width: 90.w,
            height: 8.h,
            child: Material1.textfield(
              hint: 'بڕ',
              controller: amountcontroller,
              textColor: Material1.primaryColor,
              inputType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
            ),
          ),

          // ----- Note field -----
          Container(
            margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
            width: 90.w,
            height: 8.h,
            child: Material1.textfield(
              hint: 'تێبینی',
              controller: notecontroller,
              textColor: Material1.primaryColor,
            ),
          ),

          // ----- Submit button -----
          Container(
            margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
            width: 90.w,
            height: 8.h,
            child: Material1.button(
              label: 'داواکردن',
              function: () async {
                // ---- Validation ----
                if (notecontroller.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تکایە تێبینی بنووسە')),
                  );
                  return;
                }
                if (amountcontroller.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تکایە بڕەکە بنووسە')),
                  );
                  return;
                }

                // ---- Confirmation dialog ----
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('داواکردنی سولفە'),
                    content: Text(
                      'دڵنییایت لە داواکردنی سولفە بە بڕی ${amountcontroller.text}؟',
                    ),
                    actions: [
                      Material1.button(
                        label: 'نەخێر',
                        function: () => Navigator.pop(context),
                        textcolor: Colors.white,
                        buttoncolor: Material1.primaryColor,
                      ),
                      Material1.button(
                        label: 'بەڵێ',
                        function: () async {
                          // ---- Loading dialog (covers save + notifications) ----
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (_) => const AlertDialog(
                              content: Center(child: CircularProgressIndicator()),
                            ),
                          );

                          try {
                            // ---- Save loan request ----
                            await FirebaseFirestore.instance
                                .collection('loanmanagement')
                                .doc("${widget.email} ${DateTime.now()}")
                                .set({
                              'amount': int.parse(amountcontroller.text),
                              'note': notecontroller.text,
                              'time': DateTime.now(),
                              'status': 'pending',
                              'requestedby': widget.email,
                            });

                            // ---- Notify all admins ----
                            await _notifyAdminsAboutNewLoan(
                              requesterEmail: widget.email,
                              amount: int.parse(amountcontroller.text),
                              note: notecontroller.text,
                            );

                            // ---- Success UI ----
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('سولفەکە بەسەرکەوتویی داواکرا'),
                              ),
                            );
                            Navigator.pop(context); // close loading
                            Navigator.popUntil(
                                context, (route) => route.isFirst);
                          } catch (error) {
                            if (!mounted) return;
                            Navigator.pop(context); // close loading
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('هەڵەیەک هەیە')),
                            );
                          }
                        },
                        textcolor: Colors.white,
                        buttoncolor: Material1.primaryColor,
                      ),
                    ],
                  ),
                );
              },
              textcolor: Colors.white,
              buttoncolor: Material1.primaryColor,
            ),
          ),
        ],
      ),
    );
  }
}