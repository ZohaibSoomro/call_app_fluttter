import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

import '../pages/login.dart';
import '../utilities/localStorer.dart';

class ChatHomePopupMenuButton extends StatefulWidget {
  const ChatHomePopupMenuButton({super.key});

  @override
  State<ChatHomePopupMenuButton> createState() =>
      _ChatHomePopupMenuButtonState();
}

class _ChatHomePopupMenuButtonState extends State<ChatHomePopupMenuButton> {
  bool isLoggingOut = false;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (String value) async {
        // Handle menu item selection
        if (value == 'New Chat') {
          // Handle New Chat pressed
          ZIMKit.instance.showDefaultNewPeerChatDialog(context);
        } else if (value == 'New Group') {
          // Handle New Group pressed
          ZIMKit.instance.showDefaultNewGroupChatDialog(context);
        } else if (value == 'Join group') {
          // Handle Settings pressed
          ZIMKit.instance.showDefaultJoinGroupDialog(context);
        } else if (value == 'Logout') {
          setState(() => isLoggingOut = true);
          Localstorer.setLoggedInStatus(false);
          //un-initializing zego call invitation service
          await ZegoUIKitPrebuiltCallInvitationService().uninit();
          await ZIMKit.instance.disconnectUser();
          setState(() => isLoggingOut = false); 
          Future.delayed(const Duration(seconds: 1)).then(
            (value) => Navigator.pushReplacementNamed(context, LoginPage.id),
          );
        }
      },
      itemBuilder: (BuildContext context) {
        return [
          const PopupMenuItem<String>(
            value: 'New Chat',
            child: ListTile(
              leading: Icon(Icons.chat),
              title: Text('New Chat'),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'New Group',
            child: ListTile(
              leading: Icon(Icons.group),
              title: Text('New Group'),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'Join group',
            child: ListTile(
              leading: Icon(Icons.settings),
              title: Text('Join group'),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'Logout',
            child: ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Logout'),
            ),
          ),
        ];
      },
    );
  }
}
