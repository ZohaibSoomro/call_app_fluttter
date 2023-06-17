import 'dart:convert';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:call_app_flutter/constants.dart';
import 'package:call_app_flutter/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Localstorer {
  static late SharedPreferences prefs;
  static final instance = Localstorer._();
  static const _loggedInText = "loggedIn";
  static const _currentUserText = "user";
  static MyUser? _currentUser;

  static Future<MyUser?> loadCurrentUser() async {
    _currentUser = await Localstorer.getCurrentUser();
    return _currentUser;
  }

  static Future<bool> storeWaveFormData(String filePath) async {
    final waveFormData =
        await PlayerController().extractWaveformData(path: filePath);
    showMyToast("Waveform stored");
    return prefs.setStringList(
        filePath, waveFormData.map((e) => e.toString()).toList());
  }

  static List<double>? getWaveFormData(path) {
    final list = prefs.getStringList(path);
    if (list == null) return null;
    return list.map((e) => double.parse(e)).toList();
  }

  static MyUser get currentUser => _currentUser!;

  Localstorer._();

  static Future setPrefs() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future<bool> getLoggedInStatus() async {
    bool status = false;
    status = (await prefs.getBool(_loggedInText)) ?? false;
    return status;
  }

  static Future<bool> setLoggedInStatus(bool status) async {
    return await prefs.setBool(_loggedInText, status);
  }

  static Future<MyUser> getCurrentUser() async {
    final json = prefs.getString(_currentUserText);
    return MyUser.fromJson(jsonDecode(json!));
  }

  static Future<void> setCurrentUser(MyUser user) async {
    _currentUser = user;
    await prefs.setString(_currentUserText, jsonEncode(user.toJson()));
  }
}
