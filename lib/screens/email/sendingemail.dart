import 'dart:developer';
import 'dart:io';

import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/sendingnotification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
// import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart' as paths;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class Sendingemail extends StatefulWidget {
  final String email;
  final List<String> emailList;
  final List<String> ccList;
  final String subject;
  final String content;
  final String from;
  const Sendingemail(
      {super.key,
      required this.email,
      required this.emailList,
      required this.ccList,
      required this.subject,
      required this.content,
      required this.from});

  @override
  State<Sendingemail> createState() => _SendingemailState();
}

class _SendingemailState extends State<Sendingemail> {
  List<String> emailList = [];
  TextEditingController emailController = TextEditingController();
  List<String> ccList = [];
  TextEditingController ccController = TextEditingController();
  TextEditingController subjectcontroller = TextEditingController();
  TextEditingController contentcontroller = TextEditingController();
  Future pickimage(source) async {
    try {
      ImagePicker imagePicker = ImagePicker();
      XFile? cimage = await imagePicker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (cimage == null) return;

      final imageTemporary = File(cimage.path);
      setState(() {
        images.add(imageTemporary);
      });
      // ignore: empty_catches
    } on PlatformException {}
  }

  List<String> name = [];

  List<File> images = [];

  UploadTask? task;

  List<File> files = [];

  @override
  void initState() {
    emailController.text = widget.emailList.join(' ');
    ccController.text = widget.ccList.join(' ');
    for (var email in widget.emailList) {
      emailList.add(email.trim());
    }
    for (var email in widget.ccList) {
      ccList.add(email.trim());
    }
    subjectcontroller.text = widget.subject;
    if (widget.content != '') {
      contentcontroller.text =
          "\n\n\n\n ------------------------------------------------------------\n ${widget.from}\n\n\n ${widget.content}";
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ناردنی ئیمەیل'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Container(
            alignment: Alignment.topRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
            child: Text(':ناردنی ئیمەیل بۆ',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.black,
                )),
          ),
          Container(
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
            height: 10.h,
            child: Material1.textfield(
              hint: 'TO',
              textColor: Material1.primaryColor,
              controller: emailController,
              maxLines: 3,
              fontsize: 16.sp,
              onchange: (input) {
                List<String> inputs = input.split(RegExp('[,; \n]'));
                emailList.clear(); // Clear the list before updating
                for (var email in inputs) {
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (emailRegex.hasMatch(email.trim())) {
                    emailList.add(email.trim());
                  }
                }
                log(emailList.toString());
                setState(() {});
              },
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
            child: Text(':ئەو کەسانەوی کە ئاگادارن لە ئمەیڵەکە',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.black,
                )),
          ),
          Container(
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
            height: 14.h,
            child: Material1.textfield(
              hint: 'cc',
              textColor: Material1.primaryColor,
              controller: ccController,
              maxLines: 5,
              fontsize: 16.sp,
              onchange: (input) {
                List<String> inputs = input.split(RegExp('[,; \n]'));
                ccList.clear(); // Clear the list before updating
                for (var email in inputs) {
                  final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                  if (emailRegex.hasMatch(email.trim())) {
                    ccList.add(email.trim());
                  }
                }
                log(ccList.toString());
                setState(() {});
              },
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
            height: 10.h,
            child: Row(
              children: [
                SizedBox(
                  width: 30.w,
                  height: 8.h,
                  child: ListView.builder(
                      itemCount: name.length,
                      itemBuilder: (context, index) {
                        return Text("${index + 1}.${name[index]}");
                      }),
                ),
                SizedBox(
                  width: 50.w,
                  height: 6.h,
                  child: Material1.button(
                      label: 'دڵنیابوون لەناوەکان',
                      buttoncolor: Material1.primaryColor,
                      textcolor: Colors.white,
                      function: () {
                        name.clear();
                        for (var i = 0; i < emailList.length; i++) {
                          FirebaseFirestore.instance
                              .collection('user')
                              .doc(emailList[i])
                              .get()
                              .then((value) {
                            if (value.data() != null) {
                              setState(() {
                                name.add(value.data()?['name']);
                              });
                            }
                          });
                        }
                        for (var i = 0; i < ccList.length; i++) {
                          FirebaseFirestore.instance
                              .collection('user')
                              .doc(ccList[i])
                              .get()
                              .then((value) {
                            if (value.data() != null) {
                              setState(() {
                                name.add(value.data()?['name']);
                              });
                            }
                          });
                        }
                      }),
                ),
              ],
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
            child: Text(':سەری بابەت',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.black,
                )),
          ),
          Container(
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
            height: 14.h,
            child: Material1.textfield(
              hint: 'سەری بابەت',
              textColor: Material1.primaryColor,
              controller: subjectcontroller,
              fontsize: 16.sp,
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
            child: Text(':بابەت',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.black,
                )),
          ),
          Container(
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
            height: 30.h,
            child: Material1.textfield(
              hint: 'بابەت',
              textColor: Material1.primaryColor,
              maxLines: 30,
              controller: contentcontroller,
              fontsize: 16.sp,
            ),
          ),
          images.isEmpty
              ? Container(
                  margin: EdgeInsets.all(5.w),
                  width: 100.w,
                  height: 30.h,
                  child: Icon(Icons.image,
                      size: 20.h, color: Material1.primaryColor),
                )
              : Container(
                  margin: EdgeInsets.all(5.w),
                  width: 100.w,
                  height: 30.h,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemCount: images.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              image: DecorationImage(
                                image: FileImage(images[index]),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('سڕینەوە'),
                                    content:
                                        Text('دڵنیاییت لە سڕینەوەی وێنەکەت؟'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('نەخێر',
                                            style:
                                                TextStyle(color: Colors.black)),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            images.removeAt(index);
                                          });
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          'بەڵێ',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                                alignment: Alignment.topRight,
                                child: Icon(Icons.delete,
                                    size: 20.sp, color: Colors.white)),
                          ),
                        ],
                      );
                    },
                  ),
                ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                height: 6.h,
                width: 40.w,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  color: Material1.primaryColor,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: Material1.button(
                  fontsize: 16.sp,
                  label: 'هەڵبژاردنی وێنە',
                  buttoncolor: Material1.primaryColor,
                  function: () {
                    pickimage(ImageSource.gallery);
                  },
                  textcolor: Colors.white,
                ),
              ),
              Container(
                height: 6.h,
                width: 40.w,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(20)),
                  color: Material1.primaryColor,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 10,
                      spreadRadius: -5,
                    ),
                  ],
                ),
                child: Material1.button(
                  fontsize: 16.sp,
                  label: 'گرتنی وێنە',
                  buttoncolor: Material1.primaryColor,
                  function: () {
                    pickimage(ImageSource.camera);
                  },
                  textcolor: Colors.white,
                ),
              ),
            ],
          ),
          files.isEmpty
              ? Container(
                  margin: EdgeInsets.all(5.w),
                  width: 100.w,
                  height: 30.h,
                  child: Icon(Icons.attach_file,
                      size: 20.h, color: Material1.primaryColor),
                )
              : Container(
                  margin: EdgeInsets.all(5.w),
                  width: 100.w,
                  height: 30.h,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10.0,
                      mainAxisSpacing: 10.0,
                    ),
                    itemCount: files.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Stack(
                        children: [
                          Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Center(
                                  child:
                                      Text(paths.basename(files[index].path)))),
                          GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('سڕینەوە'),
                                    content: Text('دڵنیاییت لە سڕینەوەی فایل؟'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text('نەخێر',
                                            style:
                                                TextStyle(color: Colors.black)),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          setState(() {
                                            images.removeAt(index);
                                          });
                                          Navigator.of(context).pop();
                                        },
                                        child: Text(
                                          'بەڵێ',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                            child: Container(
                                alignment: Alignment.topRight,
                                child: Icon(Icons.delete,
                                    size: 20.sp, color: Colors.red)),
                          ),
                        ],
                      );
                    },
                  ),
                ),
          Container(
            height: 8.h,
            width: 80.w,
            margin: EdgeInsets.only(top: 5.h, left: 10.w, right: 10.w),
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.all(Radius.circular(15)),
              color: Material1.primaryColor,
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  spreadRadius: -5,
                ),
              ],
            ),
            child: Material1.button(
                label: 'هەڵبژاردنی فایل',
                buttoncolor: Material1.primaryColor,
                textcolor: Colors.white,
                function: () async {
                  FilePickerResult? result =
                      await FilePicker.platform.pickFiles(allowMultiple: true);
                  if (result != null) {
                    files = result.paths.map((path) => File(path!)).toList();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('هیچ فایلێک هەڵنەبژێردرا')));
                  }
                }),
          ),
          Container(
              height: 8.h,
              width: 80.w,
              margin: EdgeInsets.only(top: 5.h, left: 10.w, right: 10.w),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                color: Material1.primaryColor,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 10,
                    spreadRadius: -5,
                  ),
                ],
              ),
              child: Material1.button(
                  label: 'ناردن',
                  buttoncolor: Material1.primaryColor,
                  textcolor: Colors.white,
                  function: () async {
                    if (emailList.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('تکایە ئیمەیلێک هەڵبژێرە')));
                      return;
                    }
                    if (subjectcontroller.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('تکایە سەردەری بابەت بنووسە')));
                      return;
                    }
                    if (contentcontroller.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('تکایە ناوەڕۆکی بابەت بنووسە')));
                      return;
                    }
                    //TODO fix uploading attachments

                    // DateTime now = DateTime.now();
                    // List<String> imagesurl = [];
                    // List<String> filesurl = [];
                    // if (images.isNotEmpty) {
                    //   for (int i = 0; i < images.length; i++) {
                    //     File file = images[i];
                    //     String imageUrl = file.path;

                    //     String extension = paths.extension(imageUrl);

                    //     firebase_storage.Reference ref = firebase_storage
                    //         .FirebaseStorage.instance
                    //         .ref()
                    //         .child('email-attachments')
                    //         .child('${now.year}-${now.month}')
                    //         .child(
                    //             '${subjectcontroller.text}/image$i$extension');
                    //     firebase_storage.UploadTask uploadTask =
                    //         ref.putFile(file);
                    //     firebase_storage.TaskSnapshot taskSnapshot =
                    //         await uploadTask;
                    //     imagesurl.add(await taskSnapshot.ref.getDownloadURL());
                    //   }
                    //   for (int i = 0; i < files.length; i++) {
                    //     File file = files[i];
                    //     String fileUrl = file.path;

                    //     String extension = paths.extension(fileUrl);

                    //     firebase_storage.Reference ref = firebase_storage
                    //         .FirebaseStorage.instance
                    //         .ref()
                    //         .child('email-attachments')
                    //         .child('${now.year}-${now.month}')
                    //         .child(
                    //             '${subjectcontroller.text}/file$i$extension');
                    //     firebase_storage.UploadTask uploadTask =
                    //         ref.putFile(file);
                    //     firebase_storage.TaskSnapshot taskSnapshot =
                    //         await uploadTask;
                    //     filesurl.add(await taskSnapshot.ref.getDownloadURL());
                    //   }
                    // }
                    List<String> subjects = [];
                    String subject = subjectcontroller.text;
                    String temp = '';
                    int counter = 0;
                    for (var i = 0; i < subject.length; i++) {
                      temp += subject[i];
                      subjects.add(temp);
                    }
                    try {
                      FirebaseFirestore.instance
                          .collection('email')
                          .doc('counter')
                          .get()
                          .then((value) {
                        counter = value.data()!['counter'];
                        String idString = counter.toString();
                        String temp1 = '';

                        for (var i = 0; i < idString.length; i++) {
                          temp1 += idString[i];
                          subjects.add(temp1);
                        }
                      }).then((value) {
                        FirebaseFirestore.instance
                            .collection('email')
                            .doc('counter')
                            .set({
                          'counter': counter + 1,
                        });
                      }).then((value) {
                        FirebaseFirestore.instance
                            .collection('email')
                            .doc(
                                '${subjectcontroller.text}-${DateTime.now().toString()}')
                            .set({
                          'from': widget.email,
                          'to': emailList,
                          'cc': ccList,
                          'id': counter+ 1,
                          'subject': subjectcontroller.text,
                          'content': contentcontroller.text,
                          'subjects': subjects,
                          'attachments': [],
                          'images': [],
                          'readlist': [],
                          'date': DateTime.now(),
                        }).then((value) {
                          for (var i = 0; i < emailList.length; i++) {
                            FirebaseFirestore.instance
                                .collection('user')
                                .doc(emailList[i])
                                .get()
                                .then((value) {
                              sendingnotification('ئیمەڵی نوێ', widget.subject,
                                  value.data()?['token'] ?? 'a');
                            });
                          }
                          for (var i = 0; i < ccList.length; i++) {
                            FirebaseFirestore.instance
                                .collection('user')
                                .doc(ccList[i])
                                .get()
                                .then((value) {
                              sendingnotification('ئیمەڵی نوێ', widget.subject,
                                  value.data()?['token'] ?? 'a');
                            });
                          }
                          counter++;
                          FirebaseFirestore.instance
                              .collection('email')
                              .doc('counter')
                              .set({'counter': counter});
                          Navigator.popUntil(context, (route) => route.isFirst);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                                  'ئیمەیلەکەت بەسەرکەوتویی نێردرا ژمارەکەی $counter')));
                        });
                      });
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text(
                              'هەڵەیەک ڕوویدا، تکایە دووبارە هەول بەرەوە')));
                    }
                  })),
          SizedBox(
            height: 10.h,
          ),
        ],
      ),
    );
  }
}
