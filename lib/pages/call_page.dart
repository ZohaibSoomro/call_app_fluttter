import 'dart:math';

import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallPage extends StatelessWidget {
  const CallPage({Key? key, required this.callId}) : super(key: key);
  final String callId;
  @override
  Widget build(BuildContext context) {
    String userID = Random().nextInt(10000).toString();

    return ZegoUIKitPrebuiltCall(
      onDispose: () {
        debugPrint("Call ended");
      },
      appID: 736957510,
      appSign:
          "aca7b4ae7589c6b0b2ca570ef6f5ce8eb237dfff16846386c245ce3019082c90",
      callID: callId,
      userID: userID,
      userName: "user_$userID",
      config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
    );
  }
}
