import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:http/http.dart' as http;

import 'Colors.dart';

class TestModel extends StatefulWidget {
  const TestModel({super.key});

  @override
  State<TestModel> createState() => _TestModelState();
}

class _TestModelState extends State<TestModel> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  bool _speechEnabled = false;
  String _wordsSpoken = "";
  double _confidenceLevel = 0;
  String _Modelresponse = "";
  bool _isLoadingResponse = false;

  // Replace this with your actual API key
  final String apiKey = 'AIzaSyA7LxDBz3bEPP1JkFjfbzdry5UIpu81H-A';
  final String endpoint =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent';

  Future<void> talkWithGemini() async {
    setState(() {
      _isLoadingResponse = true;
    });

    // Construct the request payload
    final requestPayload = {
      'contents': [
        {
          'parts': [
            {
              'text': _wordsSpoken + ' give me in 50 words',
            }
          ]
        }
      ]
    };

    try {
      // Make a POST request to your custom Gemini model's API
      final response = await http.post(
        Uri.parse(endpoint + '?key=' + apiKey),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestPayload),
      );

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        // Check if the response contains candidates and parts
        if (responseBody['candidates'] != null && responseBody['candidates'].isNotEmpty) {
          final candidate = responseBody['candidates'][0];
          if (candidate['content'] != null && candidate['content']['parts'] != null && candidate['content']['parts'].isNotEmpty) {
            setState(() {
              _Modelresponse = candidate['content']['parts'][0]['text'] ?? 'No response text';
              _isLoadingResponse = false;
            });
            _flutterTts.speak(_Modelresponse);  // Read out the response
            print('Model response: $_Modelresponse');
          } else {
            setState(() {
              _Modelresponse = 'Error: No valid parts in response';
              _isLoadingResponse = false;
            });
          }
        } else {
          setState(() {
            _Modelresponse = 'Error: No candidates in response';
            _isLoadingResponse = false;
          });
        }
      } else {
        setState(() {
          _isLoadingResponse = false;
          _Modelresponse = 'Error: ${response.statusCode} - ${response.body}';
        });
      }
    } catch (e) {
      setState(() {
        _isLoadingResponse = false;
        _Modelresponse = 'Error: $e';
      });
    }
  }

  Future<void> _speakHello() async {
    await _flutterTts.speak('Hello Welcome to your 24/7 Financial Advisor, Swipe left to access Customer Service. How may I help You.');
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
    });
  }

  void _onSpeechResult(result) {
    setState(() {
      _wordsSpoken = "${result.recognizedWords}";
      _confidenceLevel = result.confidence;
      talkWithGemini();  // Send words spoken to Gemini API
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
            InkWell(
              onTap: () {
                talkWithGemini();
              },
              child: const Text(
                "Tap the microphone to start",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w400,
                ),
                textAlign: TextAlign.center,
              ),
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
                        fontSize: 18,
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
