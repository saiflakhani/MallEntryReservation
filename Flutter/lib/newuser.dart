import 'package:flutter/material.dart';
import 'login_widgets/buttonNewUser.dart';
import 'login_widgets/newEmail.dart';
import 'login_widgets/newName.dart';
import 'login_widgets/password.dart';
import 'login_widgets/singup.dart';
import 'login_widgets/textNew.dart';
import 'login_widgets/userOld.dart';
import 'login_widgets/locality.dart';

class NewUser extends StatefulWidget {
  @override
  NewUserState createState() => NewUserState();
}

class NewUserState extends State<NewUser> {
  static var name = TextEditingController();
  static var phone = TextEditingController();
  static var password = TextEditingController();
  static var locality = TextEditingController();

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
                Row(
                  children: <Widget>[
                    SingUp(),
                    TextNew(),
                    SizedBox(width: 20),
                    Image(
                        image: AssetImage('assets/logo.png'),
                        height: 100,
                        width: 100)
                  ],
                ),
                NewNome(),
                NewEmail(),
                PasswordInput(),
                Locality(),
                ButtonNewUser(),
                UserOld(),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
