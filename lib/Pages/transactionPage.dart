import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:permission_handler/permission_handler.dart'; // For runtime permissions
import 'package:easy_upi_payment/easy_upi_payment.dart'; // For UPI payment

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();
  bool _speechEnabled = false;
  String _wordsSpoken = "";
  String _selectedContactName = "";
  String _selectedContactNumber = "";
  String _transactionAmount = "";
  bool _isFetchingContacts = false;

  List<Map<String, String>> _filteredContacts = [];
  Future<void> _speakHello() async {
    await _flutterTts.speak('Hello Welcome to Finsight Transactions.');
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
    if (_wordsSpoken.toLowerCase().contains('transfer money to')) {
      String name = _wordsSpoken.split('to').last.trim();
      await fetchContacts(name);
    } else if (_filteredContacts.isNotEmpty && _selectedContactName.isEmpty) {
      _selectedContactName = _wordsSpoken;
      var selectedContact = _filteredContacts.firstWhere(
            (contact) => contact['name']?.toLowerCase() == _selectedContactName.toLowerCase(),
        orElse: () => {'name': '', 'number': ''},
      );
      _selectedContactNumber = selectedContact['number'] ?? '';
      _flutterTts.speak('How much money would you like to transfer?');
    } else if (_selectedContactName.isNotEmpty && _transactionAmount.isEmpty) {
      _transactionAmount = _wordsSpoken.replaceAll(RegExp(r'\D'), '');
      _flutterTts.speak(
          'You are transferring ₹$_transactionAmount to $_selectedContactName. Please confirm to proceed.');
    } else if (_transactionAmount.isNotEmpty) {
      // Call the sendMoney function here
      await sendMoney();
    }
  }

  Future<void> fetchContacts(String name) async {
    // Request contacts permission
    if (await Permission.contacts.request().isGranted) {
      setState(() {
        _isFetchingContacts = true;
      });

      try {
        Iterable<Contact> contacts = await ContactsService.getContacts(withThumbnails: false);
        _filteredContacts = contacts
            .where((contact) =>
        contact.displayName != null &&
            contact.displayName!.toLowerCase().contains(name.toLowerCase()))
            .map((contact) => {
          'name': contact.displayName!,
          'number': contact.phones?.first.value ?? ''
        })
            .toList();

        if (_filteredContacts.isEmpty) {
          _flutterTts.speak('No contacts found matching $name.');
        } else {
          _flutterTts.speak(
              'I found ${_filteredContacts.length} contacts. Please confirm the name from the list.');
        }
      } catch (e) {
        _flutterTts.speak('An error occurred while fetching contacts.');
      } finally {
        setState(() {
          _isFetchingContacts = false;
        });
      }
    } else {
      _flutterTts.speak('Permission to access contacts was denied.');
    }
  }

  Future<void> sendMoney() async {
    try {
      final res = await EasyUpiPaymentPlatform.instance.startPayment(
        EasyUpiPaymentModel(
          payeeVpa: 'anis191004@okaxis', // Assuming the phone number can act as VPA
          payeeName: 'Anisha',
          amount: double.parse(_transactionAmount),
          description: 'Payment to $_selectedContactName',
        ),
      );
      // TODO: Add your success logic here
      print(res);
      _flutterTts.speak('Transaction completed successfully.');
    } catch (e) {
      print(e);
      _flutterTts.speak('Transaction failed. Please try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: InkWell(
            onTap:  _flutterTts.stop,
            child: const Text('Voice-based Transaction')),
      ),
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
            if (_isFetchingContacts)
              const CircularProgressIndicator()
            else if (_filteredContacts.isNotEmpty && _selectedContactName.isEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: _filteredContacts.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(_filteredContacts[index]['name']!),
                      subtitle: Text(_filteredContacts[index]['number']!),
                      onTap: (){
                        setState(() {
                          _selectedContactName = _filteredContacts[index]['name']!;
                          _selectedContactNumber = _filteredContacts[index]['number']!;
                        });
                        _flutterTts.speak(
                            'How much money would you like to transfer to $_selectedContactName?');
                      },

                    );
                  },
                ),
              )
            else if (_selectedContactName.isNotEmpty && _transactionAmount.isEmpty)
                Text(
                  'Say the amount to transfer to $_selectedContactName',
                  style: const TextStyle(fontSize: 18),
                )
              else if (_transactionAmount.isNotEmpty)
                  InkWell(
                    onTap: (){
                      sendMoney();
                    },
                    child: Text(
                      '₹$_transactionAmount will be transferred to $_selectedContactName ($_selectedContactNumber).',
                      style: const TextStyle(fontSize: 18),
                      textAlign: TextAlign.center,
                    ),
                  ),
            const SizedBox(height: 20),
            if (!_isFetchingContacts)
              Text(
                _speechToText.isListening
                    ? "Listening..."
                    : "Tap the microphone to start talking",
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _speechToText.isListening ? _stopListening : _startListening,
        child: Icon(
          _speechToText.isListening ? Icons.mic : Icons.mic_off,
        ),
      ),
    );
  }
}
