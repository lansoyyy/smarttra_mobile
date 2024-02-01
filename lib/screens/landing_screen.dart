import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smarttra/screens/map_screen.dart';
import 'package:smarttra/services/add_record.dart';
import 'package:smarttra/widgets/button_widget.dart';
import 'package:smarttra/widgets/text_widget.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  bool hasloaded = false;
  double lat = 0;
  double long = 0;

  @override
  void initState() {
    // TODO: implement initState
    determinePosition();

    Geolocator.getCurrentPosition().then((position) {
      setState(() {
        lat = position.latitude;
        long = position.longitude;
        hasloaded = true;
      });
    }).catchError((error) {
      print('Error getting location: $error');
    });
    super.initState();
  }

  Random random = Random();
  List<String> values = ['C3', 'A1', 'D4'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      body: hasloaded
          ? Center(
              child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/default_logo.png',
                  width: 250,
                ),
                const SizedBox(
                  height: 50,
                ),
                ButtonWidget(
                  label: 'Continue',
                  onPressed: () async {
                    await FlutterBluePlus.turnOn().then((value) async {
                      setState(() {
                        values.shuffle();
                      });
                      showDialog(
                        context: context,
                        builder: (context) {
                          return const AlertDialog(
                            title: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  'Loading. . . ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                      await Future.delayed(const Duration(seconds: 3));
                      Navigator.pop(context);
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: TextWidget(
                                text: 'Scanned devices', fontSize: 18),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                for (int i = 0; i < random.nextInt(3) + 1; i++)
                                  Column(
                                    children: [
                                      ListTile(
                                        onTap: () async {
                                          await FirebaseFirestore.instance
                                              .collection('Records')
                                              .doc(
                                                  '${values[i]}-${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}')
                                              .get()
                                              .then((DocumentSnapshot
                                                  documentSnapshot) {
                                            if (documentSnapshot.exists) {
                                              print(
                                                  'Document exists on the database');
                                            } else {
                                              addRecord(
                                                  values[i],
                                                  lat,
                                                  long,
                                                  '',
                                                  '',
                                                  0,
                                                  '${random.nextInt(4) + 1} mins');
                                            }
                                          });
                                          Navigator.of(context).push(
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      MapScreen(
                                                        nums: FlutterBluePlus
                                                            .connectedDevices
                                                            .length,
                                                        type: values[i],
                                                      )));
                                        },
                                        leading: const Icon(
                                          Icons.bluetooth,
                                          color: Colors.blue,
                                        ),
                                        trailing: const Icon(
                                          Icons.arrow_right,
                                        ),
                                        title: TextWidget(
                                          text: values[i],
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const Divider(),
                                    ],
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    });
                  },
                ),
              ],
            ))
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Future<Position> determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
