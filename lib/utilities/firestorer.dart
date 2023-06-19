import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:call_app_flutter/model/user_model.dart';
import 'package:call_app_flutter/utilities/chat_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:path/path.dart' as path;

import '../constants.dart';
import '../widgets/voice_message_widget.dart';

class Firestorer {
  static final instance = Firestorer._();

  Firestorer._();
  final collection = FirebaseFirestore.instance.collection("callAppUsers");
  Future<void> createUser(MyUser user) async {
    await collection.add(user.toJson()).then((value) {
      print("Doc added");
      user.id = value.id;
      value.update(user.toJson()).then((value) => print("doc updated"));
    });
  }

  ///used to login a user
  Future<MyUser?> loginUser(MyUser user) async {
    final doc = await collection
        .where("email", isEqualTo: user.email)
        .where("password", isEqualTo: user.password)
        .get();
    if (doc.docs.isEmpty) {
      return null;
    }
    return MyUser.fromJson(doc.docs.first.data());
  }

  Future<void> deleteUser(MyUser user) async {
    return await collection
        .doc(user.id)
        .delete()
        .then((value) => print("Doc deleted"));
  }

  Future<List<MyUser>> getAllUsers() async {
    return (await collection.get())
        .docs
        .map((e) => MyUser.fromJson(e.data()))
        .toList();
  }

  Future<void> updateUser(MyUser user) async {
    await collection.doc(user.id).update(user.toJson());
    print("user ${user.callInfo?.toJson()} updated");
  }

  Future<MyUser> getUserWithId(String senderUserID) async {
    final doc = await collection.doc(senderUserID).get();
    return MyUser.fromJson(doc.data() as Map<String, dynamic>);
  }

  ///if file not exist, download it and save it
  Future<VoiceMessageInfo> storeVoiceInfo(
      context, String filePath, String downloadUrl) async {
    final file = File(filePath);
    String? localPath;
    if (!await file.exists()) {
      String fileName = path.basename(filePath);
      localPath =
          await ChatUtils.saveFileToDevice(context, downloadUrl, fileName);
    }
    final waveFormData = await PlayerController()
        .extractWaveformData(path: localPath ?? filePath);
    final waveForms = VoiceMessageInfo(
      localPath: localPath ?? filePath,
      waveFormsList: waveFormData,
      remoteUrl: downloadUrl,
    );
    final doc = FirebaseFirestore.instance
        .collection("waveForms")
        .doc(path.basename(localPath ?? filePath));
    await doc
        .set(waveForms.toJson())
        .then((value) => showMyToast("Waveform stored"));
    return waveForms;
  }

  Future<VoiceMessageInfo?> getVoiceNoteInfo(String path) async {
    final doc = await FirebaseFirestore.instance
        .collection("waveForms")
        .doc(path)
        .get();
    if (doc.data() == null) return null;
    final waveForm = VoiceMessageInfo.fromJson(doc.data()!);
    return waveForm;
  }
}
