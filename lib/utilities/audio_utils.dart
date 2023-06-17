// Import package
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:call_app_flutter/constants.dart';
import 'package:call_app_flutter/utilities/localStorer.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class AudioUtils {
  AudioUtils._();
  static final _recorder = RecorderController();
  static String? appDirPath;

  static Future<void> recordAudio(fileName) async {
    if (appDirPath == null) initAppDirectoryPath();
    if (appDirPath == null) {
      showMyToast("App dir path is null", isError: true);
      return;
    }
    if (await _recorder.checkPermission()) {
      await _recorder.record(path: '$appDirPath/$fileName.wav');
    }
  }

  static Future<bool> isRecording() async {
    return _recorder.isRecording;
  }

  ///Stops recording and  Returns the output path.
  static Future<String?> stopRecording() async {
    final path = await _recorder.stop();
    Localstorer.storeWaveFormData(path!);
    _recorder.refresh();
    return path;
  }

  static void initAppDirectoryPath() async {
    final dirPath = (await getExternalStorageDirectory())!.path;
    final dir = Directory(path.join(dirPath, 'audios'));
    await dir.create();
    appDirPath = dir.path;
  }

  static Future<PlayerController> controllerForAudioFile(path) async {
    PlayerController controller = PlayerController(); // Initialise
    await controller.preparePlayer(
      path: path,
      shouldExtractWaveform: false,
      noOfSamples: 100,
      volume: 1.0,
    );
    controller.setRefresh(true);
    controller.updateFrequency = UpdateFrequency.low;
    return controller;
  }
}
