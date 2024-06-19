import 'package:flutter/material.dart';

class HelperMethods {
  static bool isAudioFile(String extension) {
    final audioExtensions = ['mp3', 'wav', 'm4a', 'flac', 'aac', 'ogg'];
    return audioExtensions.contains(extension.toLowerCase());
  }

  static void showSnackbar(BuildContext context,
      {required String message}) async {
    final snackBar = SnackBar(content: Text(message));

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
