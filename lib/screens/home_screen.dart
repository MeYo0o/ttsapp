// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_speech/google_speech.dart';
import 'package:ttsapp/consts/consts.dart';
import 'package:ttsapp/helpers/helper_methods.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Load your service account credentials for Google Cloud services [Text-To-Speech]
  /// please refer to the following link : https://pub.dev/packages/google_speech

  late ServiceAccount serviceAccount;
  late SpeechToText speechToText;
  dynamic responseValue = '';
  bool _isLoading = false;
  void _changeIsLoadingState(bool newValue) =>
      setState(() => _isLoading = newValue);

  @override
  void initState() {
    super.initState();
    initConfiguration();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Text To Speech'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              //

              if (responseValue is! String &&
                  (responseValue as List).isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //
                    const Text(
                      'Transcript:',
                      textAlign: TextAlign.start,
                    ),

                    const SizedBox(height: 20),

                    ...(responseValue as List).map(
                      (e) => Text(
                        e.alternatives.first.transcript.toString(),
                      ),
                    )
                  ],
                ),

              const SizedBox(height: 20),

              ElevatedButton(
                onPressed: _selectAudioFile,
                child: _isLoading
                    ? const CircularProgressIndicator.adaptive()
                    : const Text('Upload File'),
              ),

              const SizedBox(height: 70),
            ],
          ),
        ),
      ),
    );
  }

  // ------------- Google Text To Speech Config --------------
  Future<void> initConfiguration() async {
    serviceAccount = ServiceAccount.fromString(
        (await rootBundle.loadString(Constants.ttsSecretKey)).toString());

    speechToText = SpeechToText.viaServiceAccount(serviceAccount);
  }

  void _sendApiRequest({required List<int> audio}) async {
    final config = RecognitionConfig(
      encoding: AudioEncoding.MP3,
      model: RecognitionModel.basic,
      enableAutomaticPunctuation: true,
      sampleRateHertz: 16000,
      languageCode: 'en-US',
    );

    try {
      // reset the response value so the old transcript can be removed
      responseValue = '';

      _changeIsLoadingState(true);

      //* Speech To Text Response
      final response = await speechToText.recognize(config, audio);

      responseValue = response.results;
    } catch (err) {
      _changeIsLoadingState(false);

      HelperMethods.showSnackbar(context, message: err.toString());
    } finally {
      _changeIsLoadingState(false);
    }
  }

// ------------ File Picker Config --------------
  void _selectAudioFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);

      // log(file.path.toString());

      // if (HelperMethods.isAudioFile(file.path.toLowerCase())) {
      //* Send Api Request
      final audio = File(file.path).readAsBytesSync().toList();
      _sendApiRequest(audio: audio);
      // } else {
      //   HelperMethods.showSnackbar(context, message: 'Not an audio file!');
      // }
    }
  }
}
