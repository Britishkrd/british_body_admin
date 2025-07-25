import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Add this import for input formatters
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

class _RequestingLoanState extends State<RequestingLoan> {
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
          Container(
            margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
            width: 90.w,
            height: 8.h,
            child: Material1.textfield(
              hint: 'بڕ',
              controller: amountcontroller,
              textColor: Material1.primaryColor,
              inputType: TextInputType.number, // Restrict to numbers
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly, // Only allow digits
              ],
            ),
          ),
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
          Container(
            margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
            width: 90.w,
            height: 8.h,
            child: Material1.button(
              label: 'داواکردن',
              function: () async {
                if (notecontroller.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تکایە تێبینی بنووسە'),
                    ),
                  );
                  return;
                }
                if (amountcontroller.text.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تکایە بڕەکە بنووسە'),
                    ),
                  );
                  return;
                }
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      title: const Text('داواکردنی سولفە'),
                      content: Text(
                        'دڵنییایت لە داواکردنی سولفە بە بڕی ${amountcontroller.text}؟',
                      ),
                      actions: [
                        Material1.button(
                          label: 'نەخێر',
                          function: () {
                            Navigator.pop(context);
                          },
                          textcolor: Colors.white,
                          buttoncolor: Material1.primaryColor,
                        ),
                        Material1.button(
                          label: 'بەڵێ',
                          function: () async {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return const AlertDialog(
                                  title: Center(child: CircularProgressIndicator()),
                                );
                              },
                            );
                            try {
                              await FirebaseFirestore.instance
                                  .collection('loanmanagement')
                                  .doc("${widget.email} ${DateTime.now()}")
                                  .set({
                                'amount': int.parse(amountcontroller.text), // Store as int
                                'note': notecontroller.text,
                                'time': DateTime.now(),
                                'status': 'pending',
                                'requestedby': widget.email,
                              });
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('سولفەکە بەسەرکەوتویی داواکرا'),
                                ),
                              );
                              Navigator.popUntil(context, (route) => route.isFirst);
                            } catch (error) {
                              Navigator.pop(context); // Close loading dialog
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('هەڵەیەک هەیە'),
                                ),
                              );
                            }
                          },
                          textcolor: Colors.white,
                          buttoncolor: Material1.primaryColor,
                        ),
                      ],
                    );
                  },
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