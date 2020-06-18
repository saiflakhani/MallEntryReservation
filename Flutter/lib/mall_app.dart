import 'package:flutter/material.dart';
import 'views/bookings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'views/parking_grid.dart';

class MallApp extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return new MallAppState();
  }
}

class MallAppState extends State<MallApp> with TickerProviderStateMixin {

  TabController _tabController; //Switch between spaces and bookings
  TabController _upcomingController; // Switch between past and present bookings
  bool isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    //futureAlbum = fetchAlbum();
    //The following functions are defined in bookings.dart
    // upcomingCards = fetchUpcomingBookings();
    //previousCards = fetchPreviousBookings();

    _tabController = new TabController(length: 2, vsync: this);
    _upcomingController = new TabController(length: 2, vsync: this);
    // checkIfLoggedIn()
    //     .then((value) => {isLoggedIn = (value != null) ? true : false, getAppBar()});
  }

  // THE UI of the Application
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: getAppBar(),
      body: Column(children: <Widget>[
        Container(
            child: Image(
          width: double.infinity,
          height: 200,
          image: AssetImage('assets/slotbookingimage.png'),
          fit: BoxFit.fill,
        )),
        TabBar(
          unselectedLabelColor: Colors.blueGrey,
          labelColor: Colors.black,
          indicatorColor: Colors.black,
          controller: _tabController,
          tabs: [
            new Tab(text: "VIEW ALL SPACES"),
            new Tab(text: "MY BOOKINGS"),
          ],
        ),
        Expanded(
          child: Container(
            child: TabBarView(children: [
              new Container(
                  color: Colors.black12,
                  child: Flex(direction: Axis.vertical, children: <Widget>[
                    Expanded(
                      child: FutureBuilder(
                        future: fetchParkingGrid(),
                        builder: (context, snapshot) {
                          return snapshot.data != null
                              ? getGridViewWidget(snapshot.data)
                              : Center(child: CircularProgressIndicator());
                        },
                      ),
                    ),
                  ])),
              // Column(
              //   children: <Widget>[
              //     // new Container(
              //     //     child: Material(
              //     //   color: Colors.black,
              //     //   child: TabBar(
              //     //       unselectedLabelColor: Colors.grey,
              //     //       labelColor: Colors.white,
              //     //       indicatorColor: Colors.black,
              //     //       controller: _upcomingController,
              //     //       tabs: [
              //     //         new Tab(text: "UPCOMING"),
              //     //         new Tab(text: "PREVIOUS")
              //     //       ]),
              //     // )),
              //     // Expanded(
              //     //     child: TabBarView(
              //     //   children: <Widget>[
              //     Column(children: <Widget>[
              //       Expanded(
              //         child: FutureBuilder(
              //             future: fetchReservations(),
              //             builder: (context, snapshot) {
              //               print(snapshot.data);
              //               return snapshot.data != null
              //                   ? getListViewWidget(snapshot.data)
              //                   : Center(child: CircularProgressIndicator());
              //             }),
              //       )
              //     ]),
              //     //     Column(children: <Widget>[
              //     //       Expanded(
              //     //         child: ListView(
              //     //           children: previousCards,
              //     //         ),
              //     //       )
              //     //     ]),
              //     //   ],
              //     //   controller: _upcomingController,
              //     // ))
              //   ],
              // )
              Expanded(
                child: Container(
                    color: Colors.black12,
                    child: Column(children: <Widget>[
                      Expanded(
                          child: Row(
                          children: <Widget>[
                            RotatedBox(
                                quarterTurns: -1,
                                child: Container(
                                  child: Text(
                                    'Upcoming',
                                    style: TextStyle(
                                      color: Colors.blueAccent,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                )),
                            Expanded(
                              child: Container(
                                child: FutureBuilder(
                                    future: fetchReservations(),
                                    builder: (context, snapshot) {
                                      //print(snapshot.data);
                                      return (snapshot.data!=null && snapshot.data['upcomingReservations'] != null)
                                          ? getListViewWidget(snapshot.data['upcomingReservations'])
                                          : Center(
                                              child:
                                                  CircularProgressIndicator());
                                    }),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(color: Colors.blueAccent, height: 10.0, thickness: 10.0,),
                      Expanded(
                          child: Row(
                          children: <Widget>[
                            RotatedBox(
                                quarterTurns: -1,
                                child: Text(
                                  'Previous',
                                  style: TextStyle(
                                    color: Colors.blueAccent,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w900,
                                  ),
                                )),
                            Expanded(
                              child: Container(
                                child: FutureBuilder(
                                    future: fetchReservations(),
                                    builder: (context, snapshot) {
                                      //print(snapshot.data);
                                      return (snapshot.data!=null && snapshot.data['pastReservations'] != null)
                                          ? getListViewWidget(snapshot.data['pastReservations'])
                                          : Center(
                                              child:
                                                  CircularProgressIndicator());
                                    }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ])),
              )
            ], controller: _tabController),
          ),
        )
      ]),
    );
  }

  Future<Map<String, dynamic>> checkIfLoggedIn() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int personId = prefs.getInt('personId');
    String personName = prefs.getString('personName');
    if (personId != null)
      return ({"personId": personId, "personName": personName});
    else
      return null;
  }

  Widget getAppBar() {
    return AppBar(title: Text('Mall Spot Reservation', style: TextStyle(fontWeight: FontWeight.bold)),
    backgroundColor: Colors.black,
    actions: <Widget>[
      IconButton(icon: Icon(Icons.refresh), onPressed: (){
        fetchParkingGrid();
      },)
    ],);
  }
}
