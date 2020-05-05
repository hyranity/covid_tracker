import 'dart:collection';

import 'package:covidtracker/Util/AppWide.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:covidtracker/Model/CovidCountry.dart';
import 'package:intl/intl.dart';
import 'package:share/share.dart';
import 'package:http/http.dart';
import 'package:geolocator/geolocator.dart';
import 'package:iso_countries/iso_countries.dart';
import 'package:covidtracker/Util/CustomDialog.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import 'Util/NewsItem.dart';

class NewsDetail extends StatefulWidget {
  NewsItem news;
  // This widget is the root of your application.
  NewsDetail({Key key, @required this.news}) : super(key: key);

  _NewsDetail createState() => _NewsDetail(news: news);
}

class _NewsDetail extends State<NewsDetail> {
  NewsItem news;

  _NewsDetail({Key key, @required this.news});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.only(left: 30.0, top: 50, right: 30),
          child: Stack(
            children: <Widget>[
              Column(
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Text(
                        "< Back",
                        textAlign: TextAlign.left,
                        style: GoogleFonts.poppins(
                          color: Color(0xff5B8388),
                          fontWeight: FontWeight.w600,
                          fontSize: 25,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  topSection(),
                  SizedBox(
                    height: 15,
                  ),
                  news.imgUrl != null //If image is not null
                      ? Image.network(
                    news.imgUrl,
                    height: 167,
                  )
                      : noImageContainer(), //Show error msg
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    news.body,
                    maxLines: 7,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Color(0xff5B8388),
                      fontWeight: FontWeight.w500,
                      fontSize: 20,

                    ),
                  )
                ],
              ),
              Positioned(
                right: 0,
                top: 53,

                child: Container(
                  width: 200,
                  child: Text(

                    news.source,
                    maxLines: 1,
                    textAlign: TextAlign.right,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      color: Color(0xff8FD2DB),
                      fontWeight: FontWeight.w500,
                      fontSize: 25,
                    ),
                  ),
                ),
              ),
            ],

          ),
        ),
      ),
    );
  }

  Widget noImageContainer() {
    return Container(
      color: Color(0xff5B8388),
      width: MediaQuery.of(context).size.width * 0.5,
      child: Padding(
        padding: const EdgeInsets.all(40.0),
        child: Text(
            "No image",
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 17,
          ),
        ),
      ),
    );
  }

  Widget topSection() {
    String elapsedHour =
        DateTime.now().difference(news.publishedAt).inHours.toString() + "h";

    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "$elapsedHour  ago",
            style: GoogleFonts.poppins(
              color: Color(0xff8FD2DB),
              fontWeight: FontWeight.w700,
              fontSize: 25,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            news.title,
            textAlign: TextAlign.left,
            overflow: TextOverflow.ellipsis,
            maxLines: 4,
            style: GoogleFonts.poppins(
              color: Color(0xff5B8388),
              fontWeight: FontWeight.w600,
              height: 1,
              fontSize: 35,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
            children: <Widget>[
              readOriginalArticle(),
              SizedBox(
                width: 20,
              ),
              shareButton()
            ],
          ),
        ],
      ),
    );
  }

  void launchURL() async{
    String url = news.sourceUrl;
    print(url);
    if (await canLaunch(url) == true) {
      await launch(url);
    } else {
      alertUser(context, "Cannot load article", "It seems like we can't load this article for some reason.");
    }
  }

  Widget readOriginalArticle() {
    return InkWell(
      onTap: () {
         launchURL();
      },
      child: Container(
        decoration: BoxDecoration(
            color: Color(0xffF7FDFD),
            borderRadius: BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              new BoxShadow(color: Color(0xffE4E8E8), blurRadius: 25)
            ]),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 10.0, bottom: 10, left: 15, right: 15),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.book,
                color: Color(0xff5B8388),
                size: 24.0,
              ),
              SizedBox(
                width: 7,
              ),
              Text(
                "Read original article",
                textAlign: TextAlign.left,
                style: GoogleFonts.poppins(
                  color: Color(0xff5B8388),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget shareButton() {
    return InkWell(
      onTap: () {
        Share.share(news.title + " | " + news.source + "```@ " + news.sourceUrl  + " via Hopeful");
        print(news.title + " | " + news.source + "'''@ " + news.sourceUrl  + " via Hopeful");
        },
      child: Container(
        decoration: BoxDecoration(
            color: Color(0xffF7FDFD),
            borderRadius: BorderRadius.all(Radius.circular(10)),
            boxShadow: [
              new BoxShadow(color: Color(0xffE4E8E8), blurRadius: 25)
            ]),
        child: Padding(
          padding:
              const EdgeInsets.only(top: 10.0, bottom: 10, left: 15, right: 15),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.share,
                color: Color(0xff5B8388),
                size: 24.0,
              ),
              SizedBox(
                width: 7,
              ),
              Text(
                "Share",
                textAlign: TextAlign.left,
                style: GoogleFonts.poppins(
                  color: Color(0xff5B8388),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
