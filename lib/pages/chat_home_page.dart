import 'package:call_app_flutter/constants.dart';
import 'package:call_app_flutter/utilities/chat_utils.dart';
import 'package:call_app_flutter/utilities/firestorer.dart';
import 'package:call_app_flutter/widgets/chat_home_popup_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

class ChatHomePage extends StatelessWidget {
  ChatHomePage({Key? key}) : super(key: key);
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
          itemBuilder: (c, con, wid) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5.0),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
                child: ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              zimMessageListPage(context, con)),
                    );
                  },
                  trailing: defaultLastMessageTimeBuilder(
                    DateTime.fromMillisecondsSinceEpoch(
                        con.lastMessage!.info.timestamp),
                  ),
                  leading: CircleAvatar(
                    radius: 21,
                    backgroundColor: Colors.blue,
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(con.avatarUrl.isNotEmpty
                          ? con.avatarUrl
                          : kDummyImage),
                    ),
                  ),
                  title: Text(con.name),
                  subtitle: Text(con.lastMessage!.type == ZIMMessageType.text
                      ? con.lastMessage!.textContent!.text
                      : "[${con.lastMessage!.type.name}]"),
                ),
              ),
            );
          },
          onPressed: (context, conversation, defaultAction) {
            Navigator.push(context, MaterialPageRoute(
              builder: (context) {
                return zimMessageListPage(context, conversation);
              },
            ));
          },
        ),
      ),
    );
  }

  Widget zimMessageListPage(context, conversation) => ZIMKitMessageListPage(
        conversationID: conversation.id,
        conversationType: conversation.type,
        messageItemBuilder: (context, message, defaultWidget) {
          if (message.type != ZIMMessageType.text) {
            return defaultWidget;
          }
          bool isMyMessage = message.info.senderUserID ==
              ZIMKit().currentUser()?.baseInfo.userID;
          final rowMainAlignment =
              isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start;
          final columnCrossAlignment =
              isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start;
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: rowMainAlignment,
              children: [
                if (!isMyMessage)
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
                          bottomLeft: isMyMessage
                              ? const Radius.circular(20)
                              : Radius.zero,
                          bottomRight: !isMyMessage
                              ? const Radius.circular(20)
                              : Radius.zero,
                        ),
                      ),
                      color: isMyMessage ? Colors.blue : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20),
                        child: Column(
                          crossAxisAlignment: columnCrossAlignment,
                          children: [
                            FutureBuilder(
                                future: Firestorer.instance
                                    .getUserWithId(message.info.senderUserID),
                                builder: (context, snap) {
                                  return Text(
                                    !snap.hasData
                                        ? '..'
                                        : snap.data!.name.characters.first
                                                .toUpperCase() +
                                            snap.data!.name.substring(1),
                                    style: TextStyle(
                                        color: isMyMessage
                                            ? Colors.white60
                                            : Colors.grey.shade600,
                                        fontSize: 12),
                                  );
                                }),
                            const SizedBox(height: 5),
                            Text(
                              message.textContent!.text,
                              style: TextStyle(
                                  color:
                                      isMyMessage ? Colors.white : Colors.black,
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
                const SizedBox(width: 5),
                if (isMyMessage &&
                    message.info.sentStatus != ZIMMessageSentStatus.sending)
                  CircleAvatar(
                    radius: 7,
                    backgroundColor:
                        message.info.sentStatus == ZIMMessageSentStatus.success
                            ? Colors.blue
                            : Colors.red,
                    child: Icon(
                      message.info.sentStatus == ZIMMessageSentStatus.success
                          ? Icons.check
                          : Icons.close,
                      size: 10,
                      color: Colors.white,
                    ),
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
                  .then((value) => showMyToast("file saved at $value"));
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
              if (conversation.type == ZIMConversationType.peer)
                ChatUtils.zegoCallInvitationButton(
                  MediaQuery.of(context).size,
                  [
                    ZegoUIKitUser(
                      id: conversation.id,
                      name: conversation.name,
                    ),
                  ],
                ),
              if (conversation.type == ZIMConversationType.peer)
                ChatUtils.zegoCallInvitationButton(
                  MediaQuery.of(context).size,
                  [
                    ZegoUIKitUser(
                      id: conversation.id,
                      name: conversation.name,
                    ),
                  ],
                  isVideoCall: true,
                ),
            ],
          );
        },
        inputDecoration: const InputDecoration(
          hintText: 'Type here...',
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
        ),
        messageInputActions: [
          ZIMKitMessageInputAction.left(
            IconButton(icon: const Icon(Icons.mic), onPressed: () {}),
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
