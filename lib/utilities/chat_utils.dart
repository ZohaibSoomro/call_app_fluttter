import 'dart:io';

import 'package:call_app_flutter/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

class ChatUtils {
  ChatUtils._();
  static msgBorderRadius(bool isMine) {
    return BorderRadius.only(
        topLeft: const Radius.circular(25),
        topRight: const Radius.circular(25),
        bottomLeft: isMine ? const Radius.circular(30) : Radius.zero,
        bottomRight: !isMine ? const Radius.circular(30) : Radius.zero);
  }

  static Widget timeAgoWidget(DateTime? messageTime) {
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

  ///saves to device and returns the path of file on device
  static Future<String> saveFileToDevice(
      context, String downloadUrl, String fileName) async {
    final response = await http.get(Uri.parse(downloadUrl));
    final appDocumentsDir = await getExternalStorageDirectory();
    final file = File('${appDocumentsDir!.path}/$fileName');

    await file.writeAsBytes(response.bodyBytes);
    if (_isImageFile(file.path)) {
      await ImageGallerySaver.saveFile(file.path);
      viewImage(context, file.path, isFileImage: true);
    }
    return file.path;
  }

  static bool _isImageFile(String filePath) {
    final fileExtension = path.extension(filePath).toLowerCase();
    return imageExtensions.contains(fileExtension);
  }

  static const List<String> imageExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.gif',
  ];

  static viewImage(context, String url, {bool isFileImage = false}) {
    return showDialog(
      context: context,
      builder: (context) => Stack(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            margin: EdgeInsets.symmetric(
                horizontal: 20,
                vertical: MediaQuery.of(context).size.height * 0.2),
            color: Colors.transparent,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: FadeInImage(
                fit: BoxFit.cover,
                placeholder: const NetworkImage(kLoadingImage),
                alignment: Alignment.center,
                placeholderFit: BoxFit.cover,
                image: (isFileImage
                    ? FileImage(File(url))
                    : NetworkImage(url) as ImageProvider),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.2,
            right: 20,
            child: Card(
              elevation: 3,
              shape: const RoundedRectangleBorder(
                  side: BorderSide(color: Colors.red)),
              color: Colors.white,
              child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close, color: Colors.red),
              ),
            ),
          )
        ],
      ),
    );
  }

  static Widget zegoCallInvitationButton(Size s, List<ZegoUIKitUser> invitees,
          {bool isVideoCall = false}) =>
      Container(
        color: Colors.blue,
        width: s.width * 0.15,
        height: s.height * 0.1,
        child: ZegoSendCallInvitationButton(
          isVideoCall: isVideoCall,
          buttonSize: Size(s.width * 0.09, s.height * 0.06),
          iconSize: Size(s.width * 0.09, s.height * 0.06),
          icon: ButtonIcon(
            icon: Icon(
              isVideoCall ? Icons.videocam : Icons.call,
              color: Colors.white,
            ),
          ),
          resourceID: "zogo_uikit_call",
          invitees: invitees,
        ),
      );
}
