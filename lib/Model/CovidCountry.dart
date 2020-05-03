import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;

class CovidCountry {
  String name;
  int cases;
  DateTime quarantineEnd;
  int todayCases;
  int active;
  int deaths;
  int recovered;
  int todayDeaths;
  int tests;
  int critical;
  int casesMil;
  int deathsMil;
  int testsMil;
  DateTime updated;

  //Constructor
  CovidCountry(
      {this.name,
      this.cases,
      this.quarantineEnd,
      this.todayCases,
      this.active,
      this.deaths,
      this.recovered,
      this.todayDeaths,
      this.critical,
      this.updated,
      this.casesMil,
      this.deathsMil,
      this.tests,
        this.testsMil
      });

  //Alternate constructor
  factory CovidCountry.create(
      String name, int cases, DateTime quarantineEnd, int todayCases) {
    return CovidCountry(
        name: name,
        cases: cases,
        quarantineEnd: quarantineEnd,
        todayCases: todayCases);
  }

  //Convert snapshot to Country object
  CovidCountry.FromSnapshot(DataSnapshot data) {
    name = data.value["name"];
    cases = data.value["cases"];
    quarantineEnd = DateTime
        .now(); //This is because quarantineDate is obtained from a separate database, and we can't leave it null, so this is a default value
    todayCases = data.value["todayCases"];
    active = data.value["active"];
    recovered = data.value["recovered"];
    todayDeaths = data.value["todayDeaths"];
    critical = data.value["critical"];
    deaths = data.value["deaths"];
    updated = new DateTime.fromMillisecondsSinceEpoch(data.value["updated"]);

  }

  //Get country data from JSON
  static Future<CovidCountry> Get(String countryCode) async {
    final response = await http.get("http://disease.sh/v2/countries/" +
        countryCode +
        "?yesterday=false&strict=false");
    print(response.statusCode);
    if (response.statusCode == 200) {
      //OK response
      return CovidCountry.FromJson(json.decode(response.body));
    } else {
      throw Exception("Can't fetch country");
    }
  }

  //Convert JSON to Country
  factory CovidCountry.FromJson(Map<String, dynamic> json) {
    if(json['message'] != null && json['message'] == "Country not found or doesn't have any cases"){
      return null;
    }
    return CovidCountry(
      name: json['country'],
      cases: json['cases'],
      quarantineEnd: DateTime.now(),
      todayCases: json['todayCases'],
      active: json["active"],
      recovered: json["recovered"],
      todayDeaths: json["todayDeaths"],
      critical: json["critical"],
      deaths: json["deaths"],
      updated: new DateTime.fromMillisecondsSinceEpoch(json["updated"]).toLocal(),
      tests: json["tests"],
      casesMil: json["casesPerOneMillion"],
      deathsMil: json["deathsPerOneMillion"],
      testsMil: json["testsPerOneMillion"],
    );
  }

}
