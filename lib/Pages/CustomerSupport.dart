import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart'; // For runtime permissions
import 'package:easy_upi_payment/easy_upi_payment.dart';
import 'package:testvjti/Pages/BottomNavBar.dart';
import 'Colors.dart'; // For UPI payment
import 'package:testvjti/Pages/BottomNavBar.dart'; // For UPI payment

class CustomerSupport extends StatefulWidget {
  const CustomerSupport({super.key});

  @override
  State<CustomerSupport> createState() => _CustomerSupportState();
}

class _CustomerSupportState extends State<CustomerSupport> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _speechEnabled = false;
  String _wordsSpoken = "";
  String _Modelresponse = "";
  final apikey = 'AIzaSyA7LxDBz3bEPP1JkFjfbzdry5UIpu81H-A';

  List<Map<String, String>> _filteredContacts = [];
  Future<void> _speakHello() async {
    await _flutterTts.speak('Hello Welcome to Finsight Customer Support, Swipe Right to access Financial Advisor and left to perform Transactions.');
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
    setState(() {});
  }

  void _stopListening() async {
    await _speechToText.stop();
  }

  void _onSpeechResult(result) {
    setState(() {
      _wordsSpoken = result.recognizedWords;
      handleTransactionFlow();
    });
  }

  Future<void> handleTransactionFlow() async {
    if (_wordsSpoken.toLowerCase().contains('what is finsight')) {
      _flutterTts.speak('FINSIGHT is a platform for blind peoples to perform 24 7 transactions, get Financial Advise and customer support');
    } else if (_wordsSpoken.toLowerCase().contains('check my account balance')){
      _flutterTts.speak('You can check your account balance by just swiping right and saying check my bank balance.');
    }else if (_wordsSpoken.toLowerCase().contains('can i pay my bills through this platform')){
      _flutterTts.speak('Yes, you can! Go to the "Bill Payment" section, select the biller, enter the required details, and proceed with the payment.');
    }else if (_wordsSpoken.toLowerCase().contains('are there voice commands available in this app')){
      _flutterTts.speak('Yes, you can navigate and perform actions using voice commands.');
    }else if (_wordsSpoken.toLowerCase().contains('transaction is declined')){
      _flutterTts.speak('Ensure you have sufficient balance and your card is active. If the problem persists, contact customer support mobile number for assistance.');
    }else {
      talkWithGemini();
    }

  }


  Future<void> talkWithGemini() async {
    final model = GenerativeModel(model: 'gemini-pro', apiKey: apikey);

    final msg = _wordsSpoken +'keep 30 words short response as you are a customer support';
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            InkWell(
              onTap: () {
                handleTransactionFlow();
              },
              child: Text(
                "Real-time Speech: $_wordsSpoken",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
      floatingActionButton: InkWell(
        onTap: (){

        },
        child: Container(

          width: MediaQuery.of(context).size.width*0.95,
          height: MediaQuery.of(context).size.height*0.2,

          decoration: BoxDecoration(
            color:appBlue,
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: FloatingActionButton(
            backgroundColor: appBlue,
            onPressed: _speechToText.isListening ? _stopListening : _startListening,
            child: Icon(
              _speechToText.isListening ? Icons.mic : Icons.mic_off,color: Colors.white,size: MediaQuery.of(context).size.height*0.1,
            ),
          ),
        ),
      ),
    );
  }
}