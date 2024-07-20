import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get_stonkd/pages/home.dart';
import 'package:get_stonkd/pages/login_page_signup.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          // user is logged in
          if (snapshot.hasData) {
            return Home();
          }

          // user is NOT logged in
          else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}
