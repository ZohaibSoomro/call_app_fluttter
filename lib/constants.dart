// ignore_for_file: prefer_function_declarations_over_variables

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

const kSpinner = SpinKitSpinningLines(
  color: Colors.blue,
// size: 50.0,
);
const kDummyImage =
    'https://th.bing.com/th/id/R.b9941d2d7120044bd1d8e91c5556c131?rik=sDJfLfGGErT9Fg&pid=ImgRaw&r=0';

final kCallWithInvitationConfig = (ZegoCallInvitationData data) {
  var config = (data.invitees.length > 1)
      ? ZegoCallType.videoCall == data.type
          ? ZegoUIKitPrebuiltCallConfig.groupVideoCall()
          : ZegoUIKitPrebuiltCallConfig.groupVoiceCall()
      : ZegoCallType.videoCall == data.type
          ? ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
          : ZegoUIKitPrebuiltCallConfig.oneOnOneVoiceCall();

  config.onOnlySelfInRoom = (context) {
    Navigator.pop(context);
  };

  config.avatarBuilder =
      (context, Size size, ZegoUIKitUser? user, Map extraInfo) {
    return user != null
        ? CircleAvatar(
            radius: size.height * 0.1,
            backgroundColor: Colors.grey,
            backgroundImage: const NetworkImage(kDummyImage),
          )
        : const SizedBox();
  };
  //minimize button
  config.topMenuBarConfig.isVisible = true;
  config.topMenuBarConfig.buttons
      .insert(0, ZegoMenuBarButtonName.minimizingButton);

  config.audioVideoViewConfig = ZegoPrebuiltAudioVideoViewConfig(
    foregroundBuilder:
        (BuildContext context, Size size, ZegoUIKitUser? user, Map extraInfo) {
      return user != null
          ? Positioned(
              bottom: 5,
              left: 5,
              child: CircleAvatar(
                radius: size.height * 0.03,
                backgroundColor: Colors.grey,
                backgroundImage: const NetworkImage(kDummyImage),
              ),
            )
          : const SizedBox();
    },
  );
  return config;
};

const kRingtoneCallInvitationConfig = ZegoRingtoneConfig(
  //ulte naam rkh diye thay
  outgoingCallPath: "assets/zego_incoming.mp3",
  incomingCallPath: "assets/zego_outgoing.mp3",
);

final kCallInvitationEvents = ZegoUIKitPrebuiltCallInvitationEvents(
  onIncomingCallDeclineButtonPressed: () {
    showMyToast("call declined", isError: true);
  },
  onIncomingCallAcceptButtonPressed: () {
    showMyToast("call accepted");
  },
  onIncomingCallReceived: (
    String callID,
    ZegoCallUser caller,
    ZegoCallType callType,
    List<ZegoCallUser> callees,
    String customData,
  ) {
    showMyToast("Received ${callType.name} call from ${caller.name}",
        isError: true);
  },
  onIncomingCallCanceled: (String callID, ZegoCallUser caller) {
    showMyToast("call invitae canceled by ${caller.name}", isError: true);
  },
  onIncomingCallTimeout: (String callID, ZegoCallUser caller) {
    showMyToast("call timed out", isError: true);
  },
  onOutgoingCallCancelButtonPressed: () {
    showMyToast("Call canceled by user", isError: true);
  },
  onOutgoingCallAccepted: (String callID, ZegoCallUser callee) {
    showMyToast("${callee.name} has accepted call invite");
  },
  onOutgoingCallRejectedCauseBusy: (String callID, ZegoCallUser callee) {
    showMyToast("${callee.name} is on another call", isError: true);
  },
  onOutgoingCallDeclined: (String callID, ZegoCallUser callee) {
    showMyToast("Call declined by ${callee.name}", isError: true);
  },
  onOutgoingCallTimeout: (String callID, List<ZegoCallUser> callees, type) {},
);

Future showMyToast(String msg, {bool isError = false}) {
  return Fluttertoast.showToast(
      msg: msg,
      backgroundColor: isError ? Colors.red : Colors.blue,
      textColor: Colors.white);
}
