import 'dart:convert';
import 'dart:io';
import 'package:VRecycle/Components/DateTimePicker.dart';
import 'package:VRecycle/Screens/CheckOut.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:VRecycle/Components/AuthButton.dart';
import 'package:VRecycle/Components/Loader.dart';
import 'package:VRecycle/Constants/Colors.dart';
import 'package:VRecycle/Model/Item.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class CheckOutPage extends StatefulWidget {
  final List<Item> cart;
  CheckOutPage({@required this.cart});
  @override
  _CheckOutPageState createState() => _CheckOutPageState();
}

class _CheckOutPageState extends State<CheckOutPage> {
  Firestore _db = Firestore.instance;
  TextEditingController weightController = TextEditingController();
  File _image;
  TextEditingController locationController = TextEditingController();
  Widget dateTimeField = BasicDateTimeField();
  DateTime userDateTime;
  final format = DateFormat("yyyy-MM-dd HH:mm");
  String proof = '';
  String latitude, longitude;
  @override
  void initState() {
    super.initState();
  }

  Future<void> getUserLocation() async {
    try {
      Position position = await Geolocator()
          .getLastKnownPosition(desiredAccuracy: LocationAccuracy.high);
      setState(() {
        latitude = position.latitude.toString();
        longitude = position.longitude.toString();
      });
    } catch (e) {
      print("Unable to get Location.");
    }
  }

  String getCollector() {
    return '7506604268';
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
                            await _db
                                .collection('Orders')
                                .document()
                                .setData({});
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
}
