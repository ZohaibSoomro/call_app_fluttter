// ignore_for_file: use_build_context_synchronously

import 'package:audioplayers/audioplayers.dart';
import 'package:call_app_flutter/utilities/firestorer.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:zego_zimkit/services/defines.dart';
import 'package:zego_zimkit/services/services.dart';

import '../utilities/chat_utils.dart';

class VoiceMessageWidget extends StatefulWidget {
  final String filePath;
  final bool isMyMessage;
  final Widget defaultWidget;
  final String downloadUrl;
  final ZIMKitMessageBaseInfo msgBaseInfo;
  const VoiceMessageWidget(
      {super.key,
      required this.filePath,
      required this.defaultWidget,
      required this.downloadUrl,
      required this.isMyMessage,
      required this.msgBaseInfo});

  @override
  _VoiceMessageWidgetState createState() => _VoiceMessageWidgetState();
}

class _VoiceMessageWidgetState extends State<VoiceMessageWidget> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;

  VoiceMessageInfo? waveForm;

  Duration progress = const Duration(milliseconds: 0);

  Duration maxDuration = const Duration(milliseconds: 0);

  @override
  void initState() {
    super.initState();
    saveWaveForm();
    _audioPlayer = AudioPlayer();
    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.playing) {
        _isPlaying = true;
        if (mounted) setState(() {});
      } else {
        _isPlaying = false;
        if (mounted) setState(() {});
      }
    });

    _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
      if (state == PlayerState.playing) {
        _isPlaying = true;
        if (mounted) setState(() {});
      } else {
        _isPlaying = false;
        if (mounted) setState(() {});
      }
      if (state == PlayerState.completed) {
        progress = const Duration(milliseconds: 0);
        if (mounted) setState(() {});
      }
    });

    _audioPlayer.onPositionChanged.listen((Duration duration) {
      setState(() {
        progress = duration;
      });
    });
  }

  @override
  void dispose() {
    _audioPlayer.release();
    _audioPlayer.dispose();
    super.dispose();
  }

  void _playPauseAudio() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.setSourceDeviceFile(widget.filePath);
      maxDuration = (await _audioPlayer.getDuration())!;
      await _audioPlayer.play(DeviceFileSource(widget.filePath));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.5,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(25),
          topRight: const Radius.circular(25),
          bottomLeft:
              widget.isMyMessage ? const Radius.circular(50) : Radius.zero,
          bottomRight:
              !widget.isMyMessage ? const Radius.circular(50) : Radius.zero,
        ),
        color: const Color.fromARGB(255, 204, 204, 255).withOpacity(0.6),
      ),
      margin: const EdgeInsets.all(10),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: widget.isMyMessage
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            if (!widget.isMyMessage)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: FutureBuilder(
                    future: Firestorer.instance
                        .getUserWithId(widget.msgBaseInfo.senderUserID),
                    builder: (context, snap) {
                      return Text(
                        !snap.hasData
                            ? '..'
                            : snap.data!.name.characters.first.toUpperCase() +
                                snap.data!.name.substring(1),
                        style: TextStyle(
                            color: widget.isMyMessage
                                ? Colors.white60
                                : Colors.grey.shade600,
                            fontSize: 12),
                      );
                    }),
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.height * 0.03,
              child: Slider(
                activeColor: Colors.indigo,
                secondaryActiveColor: Colors.pinkAccent,
                inactiveColor: Colors.indigo.withOpacity(0.2),
                value: progress.inMilliseconds.toDouble(),
                onChangeStart: (val) {},
                onChangeEnd: (val) async {
                  await _audioPlayer.seek(Duration(milliseconds: val.toInt()));
                  setState(() {});
                },
                onChanged: (val) {
                  if (!_isPlaying) {
                    setState(() {
                      _isPlaying = true;
                    });
                    _playPauseAudio();
                  }
                  // if (progress == maxDuration) {
                  //   progress = const Duration(milliseconds: 0);
                  //   setState(() {});
                  // }
                },
                max: maxDuration.inMilliseconds.toDouble(),
              ),
            ),
            const SizedBox(height: 5),
            IconButton(
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: _isPlaying ? Colors.pink : Colors.indigo,
              ),
              iconSize: 40,
              onPressed: _playPauseAudio,
            ),
            const SizedBox(height: 5),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: ChatUtils.timeAgoWidget(
                DateTime.fromMillisecondsSinceEpoch(
                    widget.msgBaseInfo.timestamp),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void saveWaveForm() async {
    waveForm = await Firestorer.instance
        .getVoiceNoteInfo(path.basename(widget.filePath));
    if (waveForm == null) {
      await Firestorer.instance
          .storeVoiceInfo(context, widget.filePath, widget.downloadUrl);
    }
    setState(() {});
  }
}

class WaveBarWidget extends StatelessWidget {
  final List<double> amplitudes;
  final Color barColor;

  const WaveBarWidget({
    super.key,
    required this.amplitudes,
    this.barColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: CustomPaint(
        painter: _WaveBarPainter(
          amplitudes: amplitudes,
          barColor: barColor,
          barWidth: 2.5,
          barSpacing: 5,
          barHeight: 500,
        ),
      ),
    );
  }
}

class _WaveBarPainter extends CustomPainter {
  final List<double> amplitudes;
  final Color barColor;
  final double barWidth;
  final double barSpacing;
  final double barHeight;

  _WaveBarPainter({
    required this.amplitudes,
    required this.barColor,
    required this.barWidth,
    required this.barSpacing,
    required this.barHeight,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double totalWidth =
        (barWidth + barSpacing) * amplitudes.length - barSpacing;
    final double startX = (size.width - totalWidth) / 3.0;
    final double centerY = size.height / 2.0;

    final paint = Paint()
      ..color = barColor
      ..style = PaintingStyle.fill;

    for (int i = 0; i < amplitudes.length; i++) {
      final double barX = startX + i * (barWidth + barSpacing);
      final double barHeightScaled = amplitudes[i] * barHeight;
      final double barY = centerY - barHeightScaled / 2.0;

      final Rect barRect =
          Rect.fromLTRB(barX, barY, barX + barWidth, barY + barHeightScaled);
      canvas.drawRect(barRect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class VoiceMessageInfo {
  String localPath;
  String remoteUrl;
  List<double> waveFormsList;

  VoiceMessageInfo({
    required this.localPath,
    required this.remoteUrl,
    required this.waveFormsList,
  });

  factory VoiceMessageInfo.fromJson(Map<String, dynamic> json) {
    return VoiceMessageInfo(
      localPath: json['filePath'],
      remoteUrl: json['remoteUrl'],
      waveFormsList: List<double>.from(json['waveFormsList']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'filePath': localPath,
      'remoteUrl': remoteUrl,
      'waveFormsList': waveFormsList,
    };
  }
}
