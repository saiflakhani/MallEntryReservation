import 'package:flutter/material.dart';
import '../login.dart';

class InputEmail extends StatefulWidget {
  @override
  _InputEmailState createState() => _InputEmailState();
}

class _InputEmailState extends State<InputEmail> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 50, left: 50, right: 50),
      child: Container(
        height: 60,
        width: MediaQuery.of(context).size.width,
        
        child: TextField(
          controller: LoginPageState.phone,
          style: TextStyle(
            color: Colors.white,
          ),
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            border: InputBorder.none,
            fillColor: Colors.lightBlueAccent,
            labelText: 'Phone (10 Digit)',
            labelStyle: TextStyle(
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}