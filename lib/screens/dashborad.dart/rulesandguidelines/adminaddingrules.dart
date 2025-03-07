import 'dart:io';

import 'package:british_body_admin/material/materials.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:path/path.dart' as paths;
import 'package:audio_session/audio_session.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:path/path.dart' as paths;
// import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

class Adminaddinrules extends StatefulWidget {
  final DocumentReference<Map<String, dynamic>> department;
  final String email;
  const Adminaddinrules(
      {super.key, required this.department, required this.email});

  @override
  State<Adminaddinrules> createState() => _AdminaddinrulesState();
}

typedef _Fn = void Function();

class _AdminaddinrulesState extends State<Adminaddinrules> {
  TextEditingController ruletitlecontroller = TextEditingController();
  TextEditingController rulecontentcontroller = TextEditingController();
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

  Codec _codec = Codec.aacMP4;
  String _mPath = 'sound.mp4';
  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;
  TextEditingController notecontroller = TextEditingController();
  TextEditingController manpowercontroller = TextEditingController();
  DateTime? start;
  DateTime? end;

  @override
  void initState() {
    _mPlayer!.openPlayer().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });

    openTheRecorder().then((value) {
      setState(() {
        _mRecorderIsInited = true;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _mPlayer!.closePlayer();
    _mPlayer = null;

    _mRecorder!.closeRecorder();
    _mRecorder = null;
    super.dispose();
  }

  Future<void> openTheRecorder() async {
    await Permission.microphone.request();

    await _mRecorder!.openRecorder();
    if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
      _codec = Codec.opusWebM;
      _mPath = 'tau_file.webm';
      if (!await _mRecorder!.isEncoderSupported(_codec) && kIsWeb) {
        _mRecorderIsInited = true;
        return;
      }
    }

    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
      avAudioSessionCategoryOptions:
          AVAudioSessionCategoryOptions.defaultToSpeaker,
    ));
  }

  // ----------------------  Here is the code for recording and playback -------

  void record() {
    _mRecorder!
        .startRecorder(
      toFile: _mPath,
      codec: _codec,
      audioSource: AudioSource.defaultSource,
    )
        .then((value) {
      setState(() {});
    });
  }

  void stopRecorder() async {
    await _mRecorder!.stopRecorder().then((value) {
      setState(() {
        //var url = value;
        _mplaybackReady = true;
      });
    });
  }

  void play() {
    assert(_mPlayerIsInited &&
        _mplaybackReady &&
        _mRecorder!.isStopped &&
        _mPlayer!.isStopped);
    _mPlayer!
        .startPlayer(
            fromURI: _mPath,
            //codec: kIsWeb ? Codec.opusWebM : Codec.aacADTS,
            whenFinished: () {
              setState(() {});
            })
        .then((value) {
      setState(() {});
    });
  }

  void stopPlayer() {
    _mPlayer!.stopPlayer().then((value) {
      setState(() {});
    });
  }

// ----------------------------- UI --------------------------------------------

  _Fn? getRecorderFn() {
    if (!_mRecorderIsInited || !_mPlayer!.isStopped) {
      return null;
    }
    return _mRecorder!.isStopped ? record : stopRecorder;
  }

  _Fn? getPlaybackFn() {
    if (!_mPlayerIsInited || !_mplaybackReady || !_mRecorder!.isStopped) {
      return null;
    }
    return _mPlayer!.isStopped ? play : stopPlayer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('زیادکردنی یاساکان'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Container(
            alignment: Alignment.topRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
            child: Text(':ناوی یاسا',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.black,
                )),
          ),
          Container(
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
            height: 14.h,
            child: Material1.textfield(
              hint: 'ناوی یاسا',
              textColor: Material1.primaryColor,
              controller: ruletitlecontroller,
              fontsize: 16.sp,
            ),
          ),
          Container(
            alignment: Alignment.topRight,
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
            child: Text(':یاسا',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: Colors.black,
                )),
          ),
          Container(
            margin: EdgeInsets.only(left: 5.w, right: 5.w, top: 2.h),
            height: 30.h,
            child: Material1.textfield(
              hint: 'یاسا',
              textColor: Material1.primaryColor,
              maxLines: 30,
              controller: rulecontentcontroller,
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
            margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
            padding:
                EdgeInsets.only(top: 1.h, bottom: 1.h, left: 5.w, right: 5.w),
            decoration: BoxDecoration(
                color: Material1.primaryColor,
                borderRadius: BorderRadius.circular(15)),
            child: Row(children: [
              ElevatedButton(
                onPressed: getRecorderFn(),
                //color: Colors.white,
                //disabledColor: Colors.grey,
                child: Text(_mRecorder!.isRecording ? 'Stop' : 'Record'),
              ),
              const SizedBox(
                width: 20,
              ),
              Text(
                _mRecorder!.isRecording
                    ? 'Recording in progress'
                    : 'Recorder is stopped',
                style: const TextStyle(color: Colors.white),
              ),
            ]),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(5.w, 1.h, 5.w, 1.h),
            padding:
                EdgeInsets.only(top: 1.h, bottom: 1.h, left: 5.w, right: 5.w),
            decoration: BoxDecoration(
                color: Material1.primaryColor,
                borderRadius: BorderRadius.circular(15)),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: getPlaybackFn(),
                    //color: Colors.white,
                    //disabledColor: Colors.grey,
                    child: Text(_mPlayer!.isPlaying ? 'Stop' : 'Play'),
                  ),
                  Text(
                    _mPlayer!.isPlaying
                        ? 'Playback in progress'
                        : 'Player is stopped',
                    style: const TextStyle(color: Colors.white),
                  ),
                  IconButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text('Delete'),
                              content: Text(
                                  'Are you sure you want to delete this audio?'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancel',
                                      style: TextStyle(color: Colors.black)),
                                ),
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      _mplaybackReady = false;
                                    });
                                    Navigator.of(context).pop();
                                  },
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                        setState(() {
                          _mplaybackReady = false;
                          _mRecorder!.deleteRecord(fileName: _mPath);
                        });
                      },
                      icon: const Icon(
                        Icons.delete,
                        color: Colors.white,
                      ))
                ]),
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
                  label: 'زیادکردنی یاسا',
                  buttoncolor: Material1.primaryColor,
                  textcolor: Colors.white,
                  function: () async {
                    if (ruletitlecontroller.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('تکایە ناوی یاسا بنووسە بنووسە')));
                      return;
                    }
                    if (rulecontentcontroller.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('تکایە ناوەڕۆکی یاسا بنووسە بنووسە')));
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
                    // 
                    // String path =
                    //     await _mRecorder!.getRecordURL(path: _mPath) ?? '';
                    // String audiourl = '';
                    // if (_mplaybackReady) {
                    //   File file = File(path);

                    //   String imageUrl = file.path;

                    //   String extension = paths.extension(imageUrl);
                    //   // Upload the file to Firebase Storage
                    //   firebase_storage.Reference ref = firebase_storage
                    //       .FirebaseStorage.instance
                    //       .ref()
                    //       .child('request')
                    //       .child('audio')
                    //       .child(
                    //           '${ruletitlecontroller.text}/${DateTime.now().year}/${DateTime.now().month}/audio$extension');
                    //   firebase_storage.UploadTask uploadTask =
                    //       ref.putFile(file);

                    //   // Get the download URL
                    //   firebase_storage.TaskSnapshot taskSnapshot =
                    //       await uploadTask;
                    //   audiourl = await taskSnapshot.ref.getDownloadURL();
                    // }

                    widget.department
                        .collection('rules')
                        .doc(ruletitlecontroller.text)
                        .set({
                      'title': ruletitlecontroller.text,
                      'content': rulecontentcontroller.text,
                      // 'images': imagesurl,
                      // 'files': filesurl,
                      'addedby': widget.email,
                      'date': DateTime.now(),
                    }).then((value) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('بە سەرکەوتویی یاساکە دانرا')));
                      Navigator.pop(context);
                    });
                  })),
          SizedBox(
            height: 10.h,
          ),
        ],
      ),
    );
  }
}
