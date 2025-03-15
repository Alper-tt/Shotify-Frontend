import 'package:flutter/material.dart';
import 'package:flutter_signin_button/button_list.dart';
import 'package:flutter_signin_button/button_view.dart';

class SignButton extends StatelessWidget {
  final Function onPressed;
  final Buttons buttonType;
  final String? text;
  final bool mini;

  SignButton(
      {required this.onPressed,
      required this.buttonType,
      this.text,
      this.mini = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: 250,
      child: SignInButton(
        buttonType,
        onPressed: onPressed,
        text: text,
        mini: mini,
      ),
    );
  }
}