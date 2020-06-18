import 'package:flutter/material.dart';
import 'login_widgets/button.dart';
import 'login_widgets/first.dart';
import 'login_widgets/forgot.dart';
import 'login_widgets/inputEmail.dart';
import 'login_widgets/password.dart';
import 'login_widgets/textLogin.dart';
import 'login_widgets/verticalText.dart';

class LoginPage extends StatefulWidget {
  @override
  LoginPageState createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  static var phone = TextEditingController();
  static var password = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mall Spot Reservation'),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
              begin: Alignment.topRight,
              end: Alignment.bottomLeft,
              colors: [Colors.blueGrey, Colors.lightBlueAccent]),
        ),
        child: ListView(
          children: <Widget>[
            Column(
              children: <Widget>[
                Row(children: <Widget>[
                  VerticalText(),
                  TextLogin(),
                  SizedBox(width: 20),
                  Image(
                      image: AssetImage('assets/logo.png'),
                      height: 100,
                      width: 100)
                ]),
                InputEmail(),
                Padding(
                  padding: const EdgeInsets.only(top: 20, left: 50, right: 50),
                  child: Container(
                    height: 20,
                    width: MediaQuery.of(context).size.width,
                    child: TextField(
                      style: TextStyle(
                        color: Colors.white,
                      ),
                      obscureText: true,
                      controller: password,
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        labelText: 'Password',
                        labelStyle: TextStyle(
                          color: Colors.white70,
                        ),
                      ),
                    ),
                  ),
                ),
                ButtonLogin(),
                FirstTime(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
