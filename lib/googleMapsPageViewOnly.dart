import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:road_safety/services/geolocator_service.dart';
import 'package:road_safety/provider/location_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

class GoogleMapsPageViewOnly extends StatefulWidget {
  @override
  _GoogleMapsPageViewOnlyState createState() => _GoogleMapsPageViewOnlyState();
}

class _GoogleMapsPageViewOnlyState extends State<GoogleMapsPageViewOnly> {
  List<Marker> allMarker = [];
  List<LatLng> addd = [LatLng(24.5433433, 74.13243534)];

  final GeolocatorService geoService = GeolocatorService();
  Completer<GoogleMapController> _controller = Completer();

  var distanceInMeters = 0.0;
  double speed = 10;
  var loc;
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

  @override
  void initState() {
    super.initState();
    geoService.getCurrentLocation().listen((position) {
      centerScreen(position);
    });
    Firebase.initializeApp();
    final databaseReference = FirebaseFirestore.instance;
    Provider.of<LocationProvider>(context, listen: false).initialization();

    //initPlatformState();
    if (!mounted)
      return;
    else {
      new Timer.periodic(
          Duration(seconds: 3),
          (Timer t) => {
                setState(() {
                  speed = LocationProvider.speed;
                  distanceInMeters = LocationProvider.distanceInMeter;

                  if (distanceInMeters < 0) {
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
                              "Bumper Ahead!!  Be Carefull",
                              style: TextStyle(
                                  fontSize: 20, fontStyle: FontStyle.italic),
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
                })
              });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Road Safety"),
          backgroundColor: Colors.blue,
        ),
        body: googleMapUI());
  }

  Widget googleMapUI() {
    return Consumer<LocationProvider>(builder: (consumerContext, model, child) {
      if (model.locationPosition != null) {
        return Column(
          children: [
            Expanded(
              child: GoogleMap(
                mapType: MapType.normal,
                initialCameraPosition:
                    CameraPosition(target: model.locationPosition, zoom: 18),
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
              ),
            ),
            Text(
              "Info : ${double.parse((distanceInMeters).toStringAsFixed(2)) < 10 ? "Bumper Ahead" : "No bumper"}",
              style: TextStyle(fontSize: 20),
            ),
            Text(
              'Speed : $speed',
              style: TextStyle(fontSize: 20),
            ),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Go Back!',
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

  @override
  void dispose() {
    // player.dispose();
    super.dispose();
    mounted;
  }
}
