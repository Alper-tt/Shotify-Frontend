import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_builder.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:provider/provider.dart';

import '../services/auth_service.dart';
import '../services/backend_auth_service.dart';
import '../widgets/sign_button.dart';
import 'email_sign_in_screen.dart';

class SignInPage extends StatefulWidget {
  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  bool _isLoading = false;

  Future<void> _signInAnonymously() async {
    setState(() {
      _isLoading = true;
    });

    final user =
        await Provider.of<AuthService>(
          context,
          listen: false,
        ).signInAnonymously();

    Provider.of<BackendAuthService>(
      context,
      listen: false,
    ).syncUserWithBackend(user!);

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final user =
          await Provider.of<AuthService>(
            context,
            listen: false,
          ).signInWithGoogle();
      Provider.of<BackendAuthService>(
        context,
        listen: false,
      ).syncUserWithBackend(user!);
    } on FirebaseAuthException catch (e) {
      _showMyDialog("Something Went Wrong!", "${e.message}", 'Try Again');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              Provider.of<AuthService>(context, listen: false).signOut();
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Sign In Page", style: TextStyle(fontSize: 25)),
            SizedBox(height: 30),
            SizedBox(
              height: 50,
              width: 250,
              child: SignInButtonBuilder(
                icon: Icons.person,
                backgroundColor:
                    _isLoading ? Colors.teal.withOpacity(0.3) : Colors.teal,
                onPressed: () {
                  if (_isLoading) {
                    null;
                  } else {
                    try {
                      _signInAnonymously();
                    } on FirebaseAuthException catch (e) {
                      _showMyDialog(
                        "Something Went Wrong",
                        '${e.message}',
                        'Try Again',
                      );
                    }
                  }
                },
                text: "Sign in Anonymously",
              ),
            ),
            SizedBox(height: 15),
            SignButton(
              buttonType: Buttons.Email,
              onPressed: () {
                if (_isLoading) {
                  null;
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => EmailSignInPage()),
                  );
                }
              },
            ),
            SizedBox(height: 15),
            SignButton(
              buttonType: Buttons.GoogleDark,
              onPressed: () {
                if (_isLoading) {
                  null;
                } else {
                  _signInWithGoogle();
                }
              },
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
