import 'package:call_app_flutter/constants.dart';
import 'package:call_app_flutter/widgets/chat_home_popup_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

class ChatHomePage extends StatelessWidget {
  const ChatHomePage({Key? key}) : super(key: key);
  static const id = "/chatHomePage";
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Conversations'),
          actions: const [
            ChatHomePopupMenuButton(),
          ],
        ),
        body: ZIMKitConversationListView(
          loadingBuilder: (c, w) {
            return kSpinner;
          },
          onPressed: (context, conversation, defaultAction) {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return ZIMKitMessageListPage(
                  conversationID: conversation.id,
                  conversationType: conversation.type,
                  appBarBuilder: (context, appBar) {
                    return AppBar(
                      title: Row(
                        children: [
                          const CircleAvatar(
                            backgroundImage: NetworkImage(kDummyImage),
                          ),
                          const SizedBox(width: 10),
                          Text(conversation.name),
                        ],
                      ),
                    );
                  },
                );
              },
            ));
          },
        ),
      ),
    );
  }

  HomePagePopupMenuButton() {}
}
