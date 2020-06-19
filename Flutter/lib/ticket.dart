import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:parking_app/views/bookings.dart';
import 'podo/reservation.dart';
import 'package:ticket_card/ticket_card.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'views/tick_mark.dart';

class Ticket extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new TicketState();
  }
}

class TicketState extends State<Ticket> {
  Reservation reservation;
  String reservationKey;
  String personName;

  bool entered = false;
  double durationValue = 0.0;
  bool loading = false;
  bool shownOnce = false;
  FlutterBlue flutterBlue;
  Timer progressTimer;

  @override
  void initState() {
    super.initState();
    durationValue = 0.0;
    loading = false;
    flutterBlue = FlutterBlue.instance;
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    Map<String, dynamic> map = ModalRoute.of(context).settings.arguments;
    reservation = map['reservation'];
    reservationKey = map['reservation_key'];
    if (reservation.person_name == null) {
      personName = map['person_name'];
    } else {
      personName = reservation.person_name;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Mall Reservation'),
        backgroundColor: Colors.black,
      ),
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(children: <Widget>[
              TicketCard(
                decoration: TicketDecoration(
                    shadow: [TicketShadow(color: Colors.grey, elevation: 6)]),
                lineFromTop: 150,
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  height: 500,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        height: 140,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Row(
                            children: <Widget>[
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Text(
                                      "MALL ENTRY TICKET",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Text(this
                                        .reservation
                                        .reservation_date_time
                                        .toString()),
                                    Text(
                                      "Adults: " +
                                          reservation.adults.toString() +
                                          ", Children: " +
                                          reservation.children.toString(),
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    Text(
                                      reservation.vehicle_type,
                                      style: TextStyle(color: Colors.black),
                                    ),
                                    Text(
                                      "Vehicle Number: " +
                                          reservation.vehicle_number,
                                      style: TextStyle(
                                          color: Colors.blueAccent,
                                          fontSize: 10.0),
                                    ),
                                  ],
                                ),
                              ),
                              AspectRatio(
                                aspectRatio: 1,
                                child: Container(
                                  color: Colors.grey,
                                  child: Image(
                                    width: 100,
                                    height: 100,
                                    image: AssetImage('assets/logo.png'),
                                  ),
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Container(
                          margin: const EdgeInsets.only(top: 20),
                          child: Column(
                            children: <Widget>[
                              Text(
                                "Reservation Key:\n" + reservationKey,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              Container(
                                height: 200,
                                width: 200,
                                color: Colors.white,
                                child: QrImage(
                                  data: reservationKey,
                                  version: QrVersions.auto,
                                  size: 200.0,
                                  //embeddedImage: AssetImage('assets/logo.png'),
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Booked in the name of:\n" + personName,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
              loading
                  ? Column(
                      children: <Widget>[
                        Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: LinearProgressIndicator()),
                        Text("Scanning...")
                      ],
                    )
                  : Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text(
                        "Click the button to scan for entry tag",
                        style: TextStyle(
                            color: Colors.blueAccent,
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold),
                      ),
                    )
            ]),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          setState(() {
            if (!loading) {
              shownOnce = false;
              startScan();
            } else {
              flutterBlue.stopScan();
            }
            loading = !loading;
          });
        },
        tooltip: 'Scan',
        child: Icon(
          Icons.bluetooth_searching,
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  // we use this function to simulate a download
  // by updating the progress value
  // void updateProgress() {
  //   const oneSec = const Duration(seconds: 1);
  //   new Timer.periodic(oneSec, (Timer t) {
  //     setState(() {
  //       progressTimer = t;
  //       durationValue += 0.0333;
  //       if (entered) {
  //         t.cancel();
  //         // showAlertDialog();
  //       }
  //       // we "finish" downloading here
  //       if (durationValue.toStringAsFixed(1) == '1.0') {
  //         loading = false;
  //         t.cancel();
  //         durationValue = 0.0;
  //         flutterBlue.stopScan();
  //         return;
  //       }
  //     });
  //   });
  // }

  void startScan() async {
    try {
      flutterBlue.startScan(timeout: Duration(seconds: 30));
      flutterBlue.scanResults.listen((results) async {
        // do something with scan results
        for (ScanResult r in results) {
          print(r.device.name + " " + r.rssi.toString());
          if (r.device.name.toString().startsWith("Mki") &&
              loading &&
              r.rssi > -60) {
            //TODO CHECK RSSI IF WANTED
            await flutterBlue.stopScan();
            //loading = false;
            setState(() {
              loading = false;
              if (!shownOnce) {
                showAlertDialog();
                sendToServer();
                shownOnce = true;
              }
            });
            return;
          }
        }
      });
    } catch (error) {
      print("An exception occured. Skipping.");
    }
  }

  void showAlertDialog() {
    showDialog(
        context: context,
        child: new AlertDialog(
          title: new Text("Sucess"),
          content: Container(
            width: 100.0,
            height: 125.0,
            child: Column(
              children: <Widget>[
                Container(
                    child: Icon(
                  Icons.done,
                  color: Colors.green,
                  size: 30,
                )),
                Container(
                    child: Text(
                        "You can now enter the mall. Please show this ticket upon exit.")),
              ],
            ),
          ),
        ));
  }

  void sendToServer() {
    try {
     Reservation toSend = new Reservation(
          person_id: null,
          adults: null,
          children: null,
          adult_names: null,
          child_names: null,
          reservation_key: reservationKey,
          reservation_date: null,
          vehicle_type: null,
          timeslot: null,
          vehicle_number: null,
          parking: null,
          review: null,
          review_text: null,
          reservation_date_time: null,
          person_name: null);

      Future<http.Response> response = createReservation(toSend);
      bool result = false;
      response.then((response) {
        // print(response)
        if (json.decode(response.body)['status'] == "success") {
          print("Successfully: " + json.decode(response.body)['type']);
        } else {
          setState(() {
            Navigator.of(context).pop();
            showDialog(
              context: context,
              child: new AlertDialog(
                title: new Text("Failure"),
                content: Container(
                  width: 100.0,
                  height: 125.0,
                  child: Column(
                    children: <Widget>[
                      Container(
                          child: Icon(
                        Icons.error,
                        color: Colors.red,
                        size: 30,
                      )),
                      Container(
                          child: Text(
                              "This reservation is already used! Please contact security.")),
                    ],
                  ),
                ),
              ));
          });
          
        }
      });
    } catch (error) {
      print("An error occured trying to send Enter exit data");
    }
    //print("Sending --> "+NewUserState.name.text+" "+NewUserState.phone.text+" "+NewUserState.password.text+" "+NewUserState.locality.text);
  }

  Future<http.Response> createReservation(Reservation reservation) {
    //print(jsonEncode(reservation));
    return http.post('https://calm-shore-97363.herokuapp.com/reservations/entry_exit',
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: '{"reservation_key": "'+reservationKey+'"}');
  }
}
