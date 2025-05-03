// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:british_body_admin/utils/color.dart';
import 'package:british_body_admin/utils/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class CustomPasswordField extends StatelessWidget {
  final TextEditingController? controller;
  final bool isObscurePassword;
  final void Function()? onPressed;
  const CustomPasswordField({
    super.key,
    this.controller,
    this.isObscurePassword = false,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: 'وشەی نهێنی',
        labelStyle: kurdishTextStyle(14, Colors.grey[600]!),
        floatingLabelStyle: TextStyle(color: foregroundColor),
        prefixIcon: Icon(
          Icons.lock_outlined,
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
        suffixIcon: IconButton(
          icon: Icon(
            isObscurePassword
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: Colors.grey[400],
          ),
          onPressed: onPressed,
        ),
      ),
      style: GoogleFonts.poppins(color: blackColor),
      keyboardType: TextInputType.text,
      inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
      obscureText: isObscurePassword,
      controller: controller,
      validator: (value) {
        if (value!.isEmpty) {
          return 'تکایە وشەی نهێنی بنووسە';
        } else if (value.length < 6) {
          return 'پێویستە وشەی نهێنی لە ٦ کارەکتەر زیاتر بێت';
        }
        return null;
      },
    );
  }
}
