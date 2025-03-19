import 'dart:developer';
import 'dart:io';

import 'package:british_body_admin/material/materials.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';

class Soundpreview extends StatefulWidget {
  const Soundpreview({super.key});

  @override
  State<Soundpreview> createState() => _SoundpreviewState();
}

const List<String> list = <String>[
  'default1',
  'annoying',
  'annoying1',
  'arabic',
  'laughing',
  'longfart',
  'mild',
  'oud',
  'rooster',
  'salawat',
  'shortfart',
  'soft2',
  'softalert',
  'srusht',
  'witch',
];
String dropdownValue = 'default1';
typedef _Fn = void Function();

class _SoundpreviewState extends State<Soundpreview> {
  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;

  @override
  void initState() {
    super.initState();
    requestPermissions();
    _mPlayer!.openPlayer().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    }).then((value) {
      setState(() {});
    });
  }

  Future<void> requestPermissions() async {
    Permission.storage.request();
    if (await Permission.storage.request().isGranted) {
      log("Storage permission granted");
    } else {
      log("Storage permission denied");
    }
  }

  @override
  void dispose() {
    _mPlayer!.closePlayer();
    _mPlayer = null;

    _mRecorder!.closeRecorder();
    _mRecorder = null;
    super.dispose();
  }

  void play() async {
    log("Attempting to play: lib/assets/sounds/$dropdownValue.mp3");
    if (!_mPlayerIsInited) {
      log("Player is not initialized");
      return;
    }

    try {
      // Load the asset file
      final ByteData data =
          await rootBundle.load('lib/assets/sounds/$dropdownValue.mp3');
      final Uint8List bytes = data.buffer.asUint8List();

      // Write the file to a temporary location
      final tempDir = await getTemporaryDirectory();
      final tempFile = File('${tempDir.path}/$dropdownValue.mp3');
      await tempFile.writeAsBytes(bytes);

      // Play the file from the temporary location
      await _mPlayer!.startPlayer(
        fromURI: tempFile.path,
        whenFinished: () {
          setState(() {
            log("Playback finished");
          });
        },
      );

      // Listen to playback progress
      _mPlayer!.onProgress!.listen((event) {
        setState(() {
          // Update the UI during playback
        });
      });

      log("Playback started");
      setState(() {}); // Update the UI when playback starts
    } catch (e) {
      log("Error while starting player: $e");
    }
  }

  void stopPlayer() {
    _mPlayer!.stopPlayer().then((value) {
      setState(() {
        log("Playback stopped");
      });
    });
  }

  _Fn? getPlaybackFn() {
    return _mPlayer!.isStopped ? play : stopPlayer;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sound Preview'),
        backgroundColor: Material1.primaryColor,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: 5.h, left: 5.w, right: 5.w),
            height: 8.h,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 6.h,
                  width: 30.w,
                  child: DropdownButton<String>(
                    isExpanded: true,
                    value: dropdownValue,
                    icon: const Icon(
                      Icons.arrow_downward,
                      color: Colors.black,
                    ),
                    elevation: 16,
                    style: TextStyle(color: Material1.primaryColor),
                    underline:
                        Container(height: 2, color: Material1.primaryColor),
                    onChanged: (String? value) {
                      setState(() {
                        dropdownValue = value!;
                      });
                    },
                    items: list.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                          value: value, child: Text(value));
                    }).toList(),
                  ),
                ),
                SizedBox(
                    height: 6.h,
                    width: 30.w,
                    child: Center(child: Text('هەڵبژاردنی دەنگ'))),
              ],
            ),
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
                    onPressed: () {
                      getPlaybackFn()?.call();
                    },
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
                ]),
          ),
        ],
      ),
    );
  }
}
