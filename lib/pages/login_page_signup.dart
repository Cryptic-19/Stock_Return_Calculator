import 'dart:ui';

import 'package:get_stonkd/pages/auth_page.dart';
import 'package:flutter/material.dart';
import 'package:get_stonkd/components/my_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_stonkd/components/my_button.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final passwordController = TextEditingController();

  bool showLoginPage = true;

  void onTap() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  void signUserUp() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      if (passwordController.text == confirmPasswordController.text) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AuthPage()),
        );
      } else {
        Navigator.pop(context);
        showErrorMsg("Passwords are not matching!");
      }
    } on FirebaseAuthException catch (e) {
      // pop the loading circle
      Navigator.pop(context);

      showErrorMsg(e.code);
    }
  }

  void showErrorMsg(String message) {
    final snackBar = SnackBar(
      content: Text(message),
      action: SnackBarAction(
          label: 'Close',
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          }),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void signUserIn() async {
    // show loading circle
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      // pop the loading circle
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const AuthPage()),
      );
    } on FirebaseAuthException catch (e) {
      // pop the loading circle
      Navigator.pop(context);

      showErrorMsg(e.code);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      double displayW = MediaQuery.of(context).size.width;
      double displayH = MediaQuery.of(context).size.height;
      return Scaffold(
          body: Stack(children: <Widget>[
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/background2.jpeg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SafeArea(
            child: Center(
                child: SingleChildScrollView(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Column(children: [
              Icon(Icons.account_circle_outlined,
                  size: 0.0005 * displayH * displayW),
              SizedBox(height: .014 * displayH),
              Text(
                'Welcome Back!',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 0.04 * displayH,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Time to get stonk\'d again!',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 0.02 * displayH,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: .035 * displayH),
              MyTextField(
                controller: emailController,
                hintText: 'email',
                obscureText: false,
              ),
              SizedBox(height: .014 * displayH),
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
              SizedBox(height: .014 * displayH),
              MyButton(
                  fnc: signUserIn,
                  num: const Text('Sign In'),
                  bgcolor: Colors.black87,
                  fgcolor: Colors.white,
                  wd: 0.90),

              SizedBox(height: .07 * displayH),

              // not a member? register now
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  'Not a member?',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 0.04 * displayW,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: .0056 * displayW),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    'Register now.',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 0.04 * displayW,
                    ),
                  ),
                ),
              ]),
            ]),
          ),
        )))
      ]));
    } else {
      double displayW = MediaQuery.of(context).size.width;
      double displayH = MediaQuery.of(context).size.height;
      return Scaffold(
          body: Stack(children: <Widget>[
        Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/background2.jpeg"),
              fit: BoxFit.cover,
            ),
          ),
        ),
        SafeArea(
            child: Center(
                child: SingleChildScrollView(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: Column(children: [
              Icon(Icons.account_circle_outlined,
                  size: 0.0005 * displayH * displayW),
              SizedBox(height: .014 * displayH),
              Text(
                'Create An Account',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 0.04 * displayH,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Join us to find out if your stonks reached new heights! (or depths..)',
                style: TextStyle(
                  color: Colors.black87,
                  fontSize: 0.02 * displayH,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: .035 * displayH),
              MyTextField(
                controller: emailController,
                hintText: 'email',
                obscureText: false,
              ),
              SizedBox(height: .014 * displayH),
              MyTextField(
                controller: passwordController,
                hintText: 'Password',
                obscureText: true,
              ),
              SizedBox(height: .014 * displayH),
              MyTextField(
                controller: confirmPasswordController,
                hintText: 'Confirm Password',
                obscureText: true,
              ),
              SizedBox(height: .014 * displayH),
              MyButton(
                  fnc: signUserUp,
                  num: const Text('Sign Up'),
                  bgcolor: Colors.black87,
                  fgcolor: Colors.white,
                  wd: 0.90),
              SizedBox(height: .07 * displayH),

              // not a member? register now
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text(
                  'Already have an account?',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 0.04 * displayW,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: .0056 * displayW),
                GestureDetector(
                  onTap: onTap,
                  child: Text(
                    'Login here.',
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontSize: 0.04 * displayW,
                    ),
                  ),
                ),
              ]),
            ]),
          ),
        )))
      ]));
    }
  }
}
