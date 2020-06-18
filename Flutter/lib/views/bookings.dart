import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:parking_app/podo/reservation.dart';
import 'package:shared_preferences/shared_preferences.dart';

List<Widget> upcomingCards, previousCards;
Future<Reservation> reservations;
List<Reservation> pastReservationsList;
List<Reservation> upcomingReservationsList;

Future<Map<String, dynamic>> fetchReservations() async {
  Map<String, dynamic> loggedIn = await checkIfLoggedIn();
  pastReservationsList = new List<Reservation>();
  upcomingReservationsList = new List<Reservation>();

  if (loggedIn != null) {
    final response = await http.get(
        'https://calm-shore-97363.herokuapp.com/reservations/my_reservations/' +
            loggedIn['personId'].toString());

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      var data = json.decode(response.body);
      var rest = data as List;
      var reservationsListLocal =
          rest.map<Reservation>((json) => Reservation.fromJson(json)).toList();
      DateTime now = new DateTime.now();
      reservationsListLocal.forEach((element) {
        if (element.reservation_date_time.compareTo(now) < 0) {
          // Ho gaya reservation
          pastReservationsList.add(element);
        } else {
          upcomingReservationsList.add(element);
        }
      });
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      //throw Exception('Failed to load album');
      print("Failed to load");
    }
  }

  return {
    'upcomingReservations': upcomingReservationsList,
    'pastReservations': pastReservationsList
  };
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

void redirectToTicket(BuildContext context, Reservation reservation) {
  Navigator.of(context).pushNamed('/ticket', arguments: {
    "reservation": reservation,
    "reservation_key": reservation.reservation_key
  });
}

Widget getListViewWidget(List<Reservation> reservations) {
  if (reservations.length <= 0) {
    return Center(child: Text("No reservations here"));
  }
  return Container(
    child: ListView.builder(
        itemCount: reservations.length,
        padding: const EdgeInsets.all(15.0),
        itemBuilder: (context, position) {
          return Card(
            child: ListTile(
              title: Text(
                '${reservations[position].person_name}' +
                    "\n" +
                    "Reservation key: " +
                    '${reservations[position].reservation_key}'.toUpperCase(),
                style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
              leading: Icon(Icons.today, color: Colors.blue, size: 30.0),
              onTap: () => redirectToTicket(context, reservations[position]),
              subtitle: Padding(
                  padding: EdgeInsets.all(5),
                  child: Text("Date: " +
                      '${DateFormat('dd MMM').format(reservations[position].reservation_date_time)}' +
                      "\t\t\tTimeslot: " +
                      '${reservations[position].timeslot}' +
                      "\n" +
                      "Adults: " +
                      '${reservations[position].adults}' +
                      ", Children: " +
                      '${reservations[position].children}')), //TODO FORMAT THIS
            ),
          );
        }),
  );
}
