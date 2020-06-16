import 'dart:ffi';
import 'package:intl/intl.dart';

class Reservation {
  final int id, person_id, adults, children;
  final String reservation_key, reservation_date, vehicle_type, vehicle_number, timeslot, parking, review_text, person_name, adult_names, child_names;
  final DateTime reservation_date_time;
  final double review;

  Reservation({this.id, 
  this.person_id,
  this.adults, 
  this.children, 
  this.adult_names,
  this.child_names,
  this.reservation_key, 
  this.reservation_date, 
  this.vehicle_type, 
  this.vehicle_number, 
  this.timeslot, 
  this.parking, 
  this.review, 
  this.review_text, 
  this.reservation_date_time, this.person_name});

  factory Reservation.fromJson(Map<String, dynamic> json){
    return Reservation(
      id: json['id'],
      person_name: json['person_name'],
      person_id: json['person_id'],
      adults: json['adults'],
      children: json['children'],
      adult_names: json['adult_names'],
      child_names: json['child_names'],
      reservation_key: json['reservation_key'],
      reservation_date: json['reservation_date'],
      reservation_date_time: DateTime.parse(json['reservation_date'].toString()),
      vehicle_type: json['vehicle_type'],
      vehicle_number: json['vehicle_number'],
      parking: json['parking'],
      timeslot: json['timeslot'].toString(),
      review_text: json['title'],
      review: json['review'].toDouble()
    );
  }

  Map<String, dynamic> toJson() =>
  {
    'vehicle_number' : vehicle_number,
    'adults' : adults,
    'children' : children,
    'adult_names': adult_names,
    'child_names': child_names,
    'timeslot' : timeslot,
    'reservation_date' : DateFormat('yyyy-MM-dd HH:mm:ss').format(reservation_date_time),
    'vehicle_type' : vehicle_type,
    'person_id' : person_id
  };


}