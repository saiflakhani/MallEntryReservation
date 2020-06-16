import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:parking_app/views/bookings.dart';
import 'podo/reservation.dart';
import 'package:ticket_card/ticket_card.dart';
import 'package:qr_flutter/qr_flutter.dart';

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

  @override
  void initState() {
    super.initState();
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
    if(reservation.person_name == null){
      personName = map['person_name'];
    }else{
      personName = reservation.person_name;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text('Mall Reservation'),
      ),
      backgroundColor: Colors.grey[200],
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: TicketCard(
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
                              "Booked in the name of:\n" +
                                  personName,
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
          ),
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
