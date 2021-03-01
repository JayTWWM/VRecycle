import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'package:VRecycle/Components/DateTimePicker.dart';
import 'package:VRecycle/Model/Order.dart';
import 'package:VRecycle/Screens/CheckOut.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:VRecycle/Components/AuthButton.dart';
import 'package:VRecycle/Components/Loader.dart';
import 'package:VRecycle/Constants/Colors.dart';
import 'package:VRecycle/Model/Item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CheckOutPage extends StatefulWidget {
  final List<Item> cart;
  CheckOutPage({@required this.cart});
  @override
  _CheckOutPageState createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  Firestore _db = Firestore.instance;
  FirebaseAuth _auth = FirebaseAuth.instance;
  TextEditingController weightController = TextEditingController();
  File _image;
  TextEditingController locationController = TextEditingController();
  Widget dateTimeField = BasicDateTimeField();
  DateTime userDateTime;
  final usersRef = Firestore.instance.collection('Users');
  final collectorsRef = Firestore.instance.collection('Collectors');
  final format = DateFormat("yyyy-MM-dd HH:mm");
  String proof = '';
  double latitude, longitude;
  String phoneNumberUser;
  List<String> empty;
  @override
  void initState() {
    super.initState();
    getUserDetails();
  }

  void getUserDetails() async {
    FirebaseUser _user = await _auth.currentUser();
    phoneNumberUser = _user.phoneNumber.substring(3);
    print(phoneNumberUser);
  }

  Future<void> getUserLocation() async {
    try {
      Position position = await Geolocator()
          .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });
    } catch (e) {
      print("Unable to get Location.");
    }
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

  Future<String> getCollector(Timestamp pickupTime, GeoPoint location) async {
    bool flag = true;

    List<Map<String, dynamic>> collectors = new List<Map<String, dynamic>>();
    collectors = await getSortedCollectors(location);
    for (int i = 0; i < collectors.length; i++) {
      print(collectors[i]["geopoint"].latitude.toString() +
          " " +
          collectors[i]["geopoint"].longitude.toString() +
          " " +
          collectors[i]["phone_number"].toString() +
          " " +
          collectors[i]["Orders"].toString());
    }
    for (int i = 0; i < collectors.length; i++) {
      setState(() {
        flag = true;
      });
      String phoneNumber = collectors[i]["phone_number"];
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Utils.getColor(primaryColor),
          title: Text("Checkout page")),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: TextField(
              controller: weightController,
              obscureText: false,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(width: 10),
                ),
                fillColor: Utils.getColor(primaryColor),
                labelText: 'Approximate Weight in KGs',
                prefixIcon: Icon(Icons.description),
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: TextField(
              controller: locationController,
              obscureText: false,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.all(10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide(width: 10),
                ),
                fillColor: Utils.getColor(primaryColor),
                labelText: 'Enter address.',
                prefixIcon: Icon(Icons.description),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              getImage();
            },
            child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                    border:
                        Border(bottom: BorderSide(color: Colors.grey[200]))),
                child: Column(children: <Widget>[
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Utils.getColor(primaryColor)),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        _image == null
                            ? Icon(
                                Icons.person_add,
                                color: Utils.getColor(primaryColor),
                                size: 30,
                              )
                            : Image.file(
                                _image,
                                height: 50,
                                width: 50,
                              ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            'Select Image for proof',
                            style: TextStyle(
                                color: Utils.getColor(primaryColor),
                                fontSize: 18),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(20, 10, 20, 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("Choose pickup date and time:"),
                        DateTimeField(
                          initialValue: DateTime.now(),
                          format: format,
                          onShowPicker: (context, currentValue) async {
                            final date = await showDatePicker(
                                context: context,
                                firstDate: DateTime(1900),
                                initialDate: currentValue ?? DateTime.now(),
                                lastDate: DateTime(2100));
                            if (date != null) {
                              final time = await showTimePicker(
                                context: context,
                                initialTime: TimeOfDay.fromDateTime(
                                    currentValue ?? DateTime.now()),
                              );
                              setState(() {
                                userDateTime =
                                    DateTimeField.combine(date, time);
                              });
                            } else {
                              setState(() {
                                userDateTime = currentValue;
                              });
                            }
                            return userDateTime;
                          },
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                        child: AuthButton(
                          btnText: 'Place the order',
                          onTap: () async {
                            await getUserLocation();
                            Timestamp pickupTime = Timestamp.fromDate(userDateTime);
                            GeoPoint location = GeoPoint(latitude, longitude);
                            String collectorNumber =
                                await getCollector(pickupTime, location);
                            if (collectorNumber ==
                                'Could not find a collector.') {
                              Scaffold.of(context).showSnackBar(new SnackBar(
                                  content: new Text(collectorNumber)));
                            } else {
                              Order order = new Order(
                                  phoneNumberUser: phoneNumberUser,
                                  phoneNumberCollector: collectorNumber,
                                  items: widget.cart,
                                  approxWeight: double.parse(
                                      weightController.text.trim()),
                                  timestamp: pickupTime,
                                  location: location,
                                  address: locationController.text.trim(),
                                  proof: proof,
                                  status: 'Order Placed',
                                  phoneNumberdeclinedCollector: empty);
                              DocumentReference _docRef =
                                  _db.collection('Orders').document();
                              _docRef.setData(order.toJson());
                              usersRef.document(phoneNumberUser).updateData({
                                'Orders': FieldValue.arrayUnion([_docRef])
                              });
                              collectorsRef
                                  .document(collectorNumber)
                                  .updateData({
                                'Orders': FieldValue.arrayUnion([_docRef])
                              });
                              SharedPreferences _prefs =
                                  await SharedPreferences.getInstance();
                              var fireIns =
                                  collectorsRef.document(collectorNumber);
                              DocumentSnapshot doc = await fireIns.get();
                              String playerId = doc.data["onesignalId"];
                              _handleNotif(playerId);
                              _prefs.clear();
                            }
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ],
                  )
                ])),
          ),
        ],
      ),
    );
  }

  Future getImage() async {
    var image = await ImagePicker()
        .getImage(source: ImageSource.gallery, maxHeight: 300, maxWidth: 300);
    setState(() {
      _image = File(image.path);
      print('Image path $_image');
    });
    if (_image != null) {
      File croppedImage = await ImageCropper.cropImage(
          sourcePath: _image.path,
          maxWidth: 1080,
          maxHeight: 1080,
          aspectRatio: CropAspectRatio(ratioX: 1.0, ratioY: 1.0));
      if (croppedImage != null) {
        setState(() {
          _image = croppedImage;
        });
      }
      final bytes = _image.readAsBytesSync();
      String downloadUrl = base64Encode(bytes);
      setState(() {
        proof = downloadUrl;
      });
    }
  }

  void _handleNotif(String playerId) async {
    var notification1 = OSCreateNotification(
        sendAfter: DateTime.now().subtract(DateTime.now().timeZoneOffset),
        playerIds: [playerId],
        content: "You've got an order for ${locationController.text.trim()}!!",
        heading: "GOT AN ORDER!");
    var response1 = await OneSignal.shared.postNotification(notification1);
    print("response1 :" + response1.toString());
  }
}
