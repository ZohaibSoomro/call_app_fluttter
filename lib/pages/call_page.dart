import 'package:call_app_flutter/model/user_model.dart';
import 'package:call_app_flutter/utilities/firestorer.dart';
import 'package:call_app_flutter/utilities/localStorer.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallPage extends StatelessWidget {
  const CallPage({Key? key, required this.user, required this.callId})
      : super(key: key);
  final MyUser user;
  final String callId;
  @override
  Widget build(BuildContext context) {
    setTimeout(context);
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
            appID: 736957510,
            appSign:
                "aca7b4ae7589c6b0b2ca570ef6f5ce8eb237dfff16846386c245ce3019082c90",
            callID: callId,
            userID: currentUser.id!,
            userName: currentUser.name,
            config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall(),
          );
        });
  }

  void setTimeout(context) {
    Future.delayed(const Duration(seconds: 10), () async {
      //refreshing user data
      final userNew = (await Firestorer.instance.loginUser(user)) as MyUser;
      if (userNew.callInfo!.status == CallStatus.beingCalled) {
        userNew.callInfo = null;
        await Firestorer.instance.updateUser(userNew);
        Fluttertoast.showToast(msg: "timeout");
        Navigator.pop(context);
      }
    });
  }
}
