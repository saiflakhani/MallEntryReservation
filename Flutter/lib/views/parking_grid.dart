import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../podo/slot.dart';
import '../podo/reservation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

List<Widget> staticCards;
int api_counter = 0;

Future<List<Slot>> fetchParkingGrid() async {
  final response = await http.get('https://calm-shore-97363.herokuapp.com/slots/get_week');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    var data = json.decode(response.body);
    var rest = data as List;
    staticCards = addStaticRow();
    var slotListLocal = rest.map<Slot>((json) => Slot.fromJson(json)).toList();
    return slotListLocal;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    
    //throw Exception('Failed to load slots');
    print("Slots failed to load");
  }
}

// A function to create the parking grid, with numbers of available slots
Widget getGridViewWidget(List<Slot> slots) {
  var now = DateTime.now();
  api_counter = 0;
  return Container(
    child: GridView.builder(
        padding: EdgeInsets.all(10.0),
        itemCount: 40,
        gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            childAspectRatio: 1.0,
            mainAxisSpacing: 4.0,
            crossAxisSpacing: 4.0),
        itemBuilder: (context, position) {
          // Adding static cards
          if (position < 5) {
            return (staticCards[position]);
          } else if (position % 5 == 0) {
            Widget to_return = new Container(
              alignment: Alignment.center,
              
              child: Text(
                DateFormat('EEE').format(now) +
                    "\n" +
                    DateFormat('dd MMM').format(now),
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 15.0,
                    fontStyle: FontStyle.italic),
              ),
              color: Colors.blue[100],
            );
            now = now.add(new Duration(days: 1));
            return to_return;
          } else {
            switch (position % 5) {
              case 1:
                return InkWell(
                    onTap: () => addReservation(position, 'midday', slots, context),
                    child: new Container(
                    alignment: Alignment.center,
                    child: Text(
                      '${slots[api_counter].midday}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold),
                    ),
                    color: Colors.black,
                    
                  ),
                );
                break;
              case 2:
                return InkWell(
                    onTap: () => addReservation(position, 'afternoon', slots, context),
                    child: new Container(
                    alignment: Alignment.center,
                    child: Text(
                      '${slots[api_counter].afternoon}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold),
                    ),
                    color: Colors.black,
                  ),
                );
                break;
              case 3:
                return InkWell(
                    onTap: () => addReservation(position, 'evening', slots, context),
                    child: new Container(
                    alignment: Alignment.center,
                    child: Text(
                      '${slots[api_counter].evening}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold),
                    ),
                    color: Colors.black,
                  ),
                );
                break;
              case 4:
                return InkWell(
                    onTap: () => addReservation(position, 'late_evening', slots, context),
                                  child: new Container(
                    alignment: Alignment.center,
                    child: Text(
                      '${slots[api_counter++].late_evening}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.0,
                          fontWeight: FontWeight.bold),
                    ),
                    color: Colors.black,
                  ),
                );
            }
          }
          
        }),
  );
}


void addReservation(int position, String timeslot, List<Slot> slots, BuildContext context){
  //trying the slot stuff
  Slot slot = slots[(position~/5)-1];
  Reservation rSlot = new Reservation(
    person_id: 101,
    adults: 0,
    children: 0,
    reservation_key: null,
    reservation_date: slot.date.toString(),
    vehicle_type: null,
    timeslot: timeslot,
    parking: null,
    review: null,
    review_text: null,
    reservation_date_time: slot.date,
    person_name: null);
  print("Clicked on ---> "+slot.date.toString()+" and timeslot --> "+timeslot);
  Navigator.pushNamed(context, '/reserveSlot',arguments: rSlot);
}

// THIS FUNCTION ADDS A STATIC ROW TO THE GRID, FOR THE FIRST ROW
List<Widget> addStaticRow() {
  List<Widget> staticContainers = new List<Widget>();

  //BLANK
  staticContainers.add(new Container(
      alignment: Alignment.center,
      color: Colors.blue[100],
      child: Icon(
        Icons.calendar_today,
        color: Colors.blue,
        size: 60.0,
      )));

  //MIDDAY
  staticContainers.add(new Container(
      alignment: Alignment.center,
      color: Colors.blue[100],
      child: Text(
        "Midday\n(11:30-14:15)",
        style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 10.0,
            fontStyle: FontStyle.italic),
      )));

  //AFTERNOON
  staticContainers.add(new Container(
      alignment: Alignment.center,
      color: Colors.blue[100],
      child: Text(
        "Afternoon\n(14:30-17:15)",
        style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 10.0,
            fontStyle: FontStyle.italic),
      )));

  //EVENING
  staticContainers.add(new Container(
      alignment: Alignment.center,
      color: Colors.blue[100],
      child: Text(
        "Evening\n(17:30-20:15)",
        style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 10.0,
            fontStyle: FontStyle.italic),
      )));

  //LATE EVENING
  staticContainers.add(new Container(
      alignment: Alignment.center,
      color: Colors.blue[100],
      child: Text(
        "Late Evening\n(20:30-23:00)",
        style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 10.0,
            fontStyle: FontStyle.italic),
      )));
  return staticContainers;
}
