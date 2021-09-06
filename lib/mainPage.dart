import 'package:flutter/material.dart';
import 'package:road_safety/googleMapsPage.dart';
import 'package:road_safety/googleMapsPageViewOnly.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[900],
          centerTitle: true,
          title: Text('Road Safety'),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset('assets/images/img.jpg'),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    child: Text(
                      'View Only',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.symmetric(
                              vertical: 30.0, horizontal: 30.0),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.grey[700],
                        ),
                        foregroundColor: MaterialStateProperty.all<Color>(
                          Colors.white,
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.yellow)))),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GoogleMapsPageViewOnly()),
                      );
                    },
                  ),
                  TextButton(
                    child: Text(
                      'Mark Only',
                      style: TextStyle(
                        fontSize: 15,
                      ),
                    ),
                    style: ButtonStyle(
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.symmetric(
                              vertical: 30.0, horizontal: 30.0),
                        ),
                        backgroundColor: MaterialStateProperty.all<Color>(
                          Colors.grey[700],
                        ),
                        foregroundColor: MaterialStateProperty.all<Color>(
                          Colors.white,
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18.0),
                                    side: BorderSide(color: Colors.yellow)))),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => GoogleMapsPage()),
                      );
                    },
                  ),
                ],
              ),
              TextButton(
                child: Text(
                  'Both Feature Map',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                style: ButtonStyle(
                    padding: MaterialStateProperty.all<EdgeInsets>(
                      EdgeInsets.symmetric(vertical: 30.0, horizontal: 30.0),
                    ),
                    backgroundColor: MaterialStateProperty.all<Color>(
                      Colors.grey[700],
                    ),
                    foregroundColor: MaterialStateProperty.all<Color>(
                      Colors.white,
                    ),
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.yellow)))),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GoogleMapsPage()),
                  );
                },
              ),
              SizedBox(
                height: 50,
              ),
            ],
          ),
        ));
  }
}
