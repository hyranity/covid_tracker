import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:covidtracker/Model/CovidCountry.dart';
import 'package:intl/intl.dart';
import 'package:countdown/countdown.dart';
import 'package:http/http.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iso_countries/iso_countries.dart';

Future<void> alertUser(BuildContext context, String title, String message) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false, // user must tap button!
    builder: (BuildContext context){
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          FlatButton(
            child: Text("OK"),
            onPressed: (){
              Navigator.of(context).pop();
            },
          )
        ],
      );
    }
  );
}

Future<void> showGPSErr(BuildContext context, String title, String message) async {
  return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context){
        return Dialog(
            child: FlatButton(
              child: Text("OK"),
              onPressed: (){
                Navigator.of(context).pop();
              },
            )
        );
      }
  );
}
