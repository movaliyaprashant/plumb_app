import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:plumbata/providers/user.dart';
import 'package:plumbata/ui/home/contractor/voice_message.dart';
import 'package:plumbata/utils/colors.dart';
import 'package:plumbata/utils/style.dart';
import 'package:provider/provider.dart';
import 'package:responsive_framework/responsive_framework.dart';
import 'package:flutter_sound_platform_interface/flutter_sound_recorder_platform_interface.dart';


class AudioRecorder extends StatefulWidget {
  const AudioRecorder({Key? key, required this.onDone}) : super(key: key);

  final Function(File file) onDone;
  @override
  State<AudioRecorder> createState() => _AudioRecorderState();
}

class _AudioRecorderState extends State<AudioRecorder> {
  final recorder = FlutterSoundRecorder();

  IconData playIcon = Icons.mic_none;
  bool isRecording = false;
  String recordTime = "00:00";
  bool isRecorderReady = false;
  late Directory tempDir;
  late String outputFile;
  final Codec _codec = Codec.aacMP4;
  bool isInit = true;
  bool didRecord = false;

  FlutterSoundPlayer audioPlayer = FlutterSoundPlayer();

  bool _mPlayerIsInited = false;

  bool isPlayingAudio = false;
  Duration audioDuration = Duration.zero;
  Duration position = Duration.zero;

  File? audioFile;

  @override
  Widget build(BuildContext context) {
    return isInit
        ? const Center(
      child: CircularProgressIndicator.adaptive(),
    )
        : SizedBox(
      height: 300,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          !isPlayingAudio
              ? Center(
            child: CircleAvatar(
              backgroundColor: AppColors.lightPrimaryColor,
              radius: 35,
              child: IconButton(
                icon: Icon(
                  isRecording ? Icons.mic : Icons.mic_none,
                  color: Colors.white,
                ),
                iconSize: 50,
                onPressed: () async {
                  if (isRecording) {
                    isRecording = false;
                    await stopRecording();
                  } else {
                    isRecording = true;
                    await startRecording();
                    didRecord = true;
                  }
                  setState(() {});
                },
              ),
            ),
          )
              : const SizedBox(),
          const SizedBox(
            height: 16,
          ),
          didRecord && !isRecording
              ? const SizedBox()
              : StreamBuilder<RecordingDisposition>(
              stream: recorder.onProgress,
              builder: (context, snap) {
                final duration = snap.hasData
                    ? snap.data!.duration
                    : Duration.zero;

                String twoDigits(int n) => n.toString().padLeft(2);
                final twoDigitsMinutes =
                twoDigits(duration.inMinutes.remainder(60));
                final twoDigitsSeconds =
                twoDigits(duration.inSeconds.remainder(60));

                return Center(
                  child: Text(
                    "$twoDigitsMinutes:$twoDigitsSeconds s",
                    style: Style()
                        .appTextTheme(context)
                        .bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodyText1?.color),
                  ),
                );
              }),
          !isRecording
              ? !didRecord
              ? const SizedBox()
              : Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SizedBox(
                    width: !ResponsiveBreakpoints.of(context).isPhone ?
                    MediaQuery.of(context).size.width * 0.6:
                    MediaQuery.of(context).size.width,
                    child: Center(
                      child: VoiceMessage(
                        widthRatio: 200,
                        audioFile: Future.value(audioFile),
                        me: true,
                        meBgColor: AppColors.lightPrimaryColor,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          )
          // : CircleAvatar(
          //     radius: 35,
          //     child: IconButton(
          //       icon: Icon(isPlayingAudio
          //           ? Icons.pause
          //           : Icons.play_arrow),
          //       iconSize: 50,
          //       onPressed: () async {
          //         if (isPlayingAudio) {
          //           await audioPlayer.pausePlayer();
          //           isPlayingAudio = false;
          //         } else {
          //           debugPrint('Playing ${audioFile?.uri.path}');
          //           isPlayingAudio = true;
          //           play();
          //         }
          //         setState(() {});
          //       },
          //     ),
          //   )
              : const SizedBox(),
          didRecord && !isRecording && !isPlayingAudio
              ? Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);

                    debugPrint("widget.onDone $outputFile");
                    File output = File(outputFile);
                    widget.onDone(output);
                  },
                  child: const Icon(
                    Icons.send,
                    size: 30,
                  )),
            ],
          )
              : const SizedBox(),
        ],
      ),
    );
  }

  stopRecording() async {
    if (!isRecorderReady) return;

    final path = await recorder.stopRecorder();
    audioFile = File(path!);

    debugPrint('Recorded Audio $audioFile');
  }

  startRecording() async {
    if (!isRecorderReady) return;
    recorder.startRecorder(
        toFile: outputFile, codec: _codec, audioSource: AudioSource.microphone);
  }

  @override
  initState() {
    super.initState();
    init();
  }

  init() async {
    try {
      await initPlayer();
      await initRecorder();
      setState(() {
        isInit = false;
      });
      //widget.setModalState((){});
      audioPlayer.setSubscriptionDuration(const Duration(milliseconds: 100));

      audioPlayer.onProgress?.listen((PlaybackDisposition newPos) {
        setState(() {
          position = newPos.position;
          audioDuration = newPos.duration;
          debugPrint("Playing at pos $position");
        });
      });

      isRecording = true;
      await startRecording();
      didRecord = true;

    } catch (e, s) {
      debugPrint("Error recorder $e $s");
    }

  }

  initPlayer() async {
    audioPlayer.openPlayer().then((value) {
      setState(() {
        _mPlayerIsInited = true;
      });
    });
  }

  initRecorder() async {
    var repo = context.read<UserProvider>();

    final status = await Permission.microphone.status;
    if (status != PermissionStatus.granted) {
      PermissionStatus result = await Permission.microphone.request();
      debugPrint("Permission result $result ");
      if (result != PermissionStatus.granted) {
        throw "Microphone permission is not granted";
      }
    }
    String name = repo.recordFileName ?? "sgRecord.m4a";
    tempDir = await getTemporaryDirectory();

    outputFile = '${tempDir.path}/$name';

    await recorder.openRecorder();
    isRecorderReady = true;

    recorder.setSubscriptionDuration(const Duration(milliseconds: 500));
  }

  void play() {
    assert(_mPlayerIsInited &&
        !isRecording &&
        recorder!.isStopped &&
        audioPlayer!.isStopped);
    audioPlayer!
        .startPlayer(
        fromURI: outputFile,
        codec: Codec.aacMP4,
        whenFinished: () {
          setState(() {
            isPlayingAudio = false;
          });
        })
        .then((value) {
      setState(() {});
    });
  }

  @override
  Future<void> dispose() async {
    super.dispose();

    await stopRecording();
    await audioPlayer.closePlayer();

    recorder.closeRecorder();
  }
}
