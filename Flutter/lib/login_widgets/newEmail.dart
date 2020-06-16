import 'package:flutter/material.dart';
import '../newuser.dart';

class NewEmail extends StatefulWidget {
  @override
  _NewEmailState createState() => _NewEmailState();
}


class _NewEmailState extends State<NewEmail> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, left: 50, right: 50),
      child: Container(
        height: 20,
        width: MediaQuery.of(context).size.width,
        child: TextField(
          keyboardType: TextInputType.number,
          style: TextStyle(
            color: Colors.white,
          ),
          controller: NewUserState.phone,
          decoration: InputDecoration(
            border: InputBorder.none,
            fillColor: Colors.lightBlueAccent,
            
            labelText: 'Phone number (10 digit)',
            labelStyle: TextStyle(
              color: Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}