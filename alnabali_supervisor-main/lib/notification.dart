// ignore_for_file: avoid_print

import 'package:driver_app/commons.dart';
import 'package:driver_app/trip_detail.dart';
import 'package:driver_app/widgets/notification_panel.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:developer' as developer;
import 'dart:convert';
import 'package:loading_indicator/loading_indicator.dart';

const List<Color> _kDefaultRainbowColors = const [
  Colors.red,
  Colors.orange,
  Colors.yellow,
  Colors.green,
  Colors.blue,
  Colors.indigo,
  Colors.purple,
];

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  int page = 0;
  late String todayDate = "01-01-2022";
  final ScrollController _scrollController = ScrollController();
  bool isLoading = false;
  List notifications = List.empty(growable: true);

  Future<dynamic> getTrip(String tripId) async {
    Map<String, String> requestHeaders = {
      'Content-type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
      'Cookie': Commons.cookie,
    };

    final response = await http.get(
        Uri.parse(
            'http://167.86.102.230/alnabali/public/android/daily-trip/${tripId}'),
        // Send authorization headers to the backend.
        headers: requestHeaders);

    Map<String, dynamic> responseJson = jsonDecode(response.body);

    var trip = responseJson["result"];

    return trip;
  }

  void setTodayDate() {
    // DateTime now = DateTime.now();
    // todayDate = "${now.day}-${now.day}-${now.year}";
    final now = DateTime.now();

    final today = DateTime(now.year, now.month, now.day);

    todayDate = '${DateFormat('dd/MM/yyyy').format(today)}';
  }

  @override
  void initState() {
    setTodayDate();
    Commons.isTrip = false;
    _getMoreNotifications(page);
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _getMoreNotifications(page);
      }
    });
  }

  void _markNotificationAsRead(String notificationId) async {
    String url = "${Commons.baseUrl}notification/mark-read/$notificationId";
    var response = await http.post(Uri.parse(url), body: {}, headers: {
      'Content-type': 'application/x-www-form-urlencoded',
      'Accept': 'application/json',
      'Cookie': Commons.cookie,
      'X-CSRF-TOKEN': Commons.token
    });

    developer.log("updateImage" + response.body.toString());
  }

  void _getMoreNotifications(int index) async {
    if (!isLoading) {
      setState(() {
        isLoading = true;
      });

      String url =
          // "${Commons.baseUrl}notification/all/${Commons.login_id}?page=$page";
          "${Commons.baseUrl}notification/all/supervisor_${Commons.login_id}";
      // "${Commons.baseUrl}notification/today";
      var response = await http.get(
        Uri.parse(url),
      );
      Map<String, dynamic> responseJson = jsonDecode(response.body);
      print(responseJson['result'].length);
      if (response.statusCode == 200) {
        if (responseJson['result'].length < 1) {
          setState(() {
            isLoading = false;
          });
          return;
        }
        for (int i = 0; i < responseJson['result'].length; i++) {
          notifications.add(responseJson['result'][i]);
        }
      } else {
        Fluttertoast.showToast(
            msg: "Server Error",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            backgroundColor: Colors.white,
            textColor: Colors.red,
            fontSize: 16.0);
      }
      setState(() {
        isLoading = false;
        page++;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Container(
                decoration: const BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage("assets/bg_notification.png"),
                        fit: BoxFit.fill)),
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        height: MediaQuery.of(context).size.height -
                            MediaQuery.of(context).size.height / 4,
                        margin: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height / 12),
                        child: _buildList(),
                      ),
                      Container(
                          alignment: Alignment.bottomCenter,
                          margin: EdgeInsets.only(
                            bottom: MediaQuery.of(context).size.height / 55,
                            left: MediaQuery.of(context).size.width / 20,
                            right: MediaQuery.of(context).size.width / 20,
                          ),
                          width: MediaQuery.of(context).size.width * 0.9,
                          height: MediaQuery.of(context).size.height / 15,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(50)),
                            color: Colors.orange,
                          ),
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/main');
                                },
                                child: Container(
                                    child: Padding(
                                  padding: EdgeInsetsDirectional.only(
                                      start: MediaQuery.of(context).size.width *
                                          0.08,
                                      top: 20,
                                      bottom: 15),
                                  child:
                                      Image.asset("assets/navbar_track2.png"),
                                )),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/trip');
                                },
                                child: Container(
                                    child: Padding(
                                  padding: EdgeInsetsDirectional.only(
                                      start: MediaQuery.of(context).size.width *
                                          0.08,
                                      top: 20,
                                      bottom: 15),
                                  child: Image.asset("assets/navbar_trip.png"),
                                )),
                              ),
                              Container(
                                width: MediaQuery.of(context).size.width * 0.41,
                                height: MediaQuery.of(context).size.height / 20,
                                margin: EdgeInsets.only(
                                    left: 20, top: 10, bottom: 10, right: 5),
                                child: TextField(
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontFamily: 'Montserrat',
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                      enabled: false,
                                      prefixIcon: Padding(
                                        padding: EdgeInsetsDirectional.only(
                                            start: 5, top: 10, bottom: 10),
                                        child: Image.asset(
                                          "assets/navbar_notification2.png",
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      contentPadding: EdgeInsets.only(right: 5),
                                      hintText: "notification".tr(),
                                      hintStyle: const TextStyle(
                                        color: Colors.red,
                                        fontSize: 12,
                                        fontFamily: 'Montserrat',
                                        fontWeight: FontWeight.w500,
                                      ),
                                      border: const OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(50)))),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/profile');
                                },
                                child: Container(
                                    child: Padding(
                                  padding: EdgeInsetsDirectional.only(
                                      start: MediaQuery.of(context).size.width *
                                          0.03,
                                      top: 20,
                                      bottom: 15),
                                  child: Image.asset("assets/navbar_user.png"),
                                )),
                              ),
                            ],
                          ))
                    ]))));
  }

  Widget _buildList() {
    return RefreshIndicator(
      onRefresh: () async {
        page = 0;
        notifications.clear();
        _getMoreNotifications(0);
      },
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        // controller: _scrollController,
        // For header and lazy loading
        itemCount: notifications.length + 1,
        padding: const EdgeInsets.only(top: 10),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    color: Colors.black,
                    height: 1,
                    width: MediaQuery.of(context).size.width / 4,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Text(
                    "Today, $todayDate",
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Container(
                    color: Colors.black,
                    height: 1,
                    width: MediaQuery.of(context).size.width / 4,
                  ),
                ],
              ),
            );
          }
          if (index == notifications.length) {
            return _buildProgressIndicator();
          } else {
            String time = notifications[index]['updated_at'];
            time = time.split("T")[1];
            time = time.substring(0, 5);

            String tripType = "";
            switch (notifications[index]['status']) {
              case 1:
                tripType = "pending";
                break;
              case 2:
                tripType = "accept";
                break;
              case 3:
                tripType = "reject";
                break;
              case 4:
                tripType = "start";
                break;
              case 6:
                tripType = "finish";
                break;
              case 5:
                tripType = "cancel";
                break;
              case 7:
                tripType = "fake";
                break;
              default:
                break;
            }

            return Container(
                alignment: Alignment.topCenter,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        _markNotificationAsRead(
                            notifications[index]["id"].toString());
                        getTrip(notifications[index]["daily_trip_id"]
                                .toString())
                            .then((value) {
                          return Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TripDetail(
                                    avatar_url: value["client_avatar"],
                                    trip: value),
                              ));
                        });
                      },
                      child: NotificationPanel(
                        tripID: "#${notifications[index]["disp_trip_id"]}",
                        tripName: notifications[index]['trip_name'],
                        tripType: tripType,
                        message: notifications[index]['message'],
                        avatar_url: notifications[index]['client_avatar'],
                        viewed: notifications[index]['viewed'],
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomRight,
                      margin: EdgeInsets.only(
                          right: MediaQuery.of(context).size.width / 12,
                          top: 8,
                          bottom: 8),
                      child: Text(
                        time,
                        style: const TextStyle(
                          fontSize: 10,
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    )
                  ],
                ));
          }
        },
        shrinkWrap: true,
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Opacity(
          opacity: isLoading ? 1.0 : 00,
          // child: const CircularProgressIndicator(),
          child: LoadingIndicator(
              indicatorType: Indicator.ballRotateChase,
              colors: _kDefaultRainbowColors,
              strokeWidth: 4.0),
        ),
      ),
    );
  }
}
