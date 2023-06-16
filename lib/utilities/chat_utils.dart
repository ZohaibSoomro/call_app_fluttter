import 'dart:io';

import 'package:call_app_flutter/constants.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

class ChatUtils {
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
}
