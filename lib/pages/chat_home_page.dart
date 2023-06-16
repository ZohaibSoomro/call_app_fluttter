import 'package:call_app_flutter/constants.dart';
import 'package:call_app_flutter/utilities/chat_utils.dart';
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
          onLongPress: onConversationLongPress,
          loadingBuilder: (c, w) {
            return kSpinner;
          },
          onPressed: (context, conversation, defaultAction) {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return ZIMKitMessageListPage(
                  conversationID: conversation.id,
                  conversationType: conversation.type,
                  messageItemBuilder: (context, message, defaultWidget) {
                    bool isCurrentUser = message.info.senderUserID ==
                        ZIMKit().currentUser()?.baseInfo.userID;
                    final rowMainAlignment = isCurrentUser
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start;
                    final columnCrossAlignment = isCurrentUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start;
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: rowMainAlignment,
                        children: [
                          if (!isCurrentUser)
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                  conversation.avatarUrl.isNotEmpty
                                      ? conversation.avatarUrl
                                      : kDummyImage),
                            ),
                          const SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: columnCrossAlignment,
                            children: [
                              Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(20),
                                  topRight: const Radius.circular(20),
                                  bottomLeft: isCurrentUser
                                      ? const Radius.circular(20)
                                      : Radius.zero,
                                  bottomRight: !isCurrentUser
                                      ? const Radius.circular(20)
                                      : Radius.zero,
                                )),
                                color:
                                    isCurrentUser ? Colors.blue : Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Column(
                                    crossAxisAlignment: columnCrossAlignment,
                                    children: [
                                      Text(
                                        message.info.senderUserID.characters
                                                .first
                                                .toUpperCase() +
                                            message.info.senderUserID
                                                .substring(1),
                                        style: TextStyle(
                                            color: isCurrentUser
                                                ? Colors.white60
                                                : Colors.grey.shade600,
                                            fontSize: 12),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        message.textContent?.text ?? 'hi',
                                        style: TextStyle(
                                            color: isCurrentUser
                                                ? Colors.white
                                                : Colors.black,
                                            fontSize: 16),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 5),
                              defaultLastMessageTimeBuilder(
                                DateTime.fromMillisecondsSinceEpoch(
                                    message.info.timestamp),
                              ),
                            ],
                          ),
                          const SizedBox(width: 10),
                          if (isCurrentUser)
                            CircleAvatar(
                              backgroundImage: NetworkImage(
                                  conversation.avatarUrl.isNotEmpty
                                      ? conversation.avatarUrl
                                      : kDummyImage),
                            ),
                        ],
                      ),
                    );
                  },
                  onMessageItemPressd: (c, message, defaultAction) {
                    switch (message.type) {
                      case ZIMMessageType.text:
                        // showMyToast(message.textContent!.text);
                        break;
                      case ZIMMessageType.image:
                        ChatUtils.viewImage(
                            context, message.imageContent!.fileDownloadUrl);
                        break;
                      case ZIMMessageType.video:
                        break;
                      case ZIMMessageType.file:
                        ChatUtils.saveFileToDevice(
                                context,
                                message.fileContent!.fileDownloadUrl,
                                message.fileContent!.fileName)
                            .then(
                                (value) => showMyToast("file saved at $value"));
                        break;
                      default:
                        showMyToast("file type not mentioned");
                        break;
                    }
                    defaultAction();
                  },
                  appBarBuilder: (context, appBar) {
                    return AppBar(
                      title: Row(
                        children: [
                          CircleAvatar(
                            backgroundImage: NetworkImage(
                                conversation.avatarUrl.isNotEmpty
                                    ? conversation.avatarUrl
                                    : kDummyImage),
                          ),
                          const SizedBox(width: 10),
                          Text(conversation.name),
                        ],
                      ),
                      actions: [
                        IconButton(
                            icon: const Icon(Icons.local_phone),
                            onPressed: () {}),
                        IconButton(
                            icon: const Icon(Icons.videocam), onPressed: () {}),
                      ],
                    );
                  },
                  inputDecoration: const InputDecoration(
                      hintText: 'Type here...',
                      contentPadding: EdgeInsets.zero),
                  messageInputActions: [
                    ZIMKitMessageInputAction.left(
                      IconButton(icon: const Icon(Icons.mic), onPressed: () {}),
                    ),
                    ZIMKitMessageInputAction.leftInside(
                      IconButton(
                          icon: const Icon(
                              Icons.sentiment_satisfied_alt_outlined),
                          onPressed: () {}),
                    ),
                  ],
                  messageListErrorBuilder: (c, d) {
                    return Center(
                      child: Text(
                        'Some error occured!',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                    );
                  },
                  messageListLoadingBuilder: (c, d) {
                    return kSpinner;
                  },
                );
              },
            ));
          },
        ),
      ),
    );
  }

  onConversationLongPress(
      context, conversation, longPressDownDetails, defaultAction) {
    final conversationBox = context.findRenderObject()! as RenderBox;
    final offset = conversationBox
        .localToGlobal(Offset(0, conversationBox.size.height / 2));

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(
        longPressDownDetails.globalPosition.dx,
        offset.dy,
        longPressDownDetails.globalPosition.dx,
        offset.dy,
      ),
      items: [
        const PopupMenuItem(value: 0, child: Text('Delete')),
        if (conversation.type == ZIMConversationType.group)
          const PopupMenuItem(value: 1, child: Text('Quit'))
      ],
    ).then((value) {
      switch (value) {
        case 0:
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Confirm'),
                content: const Text('Do you want to delete this conversation?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      ZIMKit().deleteConversation(
                          conversation.id, conversation.type);
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
          break;
        case 1:
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Confirm'),
                content: const Text('Do you want to leave this group?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      ZIMKit().leaveGroup(conversation.id);
                      Navigator.pop(context);
                    },
                    child: const Text('OK'),
                  ),
                ],
              );
            },
          );
          break;
      }
    });
  }

  Widget defaultLastMessageTimeBuilder(DateTime? messageTime) {
    if (messageTime == null) {
      return const SizedBox.shrink();
    }
    final now = DateTime.now();
    final duration = DateTime.now().difference(messageTime);

    late String timeStr;

    if (duration.inMinutes < 1) {
      timeStr = 'just now';
    } else if (duration.inHours < 1) {
      timeStr = '${duration.inMinutes} minutes ago';
    } else if (duration.inDays < 1) {
      timeStr = '${duration.inHours} hours ago';
    } else if (now.year == messageTime.year) {
      timeStr =
          '${messageTime.month}/${messageTime.day} ${messageTime.hour}:${messageTime.minute}';
    } else {
      timeStr =
          ' ${messageTime.year}/${messageTime.month}/${messageTime.day} ${messageTime.hour}:${messageTime.minute}';
    }

    return Opacity(
        opacity: 0.64,
        child: Text(
          timeStr,
          maxLines: 1,
          overflow: TextOverflow.clip,
          style: const TextStyle(fontSize: 12),
        ));
  }
}
