import 'package:covidtracker/Model/CovidCountry.dart';
import 'package:flutter/cupertino.dart';

import 'NewsItem.dart';

class AppWide {
  static CovidCountry country;
  static String chosenCode = "MY";
  static Future<List<NewsItem>> newsList = NewsItem.GetNewsAPI(chosenCode);

  static Future<List<NewsItem>> LoadNewsList(String countryCode) async {
    if(countryCode != chosenCode){
      //Need re-search
       newsList = NewsItem.GetNewsAPI(countryCode);
       print("Re-searching news");
       chosenCode = countryCode;
    }
    return await newsList;
  }

}
