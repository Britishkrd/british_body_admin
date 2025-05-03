// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:british_body_admin/utils/color.dart';
import 'package:british_body_admin/utils/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomEmailField extends StatelessWidget {
  final TextEditingController? controller;

  const CustomEmailField({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'ئیمێڵ',
        labelStyle: kurdishTextStyle(14, Colors.grey[600]!),
        floatingLabelStyle: TextStyle(color: foregroundColor),
        prefixIcon: Icon(
          Icons.email_outlined,
          color: Colors.grey[400],
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
          borderSide: BorderSide.none,
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
      validator: (value) {
        const pattern = r'(^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$)';
        final regExp = RegExp(pattern);
        if (value!.isEmpty) {
          return 'تکایە ئیمێڵەکەت داخڵ بکە';
        } else if (!regExp.hasMatch(value)) {
          return 'تکایە ئیمێڵی درووست داخڵ';
        }
        return null;
      },
    );
  }
}
