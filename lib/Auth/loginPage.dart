import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

import '../Pages/BottomNavBar.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildUI(),
      floatingActionButton: _authButton(),
    );
  }

  Widget _authButton() {
    return FloatingActionButton(
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
              "FINSIGHT",
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
