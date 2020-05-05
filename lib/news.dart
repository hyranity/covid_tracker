import 'dart:collection';

import 'package:covidtracker/Util/AppWide.dart';
import 'package:covidtracker/newsDetail.dart';
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
import 'package:covidtracker/Util/CustomDialog.dart';
import 'package:progress_dialog/progress_dialog.dart';

import 'Util/NewsItem.dart';

class News extends StatefulWidget {
  // This widget is the root of your application.

  _News createState() => _News();
}

class _News extends State<News> {
  String selectedCountry = "MY";
  Future<Map<String, Country>> countries;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
      child: Column(
        children: <Widget>[
          topPart(),

          bottomPart(),
          SizedBox(
            height: 10,
          ),
          Text(
            "powered by NewsAPI.org",
            style: GoogleFonts.poppins(
              color: Color(0xff5B8388),
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ));
  }

  Widget bottomPart() {
    return Container(
      height: 420,
      width: 300,
      child: FutureBuilder<List<NewsItem>>(
        future: getNewsList(),
        builder:
            (BuildContext context, AsyncSnapshot<List<NewsItem>> snapshot) {
          // If data not yet loaded
          if (snapshot.connectionState != ConnectionState.done) {
            return Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(100),
                  child: new CircularProgressIndicator(
                      valueColor:
                      new AlwaysStoppedAnimation<Color>(
                          Color(0xffAEE0E5))),
                ));
          }

          if (!snapshot.hasData)
            return Text("No data found");

          //Else, show data
          return ListView.separated(
            padding: EdgeInsets.only(top: 0),

            separatorBuilder: (BuildContext context, int index) {
              return SizedBox(
                height: 15,

              );
            },
            itemCount: snapshot.data.length,
            itemBuilder: (BuildContext context, int index) {
              if (snapshot.data[index].isHighlighted)
                return importantNewsItem(snapshot.data[index]);
              else
                return normalNewsItem(snapshot.data[index]);
            },
          );
        },
      ),
    );
  }

  Widget importantNewsItem(NewsItem news) {
    String elapsedHour = DateTime.now().difference(news.publishedAt).inHours.toString() + "h";

    return InkWell(
      onTap: (){
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetail(news: news),
            ));
      },
      child: Container(
        decoration: BoxDecoration(
            color: Color(0xffAEE0E5),
            borderRadius: BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              new BoxShadow(
                color: Color(0xffE4E8E8),
                blurRadius: 25,
              )
            ]),
        child: Padding(
          padding:
          const EdgeInsets.only(top: 15, left: 25, right: 25, bottom: 15),
          child: Stack(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "$elapsedHour  ago",
                    style: GoogleFonts.poppins(
                      color: Color(0xff5B8388),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    news.title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      height: 1,

                      fontSize: 20,
                    ),
                  ),
                ],
              ),

              //Source
              Positioned(
                  right: 0,
                  child: Container(
                    width: 125,
                    child: Text(
                      news.source,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,

                      textAlign: TextAlign.right,
                      style: GoogleFonts.poppins(
                        color: Color(0xff5B8388),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  )
              )],

          ),
        ),
      ),
    );
  }

  Widget normalNewsItem(NewsItem news) {
    String elapsedHour = DateTime.now().difference(news.publishedAt).inHours.toString() + "h";

    return InkWell(
      onTap: (){
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => NewsDetail(news: news),
            ));
      },
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              new BoxShadow(
                color: Color(0xffE4E8E8),
                blurRadius: 25,
              )
            ]),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 10, left: 25, right: 25, bottom: 10),
          child: Stack(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    "$elapsedHour  ago",
                    style: GoogleFonts.poppins(
                      color: Color(0xffA9E2EB),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    news.title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    style: GoogleFonts.poppins(
                      color: Color(0xff5B8388),
                      fontWeight: FontWeight.w600,
                      height: 1,

                      fontSize: 20,
                    ),
                  ),
                ],
              ),

              //Source
              Positioned(
                right: 0,
                child: Container(
                  width: 125,
                  child: Text(
                      news.source,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,

                      textAlign: TextAlign.right,
                      style: GoogleFonts.poppins(
                        color: Color(0xffAEE0E5),
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
              ),
                )
              )],

          ),
        ),
      ),
    );
  }

  Future<List<NewsItem>> getNewsList() async {
    return AppWide.LoadNewsList(selectedCountry);

  }

  Widget topPart() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.all(10),
        child: Container(
          width: 390,
          height: 325,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(40)),
            color: Color(0xffA9E2EB),
          ),
          child: Padding(
            padding: EdgeInsets.only(top: 70, left: 50, right: 50),
            child: Column(
              children: <Widget>[
                //Back button
                Align(
                  alignment: Alignment.centerLeft,
                  child: InkWell(
                    onTap: (){
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "< back",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                        color: Color(0xff5B8388),
                        fontWeight: FontWeight.w600,
                        fontSize: 25,
                        height: 1,
                      ),
                    ),
                  ),
                ),
                Text(
                  "News",
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 65,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                Text(
                  "Sort by",
                  style: GoogleFonts.poppins(
                    color: Color(0xff5B8388),
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                new Expanded(
                  child: Container(
                    width: 275,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(15))),
                    child: Padding(
                      padding: EdgeInsets.only(left: 20, right: 10),

                      child: FutureBuilder(
                        future: getCountryList(),
                        builder: (BuildContext context, AsyncSnapshot snapshot){
                          if(snapshot.connectionState != ConnectionState.done || !snapshot.hasData)
                            return Container(
                              width: 100,
                              height: 100,
                              child: new CircularProgressIndicator()
                            );

                          return DropdownButtonHideUnderline(
                            child: DropdownButton(
                              isExpanded: true,
                                value: selectedCountry,
                                style: GoogleFonts.poppins(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xff5B8388),
                                ),
                                //On change
                                onChanged: (String newValue) {
                                  setState(() {
                                    selectedCountry = newValue;
                                  });
                                },

                                //Items
                                items:
                                snapshot.data.map<DropdownMenuItem<String>>((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList()),
                          );
                        },

                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 45,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<List<String>> getCountryList(){
    List<String> countryNames = new List();
    return IsoCountries.iso_countries.then((cList) {
      for (Country country in cList) {
        countryNames.add(country.countryCode);
      }
      return countryNames;

  });
        }


}
