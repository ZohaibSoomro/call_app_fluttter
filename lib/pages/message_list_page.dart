// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:call_app_flutter/constants.dart';
import 'package:call_app_flutter/utilities/audio_utils.dart';
import 'package:call_app_flutter/utilities/chat_utils.dart';
import 'package:call_app_flutter/utilities/firestorer.dart';
import 'package:call_app_flutter/widgets/voice_message_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_emoji_gif_picker/flutter_emoji_gif_picker.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_zimkit/zego_zimkit.dart';

import '../widgets/confirmation_dialog.dart';

class MessageListPage extends StatefulWidget {
  const MessageListPage(
      {Key? key, required this.conversation, required this.chatHomeContext})
      : super(key: key);
  final BuildContext chatHomeContext;
  final ZIMKitConversation conversation;
  @override
  State<MessageListPage> createState() => _MessageListPageState();
}

class _MessageListPageState extends State<MessageListPage>
    with SingleTickerProviderStateMixin {
  final node = FocusNode();
  final emojiController = TextEditingController();

  final textController = TextEditingController();

  bool showEmojiKeyboard = false;

  AnimationController? _animationController;
  Animation<double>? _animation;
  bool isRecording = false;
  double radiusValue = 16;

  String? audioPath;

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

    _animation = Tween<double>(begin: 16, end: 30).animate(
      CurvedAnimation(
        parent: _animationController!,
        curve: Curves.easeInOut,
      ),
    );

    _animationController?.addListener(() {
      if (!isRecording) {
        _animationController!.stop();
        radiusValue = 16;
      } else {
        radiusValue = _animation!.value;
      }
      if (mounted) {
        setState(() {});
      }
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
  Widget build(BuildContext context) {
    return EmojiGifMenuLayout(
      child: ZIMKitMessageListPage(
        conversationID: widget.conversation.id,
        conversationType: widget.conversation.type,
        editingController: textController,
        inputFocusNode: node,
        messageItemBuilder: (context, message, defaultWidget) {
          bool isMyMessage = message.info.senderUserID ==
              ZIMKit().currentUser()?.baseInfo.userID;
          final file = message.fileContent;

          final rowMainAlignment =
              isMyMessage ? MainAxisAlignment.end : MainAxisAlignment.start;
          final columnCrossAlignment =
              isMyMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start;
          if (message.type == ZIMMessageType.file &&
              (file!.fileName.endsWith(".wav") ||
                  file.fileName.endsWith(".m4a"))) {
            // return VoiceMessageWidget(
            //   filePath: file.fileLocalPath,
            //   downloadUrl: file.fileDownloadUrl,
            //   defaultWidget: defaultWidget,
            //   isMyMessage: isMyMessage,
            //   msgBaseInfo: message.info,
            // );
            return InkWell(
                borderRadius: ChatUtils.msgBorderRadius(message.isMine),
                onLongPress: () {
                  showDialog(
                      context: context,
                      builder: (context) => ConfirmationDialog(
                            onConfirm: () {
                              ZIMKit.instance.deleteMessage([message]).then(
                                  (value) => showMyToast("Msg deleted"));
                            },
                          ));
                },
                child: VoiceMessageItem(message: message));
          }
          if (message.type != ZIMMessageType.text) {
            return defaultWidget;
          }

          return buildTextMessage(
              rowMainAlignment, isMyMessage, columnCrossAlignment, message);
        },
        onMessageItemPressd: onMessagePressed,
        appBarBuilder: (context, appBar) {
          return buildAppBar(context);
        },
        inputDecoration: const InputDecoration(
          hintText: 'Type here...',
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
        ),
        messageInputActions: [
          ZIMKitMessageInputAction.left(
            buildRecordAudioWidget(),
          ),
          ZIMKitMessageInputAction.leftInside(
            buildEmojiWidget(),
          ),
        ],
        messageListErrorBuilder: (c, d) {
          return Center(
            child: Text(
              'Some error occurred!',
              style: TextStyle(color: Colors.grey.shade400),
            ),
          );
        },
        messageListLoadingBuilder: (c, d) {
          return kSpinner;
        },
      ),
    );
  }

  Padding buildTextMessage(MainAxisAlignment rowMainAlignment, bool isMyMessage,
      CrossAxisAlignment columnCrossAlignment, ZIMKitMessage message) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: rowMainAlignment,
        children: [
          if (!isMyMessage)
            CircleAvatar(
              backgroundImage: NetworkImage(
                  widget.conversation.avatarUrl.isNotEmpty
                      ? widget.conversation.avatarUrl
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
                    bottomLeft:
                        isMyMessage ? const Radius.circular(20) : Radius.zero,
                    bottomRight:
                        !isMyMessage ? const Radius.circular(20) : Radius.zero,
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
                            color: isMyMessage ? Colors.white : Colors.black,
                            fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 5),
              ChatUtils.timeAgoWidget(
                DateTime.fromMillisecondsSinceEpoch(message.info.timestamp),
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
  }

  AppBar buildAppBar(BuildContext context) {
    return AppBar(
      title: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
                widget.conversation.avatarUrl.isNotEmpty
                    ? widget.conversation.avatarUrl
                    : kDummyImage),
          ),
          const SizedBox(width: 10),
          Text(widget.conversation.name),
        ],
      ),
      actions: [
        if (widget.conversation.type == ZIMConversationType.peer)
          ChatUtils.zegoCallInvitationButton(
            MediaQuery.of(context).size,
            [
              ZegoUIKitUser(
                id: widget.conversation.id,
                name: widget.conversation.name,
              ),
            ],
          ),
        if (widget.conversation.type == ZIMConversationType.peer)
          ChatUtils.zegoCallInvitationButton(
            MediaQuery.of(context).size,
            [
              ZegoUIKitUser(
                id: widget.conversation.id,
                name: widget.conversation.name,
              ),
            ],
            isVideoCall: true,
          ),
      ],
    );
  }

  GestureDetector buildEmojiWidget() {
    return GestureDetector(
      onTap: () {
        if (EmojiGifPickerPanel.isOpened) {
          node.unfocus();
        } else {
          node.requestFocus();
        }
      },
      child: EmojiGifPickerIcon(
        id: "1",
        onGifSelected: null,
        fromStack: false,
        keyboardIcon: const Icon(Icons.sentiment_satisfied_alt_outlined,
            color: Colors.blue),
        viewGif: false,
        controller: textController,
        icon: const Icon(
          Icons.sentiment_satisfied_alt_outlined,
          color: Colors.black,
        ),
      ),
    );
  }

  AnimatedBuilder buildRecordAudioWidget() {
    return AnimatedBuilder(
      animation: _animationController!,
      builder: (context, child) {
        return CircleAvatar(
          radius: 30,
          backgroundColor: Colors.transparent,
          child: CircleAvatar(
            backgroundColor: isRecording ? Colors.red : Colors.transparent,
            radius: radiusValue,
            child: CircleAvatar(
              backgroundColor: Colors.white38,
              radius: radiusValue - 1,
              child: CircleAvatar(
                radius: 15,
                backgroundColor: Colors.red.withOpacity(isRecording ? 0.1 : 0),
                child: Center(
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.mic,
                      color: isRecording ? Colors.white : Colors.black,
                    ),
                    onPressed: startRecording,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void startRecording() async {
    final status = await AudioUtils.isRecording();
    if (!status) {
      isRecording = true;
      _animationController!.forward();
      AudioUtils.recordAudio(
          "${widget.conversation.name}-${DateTime.now().millisecondsSinceEpoch.hashCode}");
    } else {
      audioPath = await AudioUtils.stopRecording();
      showMyToast("audio file saved at $audioPath");
      final file = File(audioPath!);
      // PlatformFile platformFile = PlatformFile(
      //   name: file.path.split('/').last,
      //   path: file.absolute.path,
      //   size: file.lengthSync(),
      //   bytes: file.readAsBytesSync(),
      // );
      print("audio file saved at $audioPath");
      // await ZIMKit.instance.sendFileMessage(
      //   widget.conversation.id,
      //   widget.conversation.type,
      //   [platformFile],
      // );
      _animationController!.reset();
      isRecording = false;
      if (mounted) {
        setState(() {});
      }
      await ZIMKitCore.instance.sendMediaMessage(
        widget.conversation.id,
        widget.conversation.type,
        file.path,
        ZIMMessageType.file,
        onMessageSent: (msg) async {
          await Firestorer.instance.storeVoiceInfo(context,
              msg.fileContent!.fileLocalPath, msg.fileContent!.fileDownloadUrl);
          if (mounted) {
            setState(() {});
          }
          Navigator.pop(context);
          Navigator.push(
              widget.chatHomeContext,
              MaterialPageRoute(
                  builder: (context) => MessageListPage(
                        conversation: widget.conversation,
                        chatHomeContext: widget.chatHomeContext,
                      )));
        },
      );
    }
    if (mounted) {
      setState(() {});
    }
  }

  void onMessagePressed(c, message, defaultAction) {
    switch (message.type) {
      case ZIMMessageType.text:
        // showMyToast(message.textContent!.text);
        break;
      case ZIMMessageType.image:
        ChatUtils.viewImage(context, message.imageContent!.fileDownloadUrl);
        break;
      case ZIMMessageType.video:
        break;
      case ZIMMessageType.file:
        if (message.fileContent!.fileName.endsWith(".m4a") ||
            message.fileContent!.fileName.endsWith(".wav")) {
          //TODO just play audio
        } else {
          ChatUtils.saveFileToDevice(
                  context,
                  message.fileContent!.fileDownloadUrl,
                  message.fileContent!.fileName)
              .then((value) => showMyToast("file saved at $value"));
        }
        break;
      default:
        showMyToast("file type not mentioned");
        break;
    }
    defaultAction();
  }
}

// final future = AudioUtils.controllerForAudioFile(
//               file.fileLocalPath,
//             );
//             PlayerState playerState = PlayerState.initialized;
//             return FutureBuilder(
//                 future: future,
//                 builder: (context, snap) {
//                   if (!snap.hasData) return defaultWidget;
//                   snap.data!.onPlayerStateChanged.listen((state) {
//                     setState(() {
//                       playerState = state;
//                     });
//                   });
//                   snap.data!.onCompletion.listen((_) async {
//                     snap.data!.seekTo(0);
//                     await snap.data!.preparePlayer(path: file.fileLocalPath);
//                     setState(() {});
//                   });
//                   return Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: Stack(
//                       fit: StackFit.loose,
//                       children: [
//                         AudioFileWaveforms(
//                           size: Size(MediaQuery.of(context).size.width,
//                               MediaQuery.of(context).size.height * 0.1),
//                           playerController: snap.data!,
//                           continuousWaveform: true,
//                           enableSeekGesture: true,
//                           backgroundColor: Colors.blue,
//                           waveformType: WaveformType.long,
//                           waveformData: waveForms ?? [],
//                           playerWaveStyle: const PlayerWaveStyle(
//                             fixedWaveColor: Colors.red,
//                             liveWaveColor: Colors.blueAccent,
//                             spacing: 6,
//                             backgroundColor: Colors.lightBlue,
//                             seekLineColor: Colors.red,
//                             scaleFactor: 400,
//                             waveThickness: 2.2,
//                           ),
//                         ),
//                         Positioned(
//                           right: MediaQuery.of(context).size.width * 0.39,
//                           bottom: 2,
//                           child: IconButton(
//                             onPressed: () async {
//                               if (playerState == PlayerState.playing) {
//                                 await snap.data!
//                                     .pausePlayer(); // Pause audio player
//                               } else {
//                                 snap.data!.stopAllPlayers();
//                                 await snap.data!
//                                     .preparePlayer(path: file.fileLocalPath);
//                                 await snap.data!.startPlayer(
//                                     finishMode:
//                                         FinishMode.pause); // Start audio player
//                                 await snap.data!.setVolume(1.0);
//                               }
//                             },
//                             icon: Icon(
//                               playerState == PlayerState.playing
//                                   ? Icons.pause
//                                   : Icons.play_arrow,
//                               color: Colors.red,
//                               size: 50,
//                             ),
//                           ),
//                         )
//                       ],
//                     ),
//                   );
//                 },);
