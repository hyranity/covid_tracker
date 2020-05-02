import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
class Country{
  String name;
  int cases;
  DateTime quarantineEnd;
  int todayCases;

  //Constructor
  Country({this.name, this.cases, this.quarantineEnd, this.todayCases});

  //Alternate constructor
  factory Country.create(String name, int cases, DateTime quarantineEnd, int todayCases){
    return Country(name: name, cases: cases, quarantineEnd: quarantineEnd, todayCases: todayCases);
  }

  //Convert snapshot to Country object
  Country.FromSnapshot(DataSnapshot data){
    name = data.value["name"];
    cases = data.value["cases"];
    quarantineEnd = DateTime.now(); //This is because quarantineDate is obtained from a separate database, and we can't leave it null, so this is a default value
    todayCases = data.value["todayCases"];
  }

  //Get country data from JSON
  static Future<Country> Get(String countryCode) async{
    final response = await http.get("http://disease.sh/v2/countries/" + countryCode + "?yesterday=false&strict=false");
    print(response.statusCode);
    if(response.statusCode == 200){
      //OK response
      return Country.FromJson(json.decode(response.body));

    }
    else{
      throw Exception("Can't fetch country");
    }
  }

  //Convert JSON to Country
  factory Country.FromJson(Map<String, dynamic> json){
    print(DateTime.fromMillisecondsSinceEpoch(json["updated"]));
    return Country(
        name: json['country'],
      cases: json['cases'],
      quarantineEnd: DateTime.now(),
      todayCases: json['todayCases'],
    );
  }

  //Experimental
  Map<String, dynamic> toJson() =>
      {
        "name": name,
        "cases": cases,
        "quarantineEnd": quarantineEnd.toString(),
        "todayCases": todayCases,
      };

}