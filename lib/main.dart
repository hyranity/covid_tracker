import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:covidtracker/Model/Country.dart';
import 'package:intl/intl.dart';
import 'package:countdown/countdown.dart';

void main() {
  runApp(MyApp());
}

final FirebaseDatabase _database = FirebaseDatabase.instance;

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
        textTheme: GoogleFonts.poppinsTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  String countryCode = "MY";
  Country country = new Country("name", 1, DateTime.now(), 0);
  String displayCount = "0";
  String displayTodayCount = "0";
  String countDown = "";
  DatabaseReference ref = _database.reference().child("MY");
  bool hasSetState = false;

  DatabaseReference getRef(String countryCode) {
    return _database.reference().child(countryCode);
  }

  @override
  void onInit(){

    setState(() {
        ref.once().then((DataSnapshot snapshot) {
          setState(() {

            update(snapshot);
          });
        });

    });
  }
  //Set state listeners
  @override
  void initState(){
    WidgetsBinding.instance.addObserver(this);
    super.initState();
  }

  @override
  void dispose(){
    WidgetsBinding.instance.addObserver(this);
    super.dispose();
  }

@override
  void didChangeAppLifeCycleState(AppLifecycleState state){
    setState(() {
      print(state);
      print("test");
      if(state == AppLifecycleState.resumed){
        ref.once().then((DataSnapshot snapshot) {
          setState(() {

            update(snapshot);
          });
        });
      }
    });
  }

  update(snapshot) {
    country = Country.FromSnapshot(snapshot);
    displayCount = NumberFormat.compact().format(country.cases);
    displayTodayCount = NumberFormat.compact().format(country.todayCases);

    int durationMins =
        (country.quarantineEnd.difference(DateTime.now()).inMinutes);
    int diffDays = 0;
    int diffHours = 0;
    int diffMins = 0;
    for (var i = 0; i < durationMins; i++) {
      diffMins++;
      if (diffMins == 60) {
        diffHours++;
        diffMins = 0;
      }
      if (diffHours == 24) {
        diffDays++;
        diffHours = 0;
      }
    }

    countDown = diffDays.toString() +
        "d " +
        diffHours.toString() +
        "h " +
        diffMins.toString() +
        "m";
    print(countDown);
  }

  @override
  Widget build(BuildContext context) {
    ref.once().then((DataSnapshot snapshot) {
    if(!hasSetState){


          setState(() {
            update(snapshot);
          });

      hasSetState = true;
    }
    });
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: OverflowBox(
          child: Stack(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 70.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      "Keep calm.",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 30,
                          color: Color.fromRGBO(0, 0, 0, 0.4)),
                    ),
                    SizedBox(
                      height: 0,
                    ),
                    Text(
                      "Stay safe.",
                      textAlign: TextAlign.left,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w600,
                          fontSize: 40,
                          color: Color.fromRGBO(0, 0, 0, 0.8),
                          height: 1.1),
                    ),
                    // News
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0, bottom: 28.0),
                      child: new Container(
                        height: 125.0,
                        width: 330,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(169, 226, 235, 1),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 30.0, top: 20),
                          child: Row(
                            children: <Widget>[
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text("News",
                                      textAlign: TextAlign.left,
                                      style: GoogleFonts.poppins(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                        color: Color.fromRGBO(91, 131, 136, 1),
                                      )),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 3.5),
                                    child: ConstrainedBox(
                                      constraints:
                                          BoxConstraints(maxWidth: 180),
                                      child: Text(
                                          "New cases in Kota Kinabalu reported",
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          textAlign: TextAlign.left,
                                          style: GoogleFonts.poppins(
                                            height: 1.05,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 20,
                                            color: Colors.white,
                                          )),
                                    ),
                                  ),
                                  Text("Daily Express",
                                      style: GoogleFonts.poppins(
                                        height: 1.5,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12,
                                        color: Colors.white,
                                      ))
                                ],
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.only(bottom: 50, left: 35),
                                child: Image.asset(
                                  'assets/images/news.png',
                                  height: 50,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 0.0, bottom: 28.0),
                      child: new Container(
                        height: 125.0,
                        width: 330,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(245, 200, 134, 1),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 30.0, top: 20),
                          child: Stack(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text("Quarantine",
                                          textAlign: TextAlign.left,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            color:
                                                Color.fromRGBO(177, 133, 67, 1),
                                          )),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 3.5),
                                        child: ConstrainedBox(
                                          constraints:
                                              BoxConstraints(maxWidth: 200),
                                          child: Text(countDown,
                                              maxLines: 1,
                                              textAlign: TextAlign.left,
                                              style: GoogleFonts.poppins(
                                                height: 1.05,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 30,
                                                color: Colors.white,
                                              )),
                                        ),
                                      ),
                                      Text("until next MCO update",
                                          style: GoogleFonts.poppins(
                                            height: 1.5,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: Colors.white,
                                          ))
                                    ],
                                  ),
                                ],
                              ),
                              Positioned(
                                right: 40,
                                top: 8,
                                child: Image.asset(
                                  'assets/images/question.png',
                                  height: 50,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 0.0, bottom: 28.0),
                      child: new Container(
                        height: 125.0,
                        width: 330,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(238, 222, 155, 1),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 30.0, top: 20),
                          child: Stack(
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text("Statistics",
                                          textAlign: TextAlign.left,
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15,
                                            color:
                                                Color.fromRGBO(170, 151, 78, 1),
                                          )),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(top: 3.5),
                                        child: ConstrainedBox(
                                            constraints:
                                                BoxConstraints(maxWidth: 180),
                                            child: Row(
                                              // Total cases
                                              children: <Widget>[
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: <Widget>[
                                                    ConstrainedBox(
                                                      constraints:
                                                          BoxConstraints(
                                                              maxWidth: 110),
                                                      child: Text(displayCount,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                          maxLines: 1,
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: GoogleFonts
                                                              .poppins(
                                                            height: 1.05,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 35,
                                                            color: Colors.white,
                                                          )),
                                                    ),
                                                    Text("total cases",
                                                        style:
                                                            GoogleFonts.poppins(
                                                          height: 1,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 14,
                                                          color: Colors.white,
                                                        ))
                                                  ],
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 23.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: <Widget>[
                                                      ConstrainedBox(
                                                        constraints:
                                                            BoxConstraints(
                                                                maxWidth: 73),
                                                        child: Text(displayTodayCount,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                            maxLines: 1,
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: GoogleFonts
                                                                .poppins(
                                                              height: 1.05,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                              fontSize: 35,
                                                              color:
                                                                  Colors.white,
                                                            )),
                                                      ),
                                                      Text("today",
                                                          style: GoogleFonts
                                                              .poppins(
                                                            height: 1,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                            fontSize: 14,
                                                            color: Colors.white,
                                                          ))
                                                    ],
                                                  ),
                                                )
                                              ],
                                            )),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Positioned(
                                right: 40,
                                top: 8,
                                child: Image.asset(
                                  'assets/images/business.png',
                                  height: 50,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 0.0, bottom: 28.0),
                      child: new Container(
                        height: 125.0,
                        width: 330,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(232, 159, 159, 1),
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.all(Radius.circular(25.0)),
                        ),
                        child: Stack(children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.only(left: 30.0, top: 20),
                            child: Row(
                              children: <Widget>[
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Text("Your location",
                                        textAlign: TextAlign.left,
                                        style: GoogleFonts.poppins(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: Color.fromRGBO(0, 0, 0, 0.35),
                                        )),
                                    Padding(
                                      padding: const EdgeInsets.only(top: 3.5),
                                      child: ConstrainedBox(
                                        constraints:
                                            BoxConstraints(maxWidth: 180),
                                        child: Text(country.name,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            textAlign: TextAlign.left,
                                            style: GoogleFonts.poppins(
                                              height: 1.05,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 30,
                                              color: Colors.white,
                                            )),
                                      ),
                                    ),
                                    ConstrainedBox(
                                      constraints:
                                          BoxConstraints(maxWidth: 250),
                                      child:
                                          Text("Setapak, Wilayah Persekutuan",
                                              overflow: TextOverflow.ellipsis,
                                              style: GoogleFonts.poppins(
                                                height: 1.5,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14,
                                                color: Colors.white,
                                              )),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            right: 40,
                            top: 20,
                            child: Image.asset(
                              'assets/images/street-map.png',
                              height: 50,
                            ),
                          )
                        ]),
                      ),
                    )
                  ],
                ),
              ),
              Positioned(
                child: InkWell(
                    onTap: () {
                      ref.once().then((DataSnapshot snapshot) {
                        setState(() {
                          update(snapshot);
                        });
                      });
                    },
                    child: Text("refresh",
                        style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(50, 50, 255, 0.4)))),
                top: 125.0,
                right: 0,
              )
            ],
          ),
        ),
      ),
    );
  }
}
