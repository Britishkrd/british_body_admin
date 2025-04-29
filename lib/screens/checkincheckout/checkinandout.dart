import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/sharedprefrences/sharedprefernences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:ntp/ntp.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

// State variables
class CheckInState {
  static bool isCheckedIn = true;
  static double currentLatitude = 0.0;
  static double currentLongitude = 0.0;
  static double workplaceLatitude = 0.0;
  static double workplaceLongitude = 0.0;
  static String userEmail = '';
  static List<String> userPermissions = [];
  static bool showCheckInForm = false;
  static int workStartHour = 0;
  static int workEndHour = 0;
  static int workStartMinute = 0;
  static int workEndMinute = 0;
  static List<int> workingDays = [];
}

final TextEditingController _noteController = TextEditingController();
final GeolocatorPlatform _geolocator = GeolocatorPlatform.instance;

class CheckInOutScreen extends StatefulWidget {
  const CheckInOutScreen({super.key});

  @override
  State<CheckInOutScreen> createState() => _CheckInOutScreenState();
}

class _CheckInOutScreenState extends State<CheckInOutScreen> {
  @override
  void initState() {
    _loadUserInfo();
    super.initState();
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      CheckInState.userEmail = prefs.getString('email') ?? '';
      CheckInState.isCheckedIn = prefs.getBool('checkin') ?? false;
      CheckInState.userPermissions = prefs.getStringList('permissions') ?? [];
      CheckInState.workplaceLatitude = prefs.getDouble('worklat') ?? 0.0;
      CheckInState.workplaceLongitude = prefs.getDouble('worklong') ?? 0.0;
      CheckInState.workingDays = prefs.getStringList('weekdays')
              ?.map((e) => int.parse(e))
              .toList() ??
          [];
      CheckInState.workStartHour = prefs.getInt('starthour') ?? 0;
      CheckInState.workEndHour = prefs.getInt('endhour') ?? 0;
      CheckInState.workStartMinute = prefs.getInt('startmin') ?? 0;
      CheckInState.workEndMinute = prefs.getInt('endmin') ?? 0;
    });
  }

  Future<void> _getCurrentPosition() async {
    final position = await _geolocator.getCurrentPosition();
    setState(() {
      CheckInState.currentLatitude = position.latitude;
      CheckInState.currentLongitude = position.longitude;
    });
  }

  Widget _buildStatusHeader() {
    return Container(
      height: 8.h,
      width: 90.w,
      decoration: BoxDecoration(
        color: CheckInState.isCheckedIn ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      margin: EdgeInsets.only(top: 3.h),
      child: Center(
        child: Text(
          CheckInState.isCheckedIn
              ? 'تۆ لە ئێستادا لەکاردایت'
              : 'تۆ لە ئێستادا لەکاردا نیت تکایە چوونەژوورەوە بکە',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildCheckInButton(),
        _buildCheckOutButton(),
      ],
    );
  }

  Widget _buildCheckInButton() {
    return GestureDetector(
      onTap: CheckInState.isCheckedIn
          ? null
          : () => setState(() => CheckInState.showCheckInForm = true),
      child: Container(
        height: 8.h,
        width: 40.w,
        decoration: BoxDecoration(
          color: CheckInState.isCheckedIn ? Colors.grey : Material1.primaryColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        margin: EdgeInsets.only(top: 3.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'چوونەژوورەوە',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600),
            ),
            const Icon(Icons.login_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckOutButton() {
    return GestureDetector(
      onTap: !CheckInState.isCheckedIn
          ? null
          : () => setState(() => CheckInState.showCheckInForm = false),
      child: Container(
        height: 8.h,
        width: 40.w,
        decoration: BoxDecoration(
          color: !CheckInState.isCheckedIn ? Colors.grey : const Color(0xFFE53935),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            )
          ],
        ),
        margin: EdgeInsets.only(top: 3.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text(
              'چوونەدەرەوە',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.w600),
            ),
            const Icon(Icons.logout_rounded, color: Colors.white),
          ],
        ),
      ),
    );
  }

  Widget _buildNoteField() {
    return Container(
      margin: EdgeInsets.only(top: 3.h),
      height: 8.h,
      width: 90.w,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Material1.textfield(
        hint: 'تێبینی(هەڵبژاردەییە)',
        textColor: Material1.primaryColor,
        controller: _noteController,
      ),
    );
  }

  Widget _buildCheckInButtonSection() {
    return Column(
      children: [
        _buildNoteField(),
        SizedBox(height: 2.h),
        _buildMainCheckInButton(),
        SizedBox(height: 2.h),
        if (CheckInState.userPermissions.contains('workoutside'))
          _buildWorkOutsideCheckInButton(),
      ],
    );
  }

  Widget _buildMainCheckInButton() {
    return Container(
      margin: EdgeInsets.only(top: 1.h),
      height: 8.h,
      width: 40.w,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: CheckInState.isCheckedIn ? Colors.grey : Material1.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.2),
          padding: EdgeInsets.symmetric(horizontal: 20),
        ),
        onPressed: CheckInState.isCheckedIn
            ? null
            : () => _handleCheckIn(false),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.login_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('چوونەژوورەوە',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildWorkOutsideCheckInButton() {
    return Container(
      height: 8.h,
      width: 80.w,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: CheckInState.isCheckedIn ? Colors.grey : Material1.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.2),
          padding: EdgeInsets.symmetric(horizontal: 20),
        ),
        onPressed: CheckInState.isCheckedIn
            ? null
            : () => _handleCheckIn(true),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.login_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('چوونەژوورەوە لە دەروەی شوێنی ئیشکردن',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckOutSection() {
    return Column(
      children: [
        _buildNoteField(),
        SizedBox(height: 2.h),
        _buildCheckOutButtonSection(),
      ],
    );
  }

  Widget _buildCheckOutButtonSection() {
    return Container(
      height: 8.h,
      width: 40.w,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: !CheckInState.isCheckedIn ? Colors.grey : const Color(0xFFE53935),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          elevation: 4,
          shadowColor: Colors.black.withOpacity(0.2),
          padding: EdgeInsets.symmetric(horizontal: 20),
        ),
        onPressed: !CheckInState.isCheckedIn
            ? null
            : _handleCheckOut,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.logout_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('چوونەدەرەوە',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCheckIn(bool isOutsideWorkplace) async {
    _showLoadingDialog('تکایە چاوەڕێکەوە');

    try {
      await _getCurrentPosition();
      await _loadUserInfo();

      if (!isOutsideWorkplace) {
        final distance = Geolocator.distanceBetween(
          CheckInState.workplaceLatitude,
          CheckInState.workplaceLongitude,
          CheckInState.currentLatitude,
          CheckInState.currentLongitude,
        );

        if (distance > 100) {
          Navigator.pop(context);
          _showErrorDialog(
            'هەڵە',
            'تکایە لە ناوچەی کاری خۆت چوونەژوورەوە بکە',
          );
          return;
        }
      }

      if (CheckInState.isCheckedIn) {
        Navigator.pop(context);
        _showErrorDialog('هەڵە', 'تکایە چوونەدەرەووە بکە');
        return;
      }

      final isNewDay = await _isNewDayCheckIn();

      Navigator.pop(context);
      await _showConfirmationDialog(
        'دڵنیاکردنەوە',
        'دڵنیایت لە چوونەژوورەوە؟',
        () => _processCheckIn(isNewDay),
      );
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog('هەڵە', 'هەڵەیەک ڕوویدا: ${e.toString()}');
    }
  }

  Future<bool> _isNewDayCheckIn() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('user')
        .doc(CheckInState.userEmail)
        .collection('checkincheckouts')
        .orderBy('time', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return true;

    final lastCheckIn = (snapshot.docs.first.data()['time'] as Timestamp).toDate();
    return lastCheckIn.day != DateTime.now().day;
  }

  Future<void> _processCheckIn(bool isNewDay) async {
    _showLoadingDialog('تکایە چاوەڕێکەوە');

    try {
      final now = await _getNetworkTime();

      await FirebaseFirestore.instance
          .collection('user')
          .doc(CheckInState.userEmail)
          .collection('checkincheckouts')
          .doc(now.toIso8601String())
          .set({
        'latitude': CheckInState.currentLatitude,
        'longtitude': CheckInState.currentLongitude,
        'time': now,
        'note': _noteController.text,
        'checkout': false,
        'checkin': true,
      });

      await FirebaseFirestore.instance
          .collection('user')
          .doc(CheckInState.userEmail)
          .update({'checkin': true});

      if (isNewDay) {
        await _handleLateCheckIn(now);
      }

      await Sharedpreference.checkin(
        now.toString(),
        CheckInState.currentLatitude,
        CheckInState.currentLongitude,
        true,
      );

      setState(() => CheckInState.isCheckedIn = true);
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog('هەڵە', 'هەڵەیەک ڕوویدا: ${e.toString()}');
    }
  }

  Future<void> _handleLateCheckIn(DateTime checkInTime) async {
    final userDoc = await FirebaseFirestore.instance
        .collection('user')
        .doc(CheckInState.userEmail)
        .get();

    DateTime? changedWorkTimeEnd;
    try {
      changedWorkTimeEnd = (userDoc.data()!['changedworkend'] as Timestamp).toDate();
    } catch (e) {
      changedWorkTimeEnd = null;
    }

    if (changedWorkTimeEnd?.isAfter(checkInTime) ?? false) {
      CheckInState.workStartHour = int.parse(userDoc.data()!['changedworkstarthour']);
      CheckInState.workStartMinute = int.parse(userDoc.data()!['changedworkstartmin']);
    }

    if (CheckInState.workingDays.contains(checkInTime.weekday) &&
        checkInTime.hour >= CheckInState.workStartHour &&
        (checkInTime.hour > CheckInState.workStartHour ||
            checkInTime.minute > CheckInState.workStartMinute)) {
      final lateDuration = checkInTime.difference(DateTime(
        checkInTime.year,
        checkInTime.month,
        checkInTime.day,
        CheckInState.workStartHour,
        CheckInState.workStartMinute,
      ));

      await FirebaseFirestore.instance
          .collection('user')
          .doc(CheckInState.userEmail)
          .collection('rewardpunishment')
          .doc('punishment-late-login${DateTime.now()}')
          .set({
        'addedby': 'system',
        'amount': (lateDuration.inMinutes * 100).toString(),
        'date': DateTime.now(),
        'reason': 'for late login ${lateDuration.inMinutes} minutes',
        'type': 'punishment',
      });

      _showLateCheckInWarning(lateDuration.inMinutes);
    }
  }

  Future<void> _handleCheckOut() async {
    _showLoadingDialog('تکایە چاوەڕێکەوە');

    try {
      await _loadUserInfo();
      await _getCurrentPosition();

      if (!CheckInState.isCheckedIn) {
        Navigator.pop(context);
        _showErrorDialog('هەڵە', 'تکایە چوونەژوورەوە بکە');
        return;
      }

      Navigator.pop(context);
      await _showConfirmationDialog(
        'دڵنیاکردنەوە',
        'دڵنیایت لە چوونەدەرەوە؟',
        _processCheckOut,
      );
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog('هەڵە', 'هەڵەیەک ڕوویدا: ${e.toString()}');
    }
  }

  Future<void> _processCheckOut() async {
    _showLoadingDialog('تکایە چاوەڕێکەوە');

    try {
      final now = await _getNetworkTime();

      await FirebaseFirestore.instance
          .collection('user')
          .doc(CheckInState.userEmail)
          .collection('checkincheckouts')
          .doc(now.toIso8601String())
          .set({
        'latitude': CheckInState.currentLatitude,
        'longtitude': CheckInState.currentLongitude,
        'time': now,
        'note': _noteController.text,
        'checkout': true,
        'checkin': false,
      });

      await FirebaseFirestore.instance
          .collection('user')
          .doc(CheckInState.userEmail)
          .update({'checkin': false});

      await Sharedpreference.checkin(
        now.toString(),
        CheckInState.currentLatitude,
        CheckInState.currentLongitude,
        false,
      );

      setState(() => CheckInState.isCheckedIn = false);
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog('هەڵە', 'هەڵەیەک ڕوویدا: ${e.toString()}');
    }
  }

  Future<DateTime> _getNetworkTime() async {
    final localTime = DateTime.now().toLocal();
    final offset = await NTP.getNtpOffset(localTime: localTime);
    return localTime.add(Duration(milliseconds: offset));
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Column(
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: 2.h),
              Text(message,
                  style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Material1.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
            onPressed: () => Navigator.pop(context),
            child: Text('باشە', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Future<void> _showConfirmationDialog(
    String title,
    String message,
    VoidCallback onConfirm,
  ) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey[200],
              foregroundColor: Colors.black87,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
            onPressed: () => Navigator.pop(context),
            child: Text('پەشیمان بوونەوە',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: CheckInState.showCheckInForm
                  ? Material1.primaryColor
                  : const Color(0xFFE53935),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 4,
            ),
            onPressed: onConfirm,
            child: Text(
              CheckInState.showCheckInForm ? 'چوونەژوورەوە' : 'چوونەدەرەوە',
              style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showLateCheckInWarning(int lateMinutes) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('ئاگاداری', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(
            'لەکاتی خۆی درەنگتر چوونەژوورەوەت کردوە و سزا دراویت دەتوانیت لە بەشی پاداشت و سزا بیبیت'),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Material1.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
            onPressed: () => Navigator.pop(context),
            child: Text('باشە', style: TextStyle(fontWeight: FontWeight.w600)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildStatusHeader(),
        _buildActionButtons(),
        CheckInState.showCheckInForm
            ? _buildCheckInButtonSection()
            : _buildCheckOutSection(),
      ],
    );
  }
}