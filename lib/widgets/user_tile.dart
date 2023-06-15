import 'package:call_app_flutter/constants.dart';
import 'package:call_app_flutter/utilities/firestorer.dart';
import 'package:call_app_flutter/utilities/localStorer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_zimkit/pages/message_list_page.dart';
import 'package:zego_zimkit/services/services.dart';

import '../model/user_model.dart';
import '../pages/call_page.dart';

class UserTile extends StatelessWidget {
  const UserTile({Key? key, required this.user}) : super(key: key);
  final MyUser user;
  @override
  Widget build(BuildContext context) {
    final s = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Slidable(
        closeOnScroll: true,
        key: ValueKey(user.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            Container(
              width: s.width * 0.15,
              height: s.height * 0.1,
              color: Colors.red,
              child: IconButton(
                onPressed: () {
                  Firestorer.instance.deleteUser(user);
                },
                icon: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
            ),
            // SlidableAction(
            //   onPressed: (context) {
            //   },
            //   backgroundColor: Colors.red,
            //   foregroundColor: Colors.white,
            //   icon: Icons.delete,
            //   label: 'Delete',
            // ),
            Container(
              color: Colors.blue.shade700,
              width: s.width * 0.15,
              height: s.height * 0.1,
              child: ZegoSendCallInvitationButton(
                isVideoCall: true,
                icon: ButtonIcon(
                  icon: const Icon(
                    Icons.video_call,
                    color: Colors.white,
                  ),
                ),
                buttonSize: Size(s.width * 0.09, s.height * 0.06),
                iconSize: Size(s.width * 0.09, s.height * 0.06),
                resourceID: "zogo_uikit_call", // For offline call notification
                invitees: [
                  ZegoUIKitUser(
                    id: user.id!,
                    name: user.name,
                  ),
                ],
              ),
            ),
            Container(
              color: Colors.amber.shade700,
              width: s.width * 0.15,
              height: s.height * 0.1,
              child: ZegoSendCallInvitationButton(
                isVideoCall: false,
                buttonSize: Size(s.width * 0.09, s.height * 0.06),
                iconSize: Size(s.width * 0.09, s.height * 0.06),
                icon: ButtonIcon(
                    icon: const Icon(
                  Icons.call,
                  color: Colors.white,
                )),
                resourceID: "zogo_uikit_call", // For offline call notification
                invitees: [
                  ZegoUIKitUser(
                    id: user.id!,
                    name: user.name,
                  ),
                ],
              ),
            ),
            // SlidableAction(
            //   onPressed: (context) {
            //     user.callInfo = CallInfo(
            //       status: CallStatus.beingCalled,
            //       caller: Localstorer.currentUser,
            //       timestamp: DateTime.now().toIso8601String(),
            //     );
            //     Firestorer.instance.updateUser(user);
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => CallPage(user: user),
            //       ),
            //     );
            //   },
            //   backgroundColor: const Color(0xFF0392CF),
            //   foregroundColor: Colors.white,
            //   icon: Icons.call,
            //   label: 'Call',
            // ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ListTile(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return ZIMKitMessageListPage(
                    conversationID: user.id!,
                    conversationType: ZIMConversationType.peer,
                    appBarBuilder: (context, appBar) {
                      return AppBar(
                        title: Row(
                          children: [
                            const CircleAvatar(
                              backgroundImage: NetworkImage(kDummyImage),
                            ),
                            const SizedBox(width: 10),
                            Text(user.name),
                          ],
                        ),
                      );
                    },
                  );
                }));
              },
              tileColor: Colors.blue.shade400,
              leading: const CircleAvatar(
                backgroundColor: Colors.grey,
                backgroundImage: NetworkImage(kDummyImage),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              textColor: Colors.white,
              title: Text(user.name),
              subtitle: Text(user.email),
              trailing: FilledButton(
                onPressed: () {
                  if (ZegoUIKitPrebuiltCallMiniOverlayMachine().isMinimizing) {
                    showMyToast("already in a call.");
                    return;
                  }
                  user.callInfo = CallInfo(
                    status: CallStatus.beingCalled,
                    caller: Localstorer.currentUser,
                    timestamp: DateTime.now().toIso8601String(),
                  );
                  Firestorer.instance.updateUser(user);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CallPage(user: user),
                    ),
                  );
                },
                child: const Icon(
                  Icons.call,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
