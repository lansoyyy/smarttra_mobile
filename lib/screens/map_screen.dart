import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smarttra/screens/buses_screen.dart';
import 'package:smarttra/utlis/colors.dart';
import 'package:smarttra/widgets/button_widget.dart';
import 'package:smarttra/widgets/text_widget.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  static const CameraPosition _kLake = CameraPosition(
      bearing: 192.8334901395799,
      target: LatLng(37.43296265331129, -122.08832357078792),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  final searchController = TextEditingController();
  String nameSearched = '';

  final searchController1 = TextEditingController();
  String nameSearched1 = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextWidget(text: 'Map', fontSize: 18),
        backgroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const BusesScreen()));
            },
            icon: Icon(
              Icons.bus_alert_outlined,
              color: primary,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            GoogleMap(
              mapType: MapType.hybrid,
              initialCameraPosition: _kGooglePlex,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
            Padding(
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
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Container(
                        height: 40,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(100)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
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
                              hintStyle: TextStyle(fontFamily: 'QRegular'),
                            ),
                            controller: searchController,
                          ),
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.only(
                          left: 20, right: 20, top: 10, bottom: 10),
                      child: Divider(
                        color: Colors.white,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 20),
                      child: Container(
                        height: 40,
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.black,
                            ),
                            borderRadius: BorderRadius.circular(100)),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
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
                              hintStyle: TextStyle(fontFamily: 'QRegular'),
                            ),
                            controller: searchController1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primary,
        onPressed: _goToTheLake,
        label: const Text('Continue'),
        icon: const Icon(Icons.my_location),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    await controller.animateCamera(CameraUpdate.newCameraPosition(_kLake));
  }
}
