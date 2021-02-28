import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:VRecycle/Constants/Colors.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';

class OrderDetails extends StatefulWidget {
  @override
  _OrderDetailsState createState() => _OrderDetailsState();

  var order;
  var parent;
  var mode;

  OrderDetails(
      {Key key,
      @required this.order,
      @required this.parent,
      @required this.mode})
      : super(key: key);
}

class _OrderDetailsState extends State<OrderDetails> {
  GoogleMapController mapController;
  String username = "";
  final dataKey = new GlobalKey();
  LatLng _center;
  Map<MarkerId, Marker> markers;
  final collectorsRef = Firestore.instance.collection('Collectors');

  Firestore _db = Firestore.instance;
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    var user_doc =
        _db.collection('Users').document(widget.order["phoneNumberUser"]).get();

    user_doc.then((value) => {
          setState(() => {username = value.data["name"]})
        });
  }

  void setMapLocation() {
    _center = LatLng(
        widget.order["location"].latitude, widget.order["location"].longitude);

    markers = <MarkerId, Marker>{
      MarkerId('marker_id_1'): Marker(
        markerId: MarkerId(widget.order["address"]),
        position: _center,
        infoWindow: InfoWindow(
            title: widget.order["address"],
            snippet: 'Customer: ' + widget.order["phoneNumberUser"]),
      )
    };
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    setMapLocation();

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Utils.getColor(primaryColor),
          title: Text("Order Details"),
          centerTitle: true,
        ),
        body: getBody());
  }

  InkWell _buildButtonColumn(Color color, IconData icon, String label, fn) {
    return InkWell(
        onTap: fn,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color),
            Container(
              margin: const EdgeInsets.only(top: 8),
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: color,
                ),
              ),
            ),
          ],
        ));
  }

  Widget getOrderImage() {
    return Image.memory(base64Decode(widget.order["proof"]),
        width: 380, fit: BoxFit.fill);
  }

  getMap() {
    return SizedBox(
      width:
          MediaQuery.of(context).size.width - 32, // or use fixed size like 200
      height: MediaQuery.of(context).size.height / 2,
      key: dataKey,
      child: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(
          target: _center,
          zoom: 11.0,
        ),
        markers: Set<Marker>.of(markers.values),
      ),
    );
  }

  Widget getScrollablePage() {
    Widget titleSection = Container(
      padding: const EdgeInsets.all(32),
      child: Row(
        children: [
          Expanded(
            /*1*/
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /*2*/
                Container(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    username,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                ),
                Text(
                  widget.order["phoneNumberUser"],
                  style: TextStyle(color: Colors.grey[500], fontSize: 16),
                ),
              ],
            ),
          ),
          Icon(Icons.delete),
          Text(widget.order["approxWeight"].toString() + " gms"),
        ],
      ),
    );

    Color color = Utils.getColor(primaryColor);

    Widget buttonSection = Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildButtonColumn(color, Icons.call, 'CALL',
              () => {launch("tel:" + widget.order["phoneNumberUser"])}),
          _buildButtonColumn(
              color,
              Icons.near_me,
              'ROUTE',
              () => {
                    Scrollable.ensureVisible(dataKey.currentContext,
                        duration: Duration(seconds: 1))
                  }),
        ],
      ),
    );

    Widget textSection = Container(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: ListView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: widget.order["items"].length,
          itemBuilder: (context, index) {
            Map item_map = json.decode(widget.order["items"][index]);

            return ListTile(
              leading: Icon(Icons.arrow_forward),
              trailing: Text(item_map["quantity"].toString()),
              title: Text(item_map["itemName"]),
              subtitle: Text(item_map["desc"]),
            );
          },
        ));

    return ListView(
      children: [
        getOrderImage(),
        titleSection,
        buttonSection,
        Padding(
            padding: EdgeInsets.only(left: 32, top: 32),
            child: Text("Items",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20))),
        textSection,
        getMap()
      ],
    );
  }

  Column getButtonSection() {
    if (widget.mode == "offered") {
      return (Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            color: Color.fromARGB(175, 255, 255, 255),
            width: double.infinity,
            height: 60,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new RaisedButton(
                    color: Color.fromARGB(255, 255, 0, 0),
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: new Text('Decline',
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255))),
                    onPressed: () => {handleDecline()},
                  ),
                  new RaisedButton(
                    color: Color.fromARGB(255, 0, 220, 0),
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: new Text('Accept',
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255))),
                    onPressed: () => {handleAccept()},
                  ),
                ]),
          ),
        ],
      ));
    } else if (widget.mode == "accepted") {
      return (Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            color: Color.fromARGB(175, 255, 255, 255),
            width: double.infinity,
            height: 60,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new RaisedButton(
                    color: Color.fromARGB(255, 0, 220, 0),
                    padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                    child: new Text('Complete',
                        style: TextStyle(
                            color: Color.fromARGB(255, 255, 255, 255))),
                    onPressed: () => {handleComplete()},
                  )
                ]),
          ),
        ],
      ));
    } else {
      return (Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Container(
            color: Color.fromARGB(175, 255, 255, 255),
            width: double.infinity,
            height: 60,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text("Completed On " +
                      DateFormat('d MMMM y')
                          .format(widget.order["completed_at"].toDate()) +
                      " " +
                      DateFormat("jm")
                          .format(widget.order["completed_at"].toDate()))
                ]),
          ),
        ],
      ));
    }
  }

  Widget getBody() {
    return Padding(
        padding: const EdgeInsets.symmetric(),
        child: Stack(
          children: <Widget>[
            getScrollablePage(),
            getButtonSection(),
          ],
        ));
  }

  final AlertDialog accepted = AlertDialog(
    title: Text(
      'Accepted',
      style: TextStyle(color: Colors.green),
      textAlign: TextAlign.center,
    ),
    content: CircleAvatar(
      radius: 30,
      backgroundColor: Colors.green,
      child: Icon(
        Icons.check,
        color: Colors.white,
      ),
    ),
  );
  final AlertDialog declined = AlertDialog(
    title: Text(
      'Declined',
      style: TextStyle(color: Colors.red),
      textAlign: TextAlign.center,
    ),
    content: CircleAvatar(
      radius: 30,
      backgroundColor: Colors.red,
      child: Icon(
        Icons.close,
        color: Colors.white,
      ),
    ),
  );
  final AlertDialog completed = AlertDialog(
    title: Text(
      'Completed',
      style: TextStyle(color: Colors.green),
      textAlign: TextAlign.center,
    ),
    content: CircleAvatar(
      radius: 30,
      backgroundColor: Colors.green,
      child: Icon(
        Icons.check,
        color: Colors.white,
      ),
    ),
  );

  handleComplete() {
    _db.collection('Orders').document(widget.order["id"]).updateData({
      "status": "Order Completed",
      "completed_at": DateTime.now()
    }).whenComplete(() => {
          print("Updated"),
          widget.parent.setState(() => {}),
          showDialog<void>(
              context: context,
              builder: (ctxt) {
                Future.delayed(Duration(seconds: 3), () {
                  Navigator.of(ctxt).pop(true);
                  Navigator.pop(context);
                });
                return completed;
              }),
        });
  }

  handleAccept() {
    _db
        .collection('Orders')
        .document(widget.order["id"])
        .updateData({"status": "Order Accepted"}).whenComplete(() => {
              print("Updated"),
              widget.parent.setState(() => {}),
              showDialog<void>(
                  context: context,
                  builder: (ctxt) {
                    Future.delayed(Duration(seconds: 3), () {
                      Navigator.of(ctxt).pop(true);
                      Navigator.pop(context);
                    });
                    return accepted;
                  }),
            });
  }

  double toRadians(double degree) {
    double one_deg = math.pi / 180;
    return (one_deg * degree);
  }

  double distance(double lat1, double long1, double lat2, double long2) {
    lat1 = toRadians(lat1);
    long1 = toRadians(long1);
    lat2 = toRadians(lat2);
    long2 = toRadians(long2);

    // Haversine Formula
    double dlong = long2 - long1;
    double dlat = lat2 - lat1;

    double ans = math.pow(math.sin(dlat / 2), 2) +
        math.cos(lat1) * math.cos(lat2) * math.pow(math.sin(dlong / 2), 2);

    ans = 2 * math.asin(math.sqrt(ans));
    double r = 6371;

    ans = ans * r;
    return ans;
  }

  Future<List<Map<String, dynamic>>> getSortedCollectors(
      GeoPoint location) async {
    QuerySnapshot querySnapshot =
        await Firestore.instance.collection("Collectors").getDocuments();
    var documents = querySnapshot.documents;
    List<Map<String, dynamic>> collectors = new List<Map<String, dynamic>>();
    documents.forEach((doc) {
      Map<String, dynamic> collector = doc.data;
      GeoPoint geo = doc["geopoint"];
      double dist = distance(
          location.latitude, location.longitude, geo.latitude, geo.longitude);
      collector["distance"] = dist;
      collector["phone_number"] = doc.documentID;
      collectors.add(collector);
    });
    collectors.sort((a, b) => a["distance"].compareTo(b["distance"]));
    return collectors;
  }

  Future<String> getCollector(Timestamp pickupTime, GeoPoint location,
      List<String> phoneNumberdeclinedCollector) async {
    bool flag = true;

    List<Map<String, dynamic>> collectors = new List<Map<String, dynamic>>();
    collectors = await getSortedCollectors(location);
    // for (int i = 0; i < collectors.length; i++) {
    //   print(collectors[i]["geopoint"].latitude.toString() +
    //       " " +
    //       collectors[i]["geopoint"].longitude.toString() +
    //       " " +
    //       collectors[i]["phone_number"].toString() +
    //       " " +
    //       collectors[i]["Orders"].toString());
    // }
    for (int i = 0; i < collectors.length; i++) {
      String phoneNumber = collectors[i]["phone_number"];
      if ((phoneNumberdeclinedCollector != null &&
              phoneNumberdeclinedCollector.contains(phoneNumber)) ||
          phoneNumber == widget.order["phoneNumberCollector"]) {
        continue;
      }
      setState(() {
        flag = true;
      });
      try {
        var list = collectors[i]["Orders"];
        for (int j = 0; j < list.length; j++) {
          var diff = pickupTime
              .toDate()
              .difference(list[i]["timestamp"].toDate())
              .inHours;
          if (diff < 2) {
            setState(() {
              flag = false;
            });
          }
        }
        if (flag == true) {
          return phoneNumber;
        }
      } catch (_) {
        return phoneNumber;
      }
    }

    return 'Could not find a collector.';
  }

  handleDecline() async {
    String phoneNumberCollector = await getCollector(widget.order["timestamp"],
        widget.order["location"], widget.order["phoneNumberdeclinedCollector"]);
    if (phoneNumberCollector == 'Could not find a collector.') {
      _db
          .collection('Orders')
          .document(widget.order["id"])
          .updateData({"status": "Order Declined"}).whenComplete(() => {
                print("Updated"),
                widget.parent.setState(() => {}),
                showDialog<void>(
                    context: context,
                    builder: (ctxt) {
                      Future.delayed(Duration(seconds: 3), () {
                        Navigator.of(ctxt).pop(true);
                        Navigator.pop(context);
                      });
                      return declined;
                    }),
              });
    } else {
      _db.collection('Orders').document(widget.order["id"]).updateData({
        "phoneNumberCollector": phoneNumberCollector,
        "phoneNumberdeclinedCollector":
            FieldValue.arrayUnion([widget.order["phoneNumberCollector"]])
      }).whenComplete(() => {
            print("Updated"),
            widget.parent.setState(() => {}),
            collectorsRef.document(phoneNumberCollector).updateData({
              'Orders': FieldValue.arrayUnion(
                  [_db.collection('Orders').document(widget.order["id"])])
            }),
            showDialog<void>(
                context: context,
                builder: (ctxt) {
                  Future.delayed(Duration(seconds: 3), () {
                    Navigator.of(ctxt).pop(true);
                    Navigator.pop(context);
                  });
                  return declined;
                }),
          });
    }
  }
}
