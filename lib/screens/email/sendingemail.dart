import 'dart:developer';
import 'dart:io';

import 'package:british_body_admin/material/materials.dart';
import 'package:british_body_admin/sendingnotification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as paths;
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

class Sendingemail extends StatefulWidget {
  final String email;
  final List<String> emailList;
  final List<String> ccList;
  final String subject;
  final String content;
  final String from;

  const Sendingemail({
    super.key,
    required this.email,
    required this.emailList,
    required this.ccList,
    required this.subject,
    required this.content,
    required this.from,
  });

  @override
  State<Sendingemail> createState() => _SendingemailState();
}

class _SendingemailState extends State<Sendingemail> {
  List<String> emailList = [];
  List<String> ccList = [];
  List<String> name = [];
  List<File> images = [];
  List<File> files = [];

  TextEditingController emailController = TextEditingController();
  TextEditingController ccController = TextEditingController();
  TextEditingController subjectcontroller = TextEditingController();
  TextEditingController contentcontroller = TextEditingController();

  bool isSending = false;

  @override
  void initState() {
    super.initState();

    // Fill initial values
    emailController.text = widget.emailList.join(', ');
    ccController.text = widget.ccList.join(', ');
    subjectcontroller.text = widget.subject;

    if (widget.content.isNotEmpty) {
      contentcontroller.text =
          "\n\n\n\n------------------------------------------------------------\n${widget.from}\n\n\n${widget.content}";
    }

    // Parse valid emails
    emailList = widget.emailList.map((e) => e.trim()).where((e) => _isValidEmail(e)).toList();
    ccList = widget.ccList.map((e) => e.trim()).where((e) => _isValidEmail(e)).toList();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source, imageQuality: 85);
      if (image != null) {
        setState(() {
          images.add(File(image.path));
        });
      }
    } on PlatformException catch (e) {
      log('Failed to pick image: $e');
    }
  }

  Future<void> pickFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);
    if (result != null) {
      setState(() {
        files = result.paths.map((path) => File(path!)).toList();
      });
    }
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
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
        children: [
          // TO Field
          const Align(alignment: Alignment.topRight, child: Text(':ناردنی ئیمەیل بۆ', style: TextStyle(fontSize: 18))),
          SizedBox(height: 1.h),
          Material1.textfield(
            textColor: Colors.black,
            hint: 'TO',
            controller: emailController,
            maxLines: 4,
            onchange: (input) {
              final inputs = input.split(RegExp(r'[,;\s\n]+'));
              emailList = inputs.map((e) => e.trim()).where(_isValidEmail).toList();
              log('TO List: $emailList');
              setState(() {});
            },
          ),

          SizedBox(height: 2.h),

          // CC Field
          const Align(alignment: Alignment.topRight, child: Text(':ئەو کەسانەی ئاگادار دەکرێنەوە', style: TextStyle(fontSize: 18))),
          SizedBox(height: 1.h),
          Material1.textfield(
            textColor: Colors.black,
            hint: 'CC',
            controller: ccController,
            maxLines: 4,
            onchange: (input) {
              final inputs = input.split(RegExp(r'[,;\s\n]+'));
              ccList = inputs.map((e) => e.trim()).where(_isValidEmail).toList();
              log('CC List: $ccList');
              setState(() {});
            },
          ),

          SizedBox(height: 2.h),

          // Show Names Button
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 8.h,
                  child: ListView.builder(
                    itemCount: name.length,
                    itemBuilder: (context, i) => Text('${i + 1}. ${name[i]}'),
                  ),
                ),
              ),
              SizedBox(
                width: 45.w,
                child: Material1.button(
                  label: 'دڵنیابوون لە ناوەکان',
                  buttoncolor: Material1.primaryColor,
                  textcolor: Colors.white,
                  function: () async {
                    name.clear();
                    final allEmails = [...emailList, ...ccList];
                    for (String email in allEmails) {
                      final doc = await FirebaseFirestore.instance.collection('user').doc(email).get();
                      if (doc.exists && doc.data()?['name'] != null) {
                        name.add(doc.data()!['name']);
                      } else {
                        name.add(email.split('@').first);
                      }
                    }
                    setState(() {});
                  },
                ),
              ),
            ],
          ),

          SizedBox(height: 2.h),

          // Subject
          const Align(alignment: Alignment.topRight, child: Text(':سەری بابەت', style: TextStyle(fontSize: 18))),
          SizedBox(height: 1.h),
          Material1.textfield(textColor: Colors.black,hint: 'سەری بابەت', controller: subjectcontroller),

          SizedBox(height: 2.h),

          // Content
          const Align(alignment: Alignment.topRight, child: Text(':ناوەڕۆک', style: TextStyle(fontSize: 18))),
          SizedBox(height: 1.h),
          Material1.textfield(textColor: Colors.black,hint: 'ناوەڕۆک', controller: contentcontroller, maxLines: 15),

          SizedBox(height: 3.h),

          // Images Preview
          images.isEmpty
              ?  Icon(Icons.image, size: 100, color: Material1.primaryColor)
              : SizedBox(
                  height: 30.h,
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: images.length,
                    itemBuilder: (context, i) => Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            image: DecorationImage(image: FileImage(images[i]), fit: BoxFit.cover),
                          ),
                        ),
                        Positioned(
                          top: 5,
                          right: 5,
                          child: GestureDetector(
                            onTap: () => setState(() => images.removeAt(i)),
                            child: const Icon(Icons.delete, color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Material1.button(buttoncolor: Material1.primaryColor, textcolor: Colors.white, label: 'وێنە لە گالەری', function: () => pickImage(ImageSource.gallery)),
              Material1.button(buttoncolor: Material1.primaryColor, textcolor: Colors.white, label: 'وێنە لە کامێرا', function: () => pickImage(ImageSource.camera)),
            ],
          ),

          SizedBox(height: 3.h),

          // Files Preview
          files.isEmpty
              ?  Icon(Icons.attach_file, size: 100, color: Material1.primaryColor)
              : SizedBox(
                  height: 20.h,
                  child: ListView.builder(
                    itemCount: files.length,
                    itemBuilder: (context, i) => ListTile(
                      title: Text(paths.basename(files[i].path)),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => setState(() => files.removeAt(i)),
                      ),
                    ),
                  ),
                ),

          Material1.button(
            label: 'هەڵبژاردنی فایل',
            buttoncolor: Material1.primaryColor,
            textcolor: Colors.white,
            function: pickFiles,
          ),

          SizedBox(height: 4.h),

          // Send Button
          isSending
              ?  Center(child: CircularProgressIndicator(color: Material1.primaryColor))
              : Material1.button(
                  label: 'ناردن',
                  buttoncolor: Material1.primaryColor,
                  textcolor: Colors.white,
                  function: () async {
                    if (emailList.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تکایە ئیمەیلێک بۆ TO بنووسە')));
                      return;
                    }
                    if (subjectcontroller.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('سەری بابەت پێویستە')));
                      return;
                    }
                    if (contentcontroller.text.trim().isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ناوەڕۆک پێویستە')));
                      return;
                    }

                    setState(() => isSending = true);

                    try {
                      // 1. Get or Create Counter
                      int counter = 1;
                      final counterRef = FirebaseFirestore.instance.collection('email').doc('counter');
                      final counterSnap = await counterRef.get();

                      if (counterSnap.exists) {
                        counter = (counterSnap.data()?['counter'] ?? 0) + 1;
                      }
                      await counterRef.set({'counter': counter});

                      // 2. Generate searchable subjects
                      List<String> subjects = [];
                      final words = subjectcontroller.text.split(RegExp(r'\s+'));
                      for (String word in words) {
                        String temp = '';
                        for (var char in word.characters) {
                          temp += char;
                          subjects.add(temp);
                        }
                      }
                      // Add counter digits
                      for (var char in counter.toString().characters) {
                        subjects.add(char);
                      }

                      // 3. Upload attachments (optional later)
                      List<String> imageUrls = [];
                      List<String> fileUrls = [];
                      // TODO: Implement upload if needed

                      // 4. Save Email
                      final emailDocId = '$counter-${subjectcontroller.text.trim()}';
                      await FirebaseFirestore.instance.collection('email').doc(emailDocId).set({
                        'from': widget.email,
                        'to': emailList,
                        'cc': ccList,
                        'id': counter,
                        'subject': subjectcontroller.text.trim(),
                        'content': contentcontroller.text,
                        'subjects': subjects,
                        'images': imageUrls,
                        'attachments': fileUrls,
                        'readlist': [],
                        'date': FieldValue.serverTimestamp(),
                      });

                      // 5. Send Notifications
                      final allRecipients = [...emailList, ...ccList];
                      for (String recipient in allRecipients) {
                        final userSnap = await FirebaseFirestore.instance.collection('user').doc(recipient).get();
                        final token = userSnap.data()?['token']?.toString();
                        if (token != null && token.isNotEmpty && token != 'a') {
                          sendingnotification('ئیمەیلی نوێ', subjectcontroller.text, token, 'default1');
                        }
                      }

                      // Success
                      if (mounted) {
                        Navigator.popUntil(context, (route) => route.isFirst);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('ئیمەیل بەسەرکەوتویی نێردرا • ژمارە: $counter')),
                        );
                      }
                    } catch (e) {
                      log('Error sending email: $e');
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('هەڵەیەک ڕوویدا، تکایە دووبارە هەوڵ بدەرەوە')),
                        );
                      }
                    } finally {
                      if (mounted) setState(() => isSending = false);
                    }
                  },
                ),

          SizedBox(height: 10.h),
        ],
      ),
    );
  }
}