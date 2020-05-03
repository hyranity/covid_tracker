import 'package:covidtracker/Model/CovidCountry.dart';

class DB {
  static CovidCountry getCountry(String country) {
    Future<CovidCountry> futureCountry;

    //Get from JSON url
    futureCountry = CovidCountry.Get(country);
    futureCountry.then((result) {
      if (result != null)
        return result;
       });

    }
  }

