import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

bool checkin = true;
double worklatitude = 0.0;
double worklongtitude = 0.0;

TextEditingController notecontroller = TextEditingController();

String email = '';
String name = '';

class _ProfileState extends State<Profile> {
  @override
  void initState() {
    getuserinfo();
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        // SizedBox(
        //   width: 100.w,
        //   height: 20.h,
        //   child: Image.asset('lib/assets/logo.png'),
        // ),
        // Container(
        //   alignment: Alignment.centerRight,
        //   margin: EdgeInsets.only(top: 1.h, left: 5.w, right: 5.w),
        //   height: 5.h,
        //   width: 20.w,
        //   child: Text(
        //     'ژمارەی مۆبایل: ٠٧٧٠١٢٣٤٥٦٧',
        //     style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        //     textAlign: TextAlign.center,
        //   ),
        // ),
        // Container(
        //   alignment: Alignment.centerRight,
        //   margin: EdgeInsets.only(top: 1.h, left: 5.w, right: 5.w),
        //   height: 5.h,
        //   width: 20.w,
        //   child: Text(
        //     'ناونیشان: سلێمانی پردی نزیک پردی کۆبانێ',
        //     style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        //     textAlign: TextAlign.center,
        //   ),
        // ),
        if (checkin)
          Container(
            width: 100.w,
            margin: EdgeInsets.only(
              top: 3.h,
            ),
            padding: EdgeInsets.all(2.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                SizedBox(
                  height: 4.h,
                  child: Text(
                    "$name : بەکارهێنەر",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(
                  height: 4.h,
                  child: Text(
                    "$email : ئیمەیل",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('شوێن'),
                            content: Text("دڵنییایت لە بینینی شوێن"),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context);
                                  },
                                  child: const Text('نەخێر')),
                              TextButton(
                                  onPressed: () async {
                                    if (!await launchUrl(Uri.parse(
                                        'https://www.google.com/maps/search/?api=1&query=$worklatitude,$worklongtitude'))) {
                                      throw Exception('Could not launch ');
                                    }
                                  },
                                  child: const Text('بەڵێ')),
                            ],
                          );
                        });
                  },
                  child: SizedBox(
                    height: 4.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          "$worklatitude-$worklongtitude",
                          style: const TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.blue),
                        ),
                        Text(
                          " : شوێن",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
                Text(
                  checkin
                      ? 'تۆ لە ئێستادا لەکاردایت'
                      : 'تۆ لە ئێستادا لەکاردا نیت تکایە چوونەژوورەوە بکە',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        SizedBox(
          height: 80.h,
          width: 100.w,
          child: FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('company')
                  .doc('department')
                  .collection('department')
                  .get(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                    itemCount: snapshot.data?.docs.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      return ExpansionTile(
                        leading: Icon(Icons.add_box_outlined,
                            color: Colors.red, size: 20.sp),
                        title: Text(snapshot.data?.docs[index]['name'] ?? ''),
                        children: [
                          SizedBox(
                            height: (double.parse((snapshot
                                                .data
                                                ?.docs[index]['departments']
                                                .length ??
                                            0)
                                        .toString()) *
                                    5)
                                .h,
                            child: ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: snapshot.data
                                        ?.docs[index]['departments'].length ??
                                    0,
                                itemBuilder:
                                    (BuildContext context, int index2) {
                                  return Container(
                                    margin: EdgeInsets.only(
                                        left: 10.w, bottom: 1.h),
                                    child: Row(
                                      children: [
                                        Icon(Icons.add_box_outlined,
                                            color: Colors.red, size: 16.sp),
                                        Text(snapshot.data?.docs[index]
                                                ['departments'][index2] ??
                                            ''),
                                      ],
                                    ),
                                  );
                                }),
                          ),
                        ],
                      );
                    });
              }),
        ),
      ],
    );
  }
}
