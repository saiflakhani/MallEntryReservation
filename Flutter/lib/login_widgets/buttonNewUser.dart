import 'package:flutter/material.dart';
import 'package:parking_app/podo/person.dart';
import '../newuser.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ButtonNewUser extends StatefulWidget {
  @override
  _ButtonNewUserState createState() => _ButtonNewUserState();
}

class _ButtonNewUserState extends State<ButtonNewUser> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40, right: 50, left: 200),
      child: Container(
        alignment: Alignment.bottomRight,
        height: 50,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
            color: Colors.blue[300],
            blurRadius: 10.0, // has the effect of softening the shadow
            spreadRadius: 1.0, // has the effect of extending the shadow
            offset: Offset(
              5.0, // horizontal, move right 10
              5.0, // vertical, move down 10
            ),
          ),
        ], color: Colors.white, borderRadius: BorderRadius.circular(30)),
        child: FlatButton(
          onPressed: () {
            sendNewUser();
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'OK',
                style: TextStyle(
                  color: Colors.lightBlueAccent,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Icon(
                Icons.arrow_forward,
                color: Colors.lightBlueAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<http.Response> createPerson(Person person) async {
    //print(jsonEncode(reservation));
    return http.put('https://calm-shore-97363.herokuapp.com/persons/add',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(person));
  }

  bool sendNewUser() {
    Person person = new Person(
        person_name: NewUserState.name.text,
        contact: NewUserState.phone.text,
        password: NewUserState.password.text,
        location: NewUserState.locality.text);

    Future<http.Response> response = createPerson(person);
    bool result = false;
    response.then((response) => {
          // print(response)
          // if (json.decode(response.body)['status'] == "success")
          handlePersonAddResponse(
                  response.statusCode, person, json.decode(response.body))
              .then((value) => {if (value) Navigator.of(context).pop()})
        });
    //print("Sending --> "+NewUserState.name.text+" "+NewUserState.phone.text+" "+NewUserState.password.text+" "+NewUserState.locality.text);
  }

  Future<bool> handlePersonAddResponse(
    int statusCode, Person person, dynamic json) async {
    print(json);
    if (statusCode == 401) {
      print("Status 401");
      Scaffold.of(context).showSnackBar(
          SnackBar(content: Text('User exists, but password incorrect')));
    }
    Person gotPerson = Person.fromJson(json);
    print("Got person id --> " + gotPerson.id.toString());
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('personId', gotPerson.id);
    prefs.setString('personName', gotPerson.person_name);
    return true;
  }
}
