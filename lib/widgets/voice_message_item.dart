// ignore_for_file: use_build_context_synchronously
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:call_app_flutter/constants.dart';
import 'package:call_app_flutter/utilities/chat_utils.dart';
import 'package:call_app_flutter/utilities/firestorer.dart';
import 'package:call_app_flutter/widgets/voice_message_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:path/path.dart' as path;
import 'package:zego_zimkit/zego_zimkit.dart';

class VoiceMessageItem extends StatefulWidget {
  const VoiceMessageItem({Key? key, required this.message}) : super(key: key);
  final ZIMKitMessage message;
  @override
  State<VoiceMessageItem> createState() => _VoiceMessageItemState();
}

class _VoiceMessageItemState extends State<VoiceMessageItem> {
  PlayerController controller = PlayerController();
  VoiceMessageInfo? voiceInfo;

  // final List<double> speeds = [0.75, 1.0, 1.25, 1.5, 1.75, 2];
  int speedIndex = 1;

  Duration maxDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    initController(widget.message.fileContent!.fileLocalPath);
  }

  @override
  void dispose() {
    voiceInfo = null;
    super.dispose();
    // controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: widget.message.isMine
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!widget.message.isMine)
            Padding(
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height * 0.075),
              child: const CircleAvatar(
                backgroundImage: NetworkImage(kDummyImage),
              ),
            ),
          Column(
            crossAxisAlignment: widget.message.isMine
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (!widget.message.isMine)
                Padding(
                  padding: const EdgeInsets.fromLTRB(25.0, 15, 15, 2),
                  child: FutureBuilder(
                    future: Firestorer.instance
                        .getUserWithId(widget.message.info.senderUserID),
                    builder: (context, snap) {
                      return Text(
                        !snap.hasData
                            ? '..'
                            : snap.data!.name.characters.first.toUpperCase() +
                                snap.data!.name.substring(1),
                        style: TextStyle(
                            color: Colors.grey.shade600, fontSize: 12),
                      );
                    },
                  ),
                ),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius:
                        ChatUtils.msgBorderRadius(widget.message.isMine)),
                margin: EdgeInsets.symmetric(
                    horizontal: widget.message.isMine ? 15 : 8),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: widget.message.isMine
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.07,
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          onPressed: () async {
                            if (controller.playerState.isPlaying) {
                              controller.pausePlayer(); // Pause audio player
                            } else {
                              await controller.startPlayer(
                                  finishMode: FinishMode.pause);
                            }
                          },
                          icon: Icon(
                            controller.playerState.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: controller.playerState.isPlaying
                                ? Colors.red
                                : Colors.blue,
                            size: 50,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FutureBuilder(
                                future: Firestorer.instance.getVoiceNoteInfo(
                                    path.basename(widget
                                        .message.fileContent!.fileLocalPath)),
                                builder: (context, snap) {
                                  if (!snap.hasData) {
                                    return const SpinKitSpinningLines(
                                      color: Colors.blue,
                                      size: 25.0,
                                    );
                                  }
                                  return AudioFileWaveforms(
                                    size: Size(
                                        MediaQuery.of(context).size.width * 0.4,
                                        50.0),
                                    playerController: controller,
                                    enableSeekGesture: true,
                                    backgroundColor: Colors.black,
                                    waveformType: WaveformType.long,
                                    waveformData: snap.data!
                                        .waveFormsList, //controller.waveformData,
                                    playerWaveStyle: const PlayerWaveStyle(
                                      fixedWaveColor: Colors.blue,
                                      liveWaveColor: Colors.red,
                                      seekLineColor: Colors.blue,
                                      spacing: 7,
                                      backgroundColor: Colors.black,
                                      waveThickness: 2,
                                      scaleFactor: 500,
                                    ),
                                  );
                                }),
                            Text(
                              formatDuration(maxDuration),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: ChatUtils.timeAgoWidget(
                  DateTime.fromMillisecondsSinceEpoch(
                      widget.message.info.timestamp),
                ),
              ),
            ],
          ),
          const SizedBox(width: 5),
          if (widget.message.isMine)
            widget.message.info.sentStatus == ZIMMessageSentStatus.sending
                ? const SpinKitSpinningLines(
                    color: Colors.blue,
                    size: 10.0,
                  )
                : CircleAvatar(
                    radius: 7,
                    backgroundColor: widget.message.info.sentStatus ==
                            ZIMMessageSentStatus.success
                        ? Colors.blue
                        : Colors.red,
                    child: Icon(
                      widget.message.info.sentStatus ==
                              ZIMMessageSentStatus.success
                          ? Icons.check
                          : Icons.close,
                      size: 10,
                      color: Colors.white,
                    ),
                  ),
        ],
      ),
    );
  }

  Future<void> initController(String filePath) async {
    print("Base local name: ${path.basename(filePath)}");
    voiceInfo =
        await Firestorer.instance.getVoiceNoteInfo(path.basename(filePath));
    voiceInfo ??= await Firestorer.instance.storeVoiceInfo(
        context,
        widget.message.fileContent!.fileLocalPath,
        widget.message.fileContent!.fileDownloadUrl);
    if (mounted) setState(() {});
    controller.updateFrequency = UpdateFrequency.low;
    await controller.preparePlayer(
        path: filePath, shouldExtractWaveform: false, volume: 1.0);
    maxDuration = Duration(milliseconds: controller.maxDuration);
    if (mounted) {
      setState(() {});
    }
    controller.onCompletion.listen((event) async {
      await controller.seekTo(0);
      await controller.pausePlayer();
      if (mounted) {
        setState(() {});
      }
    });
    controller.onPlayerStateChanged.listen((event) {
      if (mounted) {
        setState(() {});
        if (event.isInitialised) showMyToast("controller initted");
      }
    });
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) {
      if (n >= 10) return "$n";
      return "0$n";
    }

    String formattedDuration = '';

    if (duration.inHours > 0) {
      formattedDuration += "${twoDigits(duration.inHours)}:";
    }

    formattedDuration += "${twoDigits(duration.inMinutes.remainder(60))}:";
    formattedDuration += twoDigits(duration.inSeconds.remainder(60));

    return formattedDuration;
  }
}

// //not working s hidden
//                       if (false)
//                         Padding(
//                           padding: const EdgeInsets.only(left: 8.0),
//                           child: SizedBox(
//                             height: MediaQuery.of(context).size.height * 0.035,
//                             width: MediaQuery.of(context).size.height * 0.07,
//                             child: FilledButton(
//                               style: FilledButton.styleFrom(
//                                   padding: EdgeInsets.zero),
//                               onPressed: () {
//                                 setState(() {
//                                   speedIndex = (speedIndex + 1) % speeds.length;
//                                 });
//                                 changePlaybackSpeed(speeds[speedIndex]);
//                               },
//                               child: Text('${speeds[speedIndex]}x'),
//                             ),
//                           ),
//                         ),
// void changePlaybackSpeed(double speed) async {
//     await controller.pausePlayer();
//
//     final ext = path.extension(voiceInfo!.localPath);
//     final outputPath =
//         "${voiceInfo!.localPath.substring(0, voiceInfo!.localPath.indexOf('.'))}fast$ext";
//     final command =
//         "-i ${voiceInfo!.localPath} -filter:a \"atempo=$speed\" -vn $outputPath";
//
//     final session =
//         await FFmpegKit.execute(command).onError((error, stackTrace) {
//       print("ffmpeg stdout:$error");
//       print("ffmpeg stderr:$stackTrace");
//       return FFmpegSession();
//     });
//     print("Logs: ");
//     (await session.getLogs()).forEach((element) {
//       print("Log: ${element.getMessage()}");
//     });
//     if (ReturnCode.isSuccess(await session.getReturnCode())) {
//       print("Playback speed changed successfully!");
//       showMyToast('fileSavedAt: $outputPath');
//       await initController(outputPath);
//       await controller.startPlayer(finishMode: FinishMode.pause);
//       if (mounted) {
//         setState(() {});
//       }
//     } else {
//       showMyToast('some error occured while playback speed.');
//       print("Error changing playback speed: ${await session.getReturnCode()}");
//     }
//   }
