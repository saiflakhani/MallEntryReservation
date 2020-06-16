import 'package:flutter/material.dart';
import 'package:parking_app/login.dart';
import 'package:parking_app/newuser.dart';
import 'mall_app.dart';
import 'reserve_slot.dart';
import 'ticket.dart';

void main() => runApp(MaterialApp(
    title: "Spot Reservation",
    theme: ThemeData(fontFamily: 'Montserrat'),
    initialRoute: '/',
    routes: {
      '/': (context) => MallApp(),
      '/reserveSlot': (context) => ReserveSlot(),
      '/ticket':(context) => Ticket(),
      '/login': (context) => LoginPage(),
      '/signup': (context) => NewUser(),
    },
    ));
