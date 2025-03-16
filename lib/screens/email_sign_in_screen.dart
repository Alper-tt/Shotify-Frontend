import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart';
import 'package:provider/provider.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:shotify_frontend/services/backend_auth_service.dart';

import '../services/auth_service.dart';

enum formStatus { signIn, register, reset }

class EmailSignInPage extends StatefulWidget {
  const EmailSignInPage({Key? key}) : super(key: key);

  @override
  _EmailSignInPageState createState() => _EmailSignInPageState();
}

class _EmailSignInPageState extends State<EmailSignInPage> {
  formStatus _formStatus = formStatus.signIn;
  final RoundedLoadingButtonController _buttonController =
      RoundedLoadingButtonController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Sign in Email")),
      body: Center(
        child: SingleChildScrollView(
          child:
              _formStatus == formStatus.signIn
                  ? buildSignInForm()
                  : _formStatus == formStatus.register
                  ? buildRegisterForm()
                  : buildResetForm(),
        ),
      ),
    );
  }

  Widget buildSignInForm() {
    final _signInFormKey = GlobalKey<FormState>();
    TextEditingController _emailController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Form(
        key: _signInFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.only(left: 40, right: 20, bottom: 20),
              child: Text(
                "Please Sign in...",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.only(left: 20, right: 30),
              child: TextFormField(
                controller: _emailController,
                validator: (value) {
                  if (!EmailValidator.validate(value!)) {
                    return 'Invalid email address!';
                  } else {
                    null;
                  }
                },
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Email Address...",
                  prefixIcon: Icon(Icons.email_outlined),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.only(left: 20, right: 30),
              child: TextFormField(
                controller: _passwordController,
                validator: ((value) {
                  if (value!.length < 6) {
                    return 'Password must be at least 6 character';
                  } else
                    null;
                }),
                textAlign: TextAlign.center,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password...",
                  prefixIcon: Icon(Icons.lock_outline),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            RoundedLoadingButton(
              failedIcon: Icons.thumb_down,
              successColor: Colors.green,
              successIcon: Icons.thumb_up,
              width: 200,
              curve: Curves.bounceIn,
              elevation: 5,
              loaderStrokeWidth: 1,
              color: Theme.of(context).primaryColor,
              resetAfterDuration: true,
              resetDuration: Duration(seconds: 3),
              controller: _buttonController,
              onPressed: () async {
                if (_signInFormKey.currentState!.validate()) {
                  try {
                    final user = await Provider.of<AuthService>(
                      context,
                      listen: false,
                    ).signInWithEmailAndPassword(
                      _emailController.text,
                      _passwordController.text,
                    );

                    Provider.of<BackendAuthService>(context, listen: false)
                        .syncUserWithBackend(user!);

                    Timer(Duration(seconds: 1), () async {
                      Navigator.pop(context);
                    });
                  } on FirebaseAuthException catch (e) {
                    _showMyDialog(
                      "Something Went Wrong!",
                      '${e.message}',
                      "Try Again",
                    );
                    _buttonController.error();
                  }
                } else {
                  Timer(Duration(seconds: 1), () {
                    _buttonController.error();
                  });
                }
              },
              child: Text("Login"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _formStatus = formStatus.register;
                });
              },
              child: Text(
                "Didn't You Sign Up?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _formStatus = formStatus.reset;
                });
              },
              child: Text(
                "You forgot your password?",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildRegisterForm() {
    final _registerFormKey = GlobalKey<FormState>();
    TextEditingController _emailController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();
    TextEditingController _passwordConfirmController = TextEditingController();
    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Form(
        key: _registerFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.only(left: 40, right: 20, bottom: 20),
              child: Text(
                "Please Sign Up...",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.only(left: 20, right: 30),
              child: TextFormField(
                controller: _emailController,
                validator: (value) {
                  if (!EmailValidator.validate(value!)) {
                    return 'Invalid email address!';
                  } else {
                    null;
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Email Address...",
                  prefixIcon: Icon(Icons.email_outlined),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.only(left: 20, right: 30),
              child: TextFormField(
                validator: (value) {
                  if (value!.length < 6) {
                    return 'Password must contain 6 character';
                  } else {
                    null;
                  }
                },
                controller: _passwordController,
                keyboardType: TextInputType.visiblePassword,
                textAlign: TextAlign.center,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password...",
                  prefixIcon: Icon(Icons.lock_outline),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.only(left: 20, right: 30),
              child: TextFormField(
                validator: (value) {
                  if (_passwordController.text != value) {
                    return 'Passwords are not same';
                  } else {
                    null;
                  }
                },
                textAlign: TextAlign.center,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: "Password Again...",
                  prefixIcon: Icon(Icons.check_box_outlined),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(left: 20, top: 30),
              child: RoundedLoadingButton(
                failedIcon: Icons.thumb_down,
                successColor: Colors.green,
                successIcon: Icons.thumb_up,
                width: 200,
                curve: Curves.bounceIn,
                elevation: 5,
                loaderStrokeWidth: 1,
                color: Theme.of(context).primaryColor,
                resetAfterDuration: true,
                resetDuration: Duration(seconds: 3),
                controller: _buttonController,
                onPressed: () async {
                  try {
                    if (_registerFormKey.currentState!.validate()) {
                      final user = await Provider.of<AuthService>(
                        context,
                        listen: false,
                      ).createUserWithEmailAndPassword(
                        _emailController.text,
                        _passwordController.text,
                      );

                      Provider.of<BackendAuthService>(context, listen: false)
                          .syncUserWithBackend(user!);

                      _buttonController.success();

                      setState(() {
                        _formStatus = formStatus.signIn;
                      });
                    } else {
                      Timer(Duration(seconds: 1), () {
                        _buttonController.error();
                      });
                    }
                  } on FirebaseAuthException catch (e) {
                    _showMyDialog(
                      "Something Went Wrong!",
                      '${e.message}',
                      "Try Again",
                    );
                  }
                },
                child: Text("Register"),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(left: 10.0),
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _formStatus = formStatus.signIn;
                  });
                },
                child: Text("Are You Already Registered?"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildResetForm() {
    final _resetFormKey = GlobalKey<FormState>();
    TextEditingController _emailController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.all(30.0),
      child: Form(
        key: _resetFormKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.only(left: 40, right: 20, bottom: 20),
              child: Text(
                "Reset Password...",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 20),
            Container(
              padding: EdgeInsets.only(left: 20, right: 30),
              child: TextFormField(
                controller: _emailController,
                validator: (value) {
                  if (!EmailValidator.validate(value!)) {
                    return 'Invalid email address!';
                  } else {
                    null;
                  }
                },
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: "Email Address...",
                  prefixIcon: Icon(Icons.email_outlined),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(50),
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.only(left: 20, top: 30),
              child: RoundedLoadingButton(
                failedIcon: Icons.thumb_down,
                successColor: Colors.green,
                successIcon: Icons.thumb_up,
                width: 200,
                curve: Curves.bounceIn,
                elevation: 5,
                loaderStrokeWidth: 1,
                color: Theme.of(context).primaryColor,
                resetAfterDuration: true,
                resetDuration: Duration(seconds: 3),
                controller: _buttonController,
                onPressed: () async {
                  if (_resetFormKey.currentState!.validate()) {
                    try {
                      await Provider.of<AuthService>(
                        context,
                        listen: false,
                      ).sendPasswordResetEmail(_emailController.text);

                      _buttonController.success();
                      await _showMyDialog(
                        'Reset Password',
                        'Hi, please check your mail box.\nYou should click the link then reset your password.',
                        'Got it',
                      );
                      Timer(Duration(seconds: 1), () {
                        Navigator.pop(context);
                      });
                    } on FirebaseAuthException catch (e) {
                      _buttonController.error();
                      _showMyDialog(
                        'Something Went Wrong!',
                        '${e.message}',
                        "Try Again",
                      );
                    }
                  } else {
                    Timer(Duration(seconds: 1), () {
                      _buttonController.error();
                    });
                  }
                },
                child: Text("Send"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showMyDialog(
    String title,
    String content,
    String buttonText,
  ) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: SingleChildScrollView(
            child: ListBody(children: <Widget>[Text(content)]),
          ),
          actions: <Widget>[
            ElevatedButton(
              child: Text(buttonText),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
