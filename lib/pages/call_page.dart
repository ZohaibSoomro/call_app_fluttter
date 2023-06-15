import 'dart:convert';
import 'dart:ui';

import 'package:call_app_flutter/constants.dart';
import 'package:call_app_flutter/model/user_model.dart';
import 'package:call_app_flutter/utilities/apputils.dart';
import 'package:call_app_flutter/utilities/firestorer.dart';
import 'package:call_app_flutter/utilities/localStorer.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class CallPage extends StatefulWidget {
  const CallPage({Key? key, required this.user}) : super(key: key);
  final MyUser user;

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {
  ZegoUIKitPrebuiltCallController? callController;
  @override
  void initState() {
    super.initState();
    callController = ZegoUIKitPrebuiltCallController();
  }

  @override
  void dispose() {
    super.dispose();
    callController = null;
  }

  @override
  Widget build(BuildContext context) {
    // setTimeout(context);
    final currentUser = Localstorer.currentUser;
    return StreamBuilder(
        stream: Firestorer.instance.collection.doc(widget.user.id).snapshots(),
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
              widget.user.callInfo = null;
              Firestorer.instance.updateUser(widget.user);
            },
            appID:
                AppUtils.kZegoAppId, //write ur zego cloud project's app id here
            appSign: AppUtils.kZegoAppSignIn, //& app sign in here
            callID: generateCallID(widget.user, currentUser),
            userID: currentUser.id!,
            userName: currentUser.name,
            config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall()
              ..audioVideoViewConfig = ZegoPrebuiltAudioVideoViewConfig(
                foregroundBuilder: (BuildContext context, Size size,
                    ZegoUIKitUser? user, Map extraInfo) {
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
                backgroundBuilder: (BuildContext context, Size size,
                    ZegoUIKitUser? user, Map extraInfo) {
                  return user != null
                      ? Center(
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                            child: const Image(
                              fit: BoxFit.contain,
                              image: NetworkImage(kDummyImage),
                            ),
                          ),
                        )
                      : const SizedBox();
                },
              )
              ..avatarBuilder = (BuildContext context, Size size,
                  ZegoUIKitUser? user, Map extraInfo) {
                return user != null
                    ? Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            fit: BoxFit.fill,
                            image: NetworkImage(kDummyImage),
                          ),
                        ),
                      )
                    : const SizedBox();
              }
              // ..topMenuBarConfig.isVisible = true
              // ..topMenuBarConfig.buttons = [
              //   ZegoMenuBarButtonName.minimizingButton,
              //   ZegoMenuBarButtonName.showMemberListButton,
              // ]
              // ..durationConfig.isVisible = true
              // ..durationConfig.onDurationUpdate = (Duration duration) {
              //   if (duration.inSeconds >= 15) {
              //     // showMyToast("Hanging now");
              //     callController?.hangUp(context);
              //     Navigator.pop(context);
              //   }
              // }
              ..topMenuBarConfig.isVisible = true
              ..topMenuBarConfig.buttons = [
                ZegoMenuBarButtonName.minimizingButton,
                ZegoMenuBarButtonName.showMemberListButton,
              ]
              ..onOnlySelfInRoom = (context) async {
                Navigator.pop(context);
              },
          );
        });
  }

  void setTimeout(context) {
    Future.delayed(const Duration(seconds: 10), () async {
      //refreshing user data
      final userNew =
          (await Firestorer.instance.loginUser(widget.user)) as MyUser;
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
