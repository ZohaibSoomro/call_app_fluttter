import 'package:call_app_flutter/constants.dart';
import 'package:call_app_flutter/utilities/audio_utils.dart';
import 'package:call_app_flutter/widgets/chat_home_popup_menu_item.dart';
import 'package:call_app_flutter/widgets/confirmation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji_gif_picker/flutter_emoji_gif_picker.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

import 'message_list_page.dart';

class ChatHomePage extends StatefulWidget {
  ChatHomePage({Key? key}) : super(key: key);
  static const id = "/chatHomePage";

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage>
    with SingleTickerProviderStateMixin {
  final node = FocusNode();

  final emojiController = TextEditingController();

  final textController = TextEditingController();

  bool showEmojiKeyboard = false;

  AnimationController? _animationController;
  Animation<double>? _animation;
  bool isRecoding = false;
  double radiusValue = 15;

  @override
  void initState() {
    super.initState();
    AudioUtils.initAppDirectoryPath();
    node.addListener(() {
      if (node.hasFocus) {
        EmojiGifPickerPanel.close();
        print("msla");
      }
    });
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = Tween<double>(begin: 15, end: 20).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeInOut,
      ),
    );

    _animationController?.addListener(() {
      setState(() {
        radiusValue = _animation!.value;
      });
    });

    _animation!.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController!.reverse();
      } else if (status == AnimationStatus.dismissed) {
        _animationController!.forward();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _animationController?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
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
                  onLongPress: () {
                    showDialog(
                      context: context,
                      builder: (context) => ConfirmationDialog(
                        onConfirm: () {
                          ZIMKit.instance
                              .deleteConversation(con.id, con.type)
                              .then((value) =>
                                  showMyToast("Conversation deleted"));
                        },
                      ),
                    );
                  },
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ZimMessageListPage(conversation: con),
                      ),
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
                return ZimMessageListPage(conversation: conversation);
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
      ),
    );
  }
}
