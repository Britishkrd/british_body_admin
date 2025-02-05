import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:map_location_picker/map_location_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:intl/intl.dart';

class Taskdetails extends StatefulWidget {
  final QueryDocumentSnapshot<Object?> task;
  final String email;
  const Taskdetails({
    super.key,
    required this.task,
    required this.email,
  });

  @override
  State<Taskdetails> createState() => _TaskdetailsState();
}

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
TextEditingController notecontroller = TextEditingController();

class _TaskdetailsState extends State<Taskdetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('وردەکاری کارەکە'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
      ),
      body: ListView(
        children: [
          SizedBox(
              height: 10.h,
              width: 90.w,
              child: Container(
                margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
                padding: EdgeInsets.all(1.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.grey,
                      blurRadius: 5,
                    )
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text("${widget.task['name']} : ئەرک",
                        style: TextStyle(
                            fontSize: 16.sp, fontWeight: FontWeight.bold)),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text(
                            "${DateFormat('MMM d, h:mm a').format(widget.task['end'].toDate())} بۆ",
                            style: TextStyle(
                              fontSize: 16.sp,
                            )),
                        Text(
                            "${DateFormat('MMM d, h:mm a').format(widget.task['start'].toDate())}  لە",
                            style: TextStyle(
                              fontSize: 16.sp,
                            )),
                      ],
                    ),
                  ],
                ),
              )),
          Container(
            margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
            padding: EdgeInsets.all(1.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
              boxShadow: const [
                BoxShadow(
                  color: Colors.grey,
                  blurRadius: 5,
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(": وردەکاری",
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.bold)),
                Text(widget.task['description'],
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          !widget.task['isdaily'] && widget.task['status'] != 'done'
              ? Container(
                  margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
                  width: 90.w,
                  height: 8.h,
                  child: Material1.textfield(
                      hint: 'تێبینی',
                      controller: notecontroller,
                      textColor: Material1.primaryColor),
                )
              : const SizedBox.shrink(),
          (!widget.task['isdaily'] && widget.task['status'] != 'done')
              ? Container(
                  margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
                  width: 90.w,
                  height: 8.h,
                  child: Material1.button(
                      label: widget.task['status'] == 'pending'
                          ? 'دەستپێکردن'
                          : 'کۆتایی پێهێنان',
                      function: () async {
                        if (widget.task['start']
                            .toDate()
                            .isAfter(DateTime.now())) {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: Text('هەڵە'),
                                  content: Text(
                                      'لەکاتی دیاری کراو دەست بە کارەکە بکە'),
                                  actions: [
                                    Material1.button(
                                        label: 'باشە',
                                        buttoncolor: Material1.primaryColor,
                                        textcolor: Colors.white,
                                        function: () {
                                          Navigator.pop(context);
                                        }),
                                  ],
                                );
                              });
                          return;
                        }
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text(widget.task['status'] == 'pending'
                                    ? 'دەستپێکردن'
                                    : 'کۆتایی پێهێنان'),
                                content: Text(widget.task['status'] == 'pending'
                                    ? 'دڵنیایتت لە دەستپێکردنی کارەکە؟'
                                    : 'دڵنیایتتت لە کۆتایی پێهێنانی کارەکە؟'),
                                actions: [
                                  Material1.button(
                                      label: 'نەخێر',
                                      function: () {
                                        Navigator.pop(context);
                                      },
                                      textcolor: Colors.white,
                                      buttoncolor: Material1.primaryColor),
                                  Material1.button(
                                      label: 'بەڵێ',
                                      function: () async {
                                        showDialog(
                                            context: context,
                                            builder: (context) {
                                              return AlertDialog(
                                                title: Center(
                                                    child:
                                                        const CircularProgressIndicator()),
                                              );
                                            });
                                        await _getCurrentPosition();
                                        widget.task.reference
                                            .collection('updates')
                                            .doc(DateTime.now().toString())
                                            .set({
                                          'note': notecontroller.text,
                                          'time': DateTime.now(),
                                          'latitude': latitude,
                                          'longtitude': longtitude,
                                          'action':
                                              widget.task['status'] == 'pending'
                                                  ? 'start'
                                                  : 'finish'
                                        }).then(
                                          (value) async{
                                            if (widget.task['status'] ==
                                                'pending') {
                                              widget.task.reference
                                                  .update({'status': 'active'});
                                            } else {
                                              String reward = '0';
                                              try {
                                                reward =
                                                    widget.task['rewardamount'];
                                              } catch (e) {
                                                reward = '0';
                                              }
                                              await FirebaseFirestore.instance
                                                  .collection('user')
                                                  .doc(widget.email)
                                                  .collection(
                                                      'rewardpunishment')
                                                  .doc(
                                                      'reward-${widget.task['name']}${DateTime.now()}')
                                                  .set({
                                                    'addedby':widget.email,
                                                     'amount':reward,
                                                     'date':DateTime.now(),
                                                     'reason':'doing task ${widget.task['name']}',
                                                     'type':'reward'
                                                  });
                                            }
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                content: Text(widget
                                                            .task['status'] ==
                                                        'pending'
                                                    ? 'دەست بە کارەکە کرا'
                                                    : 'کارەکە کۆتایی پێهات'),
                                              ),
                                            );
                                            Navigator.popUntil(context,
                                                (route) => route.isFirst);
                                          },
                                        ).catchError((error) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              content: Text('هەڵەیەک هەیە'),
                                            ),
                                          );
                                        });
                                      },
                                      textcolor: Colors.white,
                                      buttoncolor: Material1.primaryColor),
                                ],
                              );
                            });
                      },
                      textcolor: Colors.white,
                      buttoncolor: Material1.primaryColor),
                )
              : const SizedBox.shrink()
        ],
      ),
    );
  }
}
