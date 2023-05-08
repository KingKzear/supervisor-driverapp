import 'package:driver_app/commons.dart';
import 'package:driver_app/trip_track.dart';
import 'package:driver_app/widgets/trip_card.dart';
import 'package:driver_app/widgets/trip_detail_card.dart';
import 'package:driver_app/widgets/trip_detail_track.dart';
import 'package:driver_app/widgets/trip_info.dart';
import 'package:flutter/material.dart';

import 'widgets/constants.dart';
import 'widgets/ctm_painter.dart';

class TripDetail extends StatefulWidget {
  final dynamic trip;
  final String avatar_url;

  const TripDetail({Key? key, this.trip, required this.avatar_url})
      : super(key: key);

  @override
  State<TripDetail> createState() => _TripDetailState();
}

class _TripDetailState extends State<TripDetail>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _tabController.dispose();
    super.dispose();
  }

  TripInfo getInfoModel(TripStatus type) {
    return TripInfo(
      status: type,
      tripNo: widget.trip['id'],
      company: CompanyInfo(
        companyName: widget.trip['client_name'],
        tripName: widget.trip['trip_name'],
      ),
      busNo: widget.trip['bus_no'],
      passengers: widget.trip['bus_size_id'],
      busLine: BusLineInfo(
        fromTime: DateTime(
            Commons.getYear(widget.trip['start_date']),
            Commons.getMonth(widget.trip['start_date']),
            Commons.getDay(widget.trip['start_date']),
            Commons.getHour(widget.trip['start_time']),
            Commons.getMinute(widget.trip['start_time'])),
        toTime: DateTime(
            Commons.getYear(widget.trip['end_date']),
            Commons.getMonth(widget.trip['end_date']),
            Commons.getDay(widget.trip['end_date']),
            Commons.getHour(widget.trip['end_time']),
            Commons.getMinute(widget.trip['end_time'])),
        // courseName: "${widget.trip['origin_area']} - ${widget.trip['destination_area']}",
        // cityName: widget.trip['origin_city'],
        courseName: "${widget.trip['origin_area'] ?? 'here'} ",
        cityName: widget.trip['origin_city'] ?? "here",
        // courseName: "code here",
        // cityName: "code here",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeConfig().init(context);
    final primaryTabBarHMargin = 150 * SizeConfig.scaleX;

    TripStatus tripStatus = TripStatus.pending;
    if (widget.trip['status'] == "1") {
      tripStatus = TripStatus.pending;
    } else if (widget.trip['status'] == "2") {
      //accept
      tripStatus = TripStatus.accepted;
    } else if (widget.trip['status'] == "3") {
      //reject
      tripStatus = TripStatus.rejected;
    } else if (widget.trip['status'] == "5") {
      //cancel
      tripStatus = TripStatus.canceled;
    } else if (widget.trip['status'] == "4") {
      //start
      tripStatus = TripStatus.started;
    } else if (widget.trip['status'] == "6") {
      //finish
      tripStatus = TripStatus.finished;
    } else if (widget.trip['status'] == "7") {
      //finish
      tripStatus = TripStatus.fake;
    }
    return SafeArea(
      child: Scaffold(
          body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/bg_trip.png"), fit: BoxFit.fill)),
        child: Column(
          children: [
            // SizedBox(height: MediaQuery.of(context).size.height/10,),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: 20,
                    height: 30,
                    margin: EdgeInsets.only(top: 15, left: 30),
                    child: CustomPaint(
                      painter: BackArrowPainter(),
                    ),
                  ),
                ),
                Padding(
                    padding: EdgeInsets.only(top: 25, left: 65),
                    child: Column(
                      children: [
                        Text(
                          "${widget.trip['trip_name']}",
                          style: TextStyle(
                              fontSize: 20,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.none),
                        ),
                        Text(
                          "TRIP #${widget.trip['trip_id']}",
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                              decoration: TextDecoration.none),
                        ),
                      ],
                    )),
              ],
            ),

            Container(
              height: 130 * SizeConfig.scaleY,
              margin: EdgeInsets.only(
                left: primaryTabBarHMargin,
                right: primaryTabBarHMargin,
                top: 50 * SizeConfig.scaleY,
              ),
              decoration: BoxDecoration(
                color: kColorPrimaryBlue,
                borderRadius: BorderRadius.circular(100),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(100)),
                    color: Colors.deepOrangeAccent),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white,
                labelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 40 * SizeConfig.scaleY,
                ),
                tabs: const [
                  Tab(
                    text: "Details",
                  ),
                  Tab(
                    text: "Tracking",
                  )
                ],
              ),
            ),
            Expanded(
                child: TabBarView(
              controller: _tabController,
              children: [
                Container(
                  child: Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 80,
                        ),
                        TripDetailCard(
                          info: getInfoModel(tripStatus),
                          onPressed: () => {print("card selected!")},
                          trip: widget.trip,
                          avatar_url: widget.avatar_url != ""
                              ? widget.avatar_url
                              : "http://167.86.102.230/alnabali/public/images/admin/client_default.png",
                        ),
                      ],
                    ),
                  ),
                ),
                TripDetailTrack(
                  trip_id: widget.trip["id"].toString(),
                )
              ],
            ))
          ],
        ),
      )),
    );
  }
}
