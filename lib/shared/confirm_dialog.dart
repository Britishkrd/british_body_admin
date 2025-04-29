import 'package:british_body_admin/utils/style.dart';
import 'package:flutter/material.dart';

class ConfirmationDialog {
  final BuildContext context;
  final String content;
  // final void Function()? okOnPressed;

  final VoidCallback onConfirm;
  final bool showCheckInForm;

  ConfirmationDialog({
    required this.context,
    required this.content,
    // required this.okOnPressed,
    required this.onConfirm,
    required this.showCheckInForm,
  });

  Future<void> show() async {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'دڵنیاکردنەوە',
            textAlign: TextAlign.right, // Add this line
            textDirection: TextDirection.rtl, // Add this line
            style: TextStyle(
              fontFamily: 'kurdish',
              fontWeight: FontWeight.w600,
              color: blackColor,
            ),
          ),
          content: Text(
            content,
            textAlign: TextAlign.right, // Add this line
            textDirection: TextDirection.rtl, // Add this line
            style: TextStyle(
              fontFamily: 'kurdish',
              color: blackColor,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'نەخێر',

                textDirection: TextDirection.rtl, // Add this line
                style: TextStyle(
                  fontFamily: 'kurdish',
                  color: blackColor,
                ),
              ),
            ),
            ElevatedButton(
              // onPressed: okOnPressed,
              // onPressed: okOnPressed,
                        onPressed: () {
            Navigator.pop(context); // Close the confirmation dialog first
            onConfirm(); // Then execute the callback
          },
              style: ElevatedButton.styleFrom(
                backgroundColor: showCheckInForm ? foregroundColor : redColor,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'بەڵێ',

                textDirection: TextDirection.rtl, // Add this line
                style: TextStyle(
                  fontFamily: 'kurdish',
                  color: whiteColor,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
