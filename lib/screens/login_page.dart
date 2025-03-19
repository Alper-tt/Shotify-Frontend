import 'dart:async';

import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../components/my_button.dart';
import '../components/my_text_field.dart';
import '../components/square_tile.dart';
import '../services/auth_service.dart';
import '../services/backend_auth_service.dart';

enum formStatus { signIn, register, reset }

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  Future<void> _signInAnonymously() async {
    final user =
    await Provider.of<AuthService>(
      context,
      listen: false,
    ).signInAnonymously();

    Provider.of<BackendAuthService>(
      context,
      listen: false,
    ).syncUserWithBackend(user!);
  }

  Future<void> _signInWithGoogle() async {
    try {
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
    }
  }

  formStatus _formStatus = formStatus.signIn;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
    return SafeArea(
        child: Center(
          child: Form(
            key: _signInFormKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 50),

                const Icon(
                  Icons.lock,
                  size: 100,
                ),

                const SizedBox(height: 50),

                Text(
                  'Welcome back you\'ve been missed!',
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                MyTextField(
                  inputType: TextInputType.emailAddress,
                  controller: _emailController,
                  hintText: 'Email',
                  obscureText: false,
                  validator: (value) {
                    if (!EmailValidator.validate(value!)) {
                      return 'Invalid email address!';
                    } else {
                      null;
                    }
                  },
                ),

                const SizedBox(height: 10),

                // password textfield
                MyTextField(
                  inputType: TextInputType.visiblePassword,
                  controller: _passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  validator: ((value) {
                    if (value!.length < 6) {
                      return 'Password must be at least 6 character';
                    } else
                      null;
                  }),
                ),

                const SizedBox(height: 10),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        child: Text('Forgot Password?',
                          style: TextStyle(
                          ),),
                        onPressed: () {
                          setState(() {
                            _formStatus = formStatus.reset;
                          });
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                // sign in button
                MyButton(
                  text: "Sign In",
                  onTap: () async {
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

                      } on FirebaseAuthException catch (e) {
                        _showMyDialog(
                          "Something Went Wrong!",
                          '${e.message}',
                          "Try Again",
                        );
                      }
                    } else {
                      _showMyDialog(
                        "Something Went Wrong!",
                        "",
                        "Try Again"
                      );
                    }
                  },
                ),
                const SizedBox(height: 50),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          'Or continue with',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    SquareTile(imagePath: 'assets/images/google.png'),

                    SizedBox(width: 25),

                    // apple button
                    SquareTile(imagePath: 'assets/images/apple.png')
                  ],
                ),

                const SizedBox(height: 50),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Not a member?',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    const SizedBox(width: 4),
                    TextButton(
                      child: Text('Register Now',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue
                        ),),
                      onPressed: () {
                        setState(() {
                          _formStatus = formStatus.register;
                        });
                      },
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
    );
  }

  Widget buildRegisterForm() {
    final _registerFormKey = GlobalKey<FormState>();
    TextEditingController _emailController = TextEditingController();
    TextEditingController _passwordController = TextEditingController();
    TextEditingController _passwordConfirmController = TextEditingController();

    return SafeArea(
      child: Center(
        child: Form(
          key: _registerFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),

              const Icon(
                Icons.lock,
                size: 100,
              ),

              const SizedBox(height: 50),

              Text(
                'Hi, Welcome to Shotify!',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25),

              MyTextField(
                inputType: TextInputType.emailAddress,
                controller: _emailController,
                hintText: 'Email',
                obscureText: false,
                validator: (value) {
                  if (!EmailValidator.validate(value!)) {
                    return 'Invalid email address!';
                  } else {
                    null;
                  }
                },
              ),

              const SizedBox(height: 10),

              MyTextField(
                inputType: TextInputType.visiblePassword,
                controller: _passwordController,
                hintText: 'Password',
                obscureText: true,
                validator: ((value) {
                  if (value!.length < 6) {
                    return 'Password must be at least 6 character';
                  } else
                    null;
                }),
              ),

              const SizedBox(height: 10),

              MyTextField(
                inputType: TextInputType.visiblePassword,
                controller: _passwordConfirmController,
                hintText: 'Confirm Password',
                obscureText: true,
                validator: ((value) {
                  if (_passwordController.text != value) {
                    return 'Passwords are not same';
                  } else
                    null;
                }),
              ),

              const SizedBox(height: 25),

              // sign in button
              MyButton(
                text: "Sign Up",
                onTap: () async {
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

                      setState(() {
                        _formStatus = formStatus.signIn;
                      });
                    } else {
                    }
                  } on FirebaseAuthException catch (e) {
                    _showMyDialog(
                      "Something Went Wrong!",
                      '${e.message}',
                      "Try Again",
                    );
                  }
                },
              ),
              const SizedBox(height: 50),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'Or continue with',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color: Colors.grey[400],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 50),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  SquareTile(imagePath: 'assets/images/google.png'),

                  SizedBox(width: 25),

                  // apple button
                  SquareTile(imagePath: 'assets/images/apple.png')
                ],
              ),

              const SizedBox(height: 50),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already Have An Account?',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    child: Text('Sign In',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                      color: Colors.blue
                    ),),
                    onPressed: () {
                      setState(() {
                        _formStatus = formStatus.signIn;
                      });
                    },
                    ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget buildResetForm() {
    final _resetFormKey = GlobalKey<FormState>();
    TextEditingController _emailController = TextEditingController();

    return SafeArea(
      child: Center(
        child: Form(
          key: _resetFormKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 50),

              const Icon(
                Icons.lock,
                size: 100,
              ),

              const SizedBox(height: 50),

              Text(
                "Let's, reset your password!",
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25),

              MyTextField(
                inputType: TextInputType.emailAddress,
                controller: _emailController,
                hintText: 'Email',
                obscureText: false,
                validator: (value) {
                  if (!EmailValidator.validate(value!)) {
                    return 'Invalid email address!';
                  } else {
                    null;
                  }
                },
              ),

              const SizedBox(height: 10),

              // sign in button
              MyButton(
                text: "Reset Password",
                onTap: () async {
                  if (_resetFormKey.currentState!.validate()) {
                    try {
                      await Provider.of<AuthService>(
                        context,
                        listen: false,
                      ).sendPasswordResetEmail(_emailController.text);

                      await _showMyDialog(
                        'Reset Password',
                        'Hi, please check your mail box.\nYou should click the link then reset your password.',
                        'Got it',
                      );
                    } on FirebaseAuthException catch (e) {
                      _showMyDialog(
                        'Something Went Wrong!',
                        '${e.message}',
                        "Try Again",
                      );
                    }
                  } else {
                  }
                },
              ),
              const SizedBox(height: 50),
            ],
          ),
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
