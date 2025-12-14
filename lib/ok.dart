import 'package:flutter/material.dart';
import 'package:british_body_admin/utils/color.dart';
import 'package:british_body_admin/utils/textstyle.dart';
import 'package:british_body_admin/material/materials.dart';
import 'package:sizer/sizer.dart';

class LocationDisclosureDialog {
  final BuildContext context;

  LocationDisclosureDialog({required this.context});

  Future<bool> show() async {
    return await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Column(
            children: [
              Icon(
                Icons.location_on,
                size: 50,
                color: Material1.primaryColor,
              ),
              SizedBox(height: 2.h),
              Text(
                'Location Permission Required',
                style: kurdishTextStyle(18, blackColor),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This application requires background location permission for:',
                  style: kurdishTextStyle(14, blackColor),
                ),
                SizedBox(height: 2.h),
                _buildFeatureItem(
                  Icons.access_time,
                  'Monitoring work hours (Check-in/Check-out)',
                ),
                SizedBox(height: 1.h),
                _buildFeatureItem(
                  Icons.work,
                  'Ensuring you are at the workplace',
                ),
                SizedBox(height: 1.h),
                _buildFeatureItem(
                  Icons.history,
                  'Recording attendance times accurately',
                ),
                SizedBox(height: 2.h),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.blue.shade700,
                        size: 20,
                      ),
                      SizedBox(width: 2.w),
                      Expanded(
                        child: Text(
                          'Your location is only recorded during work hours and is stored securely.',
                          style: kurdishTextStyle(12, Colors.blue.shade900),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  'Please press "Allow" to accurately record work hours.',
                  style: kurdishTextStyle(13, Colors.grey[700]!),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          actions: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Text(
                      'Later',
                      style: kurdishTextStyle(14, Colors.grey[600]!),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Material1.primaryColor,
                      foregroundColor: whiteColor,
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Allow',
                          style: kurdishTextStyle(14, whiteColor),
                        ),
                        SizedBox(width: 1.w),
                        Icon(Icons.check_circle, size: 18),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    ) ?? false;
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Material1.primaryColor,
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Text(
            text,
            style: kurdishTextStyle(13, Colors.grey[700]!),
          ),
        ),
      ],
    );
  }
}