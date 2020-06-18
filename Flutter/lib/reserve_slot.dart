import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:parking_app/podo/person.dart';
import 'podo/reservation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReserveSlot extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new ReserveSlotState();
  }
}

class ReserveSlotState extends State<ReserveSlot> {
  String adultsDropdownValue = '1';
  String childrenDropdownValue = '0';
  bool fourWheeler = true;
  bool twoWheeler = false;
  final adultNamesFormKey = GlobalKey<FormState>();
  final childNamesFormKey = GlobalKey<FormState>();
  final vehicleNumberController = TextEditingController();
  final List<TextEditingController> adultNamesController = [
    new TextEditingController(),
    new TextEditingController(),
    new TextEditingController(),
    new TextEditingController()
  ];
  final List<TextEditingController> childNamesContoller = [
    new TextEditingController(),
    new TextEditingController(),
    new TextEditingController(),
    new TextEditingController()
  ];
  Reservation reservation;

  @override
  void initState() {
    super.initState();
  }

  Future<http.Response> createReservation(Reservation reservation) {
    //print(jsonEncode(reservation));
    return http.put('https://calm-shore-97363.herokuapp.com/reservations/add',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(reservation));
  }

  void reserveSlot() {
    checkIfLoggedIn().then((value) => {
          if (value != null)
            {sendAPIRequest(value)}
          else
            {Navigator.of(context).pushNamed('/signup')}
        });
  }

  void sendAPIRequest(Map<String, dynamic> storedPrefs) {
    if (validateForm()) {
      Reservation toSend = new Reservation(
          person_id: storedPrefs['personId'],
          adults: int.parse(adultsDropdownValue),
          children: int.parse(childrenDropdownValue),
          adult_names: addNames(adultNamesController),
          child_names: addNames(childNamesContoller),
          reservation_key: null,
          reservation_date: reservation.reservation_date,
          vehicle_type: fourWheeler ? "Four Wheeler" : "Two Wheeler",
          timeslot: reservation.timeslot,
          vehicle_number: vehicleNumberController.text,
          parking: null,
          review: null,
          review_text: null,
          reservation_date_time: reservation.reservation_date_time,
          person_name: null);
      Future<http.Response> response = createReservation(toSend);
      response.then((response) => {
            if (json.decode(response.body)['status'] == "success")
              {
                _showSuccessDialog(toSend, json.decode(response.body),
                    storedPrefs['personName'])
              }
          });
    }
  }

  bool validateForm() {
    if (adultNamesFormKey.currentState.validate() &&
        childNamesFormKey.currentState.validate()) {
      // If the form is valid, display a snackbar. In the real world,
      // you'd often call a server or save the information in a database.

      return true;
    }
    return false;
  }

  //Utility function for adding names as a comma separated string
  String addNames(List<TextEditingController> controllerArray) {
    String result = "";
    for (TextEditingController controller in controllerArray) {
      result += controller.text + ", ";
    }
    return result;
  }

  // THE UI of the Application
  @override
  Widget build(BuildContext context) {
    this.reservation = ModalRoute.of(context).settings.arguments;
    return Scaffold(
      appBar: AppBar(
        title: Text('Mall Spot Reservation'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[24],
      //resizeToAvoidBottomInset: false,
      body: ListView(
        children: <Widget>[
          Container(
              child: Image(
            width: double.infinity,
            height: 200,
            image: AssetImage('assets/slotbookingimage.png'),
            fit: BoxFit.fill,
          )),
          Container(
            width: double.infinity,
            height: 50.0,
            color: Colors.black,
            child: Center(
              child: Text("Reserve a slot",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold)),
            ),
          ),
          Container(
            //TODO Future here
            color: Colors.black45,
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 20,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.calendar_today,
                            color: Colors.white,
                          ),
                          Text(
                            "\t\t" +
                                DateFormat('EEE')
                                    .format(reservation.reservation_date_time) +
                                "\n\t\t" +
                                DateFormat('dd MMMM')
                                    .format(reservation.reservation_date_time),
                            style: TextStyle(color: Colors.white),
                          ) //TODO FORMAT THIS
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.access_time,
                            color: Colors.white,
                          ),
                          getTimeslotText(),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  color: Colors.white,
                  height: 4,
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                          Text(
                            "Adults",
                            style: TextStyle(color: Colors.white),
                          ),
                        ])),
                    Expanded(
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                          Text(
                            "Children",
                            style: TextStyle(color: Colors.white),
                          ),
                        ])),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.person,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          DropdownButton<String>(
                            value: adultsDropdownValue,
                            icon: Icon(
                              Icons.arrow_downward,
                              color: Colors.white,
                            ),
                            iconSize: 24,
                            dropdownColor: Colors.blueGrey,
                            elevation: 16,
                            style: TextStyle(color: Colors.white),
                            underline: Container(
                              height: 2,
                              color: Colors.white,
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                adultsDropdownValue = newValue;
                              });
                            },
                            items: <String>['0', '1', '2', '3', '4']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                          )
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.child_care,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          DropdownButton<String>(
                            value: childrenDropdownValue,
                            dropdownColor: Colors.blueGrey,
                            icon: Icon(
                              Icons.arrow_downward,
                              color: Colors.white,
                            ),
                            iconSize: 24,
                            elevation: 16,
                            style: TextStyle(color: Colors.white),
                            underline: Container(
                              height: 2,
                              color: Colors.white,
                            ),
                            onChanged: (String newValue) {
                              setState(() {
                                childrenDropdownValue = newValue;
                              });
                            },
                            items: <String>['0', '1', '2', '3', '4']
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(
                                  value,
                                  style: TextStyle(color: Colors.white),
                                ),
                              );
                            }).toList(),
                          )
                        ],
                      ),
                    )
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  color: Colors.white,
                  height: 4,
                ),
                SizedBox(
                  height: 10,
                ),

                //TODO ADD LISTVIEW HERE
                Column(children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Form(
                          key: adultNamesFormKey,
                          child: Container(
                            height: double.parse(adultsDropdownValue) * 50.0,
                            child: ListView.builder(
                                itemCount: int.parse(adultsDropdownValue),
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext ctxt, int index) {
                                  return Container(
                                    padding:
                                        EdgeInsets.only(left: 5.0, right: 5.0),
                                    width: 50.0,
                                    child: Center(
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'Please enter some text';
                                          }
                                          return null;
                                        },
                                        style: TextStyle(color: Colors.white),
                                        textAlign: TextAlign.center,
                                        controller: adultNamesController[index],
                                        decoration: InputDecoration(
                                            prefixIcon: Icon(Icons.person,
                                                color: Colors.white),
                                            // border: InputBorder.none,
                                            // contentPadding: EdgeInsets.all(20.0),
                                            hintText: 'Name of adult ' +
                                                (index + 1).toString(),
                                            hintStyle: TextStyle(
                                              color: Colors.white,
                                            )),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Form(
                          key: childNamesFormKey,
                          child: Container(
                            height: double.parse(childrenDropdownValue) * 50.0,
                            child: ListView.builder(
                                itemCount: int.parse(childrenDropdownValue),
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (BuildContext ctxt, int index) {
                                  return Container(
                                    padding:
                                        EdgeInsets.only(left: 5.0, right: 5.0),
                                    width: 50.0,
                                    child: Center(
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value.isEmpty) {
                                            return 'Please enter some text';
                                          }
                                          return null;
                                        },
                                        style: TextStyle(color: Colors.white),
                                        textAlign: TextAlign.left,
                                        controller: childNamesContoller[index],
                                        decoration: InputDecoration(
                                            // border: InputBorder.none,
                                            // contentPadding: EdgeInsets.all(20.0),
                                            prefixIcon: Icon(Icons.child_care,
                                                color: Colors.white),
                                            hintText: 'Name of child ' +
                                                (index + 1).toString(),
                                            hintStyle: TextStyle(
                                              color: Colors.white,
                                            )),
                                      ),
                                    ),
                                  );
                                }),
                          ),
                        ),
                      ),
                    ],
                  )
                ]),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  color: Colors.white,
                  height: 4,
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.directions_car,
                            color: Colors.white,
                          ),
                          Text(
                            "\t\tFour Wheeler\t\t",
                            style: TextStyle(color: Colors.white),
                          ),
                          Checkbox(
                              value: fourWheeler,
                              activeColor: Colors.blueAccent,
                              onChanged: (bool newValue) {
                                setState(() {
                                  fourWheeler = newValue;
                                  twoWheeler = !newValue;
                                });
                              }) //TODO FORMAT THIS
                        ],
                      ),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.directions_bike,
                            color: Colors.white,
                          ),
                          Text(
                            "\t\tTwo Wheeler\t\t",
                            style: TextStyle(color: Colors.white),
                          ),
                          Checkbox(
                              value: twoWheeler,
                              activeColor: Colors.blueAccent,
                              onChanged: (bool newValue) {
                                setState(() {
                                  twoWheeler = newValue;
                                  fourWheeler = !newValue;
                                });
                              }),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  color: Colors.white,
                  height: 4,
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.confirmation_number,
                            color: Colors.white,
                          ),
                          Text(
                            "\t\tVehicle Number\t\t",
                            style: TextStyle(color: Colors.white),
                          ) //TODO FORMAT THIS
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Center(
                            child: Container(
                              width: 300.0,
                              child: Center(
                                child: TextField(
                                  style: TextStyle(color: Colors.white),
                                  controller: vehicleNumberController,
                                  decoration: InputDecoration(
                                      // border: InputBorder.none,
                                      // contentPadding: EdgeInsets.all(20.0),
                                      hintText: 'Enter your vehicle Number',
                                      hintStyle: TextStyle(
                                        color: Colors.white,
                                      )),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Divider(
                  color: Colors.white,
                  height: 4,
                ),
                SizedBox(
                  height: 10,
                ),
                RaisedButton(
                  onPressed: () {
                    reserveSlot();
                  },
                  child: const Text('Reserve',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold)),
                  color: Colors.blueAccent,
                  splashColor: Colors.white,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget getTimeslotText() {
    switch (reservation.timeslot) {
      case 'midday':
        return Text("\t\tMidday\n\t\t11:30 - 14:15",
            style: TextStyle(color: Colors.white));
        break;
      case 'afternoon':
        return Text("\t\t\tAfternoon\n\t\t14:30 - 17:15",
            style: TextStyle(color: Colors.white));
        break;
      case 'evening':
        return Text("\t\tEvening\n\t\t17:30 - 20:15",
            style: TextStyle(color: Colors.white));
        break;
      case 'late_evening':
        return Text("\t\tLate Evening\n\t\t20:30 - 23:00",
            style: TextStyle(color: Colors.white));
        break;
    }
  }

  Future<void> _showSuccessDialog(
      Reservation reservation, dynamic response, String personName) async {
    String reservationKey = response['reservationKey'];
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reservation Booked!'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Your reservation has been successfully booked'),
              ],
            ),
          ),
          actions: <Widget>[
            FlatButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed('/ticket', arguments: {
                  "reservation": reservation,
                  "reservation_key": reservationKey,
                  "person_name": personName
                });
              },
            ),
          ],
        );
      },
    );
  }

  // A Separate Function called from itemBuilder
  Widget buildDynamicListView(BuildContext ctxt, int index) {
    print(index.toString());
    return new Text(index.toString());
  }

  Future<Map<String, dynamic>> checkIfLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int personId = prefs.getInt('personId');
    String personName = prefs.getString('personName');
    if (personId != null)
      return ({"personId": personId, "personName": personName});
    else
      return null;
  }
}
