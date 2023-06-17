// Import package
import 'dart:io';

import 'package:call_app_flutter/constants.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

class AudioRecorder {
  AudioRecorder._();
  static final _recorder = Record();
  static String? appDirPath;

  static recordAudio(fileName) async {
    if (appDirPath == null) _initAppDirectoryPath();
    if (appDirPath == null) {
      showMyToast("App dir path is null", isError: true);
      return;
    }
    if (await _recorder.hasPermission()) {
      await _recorder.start(path: '$appDirPath/$fileName.m4a');
    }
  }

  static Future<bool> isRecording() async {
    return await _recorder.isRecording();
  }

  ///Stops recording and  Returns the output path.
  static Future<String?> stopRecording() async {
    return await _recorder.stop();
  }

  static void _initAppDirectoryPath() async {
    final dirPath = (await getExternalStorageDirectory())!.path;
    final dir = Directory(path.join(dirPath, 'audios'));
    await dir.create();
    appDirPath = dir.path;
  }
}
