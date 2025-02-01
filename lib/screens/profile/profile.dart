import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(
          width: 100.w,
          height: 20.h,
          child: Image.asset('lib/assets/logo.png'),
        ),
        Container(
          alignment: Alignment.centerRight,
          margin: EdgeInsets.only(top: 1.h, left: 5.w, right: 5.w),
          height: 5.h,
          width: 20.w,
          child: Text(
            'ژمارەی مۆبایل: ٠٧٧٠١٢٣٤٥٦٧',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          alignment: Alignment.centerRight,
          margin: EdgeInsets.only(top: 1.h, left: 5.w, right: 5.w),
          height: 5.h,
          width: 20.w,
          child: Text(
            'ناونیشان: سلێمانی پردی نزیک پردی کۆبانێ',
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ),
        SizedBox(
          height: 80.h,
          width: 100.w,
          child: FutureBuilder(
              future: FirebaseFirestore.instance.collection('company').get(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data?.docs.length ?? 0,
                    itemBuilder: (BuildContext context, int index) {
                      return SizedBox(
                        height: ((snapshot.data?.docs.length ?? 0) * 60).h,
                        width: 90.w,
                        child: ExpansionTile(
                          leading: Icon(Icons.add_box_outlined,
                              color: Colors.red, size: 20.sp),
                          title: Text(snapshot.data?.docs[index]['name'] ?? ''),
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  left: 10.w, bottom: 1.h, right: 10.w),
                              height:
                                  ((snapshot.data?.docs.length ?? 0) * 50).h,
                              child: FutureBuilder(
                                  future: snapshot.data?.docs[index].reference
                                      .collection(snapshot.data?.docs[index]
                                              ['name'] ??
                                          'name')
                                      .get(),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<QuerySnapshot> snapshot1) {
                                    if (snapshot1.connectionState ==
                                        ConnectionState.waiting) {
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    }
                                    return SizedBox(
                                      height:
                                          ((snapshot1.data?.docs.length ?? 0) *
                                                  40)
                                              .h,
                                      child: ListView.builder(
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          itemCount:
                                              snapshot1.data?.docs.length ?? 0,
                                          itemBuilder: (BuildContext context,
                                              int index1) {
                                            return ExpansionTile(
                                              leading: Icon(
                                                  Icons.add_box_outlined,
                                                  color: Colors.red,
                                                  size: 18.sp),
                                              title: Text(
                                                  snapshot1.data?.docs[index1]
                                                          ['location'] ??
                                                      ''),
                                              children: [
                                                SizedBox(
                                                  height: (double.parse((snapshot1
                                                                      .data
                                                                      ?.docs[
                                                                          index1]
                                                                          [
                                                                          'departments']
                                                                      .length ??
                                                                  0)
                                                              .toString()) *
                                                          5)
                                                      .h,
                                                  child: ListView.builder(
                                                      physics:
                                                          NeverScrollableScrollPhysics(),
                                                      itemCount: snapshot1
                                                              .data
                                                              ?.docs[index1][
                                                                  'departments']
                                                              .length ??
                                                          0,
                                                      itemBuilder:
                                                          (BuildContext context,
                                                              int index2) {
                                                        return Container(
                                                          margin:
                                                              EdgeInsets.only(
                                                                  left: 10.w,
                                                                  bottom: 1.h),
                                                          child: Row(
                                                            children: [
                                                              Icon(
                                                                  Icons
                                                                      .add_box_outlined,
                                                                  color: Colors
                                                                      .red,
                                                                  size: 16.sp),
                                                              Text(snapshot1.data
                                                                              ?.docs[index1]
                                                                          [
                                                                          'departments']
                                                                      [
                                                                      index2] ??
                                                                  ''),
                                                            ],
                                                          ),
                                                        );
                                                      }),
                                                ),
                                              ],
                                            );
                                          }),
                                    );
                                  }),
                            ),
                          ],
                        ),
                      );
                    });
              }),
        ),
      ],
    );
  }
}
