// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:british_body_admin/utils/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomEmailField extends StatelessWidget {
  // final void Function(String?)? onSaved;
  final TextEditingController? controller;
  final FormFieldValidator<String>? validator;

  const CustomEmailField({super.key, this.controller, this.validator});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'Email',
        labelStyle: GoogleFonts.poppins(color: Colors.grey, fontSize: 14),
        floatingLabelStyle: TextStyle(color: foregroundColor),
        prefixIcon: Icon(
          Icons.email_outlined,
          color: Colors.grey.withValues(alpha: 0.6 * 255),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: foregroundColor, width: 1.5),
        ),
        filled: true,
        fillColor: backgroundColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
      style: GoogleFonts.poppins(color: blackColor),
      keyboardType: TextInputType.emailAddress,
      inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
      controller: controller,
      validator:
          validator ??
          (value) {
            const pattern =
                r'(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)';
            final regExp = RegExp(pattern);
            if (value!.isEmpty) {
              return 'Please enter your email';
            } else if (!regExp.hasMatch(value)) {
              return 'Please enter a valid email';
            }
            return null;
          },
    );
  }
}
