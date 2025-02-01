import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:sizer/sizer.dart';

class Material1 {
  static get primaryColor => const Color.fromARGB(255, 4, 131, 159);
  static get secondary => const Color.fromARGB(255, 6, 190, 231);
  bool obsucre = false;
  static textfield(
          {required String hint,
          required Color textColor,
          TextEditingController? controller,
          bool? obscure,
          String? value,
          String initialvalue = '',
          bool? readonly,
          double? fontsize,
          Color? hintcolor,
          validation,
          TextInputType? inputType}) =>
      Directionality(
          textDirection: TextDirection.rtl,
          child: TextFormField(
            validator: validation,
            controller: controller,
            keyboardType: inputType,
            readOnly: readonly ?? false,
            style: TextStyle(
                color: textColor,
                fontSize: fontsize ?? 16.sp,
                fontWeight: FontWeight.w500),
            decoration: InputDecoration(
              fillColor: textColor,
              focusColor: textColor,
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: textColor, width: 3)),
              hintStyle: TextStyle(
                  color: hintcolor ?? Colors.grey,
                  fontSize: fontsize ?? 16.sp,
                  fontWeight: FontWeight.w500),
              hintText: hint,
            ),
            obscureText: obscure ?? false,
          ));

  static button(
          {required String label,
          required Color buttoncolor,
          required Color textcolor,
          double? width,
          Color? buttonBorderColor,
          double? height,
          double? fontsize,
          Widget? child,
          required Function() function}) =>
      ElevatedButton(
          onPressed: function,
          style: OutlinedButton.styleFrom(
            side: buttonBorderColor == null
                ? null
                : BorderSide(width: 2.0, color: buttonBorderColor),
            backgroundColor: buttoncolor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: child == null
              ? Text(
                  label,
                  style: TextStyle(
                      color: textcolor,
                      fontSize: fontsize ?? 16.sp,
                      fontWeight: FontWeight.w600),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                          color: textcolor,
                          fontSize: fontsize ?? 16.sp,
                          fontWeight: FontWeight.w600),
                    ),
                    child
                  ],
                ));

  static image(String url, int? width, int? height, BoxFit? fit) {
    return CachedNetworkImage(
      memCacheWidth: width,
      memCacheHeight: height,
      fit: fit ?? BoxFit.cover,
      imageUrl: url,
      progressIndicatorBuilder: (context, url, downloadProgress) => Center(
        child: Lottie.asset('lib/assets/loading.json'),
      ),
      errorWidget: (context, url, error) => Image.asset('lib/assets/shop.png'),
    );
  }

  static showdialog(
      BuildContext context, String title, String body, List<Widget> actions) {
    showDialog<String>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(title),
        content: Text(body),
        actions: actions,
      ),
    );
  }
}
