import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:parking_app/podo/reservation.dart';

List<Widget> upcomingCards, previousCards;
Future<Reservation> reservations;
List<Reservation> reservationsList;

Future<List<Reservation>> fetchReservations() async {
  final response = await http.get('https://calm-shore-97363.herokuapp.com/reservations/');

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    var data = json.decode(response.body);
    var rest = data as List;
    var reservationsListLocal = rest.map<Reservation>((json) => Reservation.fromJson(json)).toList();
    return reservationsListLocal;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    //throw Exception('Failed to load album');
    print("Failed to load");
  }
}

List<Widget> fetchPreviousBookings() {
  previousCards = new List<Widget>();
  for (int i = 0; i < 5; i++) {
    previousCards.add(Card(
      child: InkWell(
        splashColor: Colors.blue.withAlpha(30),
        onTap: () {
          print('Card tapped.');
        },
        child: Container(
          width: double.infinity,
          height: 100,
          alignment: Alignment.center,
          padding: EdgeInsets.all(10.0),
          child: Text('Previous Booking: '+i.toString()),
        ),
      ),
    ));
  }
  return previousCards;
}



void redirectToTicket(BuildContext context, Reservation reservation){
  Navigator.of(context).pushNamed('/ticket', arguments: {"reservation":reservation, "reservation_key":reservation.reservation_key});
}


Widget getListViewWidget(List<Reservation> reservations)
{
  
  return Container(
      child: ListView.builder(
          itemCount: reservations.length,
          padding: const EdgeInsets.all(2.0),
          itemBuilder: (context, position) {
            return Card(
              child: ListTile(
                title: Text(
                  '${reservations[position].person_name}'+"\n"+"Reservation key: "+'${reservations[position].reservation_key}'.toUpperCase(),
                  style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                leading: Icon(Icons.today, color: Colors.blue, size:30.0),
                onTap: () => redirectToTicket(context, reservations[position]),
                subtitle: Text("\nDate: "+'${DateFormat('dd MMM').format(reservations[position].reservation_date_time)}' + "\t\t\tTimeslot: "+'${reservations[position].timeslot}' +"\n\n" + "Adults: "+'${reservations[position].adults}' + ", Children: "+'${reservations[position].children}'), //TODO FORMAT THIS
              ),
            );
          }),
    );
}