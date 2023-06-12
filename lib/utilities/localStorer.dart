import 'dart:convert';

import 'package:call_app_flutter/model/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Localstorer {
  static late SharedPreferences prefs;
  static final instance = Localstorer._();
  static const _loggedInText = "loggedIn";
  static const _currentUserText = "user";
  static MyUser? _currentUser;

  static Future loadCurrentUser() async {
    _currentUser = await Localstorer.getCurrentUser();
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
