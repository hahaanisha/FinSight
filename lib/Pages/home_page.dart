import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

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
  String _Modelresponse="";
  bool _isLoadingResponse=false;

  Future<void> talkWithGemini() async{

    final model = GenerativeModel(model: 'gemini-pro', apiKey: apikey);

    final msg = _wordsSpoken+'keep the response to be short of 10-15 lines and keep tone that you are adressing as a sam named financial advisor';

    final content = Content.text(msg);

    final response = await model.generateContent([content]);

    setState(() {
      _Modelresponse = response.text!;
    });
    print('response : ${_Modelresponse}');

  }



  @override
  void initState() {
    super.initState();
    initSpeech();
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
      talkWithGemini();
    });
  }


  void _onSpeechResult(result) {
    setState(() {
      _wordsSpoken = "${result.recognizedWords}";
      _confidenceLevel = result.confidence;

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: Text(
          'Speech Demo',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Speech status display
            Container(
              padding: EdgeInsets.all(16),
              child: Text(
                _speechToText.isListening
                    ? "Listening..."
                    : _speechEnabled
                    ? "Tap the microphone to start listening..."
                    : "Speech not available",
                style: TextStyle(fontSize: 20.0),
              ),
            ),
            // Display words spoken
            Expanded(
              child: Container(
                padding: EdgeInsets.all(16),
                child: Text(
                  _wordsSpoken,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // Confidence level display
            if (!_speechToText.isListening && _confidenceLevel > 0)
                InkWell(
                  onTap: (){
                    talkWithGemini();
                  },
                  child: Text(
                      "Done: ${(_confidenceLevel * 100).toStringAsFixed(1)}%",
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w200,
                      ),
                    ),
                ),



            // Display model response or loading indicator
            if (_isLoadingResponse)
              Padding(
                padding: const EdgeInsets.all(6.0),
                child: CircularProgressIndicator(),
              )
            else if (_Modelresponse.isNotEmpty)
              SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(6.0),
                  child: InkWell(
                    onTap: (){
                      _flutterTts.speak(_Modelresponse);
                    },
                    child: Text(
                      "Response: $_Modelresponse",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),


          ],
        ),
      ),
      // Floating action button for starting/stopping speech recognition
      floatingActionButton: FloatingActionButton(
        onPressed: _speechToText.isListening ? _stopListening : _startListening,
        tooltip: 'Listen',
        child: _isLoadingResponse
            ? CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        )
            : Icon(
          _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
          color: Colors.white,
        ),
        backgroundColor: Colors.red,
      ),
    );
  }
}