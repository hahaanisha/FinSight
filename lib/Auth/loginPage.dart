import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:local_auth/local_auth.dart';

import '../Pages/BottomNavBar.dart';
import '../Pages/Colors.dart';
import '../Pages/home_page.dart';
 // Import the HomePage

class HomeAuthPage extends StatefulWidget {
  const HomeAuthPage({super.key});

  @override
  State<HomeAuthPage> createState() => _HomeAuthPage();
}

class _HomeAuthPage extends State<HomeAuthPage> {
  final LocalAuthentication _auth = LocalAuthentication();

  bool _isAuthenticated = false;

  final FlutterTts _flutterTts = FlutterTts();


  Future<void> _initspeech() async {
    await _flutterTts.speak('Tap on bottom part of your screen to proceed for Fingerprint login');
  }
  @override
  void initState() {
    super.initState();
    _initspeech();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
      floatingActionButton: _authButton(),
    );
  }

  Widget _authButton() {
    return Container(
      width: MediaQuery.of(context).size.width*0.95,
      height: MediaQuery.of(context).size.height*0.3,

      decoration: BoxDecoration(
        color:appBlue,
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: FloatingActionButton(
        backgroundColor: appBlue,
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
                      MaterialPageRoute(builder: (context) =>BottomNavBarPage()),
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
          _isAuthenticated ? Icons.lock : Icons.lock_open,
        ),
      ),
    );
  }

  Widget _buildUI() {
    return SizedBox(
      width: MediaQuery.sizeOf(context).width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (!_isAuthenticated)
            const Text(
              "Tap on bottom part of your screen to proceed for Fingerprint login",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}
