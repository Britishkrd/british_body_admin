import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/screens/dashborad.dart/map/map_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:day_night_time_picker/lib/daynight_timepicker.dart';
import 'package:day_night_time_picker/lib/state/time.dart';
import 'package:day_picker/day_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Adduser extends StatefulWidget {
  const Adduser({super.key});

  @override
  State<Adduser> createState() => _AdduserState();
}

class _AdduserState extends State<Adduser> {
  TextEditingController emailcontroller = TextEditingController();
  TextEditingController namecontroller = TextEditingController();
  TextEditingController locationcontroller = TextEditingController();
  TextEditingController phonenumbercontroller = TextEditingController();
  TextEditingController salarycontroller = TextEditingController();
  TextEditingController agecontroller = TextEditingController();
  TextEditingController workhourtargetcontroller = TextEditingController();
  TextEditingController passwordcontroller = TextEditingController();

  String? selectedPlaceId;
  List<Map<String, dynamic>> places = [];
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
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
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading places: $e')),
      );
    }
  }

  List<String> permissions = [
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

  Time starthour =
      Time(hour: DateTime.now().hour, minute: DateTime.now().minute);
  Time endhour = Time(hour: DateTime.now().hour, minute: DateTime.now().minute);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('زیادکردنی کارمەند'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.location_on_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const PlacePickerScreen()),
              ).then((_) => _fetchPlaces());
            },
          ),
        ],
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
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: EdgeInsets.symmetric(horizontal: 4.w),
                ),
                hint: const Text('Select Work Place'),
                initialValue: selectedPlaceId,
                items: places.map((place) {
                  return DropdownMenuItem<String>(
                    value: place['id'],
                    child: Text(place['workPlaceName']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPlaceId = value;
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
                },
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0.w, 1.h, 0.w, 1.h),
              constraints: BoxConstraints(
                maxHeight: 40.h, // Set a reasonable max height
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
                  label: 'دروستکردنی بەکار هێنەر',
                  buttoncolor: Material1.primaryColor,
                  textcolor: Colors.white,
                  function: () {
                    if (emailcontroller.text.isEmpty ||
                        namecontroller.text.isEmpty ||
                        locationcontroller.text.isEmpty ||
                        phonenumbercontroller.text.isEmpty ||
                        salarycontroller.text.isEmpty ||
                        // worklatcontroller.text.isEmpty ||
                        // worklongcontroller.text.isEmpty ||
                        agecontroller.text.isEmpty ||
                        workhourtargetcontroller.text.isEmpty ||
                        passwordcontroller.text.isEmpty ||
                        selectedPlaceId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('تکایە هەموو خانەکان پڕبکەوە')));
                    } else {
                      final selectedPlace = places.firstWhere(
                          (place) => place['id'] == selectedPlaceId);

                      FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                        email: emailcontroller.text,
                        password: passwordcontroller.text,
                      )
                          .then((userCredential) {
                        // User created successfully
                      }).catchError((error) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Error: ${error.message}'),
                        ));
                      }).then((value) {
                        FirebaseFirestore.instance
                            .collection('user')
                            .doc(emailcontroller.text.toLowerCase())
                            .set({
                          'email': emailcontroller.text.toLowerCase(),
                          'name': namecontroller.text,
                          'location': locationcontroller.text,
                          'phonenumber': phonenumbercontroller.text.toString(),
                          'salary': int.parse(salarycontroller.text),
                          'worklat': selectedPlace['lat'],
                          'worklong': selectedPlace['long'],
                          'workPlaceName': selectedPlace['workPlaceName'],
                          'permissions': selectedpermissions,
                          'age': agecontroller.text.toString(),
                          'token': '',
                          'checkin': false,
                          'deviceid': '',
                          'lat': 0.0,
                          'long': 0.0,
                          'loanstatus': 'no',
                          'worktarget':
                              int.parse(workhourtargetcontroller.text),
                          'password': passwordcontroller.text,
                          'weekdays': workdays,
                          'starthour': starthour.hour,
                          'endhour': endhour.hour,
                          'startmin': starthour.minute,
                          'endmin': endhour.minute,
                        }).then((value) {
                          ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('بە سەرکەوتویی زیادکرا')));
                          Navigator.pop(context);
                        });
                      });
                    }
                  }),
            )
          ],
        ),
      ),
    );
  }
}
