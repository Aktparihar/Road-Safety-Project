import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:road_safety/services/geolocator_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:road_safety/provider/location_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
//import 'package:audioplayers/audioplayers.dart';
import 'package:audioplayers/audio_cache.dart';
import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
import 'package:sensors/sensors.dart';
import 'package:stack/stack.dart' as Stk;

class GoogleMapsPage extends StatefulWidget {
  @override
  _GoogleMapsPageState createState() => _GoogleMapsPageState();
}

class _GoogleMapsPageState extends State<GoogleMapsPage> {
  List<Marker> allMarker = [];
  List<LatLng> addd = [LatLng(24.5433433, 74.13243534)];
  Stk.Stack<LatLng> st;
  LatLng lt = LatLng(24.5433433, 74.13243534);

  double x = 0.0, y = 0.0, z = 0.0;

  Duration oneSec = const Duration(seconds: 1);
  Duration interval = Duration(minutes: 1);
  IconData iconCancel = Icons.cancel;
  IconData iconStart = Icons.alarm;
  String alarmAudioPath = "alarm.mp3";

  final GeolocatorService geoService = GeolocatorService();
  Completer<GoogleMapController> _controller = Completer();
  var distance = 0.0;
  double speed = 0;
  LocationProvider loc;
  //var loc;
  GoogleMapController mapController;
  var clients = [];
  Map<MarkerId, Marker> markers = <MarkerId, Marker>{};

  Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))
        .buffer
        .asUint8List();
  }

  DateTime duration =
      new DateTime.fromMicrosecondsSinceEpoch(Duration.microsecondsPerSecond);
  Timer counterSeconds;
  Icon iconTimerStarter = new Icon(Icons.alarm);
  //DateFormat minutesSeconds = new DateFormat("ms");
  AudioCache player = new AudioCache();

  void handleTick() {
    setState(() {
      if (LocationProvider.distanceInMeter > 0) {
        player.play(alarmAudioPath);
        player.clearCache();
      }
      player.clearCache();
      // player.play(alarmAudioPath);
      // stopTimer();
    });
  }

  void _setIconForButton(Icon icon) {
    setState(() {
      iconTimerStarter = icon;
    });
  }

  getUserLocation() async {
    StreamSubscription<Position> homeTabPostionStream;

    homeTabPostionStream = Geolocator.getPositionStream(distanceFilter: 4)
        .listen((Position event) {
      speed = event.speed;
    });
  }

  int cnt = 0;
  @override
  void initState() {
    accelerometerEvents.listen((AccelerometerEvent event) {
      setState(() {
        x = event.x;
        y = event.y;
        if (y > 25 && !addd.contains(LocationProvider.loc)) {
          FirebaseFirestore.instance.collection('locations').add({
            'position': new GeoPoint(
                LocationProvider.loc.latitude, LocationProvider.loc.longitude),
          });
          addd.add(LocationProvider.loc);
          allMarker.add(Marker(
            markerId: MarkerId(LocationProvider.loc.toString()),
            position: LocationProvider.loc,
          ));
        }
        z = event.z;
      });
    });
    super.initState();

    //setCustomMarker();

    geoService.getCurrentLocation().listen((position) {
      centerScreen(position);
    });
    Provider.of<LocationProvider>(context, listen: false).initialization();
    Timer.periodic(Duration(milliseconds: 600), (Timer t) {
      setState(() {
        getAlert();
      });
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      setState(() {
        //speed = LocationProvider.speed;
        distance = LocationProvider.distanceInMeter;
        //print("distance in mark is $distanceInMeters");
        getUserLocation();
        getAlert();
        //handleTick();
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).backgroundColor,
        appBar: AppBar(
          centerTitle: true,
          title: Text("Road Safety"),
          backgroundColor: Colors.blue,
        ),
        body: googleMapUI());
  }

  Widget googleMapUI() {
    return Consumer<LocationProvider>(builder: (consumerContext, model, child) {
      _handleTap(LatLng tappedPoint) {
        setState(() {
          // myMarker = [];
          FirebaseFirestore.instance.collection('locations').add({
            'position':
                new GeoPoint(tappedPoint.latitude, tappedPoint.longitude)
          });

          addd.add(tappedPoint);
          allMarker.add(Marker(
            markerId: MarkerId(tappedPoint.toString()),
            position: tappedPoint,
          ));

          for (int i = 0; i < addd.length; i++) {
            print("$i item is $addd[i]");
          }
        });
      }

      if (model.locationPosition != null) {
        return Column(
          children: [
            Expanded(
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition: CameraPosition(
                  target: model.locationPosition,
                  zoom: 30,
                ),
                myLocationEnabled: true,
                myLocationButtonEnabled: true,
                onMapCreated: (GoogleMapController controller) {
                  setState(() {
                    mapController = controller;
                    _controller.complete(controller);
                    getData();
                  });
                },
                markers: Set.from(allMarker),
                onTap: _handleTap,
              ),
            ),
            Text(
              "Info : ${double.parse((LocationProvider.distanceInMeter).toStringAsFixed(2)) > 0 ? "Bumper Ahead" : "No bumper"}",
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Speed : ${(speed).ceil() - 6 < 0 ? 0 : double.parse((speed).toStringAsFixed(2)) * 4} kmph',
              style: TextStyle(fontSize: 20),
            ),
            // FlatButton(
            //   onPressed: () async {
            //     await player.setAsset('assets/audio/moo.mp3');
            //     player.play();
            //   },
            //   child: Text("Sound"),
            // ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  y.toStringAsFixed(2),
                  style: TextStyle(
                    color: Colors.grey[700],
                  ),
                ),
              ),
            ),
          ],
        );
      }

      return Container(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    });
  }

  void getData() async {
    final Uint8List markerIcon =
        await getBytesFromAsset('assets/images/bump.png', 100);
    FirebaseFirestore.instance
        .collection("locations")
        .get()
        .then((QuerySnapshot snapshot) {
      for (int i = 0; i < snapshot.docs.length; i++) {
        allMarker.add(Marker(
          icon: BitmapDescriptor.fromBytes(markerIcon),
          markerId: MarkerId(snapshot.docs[i].id),
          position: LatLng(snapshot.docs[i].data()['position'].latitude,
              snapshot.docs[i].data()['position'].longitude),
        ));
      }
    });
  }

  Future<void> centerScreen(Position position) async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
        target: LatLng(position.latitude, position.longitude), zoom: 18.0)));
  }

  void getAlert() {
    if (LocationProvider.distanceInMeter > 0) {
      showDialog(
          context: context,
          builder: (ctx) {
            Future.delayed(Duration(seconds: 1), () {
              Navigator.of(context).pop(true);
            });
            return AlertDialog(
              backgroundColor: Colors.red,
              title: Center(
                child: Text(
                  "Alert",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              content: Text(
                "Bumper Ahead!!  Be Carefull!! Please Slow Speed!!",
                style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
              ),
              actions: [
                FlatButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                  },
                )
              ],
            );
          });
    }
  }
}
