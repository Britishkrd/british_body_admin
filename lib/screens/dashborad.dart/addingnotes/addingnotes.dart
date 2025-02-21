import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:sizer/sizer.dart';

class Addingnotes extends StatefulWidget {
  final String email;
  final DocumentReference reference;
  const Addingnotes({super.key, required this.email, required this.reference});

  @override
  State<Addingnotes> createState() => _AddingnotesState();
}

class _AddingnotesState extends State<Addingnotes> {
  List<TextEditingController> linkcontrollerslist = [TextEditingController()];
  List<TextEditingController> notecontrollerslist = [TextEditingController()];
  double listviewheight = 0;

  Future<void> _getCurrentPosition() async {
    final position = await _geolocatorPlatform.getCurrentPosition();
    latitude = position.latitude;
    longtitude = position.longitude;
    return;
  }

  final GeolocatorPlatform _geolocatorPlatform = GeolocatorPlatform.instance;

  bool checkin = true;
  double latitude = 0.0;
  double longtitude = 0.0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('زیادکردنی تێبینی و لینک'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          SizedBox(
            height: ((notecontrollerslist.length * 8) + 5).h,
            child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: notecontrollerslist.length,
                itemBuilder: (context, index1) {
                  return Container(
                    margin: EdgeInsets.only(top: 0.h, left: 5.w, right: 5.w),
                    width: 90.w,
                    height: 8.h,
                    child: Material1.textfield(
                        hint: 'تێبینی ${index1 + 1}   ',
                        controller: notecontrollerslist[index1],
                        textColor: Material1.primaryColor),
                  );
                }),
          ),
          SizedBox(
            height: ((linkcontrollerslist.length * 8) + 5).h,
            child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: linkcontrollerslist.length,
                itemBuilder: (context, index1) {
                  return Container(
                    margin: EdgeInsets.only(top: 0.h, left: 5.w, right: 5.w),
                    width: 90.w,
                    height: 8.h,
                    child: Material1.textfield(
                        hint: 'لینکی ${index1 + 1}  ',
                        controller: linkcontrollerslist[index1],
                        textColor: Material1.primaryColor),
                  );
                }),
          ),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    linkcontrollerslist.add(TextEditingController());
                  });
                },
                child: Container(
                  width: 40.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[200],
                  ),
                  margin: EdgeInsets.only(left: 5.w, right: 5.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.black),
                      Text('زیادکردنی لینک',
                          style:
                              TextStyle(fontSize: 16.sp, color: Colors.black)),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  setState(() {
                    notecontrollerslist.add(TextEditingController());
                  });
                },
                child: Container(
                  width: 40.w,
                  height: 6.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.grey[200],
                  ),
                  margin: EdgeInsets.only(left: 5.w, right: 5.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.black),
                      Text('زیادکردنی تێبینی',
                          style:
                              TextStyle(fontSize: 16.sp, color: Colors.black)),
                    ],
                  ),
                ),
              ),
            ],
          ),
          Container(
            margin: EdgeInsets.only(top: 2.h, left: 5.w, right: 5.w),
            child: Material1.button(
                label: 'زیادکردنی تێبینی و لینک',
                buttoncolor: Material1.primaryColor,
                textcolor: Colors.white,
                function: () async {
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      });
                  await _getCurrentPosition();
                  showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title:
                              const Text('دڵنیایت لە زیادکردنی تێبینی و لینک؟'),
                          actions: [
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('نەخێر')),
                            TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                  List<String> notes = [];
                                  List<String> links = [];
                                  for (int i = 0;
                                      i < notecontrollerslist.length;
                                      i++) {
                                    notes.add(notecontrollerslist[i].text);
                                  }
                                  for (var i = 0;
                                      i < linkcontrollerslist.length;
                                      i++) {
                                    links.add(linkcontrollerslist[i].text);
                                  }
                                  widget.reference
                                      .collection('updates')
                                      .doc(DateTime.now().toIso8601String())
                                      .set({
                                    'note': notes,
                                    'link': links,
                                    'email': widget.email,
                                    'latitude': latitude,
                                    'longtitude': longtitude,
                                    'time': DateTime.now(),
                                    'action': 'زیادکردنی تێبینی و لینک',
                                    'stage': 'دەرەکی'
                                  });

                                  Navigator.popUntil(
                                      context, (route) => route.isFirst);
                                },
                                child: const Text('بەڵێ'))
                          ],
                        );
                      });
                }),
          )
        ],
      ),
    );
  }
}
