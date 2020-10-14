import 'package:http/http.dart' as http;
import 'dart:convert';

class NewsItem {
  String title;
  String body;
  String source;
  String imgUrl;
  String sourceUrl;
  bool isHighlighted;
  DateTime publishedAt;
  static final _apiKey = "apiKey=cdd0f86c454e454191b3443a3415bb51";

  NewsItem(
      {this.title,
      this.body,
      this.source,
      this.imgUrl,
      this.sourceUrl,
      this.isHighlighted = false,
      this.publishedAt});

  //Get country data from JSON
  static Future<List<NewsItem>> GetNewsAPI(String selectedCountry) async {
    try {
      final response =
          await http.get("http://newsapi.org/v2/top-headlines?q=covid-19&country=" + selectedCountry +"&" + _apiKey);
      if (response.statusCode == 200) {
        //OK response
        return FromNewsAPIJson(json.decode(response.body));
      } else {
        throw Exception("Can't fetch news");
      }
    } on Exception catch (e) {
      print(e.toString());
    }
  }

  //Convert JSON to Country
  static List<NewsItem> FromNewsAPIJson(Map<String, dynamic> json) {
    if (json['totalResults'] == 0) {
      print("No results");
      return null;
    }

    List<NewsItem> newsList = new List();
    for (var i = 0; i < json['totalResults']; i++) {
      String source  = "";

      //Removes .com, etc
      if(json['articles'][i]['source']['name'].toString().indexOf('.')> -1){
        source = json['articles'][i]['source']['name'].toString().substring(0, json['articles'][i]['source']['name'].toString().indexOf('.'));
      } else{
        source = json['articles'][i]['source']['name'].toString();
      }

      newsList.add(new NewsItem(
          source: source,
          title: json['articles'][i]['title'],
          body: json['articles'][i]['description'],
          sourceUrl: json['articles'][i]['url'].toString(),
          publishedAt:
              DateTime.tryParse(json['articles'][i]['publishedAt']).toLocal(),
          imgUrl: json['articles'][i]['urlToImage'],
          //Is important if title contains dead/death
          isHighlighted: json['articles'][i]['description']
                      .toString()
                      .contains("death") ||
                  json['articles'][i]['description'].toString().contains("dead ") || json['articles'][i]['description'].toString().contains("cases")
              ? true
              : false));


    }

    return newsList;
  }
}
