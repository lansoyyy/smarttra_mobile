import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smarttra/screens/buses_screen.dart';
import 'package:smarttra/services/add_record.dart';
import 'package:smarttra/utlis/colors.dart';
import 'package:smarttra/widgets/button_widget.dart';
import 'package:smarttra/widgets/text_widget.dart';
import 'package:smarttra/widgets/toast_widget.dart';

class MapScreen extends StatefulWidget {
  String type;
  int nums;

  MapScreen({super.key, required this.type, required this.nums});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
  }

  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  final searchController = TextEditingController();
  String nameSearched = '';

  final searchController1 = TextEditingController();
  String nameSearched1 = '';

  bool hasclicked = false;

  bool hasloaded = false;
  double lat = 0;
  double long = 0;

  @override
  Widget build(BuildContext context) {
    CameraPosition kGooglePlex = CameraPosition(
      target: LatLng(lat, long),
      zoom: 14.4746,
    );
    return Scaffold(
        appBar: AppBar(
          title: TextWidget(text: 'Map', fontSize: 18),
          backgroundColor: Colors.white,
          centerTitle: true,
          actions: [
            IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const BusesScreen()));
              },
              icon: Icon(
                Icons.bus_alert_outlined,
                color: primary,
              ),
            ),
          ],
        ),
        body: hasloaded
            ? SafeArea(
                child: Stack(
                  children: [
                    GoogleMap(
                      zoomControlsEnabled: false,
                      mapType: MapType.normal,
                      initialCameraPosition: kGooglePlex,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                    ),
                    !hasclicked
                        ? Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Container(
                              width: 500,
                              height: 150,
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20),
                                    child: Container(
                                      height: 40,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.black,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(100)),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: TextFormField(
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontFamily: 'Regular',
                                              fontSize: 14),
                                          onChanged: (value) {
                                            setState(() {
                                              nameSearched = value;
                                            });
                                          },
                                          decoration: const InputDecoration(
                                            filled: true,
                                            suffixIcon: Icon(Icons.location_on),
                                            fillColor: Colors.white,
                                            labelStyle: TextStyle(
                                              color: Colors.black,
                                            ),
                                            hintText: 'From:',
                                            hintStyle: TextStyle(
                                                fontFamily: 'QRegular'),
                                          ),
                                          controller: searchController,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(
                                        left: 20,
                                        right: 20,
                                        top: 10,
                                        bottom: 10),
                                    child: Divider(
                                      color: Colors.white,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20),
                                    child: Container(
                                      height: 40,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          border: Border.all(
                                            color: Colors.black,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(100)),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 10, right: 10),
                                        child: TextFormField(
                                          style: const TextStyle(
                                              color: Colors.black,
                                              fontFamily: 'Regular',
                                              fontSize: 14),
                                          onChanged: (value) {
                                            setState(() {
                                              nameSearched1 = value;
                                            });
                                          },
                                          decoration: const InputDecoration(
                                            suffixIcon: Icon(Icons.location_on),
                                            filled: true,
                                            fillColor: Colors.white,
                                            labelStyle: TextStyle(
                                              color: Colors.black,
                                            ),
                                            hintText: 'To:',
                                            hintStyle: TextStyle(
                                                fontFamily: 'QRegular'),
                                          ),
                                          controller: searchController1,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Container(
                              width: 500,
                              height: 125,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(25.0),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            TextWidget(
                                              text: 'Jeep: ${widget.type}',
                                              fontSize: 18,
                                              color: Colors.white,
                                              fontFamily: 'Bold',
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            TextWidget(
                                              text: 'No. of Passengers: ${4}',
                                              fontSize: 14,
                                              color: Colors.white,
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            TextWidget(
                                              text: 'Status: Recorded',
                                              fontSize: 14,
                                              color: Colors.green,
                                              fontFamily: 'Bold',
                                            ),
                                          ],
                                        ),
                                        const Icon(
                                          Icons.account_circle,
                                          color: Colors.white,
                                          size: 50,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              )
            : const Center(
                child: CircularProgressIndicator(),
              ),
        floatingActionButton: hasclicked
            ? const SizedBox()
            : searchController.text != '' && searchController1.text != ''
                ? FloatingActionButton.extended(
                    backgroundColor: Colors.blue,
                    onPressed: () {
                      setState(() {
                        hasclicked = true;
                      });
                      addRecord(widget.type, lat, long, searchController.text,
                          searchController1.text, widget.nums);
                      showToast(
                          'Jeep: ${widget.type}, No. of passengers: ${4}\nRecorded succesfully!');
                    },
                    label: const Text('Continue'),
                    icon: const Icon(Icons.my_location),
                  )
                : const SizedBox());
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
