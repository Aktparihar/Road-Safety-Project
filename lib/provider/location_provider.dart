import 'dart:async';
import 'dart:collection';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:geolocator/geolocator.dart';
import 'package:audioplayers/audio_cache.dart';

class LocationProvider with ChangeNotifier {
  Location _location;
  Location get location => _location;
  LatLng _locationPosition;
  LatLng get locationPosition => _locationPosition;
  bool locationServiceActive = true;

  AudioCache player = new AudioCache();

  var geolocator = Geolocator();
  static double speed = 0;
  static double distanceInMeter = 0.0;
  double caldist;
  String alarmAudioPath = "alarm.mp3";
  //List<double> dtLst = [];
  static SplayTreeSet dtLst = new SplayTreeSet();
  static LatLng loc;
  LocationProvider() {
    _location = new Location();
  }

  void handleTick() {
    player.play(alarmAudioPath);
    player.clearCache();
  }

  //Initialization Method
  initialization() async {
    await getUserLocation();
  }

  getUserLocation() async {
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();

      if (!_serviceEnabled) {
        return;
      }
    }
    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    location.onLocationChanged.listen((LocationData currentLocation) {
      _locationPosition =
          LatLng(currentLocation.latitude, currentLocation.longitude);
      //print(_locationPosition);
      loc = LatLng(currentLocation.latitude, currentLocation.longitude);
      notifyListeners();

      //var options = LocationOptions(accuracy: LocationAccuracy.high, distanceFilter: 10);

      StreamSubscription<Position> homeTabPostionStream;

      homeTabPostionStream = Geolocator.getPositionStream(distanceFilter: 10)
          .listen((Position event) {
        speed = event.speed;
        dtLst.add(0.0);
        FirebaseFirestore.instance
            .collection("locations")
            .get()
            .then((QuerySnapshot snapshot) {
          for (int i = 0; i < snapshot.docs.length; i++) {
            caldist = Geolocator.distanceBetween(
              double.parse((loc.latitude).toStringAsFixed(7)),
              double.parse((loc.longitude).toStringAsFixed(7)),
              double.parse((snapshot.docs[i].data()['position'].latitude)
                  .toStringAsFixed(7)),
              double.parse((snapshot.docs[i].data()['position'].longitude)
                  .toStringAsFixed(7)),
            );
            //print("This is point: ");
            //print(caldist);
            if (caldist < 20) {
              dtLst.add(caldist);
              continue;
            }
          }
        });
      });
      print(dtLst);
      //print(speed);
      //dtLst.sort();
      //print(dtLst);
      if (dtLst.isNotEmpty) {
        if (dtLst.length > 1) {
          distanceInMeter = dtLst.last;
          handleTick();
        } else {
          distanceInMeter = dtLst.first;
        }
      }
      //if (dtLst != null && dtLst.isNotEmpty) distanceInMeter = dtLst.first;
      dtLst.clear();

      if (dtLst.isEmpty) {
        dtLst.add(0.0);
      }
      // if (speed - 6 < 0) {
      //   speed = 0;
      // } else {
      //   ((speed.ceil() - 6) * 6;
      // }
      // print(loc.latitude);
      //print(distanceInMeter);
      // print(((speed).ceil()) - 6 * 6);
      // print(loc.longitude);
    });
  }
}
