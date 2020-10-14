import 'package:covidtracker/Model/CovidCountry.dart';
import 'package:flutter/cupertino.dart';

import 'NewsItem.dart';

class AppWide {
  static CovidCountry country;
  static String chosenCode = "MY";
  static Future<List<NewsItem>> newsList = NewsItem.GetNewsAPI(chosenCode);

  static Future<List<NewsItem>> LoadNewsList(String countryCode) async {

       return newsList = NewsItem.GetNewsAPI(countryCode).then((newsList){
         print("Re-searching news");
         chosenCode = countryCode;
         print(newsList.length);
         return newsList;
       }).catchError((error){
         print(error);
       });


  }

}
