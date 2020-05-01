import 'package:firebase_database/firebase_database.dart';

class Country{
  String name;
  int cases;
  DateTime quarantineEnd;
  int todayCases;

  Country(String name, int cases, DateTime quarantineEnd, int todayCases){
    this.name = name;
    this.cases = cases;
    this.quarantineEnd = quarantineEnd;
    this.todayCases = todayCases;
  }

  Country.FromSnapshot(DataSnapshot data){
    name = data.value["name"];
    cases = data.value["cases"];
    quarantineEnd = DateTime.parse(data.value["quarantineEnd"].toString());
    todayCases = data.value["todayCases"];
  }

  Map<String, dynamic> toJson() =>
      {
        "name": name,
        "cases": cases,
        "quarantineEnd": quarantineEnd.toString(),
        "todayCases": todayCases,
      };

}