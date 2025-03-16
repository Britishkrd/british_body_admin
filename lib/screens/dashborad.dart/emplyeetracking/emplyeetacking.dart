import 'dart:developer';

import 'package:audio_session/audio_session.dart';
import 'package:british_body_admin/material/materials.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class Emplyeetacking extends StatefulWidget {
  final String email;
  const Emplyeetacking({super.key, required this.email});

  @override
  State<Emplyeetacking> createState() => _EmplyeetackingState();
}

typedef _Fn = void Function();

class _EmplyeetackingState extends State<Emplyeetacking> {
  Codec _codec = Codec.aacMP4;
  String _mPath = 'sound.mp4';
  FlutterSoundPlayer? _mPlayer = FlutterSoundPlayer();
  FlutterSoundRecorder? _mRecorder = FlutterSoundRecorder();
  bool _mPlayerIsInited = false;
  bool _mRecorderIsInited = false;
  bool _mplaybackReady = false;

  @override
  void initState() {
    _mPath = '${widget.email}-${DateTime.now()}.mp4';
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
        title: Text('ناردنی ڤۆیس'),
        foregroundColor: Colors.white,
        backgroundColor: Material1.primaryColor,
        centerTitle: true,
      ),
      body: Column(
        children: [
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
              child: Material1.button(
                  label: 'ناردنی قویس',
                  buttoncolor: Material1.primaryColor,
                  textcolor: Colors.white,
                  function: () async {
                    final url = Uri.parse(
                        'https://api.telegram.org/bot7729692126:AAGSO08oifYVsSOlNg9skkz-LSlpPErILec/sendDocument');
                    log(_mPath);
                    String path =
                        await _mRecorder!.getRecordURL(path: _mPath) ?? '';
                    log(path);
                    var request = http.MultipartRequest('POST', url)
                      ..fields['chat_id'] = '1132064820'
                      ..files.add(await http.MultipartFile.fromPath(
                        'document',
                        path,
                        contentType: MediaType('application', 'octet-stream'),
                      ));

                    try {
                      var response = await request.send();
                      if (response.statusCode == 200) {
                        print('File sent successfully');
                      } else {
                        print('Failed to send file: ${response.reasonPhrase}');
                      }
                    } catch (e) {
                      print('Error sending file: $e');
                    }
                  })),
        ],
      ),
    );
  }
}
