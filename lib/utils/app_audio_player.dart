import 'package:flutter/material.dart';
import 'package:plumbata/ui/home/contractor/voice_message.dart';
import 'package:plumbata/utils/colors.dart';

class AppAudioPlayer extends StatefulWidget {
  const AppAudioPlayer({Key? key, required this.link}) : super(key: key);
  final String link;

  @override
  State<AppAudioPlayer> createState() => _AppAudioPlayerState();
}

class _AppAudioPlayerState extends State<AppAudioPlayer> {
  bool _play = false;
  bool isReady = true;
  Duration? all;
  Duration? currentPos;

  @override
  Widget build(BuildContext context) {
    //inside a stateful widget
    return SizedBox(
        height: 100,
        child: isReady
            ? VoiceMessage(
          audioSrc: widget.link,
          me: true,
          meBgColor: AppColors.lightPrimaryColor,
        )
            : const Center(
          child: CircularProgressIndicator.adaptive(),
        ));
  }

  String getDurationText(Duration? duration) {
    String sDuration =
        "${duration?.inHours ?? "00"}:${duration?.inMinutes.remainder(60) ?? "00"}:${(duration?.inSeconds.remainder(60)) ?? "00"}";
    return sDuration;
  }
}
