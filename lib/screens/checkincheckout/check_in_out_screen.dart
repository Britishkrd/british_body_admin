import 'dart:async';

import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/sharedprefrences/sharedprefernences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
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
  //work time Store these 3 below for it
  static Duration cachedWorkingHours = Duration.zero;
  static Duration cachedBreakTime = Duration.zero;
  static DateTime? lastCalculationTime;
}

final TextEditingController _noteController = TextEditingController();
final GeolocatorPlatform _geolocator = GeolocatorPlatform.instance;

class CheckInOutScreen extends StatefulWidget {
  const CheckInOutScreen({super.key});

  @override
  State<CheckInOutScreen> createState() => _CheckInOutScreenState();
}

class _CheckInOutScreenState extends State<CheckInOutScreen>
    with WidgetsBindingObserver, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  bool checkin = true;
  double worklatitude = 0.0;
  double worklongtitude = 0.0;

  TextEditingController notecontroller = TextEditingController();

  String email = '';
  String name = '';

  // Timer and duration variables
  Timer? _liveTimer;
  Duration _currentSessionDuration = Duration.zero;
  Duration _todayWorkingHours = Duration.zero;
  Duration _todayBreakTime = Duration.zero;
  bool _isLoadingStats = false;
  DateTime? _lastCheckInTime;
  DateTime? _lastCheckOutTime;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadUserInfo();
    _startLiveTimer();
    _loadCachedStats(); // Add this
    _checkForNewDay().then((_) => _calculateDailyStats());
  }

  Future<void> _loadCachedStats() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final lastSavedDay = prefs.getString('lastCalculationDay');

    if (lastSavedDay == startOfDay.toIso8601String()) {
      final savedWorkingHours = prefs.getInt('workingHours') ?? 0;
      final savedBreakTime = prefs.getInt('breakTime') ?? 0;

      setState(() {
        _todayWorkingHours = Duration(seconds: savedWorkingHours);
        _todayBreakTime = Duration(seconds: savedBreakTime);
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkForNewDay();
      _calculateDailyStats();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _liveTimer?.cancel();
    super.dispose();
  }

  void _startLiveTimer() {
    _liveTimer = Timer.periodic(Duration(seconds: 1), (timer) async {
      if (CheckInState.isCheckedIn) {
        final prefs = await SharedPreferences.getInstance();

        setState(() {
          _currentSessionDuration += Duration(seconds: 1);
          _todayWorkingHours += Duration(seconds: 1);
        });

        // Update SharedPreferences every minute to reduce writes
        if (_currentSessionDuration.inSeconds % 60 == 0) {
          await prefs.setInt('workingHours', _todayWorkingHours.inSeconds);
        }
      } else {
        setState(() {
          _currentSessionDuration = Duration.zero;
        });
      }
    });
  }

  Future<void> _checkForNewDay() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final lastSavedDay = prefs.getString('lastCalculationDay');

    if (lastSavedDay != startOfDay.toIso8601String()) {
      await prefs.remove('workingHours');
      await prefs.remove('breakTime');
      await prefs.setString('lastCalculationDay', startOfDay.toIso8601String());
      _calculateDailyStats(); // Recalculate for the new day
    }
  }

  getuserinfo() async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    email = preference.getString('email') ?? '';
    name = preference.getString('name') ?? '';
    checkin = preference.getBool('checkin') ?? false;
    worklatitude = preference.getDouble('worklat') ?? 0.0;
    worklongtitude = preference.getDouble('worklong') ?? 0.0;
    setState(() {});
  }

  Future<void> _loadUserInfo() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      CheckInState.userEmail = prefs.getString('email') ?? '';
      CheckInState.isCheckedIn = prefs.getBool('checkin') ?? false;
      CheckInState.userPermissions = prefs.getStringList('permissions') ?? [];
      CheckInState.workplaceLatitude = prefs.getDouble('worklat') ?? 0.0;
      CheckInState.workplaceLongitude = prefs.getDouble('worklong') ?? 0.0;
      CheckInState.workingDays =
          prefs.getStringList('weekdays')?.map((e) => int.parse(e)).toList() ??
              [];
      CheckInState.workStartHour = prefs.getInt('starthour') ?? 0;
      CheckInState.workEndHour = prefs.getInt('endhour') ?? 0;
      CheckInState.workStartMinute = prefs.getInt('startmin') ?? 0;
      CheckInState.workEndMinute = prefs.getInt('endmin') ?? 0;
      // Add these two lines:
      name = prefs.getString('name') ?? '';
      email = prefs.getString('email') ?? '';
    });
  }

  Future<void> _getCurrentPosition() async {
    final position = await _geolocator.getCurrentPosition();
    setState(() {
      CheckInState.currentLatitude = position.latitude;
      CheckInState.currentLongitude = position.longitude;
    });
  }

  Widget _buildCheckInButtonSection() {
    return Column(
      children: [
        // Note field
        _buildModernNoteField(),

        SizedBox(height: 24),

        // Show either check-in or check-out button based on current state
        if (!CheckInState.isCheckedIn) ...[
          // Main check-in button
          _buildModernActionButton(
            icon: Icons.login_rounded,
            label: 'چوونەژوورەوە',
            color: Material1.primaryColor,
            onPressed: () => _handleCheckIn(false),
          ),

          SizedBox(height: 12),

          // Work outside button (conditionally shown)
          if (CheckInState.userPermissions.contains('workoutside'))
            _buildModernActionButton(
              icon: Icons.pin_drop_outlined,
              label: 'لە دەروەی شوێنی ئیشکردن',
              color: Material1.primaryColor,
              onPressed: () => _handleCheckIn(true),
              isFullWidth: true,
            ),
        ] else ...[
          // Check-out button
          _buildModernActionButton(
            icon: Icons.logout_rounded,
            label: 'چوونەدەرەوە',
            color: Color(0xFFE53935),
            onPressed: _handleCheckOut,
          ),
        ],
      ],
    );
  }

  Widget _buildModernNoteField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _noteController,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          hintText: 'تێبینی(هەڵبژاردەییە)',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildModernActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
    bool isFullWidth = false,
  }) {
    return SizedBox(
      width: isFullWidth ? double.infinity : null,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed == null ? Colors.grey : color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          shadowColor: color.withOpacity(0.3),
          padding: EdgeInsets.symmetric(horizontal: 24),
        ),
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 20),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleCheckIn(bool isOutsideWorkplace) async {
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
          _showErrorDialog(
            'هەڵە',
            'تکایە لە ناوچەی کاری خۆت چوونەژوورەوە بکە',
          );
          return;
        }
      }

      if (CheckInState.isCheckedIn) {
        _showErrorDialog('هەڵە', 'تکایە چوونەدەرەووە بکە');
        return;
      }

      final isNewDay = await _isNewDayCheckIn();
      _showLoadingDialog('تکایە چاوەڕێکەوە');
      _processCheckIn(isNewDay);
    } catch (e) {
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

    final lastCheckIn =
        (snapshot.docs.first.data()['time'] as Timestamp).toDate();
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

      // if (isNewDay) {
      //   await _handleLateCheckIn(now);
      // }

      await Sharedpreference.checkin(
        now.toString(),
        CheckInState.currentLatitude,
        CheckInState.currentLongitude,
        true,
      );

      setState(() {
        CheckInState.isCheckedIn = true;
        _currentSessionDuration = Duration.zero; // Reset session timer
      });

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
      changedWorkTimeEnd =
          (userDoc.data()!['changedworkend'] as Timestamp).toDate();
    } catch (e) {
      changedWorkTimeEnd = null;
    }

    if (changedWorkTimeEnd?.isAfter(checkInTime) ?? false) {
      CheckInState.workStartHour =
          int.parse(userDoc.data()!['changedworkstarthour']);
      CheckInState.workStartMinute =
          int.parse(userDoc.data()!['changedworkstartmin']);
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
    try {
      await _loadUserInfo();
      await _getCurrentPosition();

      if (!CheckInState.isCheckedIn) {
        _showErrorDialog('هەڵە', 'تکایە چوونەژوورەوە بکە');
        return;
      }

      _showLoadingDialog('تکایە چاوەڕێکەوە');
      _processCheckOut();
    } catch (e) {
      _showErrorDialog('هەڵە', 'هەڵەیەک ڕوویدا: ${e.toString()}');
    }
  }

  Future<void> _processCheckOut() async {
    _showLoadingDialog('تکایە چاوەڕێکەوە');

    try {
      final now = await _getNetworkTime();
      final exactCheckOutTime = now; // This is the exact time we'll use

      await FirebaseFirestore.instance
          .collection('user')
          .doc(CheckInState.userEmail)
          .collection('checkincheckouts')
          .doc(exactCheckOutTime.toIso8601String())
          .set({
        'latitude': CheckInState.currentLatitude,
        'longtitude': CheckInState.currentLongitude,
        'time': exactCheckOutTime,
        'note': _noteController.text,
        'checkout': true,
        'checkin': false,
      });

      await FirebaseFirestore.instance
          .collection('user')
          .doc(CheckInState.userEmail)
          .update({'checkin': false});

      await Sharedpreference.checkin(
        exactCheckOutTime.toString(),
        CheckInState.currentLatitude,
        CheckInState.currentLongitude,
        false,
      );

      setState(() {
        CheckInState.isCheckedIn = false;
        _currentSessionDuration = Duration.zero;
        _lastCheckOutTime = exactCheckOutTime; // Store the exact logout time
      });

      // Recalculate stats using the exact time
      await _calculateDailyStats();

      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      Navigator.pop(context);
      _showErrorDialog('هەڵە', 'هەڵەیەک ڕوویدا: ${e.toString()}');
    }
  }

  Future<DateTime> _getNetworkTime() async {
    if (kIsWeb) {
      // For web, just use the local time since we can't reliably get NTP time
      return DateTime.now().toLocal();
    } else {
      // For mobile, use NTP as before
      final localTime = DateTime.now().toLocal();
      final offset = await NTP.getNtpOffset(localTime: localTime);
      return localTime.add(Duration(milliseconds: offset));
    }
  }

  void _showLoadingDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Material1.primaryColor),
              ),
              SizedBox(height: 16),
              Text(
                message,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.red[700],
                ),
              ),
              SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp),
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'باشە',
                        style: TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLateCheckInWarning(int lateMinutes) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded,
                  size: 40, color: Colors.orange[700]),
              SizedBox(height: 8),
              Text(
                'ئاگاداری',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 12),
              Text(
                'لەکاتی خۆی درەنگتر چوونەژوورەوەت کردوە و سزا دراویت دەتوانیت لە بەشی پاداشت و سزا بیبیت',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14.sp),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: Material1.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'باشە',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _calculateDailyStats() async {
    // setState(() => _isLoadingStats = true);
    if (_todayWorkingHours.inSeconds == 0 && _todayBreakTime.inSeconds == 0) {
      setState(() => _isLoadingStats = true);
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);

      // Load cached data if it exists and is from today
      final lastSavedDay = prefs.getString('lastCalculationDay');
      if (lastSavedDay == startOfDay.toIso8601String()) {
        final savedWorkingHours = prefs.getInt('workingHours') ?? 0;
        final savedBreakTime = prefs.getInt('breakTime') ?? 0;

        setState(() {
          _todayWorkingHours = Duration(seconds: savedWorkingHours);
          _todayBreakTime = Duration(seconds: savedBreakTime);
        });
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(CheckInState.userEmail)
          .collection('checkincheckouts')
          .where('time', isGreaterThanOrEqualTo: startOfDay)
          .orderBy('time', descending: false)
          .get();

      Duration workingHours = Duration.zero;
      Duration breakTime = Duration.zero;
      DateTime? lastCheckInTime;
      DateTime? lastCheckOutTime;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final timestamp = data['time'] as Timestamp;
        final time = timestamp.toDate();
        final isCheckIn = data['checkin'] == true;

        if (isCheckIn) {
          lastCheckInTime = time;

          if (lastCheckOutTime != null) {
            breakTime += time.difference(lastCheckOutTime);
            lastCheckOutTime = null;
          }
        } else {
          lastCheckOutTime = time;

          if (lastCheckInTime != null) {
            workingHours += time.difference(lastCheckInTime);
            lastCheckInTime = null;
          }
        }
      }

      // If currently checked in, add the time since last check-in
      if (CheckInState.isCheckedIn && lastCheckInTime != null) {
        final additionalTime = now.difference(lastCheckInTime);
        workingHours += additionalTime;
      }

      // Save to SharedPreferences
      await prefs.setInt('workingHours', workingHours.inSeconds);
      await prefs.setInt('breakTime', breakTime.inSeconds);
      await prefs.setString('lastCalculationDay', startOfDay.toIso8601String());

      setState(() {
        _todayWorkingHours = workingHours;
        _todayBreakTime = breakTime;
        _isLoadingStats = false;
      });
    } catch (e) {
      setState(() => _isLoadingStats = false);
      if (kDebugMode) print('هەڵە لە هەژمارکردنی کاتەکان: $e');
    }
  }

  String _formatDuration(Duration duration) {
    return '${duration.inHours}:${(duration.inMinutes % 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  Widget _buildLiveTimeDisplay() {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Status indicator with icon
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: CheckInState.isCheckedIn
                  ? Colors.green.withOpacity(0.1)
                  : Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CheckInState.isCheckedIn ? Icons.check_circle : Icons.pending,
                  color: CheckInState.isCheckedIn ? Colors.green : Colors.red,
                  size: 18,
                ),
                SizedBox(width: 8),
                Text(
                  CheckInState.isCheckedIn ? 'لە کاردایت' : 'لە کاردا نیت',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: CheckInState.isCheckedIn ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16),

          // Stats cards
          Row(
            children: [
              // Working hours card
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.green.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'کۆی کارکردن',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.green,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _formatDuration(_todayWorkingHours),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(width: 12),

              // Break time card
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.red.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'کۆی پشوو',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.red,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _formatDuration(_todayBreakTime),
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // User info card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            Material1.primaryColor.withOpacity(0.2),
                        child:
                            Icon(Icons.person, color: Material1.primaryColor),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              email,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  _isLoadingStats &&
                          _todayWorkingHours.inSeconds == 0 &&
                          _todayBreakTime.inSeconds == 0
                      ? Center(child: CircularProgressIndicator())
                      : _buildLiveTimeDisplay(),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Only show the check-in/out form
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: _buildCheckInButtonSection(),
            ),
          ],
        ),
      ),
    );
  }
}
