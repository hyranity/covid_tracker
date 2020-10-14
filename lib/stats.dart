import 'package:covidtracker/Util/AppWide.dart';
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

class Stats extends StatefulWidget {
  // This widget is the root of your application.

  _Stats createState() => _Stats();
}

class _Stats extends State<Stats> {
  String selectedCountry = "MY";
  CovidCountry country;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        //Top section
        child: Stack(
          alignment: Alignment.center,
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                  height: 750,
                  width: 390,
                  decoration: BoxDecoration(
                      color: Color(0xffEEDE9B),
                      borderRadius: BorderRadius.all(Radius.circular(50))),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Column(
                      children: <Widget>[
                        topItem(),
                        FutureBuilder<CovidCountry>(
                            future: getCountry(),
                            builder:
                                (BuildContext context, AsyncSnapshot snapshot) {
                              if (snapshot.connectionState !=
                                  ConnectionState.done) {
                                return Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 200),
                                      child: new CircularProgressIndicator(
                                          valueColor:
                                              new AlwaysStoppedAnimation<Color>(
                                                  Color(0xff877B50))),
                                    ));
                              }

                              //if no result
                              if (!snapshot.hasData) {
                                return Align(
                                    alignment: Alignment.center,
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 100, left: 20, right: 20),
                                      child: Text(
                                        "It seems like we don't have any data on this country.",
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xff877B50),
                                          fontSize: 25,
                                        ),
                                      ),
                                    ));
                              }

                              return middleItem(snapshot.data);
                            }),
                      ],
                    ),
                  )),
            ),
            Positioned(
              bottom: 10,
              child: Text(
                "powered by Novel COVID API",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w500,
                  color: Color(0xff877B50),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  String formatLastUpdated(DateTime updated) {
    Duration diff = DateTime.now().difference(updated);

    if (diff.inHours > 0 && diff.inDays == 0)
      return diff.inHours.toString() + " hours ";

    if (diff.inDays > 0)
      return diff.inDays.toString() + " days ";
    else
      return diff.inMinutes.toString() + " mins ";
  }

  // Middle item section
  Widget middleItem(CovidCountry country) {
    print(country.updated);
    return Align(
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          middleTopRow(country),
          SizedBox(
            height: 15,
          ),
          middleMainPart(country),
          //Updated label
          SizedBox(
            height: 20,
          ),
          Text(
            "Last updated " + formatLastUpdated(country.updated) + "ago",
            style: GoogleFonts.poppins(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: Color(0xff877B50),
            ),
          )
        ],
      ),
    );
  }

  Widget middleTopRow(CovidCountry country) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        giantStatLeft(country.cases, "Total cases"),
        SizedBox(
          width: 40,
        ),
        giantStatRight(country.todayCases, "Today"),
      ],
    );
  }

  Widget middleMainPart(CovidCountry country) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        //Text stuff
        middleMainTextSection(),
        SizedBox(
          width: 13,
        ),
        middleMainNumSection(country)
      ],
    );
  }

  Widget middleMainNumSection(CovidCountry country) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        middleMainNumbers(country.recovered),
        middleMainNumbers(country.active),
        middleMainNumbers(country.critical),
        middleMainNumbers(country.todayDeaths),
        middleMainNumbers(country.deaths),
        middleMainNumbers(country.tests),
        middleMainNumbersDouble(country.recovered/(country.recovered+country.active)),
      ],
    );
  }

  Widget middleMainTextSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        middleMainText("Recovered"),
        middleMainText("Active"),
        middleMainText("Critical"),
        middleMainText("Deaths today"),
        middleMainText("Deaths"),
        middleMainText("Tests"),
        middleMainText("Recovery ratio"),
      ],
    );
  }

  Widget middleMainText(String text) {
    return Text(
      text,
      textAlign: TextAlign.right,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: Color(0xffBFAE69),
        fontSize: 17,
      ),
    );
  }

  Widget middleMainNumbers(int number) {
    return Text(
      NumberFormat.compact().format(number),
      textAlign: TextAlign.left,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: Color(0xff877B50),
        fontSize: 17,
      ),
    );
  }

  Widget middleMainNumbersDouble(double number) {
    return Text(
      (number*100).toStringAsFixed(2) + "%",
      textAlign: TextAlign.left,
      style: GoogleFonts.poppins(
        fontWeight: FontWeight.w600,
        color: Color(0xff877B50),
        fontSize: 17,
      ),
    );
  }

  Widget giantStatRight(number, text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(NumberFormat.compact().format(number),
            textAlign: TextAlign.left,
            style: GoogleFonts.poppins(
              color: Color(0xffAA974E),
              fontWeight: FontWeight.w600,
              fontSize: 50,
            )),
        Text("${text}",
            textAlign: TextAlign.left,
            style: GoogleFonts.poppins(
              color: Color(0xff877B50),
              fontWeight: FontWeight.w600,
              fontSize: 22,
              height: 0.4,
            )),
      ],
    );
  }

  Widget giantStatLeft(number, text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(NumberFormat.compact().format(number),
            textAlign: TextAlign.right,
            style: GoogleFonts.poppins(
              color: Color(0xffAA974E),
              fontWeight: FontWeight.w600,
              fontSize: 50,
            )),
        Text("${text}",
            textAlign: TextAlign.right,
            style: GoogleFonts.poppins(
              color: Color(0xff877B50),
              fontWeight: FontWeight.w600,
              fontSize: 22,
              height: 0.4,
            )),
      ],
    );
  }

  //Top item
  Widget topItem() {
    return Container(
      height: 330,
      width: 390,
      decoration: BoxDecoration(
          color: Color(0xffBCA54E),
          borderRadius: BorderRadius.all(Radius.circular(50))),
      child: Align(
        alignment: Alignment.topCenter,
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 90,
                ),
                Text("statistics",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontSize: 60,
                    )),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "country",
                  style: GoogleFonts.poppins(
                    color: Color(0xffEEDE9B),
                    fontWeight: FontWeight.w500,
                    fontSize: 20,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                new Expanded(
                  child: countryDropDown(),
                ),
                SizedBox(
                  height: 50,
                ),
              ],
            ),
            Positioned(
              top: 60,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "< back",
                  style: GoogleFonts.poppins(
                    color: Color(0xffEEDE9B),
                    fontWeight: FontWeight.w600,
                    fontSize: 25,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget countryDropDown() {
    return FutureBuilder(
      future: getCountryList(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if (snapshot.connectionState != ConnectionState.done)
          return new CircularProgressIndicator();
        return Container(
          padding: EdgeInsets.only(left: 20, right: 20),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15)),
              color: Colors.white),
          width: 250,
          child: DropdownButtonHideUnderline(
            child: DropdownButton(
                isExpanded: true,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xffBCA54E),
                ),
                focusColor: Colors.white,
                value: selectedCountry,
                onChanged: (String newValue) {
                  setState(() {
                    selectedCountry = newValue;
                  });
                },
                items:
                    snapshot.data.map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList()),
          ),
        );
      },
    );
  }

  Future<CovidCountry> getCountry() async {
    return CovidCountry.Get(selectedCountry);
  }

  Future<List<String>> getCountryList() {
    List<String> nameList = new List();
    return IsoCountries.iso_countries.then((cList) {
      for (Country country in cList) {
        nameList.add(country.name);
      }
      return nameList;
    });
  }
}
