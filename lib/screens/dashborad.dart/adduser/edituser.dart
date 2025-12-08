import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/sendingnotification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:day_night_time_picker/lib/daynight_timepicker.dart';
import 'package:day_night_time_picker/lib/state/time.dart';
import 'package:day_picker/day_picker.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

class Edituserr extends StatefulWidget {
  final String email;
  final String name;
  final String location;
  final String phonenumber;
  final int salary;
  final String age;
  final String workhourtarget;
  final String worklat;
  final String worklong;
  final String password;
  final List<String> permissions;
  final int starthour;
  final int endhour;
  final int startmin;
  final int endmin;
  final List<dynamic> weekdays; // Changed to dynamic to handle Firestore data
  final String workPlaceName; // Add this parameter
  const Edituserr({
    super.key,
    required this.email,
    required this.name,
    required this.location,
    required this.phonenumber,
    required this.salary,
    required this.age,
    required this.workhourtarget,
    required this.worklat,
    required this.worklong,
    required this.password,
    required this.permissions,
    required this.starthour,
    required this.endhour,
    required this.startmin,
    required this.endmin,
    required this.weekdays,
    required this.workPlaceName,
  });

  @override
  State<Edituserr> createState() => _EdituserrState();
}


class _EdituserrState extends State<Edituserr> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController locationcontroller = TextEditingController();
  TextEditingController phonenumbercontroller = TextEditingController();
  TextEditingController salarycontroller = TextEditingController();
  TextEditingController agecontroller = TextEditingController();
  TextEditingController workhourtargetcontroller = TextEditingController();
  TextEditingController worklatcontroller = TextEditingController();
  TextEditingController worklongcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  List<String> permissions = [
    'isTester',
    'isAdmin',
    'workoutside',
    'accepting absence',
    'adding task',
    'sending alert',
    'viewing task detail',
    'accepting change time',
    'reward and punishment',
    'accepting loan',
    'giving salary',
    'setting feedback',
    'login and logout',
    'setting target',
    'add user',
    'changing worker phone',
    'adding rules',
    'testing sounds',
    'user status',
    'holiday management',
    'view user location'
  ];
  List<String> selectedpermissions = [];
  final List<DayInWeek> _days = [
    DayInWeek("Mon", dayKey: "1"),
    DayInWeek("Tue", dayKey: "2"),
    DayInWeek("Wen", dayKey: "3"),
    DayInWeek("Thu", dayKey: "4"),
    DayInWeek("Fri", dayKey: "5"),
    DayInWeek("Sat", dayKey: "6"),
    DayInWeek("Sun", dayKey: "7"),
  ];
  List<int> workdays = [];
  List<int> originalWorkdays = []; // Store original weekdays
  Time starthour = Time(hour: DateTime.now().hour, minute: DateTime.now().minute);
  Time endhour = Time(hour: DateTime.now().hour, minute: DateTime.now().minute);
  String? selectedPlaceId;
  List<Map<String, dynamic>> places = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    emailcontroller.text = widget.email;
    namecontroller.text = widget.name;
    locationcontroller.text = widget.location;
    phonenumbercontroller.text = widget.phonenumber;
    salarycontroller.text = widget.salary.toString();
    agecontroller.text = widget.age;
    workhourtargetcontroller.text = widget.workhourtarget;
    worklatcontroller.text = widget.worklat;
    worklongcontroller.text = widget.worklong;
    passwordcontroller.text = widget.password;
    selectedpermissions = widget.permissions;
    starthour = Time(hour: widget.starthour, minute: widget.startmin);
    endhour = Time(hour: widget.endhour, minute: widget.endmin);
    workdays = widget.weekdays.map((day) => day as int).toList();
    originalWorkdays = List.from(workdays); // Store original weekdays
    _days.forEach((day) {
      if (workdays.contains(int.parse(day.dayKey))) {
        day.isSelected = true;
      }
    });
    _fetchPlaces();
  }

  Future<void> _fetchPlaces() async {
    try {
      final querySnapshot = await _firestore.collection('places').get();
      setState(() {
        places = querySnapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'workPlaceName': doc['workPlaceName'],
                  'lat': doc['lat'],
                  'long': doc['long'],
                })
            .toList();
        final currentPlace = places.firstWhere(
          (place) => place['workPlaceName'] == widget.workPlaceName,
          orElse: () => {'id': null},
        );
        selectedPlaceId = currentPlace['id'];
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading places: $e')),
      );
    }
  }

  // New method to delete tasks for deselected weekdays
  Future<void> _deleteTasksForDeselectedDays(String userEmail, List<int> deselectedDays) async {
    try {
      // Get all tasks for the user
      final tasksSnapshot = await FirebaseFirestore.instance
          .collection('user')
          .doc(userEmail)
          .collection('tasks')
          .get();

      // Convert Firestore weekday indices (1-7) to DateTime.weekday (1-7, where 7 is Sunday)
      for (var task in tasksSnapshot.docs) {
        DateTime deadline = (task['deadline'] as Timestamp).toDate();
        int taskWeekday = deadline.weekday; // 1 (Mon) to 7 (Sun)
        int firestoreWeekday = taskWeekday == 7 ? 7 : taskWeekday; // Map to Firestore weekday format

        // If the task's weekday is in the deselected days, delete it
        if (deselectedDays.contains(firestoreWeekday)) {
          await FirebaseFirestore.instance
              .collection('user')
              .doc(userEmail)
              .collection('tasks')
              .doc(task.id)
              .delete();
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting tasks: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('زیادکردنی کارمەند'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 100.w,
              height: 6.h,
              margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
              child: Material1.textfield(
                  hint: 'ئیمەیل',
                  textColor: Colors.black,
                  controller: emailcontroller),
            ),
            Container(
              width: 100.w,
              height: 6.h,
              margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
              child: Material1.textfield(
                  hint: 'پاسوورد',
                  textColor: Colors.black,
                  controller: passwordcontroller),
            ),
            Container(
              width: 100.w,
              height: 6.h,
              margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
              child: Material1.textfield(
                  hint: 'ناو',
                  textColor: Colors.black,
                  controller: namecontroller),
            ),
            Container(
              width: 100.w,
              height: 6.h,
              margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
              child: Material1.textfield(
                  hint: 'تەمەن',
                  inputType: TextInputType.number,
                  textColor: Colors.black,
                  controller: agecontroller),
            ),
            Container(
              width: 100.w,
              height: 6.h,
              margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
              child: Material1.textfield(
                  hint: 'تارگێتی کاتژمێری کار',
                  textColor: Colors.black,
                  inputType: TextInputType.number,
                  controller: workhourtargetcontroller),
            ),
            Container(
              width: 100.w,
              height: 6.h,
              margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
              child: Material1.textfield(
                  hint: 'ناونیشان',
                  textColor: Colors.black,
                  controller: locationcontroller),
            ),
            Container(
              width: 100.w,
              height: 6.h,
              margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
              child: Material1.textfield(
                  hint: 'ژمارەی مۆبایل',
                  textColor: Colors.black,
                  inputType: TextInputType.number,
                  controller: phonenumbercontroller),
            ),
            Container(
              width: 100.w,
              height: 6.h,
              margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
              child: Material1.textfield(
                  hint: 'مووچە',
                  textColor: Colors.black,
                  inputType: TextInputType.number,
                  controller: salarycontroller),
            ),
            Container(
              width: 100.w,
              height: 6.h,
              margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
              child: Material1.textfield(
                  hint: 'درێژایی کارکەی',
                  textColor: Colors.black,
                  inputType: TextInputType.number,
                  controller: worklatcontroller),
            ),
            Container(
              width: 100.w,
              height: 6.h,
              margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
              child: Material1.textfield(
                  hint: 'پانایی کارکەی',
                  textColor: Colors.black,
                  inputType: TextInputType.number,
                  controller: worklongcontroller),
            ),
            Container(
              width: 100.w,
              height: 6.h,
              margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
                ),
                hint: const Text('Select Work Place'),
                value: selectedPlaceId,
                items: places.map((place) {
                  return DropdownMenuItem<String>(
                    value: place['id'],
                    child: Text(place['workPlaceName']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPlaceId = value;
                    final selectedPlace = places.firstWhere(
                      (place) => place['id'] == value);
                    worklatcontroller.text = selectedPlace['lat'].toString();
                    worklongcontroller.text = selectedPlace['long'].toString();
                  });
                },
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  showPicker(
                    context: context,
                    value: starthour,
                    sunrise: TimeOfDay(hour: 6, minute: 0),
                    sunset: TimeOfDay(hour: 18, minute: 0),
                    duskSpanInMinutes: 120,
                    onChange: (value) {
                      setState(() {
                        starthour = value;
                      });
                    },
                  ),
                );
              },
              child: Text(
                "هەڵبژاردنی کاتی دەستپێکردن",
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(
              width: 100.w,
              height: 8.h,
              child: Center(
                child: Text(
                  'کاتی دەستپێکردن: ${starthour.hour}:${starthour.minute}',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  showPicker(
                    context: context,
                    value: endhour,
                    sunrise: TimeOfDay(hour: 6, minute: 0),
                    sunset: TimeOfDay(hour: 18, minute: 0),
                    duskSpanInMinutes: 120,
                    onChange: (value) {
                      setState(() {
                        endhour = value;
                      });
                    },
                  ),
                );
              },
              child: Text(
                "هەڵبژاردنی کاتی کۆتایی",
                style: TextStyle(color: Colors.black),
              ),
            ),
            SizedBox(
              width: 100.w,
              height: 8.h,
              child: Center(
                child: Text(
                  'کاتی کۆتایی: ${endhour.hour}:${endhour.minute}',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 2.h, right: 5.w, left: 5.w),
              child: SelectWeekDays(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                days: _days,
                border: false,
                width: 90.w,
                boxDecoration: BoxDecoration(
                  color: Material1.primaryColor,
                  borderRadius: BorderRadius.circular(30.0),
                ),
                onSelect: (values) {
                  List daysoff = values;
                  workdays = [];
                  for (int i = 0; i < values.length; i++) {
                    workdays.add(int.parse(daysoff[i]));
                  }
                  setState(() {});
                },
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0.w, 1.h, 0.w, 1.h),
              constraints: BoxConstraints(
                maxHeight: 40.h,
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const ClampingScrollPhysics(),
                itemCount: permissions.length,
                itemBuilder: (context, index) {
                  return CheckboxListTile(
                    title: Text(permissions[index]),
                    value: selectedpermissions.contains(permissions[index]),
                    onChanged: (value) {
                      if (selectedpermissions.contains(permissions[index])) {
                        selectedpermissions.remove(permissions[index]);
                      } else {
                        selectedpermissions.add(permissions[index]);
                      }
                      setState(() {});
                    },
                  );
                },
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
              height: 8.h,
              width: 100.w,
              child: Material1.button(
                  label: 'نوێکردنەوەی بەکارهێنەر',
                  buttoncolor: Material1.primaryColor,
                  textcolor: Colors.white,
                  function: () async {
                    if (emailcontroller.text.isEmpty ||
                        namecontroller.text.isEmpty ||
                        locationcontroller.text.isEmpty ||
                        phonenumbercontroller.text.isEmpty ||
                        salarycontroller.text.isEmpty ||
                        worklatcontroller.text.isEmpty ||
                        worklongcontroller.text.isEmpty ||
                        agecontroller.text.isEmpty ||
                        workhourtargetcontroller.text.isEmpty ||
                        passwordcontroller.text.isEmpty ||
                        selectedPlaceId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('تکایە هەموو خانەکان پڕبکەوە')));
                      return;
                    }

                    // Identify deselected weekdays
                    List<int> deselectedDays = originalWorkdays
                        .where((day) => !workdays.contains(day))
                        .toList();

                    // Delete tasks for deselected days
                    if (deselectedDays.isNotEmpty) {
                      await _deleteTasksForDeselectedDays(
                          emailcontroller.text.toLowerCase(), deselectedDays);
                    }

                    // Proceed with user update
                    final selectedPlace = places.firstWhere(
                        (place) => place['id'] == selectedPlaceId);

                    try {
                      await FirebaseFirestore.instance
                          .collection('user')
                          .doc(emailcontroller.text.toLowerCase())
                          .update({
                        'email': emailcontroller.text.toLowerCase(),
                        'name': namecontroller.text,
                        'location': locationcontroller.text,
                        'phonenumber': phonenumbercontroller.text.toString(),
                        'salary': int.parse(salarycontroller.text),
                        'worklat': double.parse(worklatcontroller.text),
                        'worklong': double.parse(worklongcontroller.text),
                        'workPlaceName': selectedPlace['workPlaceName'],
                        'permissions': selectedpermissions,
                        'age': agecontroller.text.toString(),
                        'worktarget': int.parse(workhourtargetcontroller.text),
                        'password': passwordcontroller.text,
                        'weekdays': workdays,
                        'starthour': starthour.hour,
                        'endhour': endhour.hour,
                        'startmin': starthour.minute,
                        'endmin': endhour.minute,
                      });

                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setDouble(
                          'worklat', double.parse(worklatcontroller.text));
                      await prefs.setDouble(
                          'worklong', double.parse(worklongcontroller.text));

                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('بە سەرکەوتویی نوێکرایەوە')));

                      // Optionally send notification to user
                      // final userDoc = await FirebaseFirestore.instance
                      //     .collection('user')
                      //     .doc(emailcontroller.text.toLowerCase())
                      //     .get();
                      // if (userDoc.exists && deselectedDays.isNotEmpty) {
                      //   sendingnotification(
                      //     'نوێکردنەوەی داتا',
                      //     'ڕۆژەکانی کارکردنت گۆڕدرا و ئەرکەکانی ئەو ڕۆژانە سڕانەوە',
                      //     userDoc.data()?['token'],
                      //     'default1',
                      //   );
                      // }

                      Navigator.pop(context);
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error updating user: $e'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }
}