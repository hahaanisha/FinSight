import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:local_auth/local_auth.dart';

import '../Pages/BottomNavBar.dart';
import '../Pages/Colors.dart';

class HomeAuthPage extends StatefulWidget {
  const HomeAuthPage({super.key});

  @override
  State<HomeAuthPage> createState() => _HomeAuthPage();
}

class _HomeAuthPage extends State<HomeAuthPage> {
  final LocalAuthentication _auth = LocalAuthentication();
  final FlutterTts _flutterTts = FlutterTts();

  bool _isAuthenticated = false;

  Future<void> _initspeech() async {
    await _flutterTts.speak(
        'Tap on the bottom part of your screen to proceed for Fingerprint login');
  }

  @override
  void initState() {
    super.initState();
    _initspeech();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent background
        elevation: 0, // Remove shadow
        centerTitle: true,
        title: const Text(
          "    Login\n⠠⠇⠕⠛⠊⠝",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Black text
          ),
        ),
      ),
      body: _buildUI(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _authButton(),
    );
  }

  Widget _authButton() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      height: MediaQuery.of(context).size.height * 0.3,
      decoration: BoxDecoration(
        color: Colors.white, // Changed to white
        borderRadius: BorderRadius.circular(10.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: FloatingActionButton(
        backgroundColor: Colors.white, // Matches the container color
        elevation: 0, // Removed elevation for seamless integration
        onPressed: () async {
          if (!_isAuthenticated) {
            final bool canAuthenticateWithBiometrics =
            await _auth.canCheckBiometrics;
            if (canAuthenticateWithBiometrics) {
              try {
                final bool didAuthenticate = await _auth.authenticate(
                  localizedReason: 'Please authenticate to access the app',
                  options: const AuthenticationOptions(
                    biometricOnly: false,
                  ),
                );
                if (didAuthenticate) {
                  setState(() {
                    _isAuthenticated = true;
                  });

                  // Navigate to HomePage
                  if (_isAuthenticated) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => BottomNavBarPage()),
                    );
                  }
                }
              } catch (e) {
                print(e);
              }
            }
          } else {
            setState(() {
              _isAuthenticated = false;
            });
          }
        },
        child: Icon(
          _isAuthenticated ? Icons.lock_open : Icons.lock,
          color: appBlue,
          size: 30,
        ),
      ),
    );
  }

  Widget _buildUI() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.fingerprint, // Fingerprint logo
            size: 100,
            color: Colors.blueAccent,
          ),
          const SizedBox(height: 20),
          const Text(
            "Tap below for Fingerprint Login", // Text below the logo
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}
