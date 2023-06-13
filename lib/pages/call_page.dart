import 'dart:convert';

import 'package:call_app_flutter/model/user_model.dart';
import 'package:call_app_flutter/utilities/apputils.dart';
import 'package:call_app_flutter/utilities/firestorer.dart';
import 'package:call_app_flutter/utilities/localStorer.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallPage extends StatelessWidget {
  const CallPage({Key? key, required this.user}) : super(key: key);
  final MyUser user;
  @override
  Widget build(BuildContext context) {
    // setTimeout(context);
    final currentUser = Localstorer.currentUser;
    return StreamBuilder(
        stream: Firestorer.instance.collection.doc(user.id).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.waiting) {
            print("popo ntho kre ");
            final user =
                MyUser.fromJson(snapshot.data!.data() as Map<String, dynamic>);
            if (user.callInfo?.status == CallStatus.declined) {
              print("hanre ta kar");
              Navigator.pop(context);
            } else {
              user.callInfo?.status = CallStatus.inACall;
              Firestorer.instance.updateUser(user);
            }
            print("bus byo cha kre");
          }
          return ZegoUIKitPrebuiltCall(
            onDispose: () {
              user.callInfo = null;
              Firestorer.instance.updateUser(user);
            },
            appID:
                AppUtils.kZegoAppId, //write ur zego cloud project's app id here
            appSign: AppUtils.kZegoAppSignIn, //& app sign in here
            callID: generateCallID(user, currentUser),
            userID: currentUser.id!,
            userName: currentUser.name,
            config: ZegoUIKitPrebuiltCallConfig(
              turnOnCameraWhenJoining: true,
              turnOnMicrophoneWhenJoining: true,
              onOnlySelfInRoom: (context) async {
                // final userNew =
                //     (await Firestorer.instance.loginUser(user)) as MyUser;
                // if (userNew.callInfo?.status == CallStatus.beingCalled) {
                //   userNew.callInfo = null;
                //   await Firestorer.instance.updateUser(userNew);
                //   Fluttertoast.showToast(msg: "timeout");
                Navigator.pop(context);
                // }
              },
              layout: ZegoLayout.pictureInPicture(),
              useSpeakerWhenJoining: true,
              avatarBuilder: (context, size, user, map) {
                return user != null
                    ? CircleAvatar(
                        radius: size.height * 0.5,
                        backgroundColor: Colors.red,
                        backgroundImage: const NetworkImage(
                            'https://th.bing.com/th/id/R.b9941d2d7120044bd1d8e91c5556c131?rik=sDJfLfGGErT9Fg&pid=ImgRaw&r=0'),
                      )
                    : const SizedBox();
              },
              audioVideoViewConfig: ZegoPrebuiltAudioVideoViewConfig(
                showSoundWavesInAudioMode: true,
                showAvatarInAudioMode: true,
                showCameraStateOnView: true,
                showMicrophoneStateOnView: true,
                showUserNameOnView: true,
                useVideoViewAspectFill: true,
                isVideoMirror: true,
              ),
            ),
          );
        });
  }

  void setTimeout(context) {
    Future.delayed(const Duration(seconds: 10), () async {
      //refreshing user data
      final userNew = (await Firestorer.instance.loginUser(user)) as MyUser;
      if (userNew.callInfo?.status == CallStatus.beingCalled) {
        userNew.callInfo = null;
        await Firestorer.instance.updateUser(userNew);
        Fluttertoast.showToast(msg: "timeout");
        Navigator.pop(context);
      }
    });
  }

  String generateCallID(MyUser u1, MyUser u2) {
    // Sort the properties alphabetically
    List<String> properties = [
      u1.name,
      u1.email,
      u1.id ?? '',
      u2.name,
      u2.email,
      u2.id ?? ''
    ];
    properties.sort();

    // Concatenate the sorted properties
    String combinedString = properties.join();

    // Generate a hash value from the combined string
    var bytes = utf8.encode(combinedString);
    var hash = sha256.convert(bytes);

    // Take the first 8 characters of the hash as the call ID
    String callID = hash.toString().substring(0, 8);

    return callID;
  }
}
