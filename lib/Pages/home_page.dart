import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import 'Colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SpeechToText _speechToText = SpeechToText();

  final apikey = 'AIzaSyA7LxDBz3bEPP1JkFjfbzdry5UIpu81H-A';

  final FlutterTts _flutterTts = FlutterTts();

  bool _speechEnabled = false;
  String _wordsSpoken = "";
  double _confidenceLevel = 0;
  String _Modelresponse = "";
  bool _isLoadingResponse = false;

  Future<void> talkWithGemini() async {
    final model = GenerativeModel(model: 'gemini-pro', apiKey: apikey);

    final msg = _wordsSpoken; //+
    //     '''
    // You are a friendly financial advisor named Sam, specialized in helping visually impaired users manage their finances. Based on their questions ask followup questions one by one to understand their financial needs better and based on the user's responses, provide concise and personalized financial advice in 50 words without any symbol. Ensure that you dont your tone is supportive and encouraging, and your suggestions are easy to understand. Make sure to confirm the user's answers before proceeding to the next steps.
    // ''';


    final content = Content.text(msg);

    final response = await model.generateContent([content]);

    setState(() {
      _Modelresponse = response.text!;
    });

    _flutterTts.speak(_Modelresponse);
    print('response : ${_Modelresponse}');
  }

  Future<void> _speakHello() async {
    await _flutterTts.speak('Hello Welcome to 24/7 Customer Support. How may I help You.');
  }

  @override
  void initState() {
    super.initState();
    initSpeech();
    _speakHello();
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _confidenceLevel = 0;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {
      print('generating');
      // talkWithGemini();
    });
  }

  void _onSpeechResult(result) {
    setState(() {
      _wordsSpoken = "${result.recognizedWords}";
      _confidenceLevel = result.confidence;
      talkWithGemini();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Display prompt text
            const Text(
              "Tap the microphone to start",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // Microphone button
            GestureDetector(
              onTap: _speechToText.isListening ? _stopListening : _startListening,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: appBlue,
                child: Icon(
                  _speechToText.isListening ? Icons.mic : Icons.mic_off,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Display words spoken or loading indicator
            if (_speechToText.isListening || _wordsSpoken.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _speechToText.isListening ? "Listening..." : _wordsSpoken,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

            // Display model response or loading indicator
            if (_isLoadingResponse)
              const Padding(
                padding: EdgeInsets.all(6.0),
                child: CircularProgressIndicator(),
              )
            else if (_Modelresponse.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: GestureDetector(
                    onTap: () {
                      _flutterTts.stop();
                    },
                    child: Text(
                      "Response: $_Modelresponse",
                      style: const TextStyle(
                        fontSize: 5,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}