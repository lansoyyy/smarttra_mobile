import 'dart:async';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_activity_recognition/flutter_activity_recognition.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_google_places/flutter_google_places.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smarttra/screens/buses_screen.dart';
import 'package:smarttra/screens/landing_screen.dart';
import 'package:smarttra/utlis/colors.dart';
import 'package:smarttra/widgets/text_widget.dart';
import 'package:smarttra/widgets/toast_widget.dart';
import 'package:google_maps_webservice/places.dart' as location;
import 'package:google_api_headers/google_api_headers.dart';
import '../models/coordinate_model.dart';
import '../utlis/functions.dart';
import '../utlis/keys.dart';

class MapScreen extends StatefulWidget {
  String type;
  int nums;

  MapScreen({super.key, required this.type, required this.nums});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> with WidgetsBindingObserver {
  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    // TODO: implement initState
    super.initState();
    // getRecords();
    determinePosition();

    isPermissionGrants();

    update();
    remove();

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

  bool hasInputted = false;

  update() {
    // update here

    print('called');

    activityRecognition.activityStream.handleError(
      (error) {
        print('asd');
      },
    ).listen(
      (event) async {
        if (event.type.name.toString() == 'IN_VEHICLE') {
          if (!hasInputted) {
            await FirebaseFirestore.instance
                .collection('Records')
                .doc(
                    '${widget.type}-${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}')
                .update({
              'passengers': FieldValue.increment(1),
            }).whenComplete(() {
              setState(() {
                hasInputted = true;
              });
            });
          }
        }
      },
    );
  }

  update1() {
    Timer.periodic(const Duration(seconds: 5), (timer) {
      Geolocator.getCurrentPosition().then((position) async {
        PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
            kGoogleApiKey,
            PointLatLng(position.latitude, position.longitude),
            PointLatLng(dropOff.latitude, dropOff.longitude));
        if (result.points.isNotEmpty) {
          polylineCoordinates = result.points
              .map((point) => LatLng(point.latitude, point.longitude))
              .toList();
        }
        setState(() {
          _poly = Polyline(
              color: Colors.red,
              polylineId: const PolylineId('route'),
              points: polylineCoordinates,
              width: 4);
        });

        double miny =
            (lat <= dropOff.latitude) ? position.latitude : dropOff.latitude;
        double minx = (position.longitude <= dropOff.longitude)
            ? position.longitude
            : dropOff.longitude;
        double maxy = (position.latitude <= dropOff.latitude)
            ? dropOff.latitude
            : position.latitude;
        double maxx = (position.longitude <= dropOff.longitude)
            ? dropOff.longitude
            : position.longitude;

        double southWestLatitude = miny;
        double southWestLongitude = minx;

        double northEastLatitude = maxy;
        double northEastLongitude = maxx;

        // Accommodate the two locations within the
        // camera view of the map
        mapController!.animateCamera(
          CameraUpdate.newLatLngBounds(
            LatLngBounds(
              northeast: LatLng(
                northEastLatitude,
                northEastLongitude,
              ),
              southwest: LatLng(
                southWestLatitude,
                southWestLongitude,
              ),
            ),
            100.0,
          ),
        );
      }).catchError((error) {
        print('Error getting location: $error');
      });
    });
  }

  bool hasInputted1 = false;

  remove() {
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      FirebaseFirestore.instance
          .collection('Records')
          .where('docId',
              isEqualTo:
                  '${widget.type}-${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}')
          .get()
          .then((QuerySnapshot querySnapshot) async {
        if (!hasInputted1) {
          if (await FlutterBluePlus.isOn == false &&
              querySnapshot.docs.first["passengers"] > 0) {
            await FirebaseFirestore.instance
                .collection('Records')
                .doc(
                    '${widget.type}-${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}')
                .update({
              'passengers': FieldValue.increment(-1),
            });

            setState(() {
              hasInputted1 = true;
            });
          }
        }
      });
    });
  }

  late String drop = 'To';

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

  Set<Marker> markers = {};

  Random random = Random();

  late Polyline _poly = const Polyline(polylineId: PolylineId('new'));

  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();

  // Subscribe to the activity stream.

  @override
  void dispose() {
    super.dispose();
  }

  // getRecords() {
  //   FirebaseFirestore.instance
  //       .collection('Records')
  //       .where('day', isEqualTo: DateTime.now().day)
  //       .get()
  //       .then((QuerySnapshot querySnapshot) async {
  //     for (var doc in querySnapshot.docs) {
  //       setState(() {
  //         markers.add(Marker(
  //             markerId: MarkerId(doc.id),
  //             icon: BitmapDescriptor.defaultMarker,
  //             position: LatLng(doc['lat'], doc['long']),
  //             infoWindow: InfoWindow(title: doc['type'])));
  //       });
  //     }
  //   });
  // }

  late LatLng dropOff;

  addMyMarker1(lat1, long1) async {
    markers.add(Marker(
        icon: BitmapDescriptor.defaultMarker,
        markerId: const MarkerId("pickup"),
        position: LatLng(lat1, long1),
        infoWindow: const InfoWindow(title: 'From')));
  }

  addMyMarker12(lat1, long1) async {
    markers.add(Marker(
        icon: BitmapDescriptor.defaultMarker,
        markerId: const MarkerId("dropOff"),
        position: LatLng(lat1, long1),
        infoWindow: const InfoWindow(title: 'To')));
  }

  GoogleMapController? mapController;
  @override
  Widget build(BuildContext context) {
    CameraPosition kGooglePlex = CameraPosition(
      target: LatLng(lat, long),
      zoom: 14.4746,
    );
    return Scaffold(
        appBar: AppBar(
          foregroundColor: Colors.black,
          title: TextWidget(text: 'Map', fontSize: 18),
          backgroundColor: Colors.white,
          centerTitle: true,
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const BusesScreen()));
            },
            icon: Icon(
              Icons.bus_alert_outlined,
              color: primary,
            ),
          ),
          actions: [
            IconButton(
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                          title: const Text(
                            'Logout Confirmation',
                            style: TextStyle(
                                fontFamily: 'QBold',
                                fontWeight: FontWeight.bold),
                          ),
                          content: const Text(
                            'Are you sure you want to Logout?',
                            style: TextStyle(fontFamily: 'QRegular'),
                          ),
                          actions: <Widget>[
                            MaterialButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              child: const Text(
                                'Close',
                                style: TextStyle(
                                    fontFamily: 'QRegular',
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            MaterialButton(
                              onPressed: () async {
                                Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const LoginPage()));
                              },
                              child: const Text(
                                'Continue',
                                style: TextStyle(
                                    fontFamily: 'QRegular',
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ));
              },
              icon: Icon(
                Icons.logout,
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
                      myLocationEnabled: true,
                      polylines: {_poly},
                      markers: markers,
                      zoomControlsEnabled: false,
                      mapType: MapType.normal,
                      initialCameraPosition: kGooglePlex,
                      onMapCreated: (GoogleMapController controller) {
                        mapController = controller;
                        _controller.complete(controller);
                      },
                    ),
                    !hasclicked
                        ? Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Container(
                              width: 500,
                              height: 100,
                              decoration: BoxDecoration(
                                color: primary.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
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
                                    child: GestureDetector(
                                      onTap: () async {
                                        location.Prediction? p =
                                            await PlacesAutocomplete.show(
                                                mode: Mode.overlay,
                                                context: context,
                                                apiKey: kGoogleApiKey,
                                                language: 'en',
                                                strictbounds: false,
                                                types: [""],
                                                decoration: InputDecoration(
                                                    hintText:
                                                        'Search Drop-off Location',
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        20),
                                                            borderSide:
                                                                const BorderSide(
                                                                    color: Colors
                                                                        .white))),
                                                components: [
                                                  location.Component(
                                                      location
                                                          .Component.country,
                                                      "ph")
                                                ]);

                                        location.GoogleMapsPlaces places =
                                            location.GoogleMapsPlaces(
                                                apiKey: kGoogleApiKey,
                                                apiHeaders:
                                                    await const GoogleApiHeaders()
                                                        .getHeaders());

                                        location.PlacesDetailsResponse detail =
                                            await places.getDetailsByPlaceId(
                                                p!.placeId!);

                                        addMyMarker12(
                                            detail
                                                .result.geometry!.location.lat,
                                            detail
                                                .result.geometry!.location.lng);

                                        setState(() {
                                          drop = detail.result.name;

                                          dropOff = LatLng(
                                              detail.result.geometry!.location
                                                  .lat,
                                              detail.result.geometry!.location
                                                  .lng);
                                        });

                                        PolylineResult result =
                                            await polylinePoints
                                                .getRouteBetweenCoordinates(
                                                    kGoogleApiKey,
                                                    PointLatLng(lat, long),
                                                    PointLatLng(
                                                        detail.result.geometry!
                                                            .location.lat,
                                                        detail.result.geometry!
                                                            .location.lng));
                                        if (result.points.isNotEmpty) {
                                          polylineCoordinates = result.points
                                              .map((point) => LatLng(
                                                  point.latitude,
                                                  point.longitude))
                                              .toList();
                                        }
                                        setState(() {
                                          _poly = Polyline(
                                              color: Colors.red,
                                              polylineId:
                                                  const PolylineId('route'),
                                              points: polylineCoordinates,
                                              width: 4);
                                        });

                                        mapController!.animateCamera(
                                            CameraUpdate.newLatLngZoom(
                                                LatLng(
                                                    detail.result.geometry!
                                                        .location.lat,
                                                    detail.result.geometry!
                                                        .location.lng),
                                                18.0));

                                        double miny = (lat <= dropOff.latitude)
                                            ? lat
                                            : dropOff.latitude;
                                        double minx =
                                            (long <= dropOff.longitude)
                                                ? long
                                                : dropOff.longitude;
                                        double maxy = (lat <= dropOff.latitude)
                                            ? dropOff.latitude
                                            : lat;
                                        double maxx =
                                            (long <= dropOff.longitude)
                                                ? dropOff.longitude
                                                : long;

                                        double southWestLatitude = miny;
                                        double southWestLongitude = minx;

                                        double northEastLatitude = maxy;
                                        double northEastLongitude = maxx;

                                        // Accommodate the two locations within the
                                        // camera view of the map
                                        mapController!.animateCamera(
                                          CameraUpdate.newLatLngBounds(
                                            LatLngBounds(
                                              northeast: LatLng(
                                                northEastLatitude,
                                                northEastLongitude,
                                              ),
                                              southwest: LatLng(
                                                southWestLatitude,
                                                southWestLongitude,
                                              ),
                                            ),
                                            100.0,
                                          ),
                                        );
                                      },
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
                                              left: 10, right: 10, top: 10),
                                          child: TextWidget(
                                            text: drop,
                                            fontSize: 14,
                                          ),
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
            : drop != 'To'
                ? FloatingActionButton.extended(
                    backgroundColor: Colors.blue,
                    onPressed: () async {
                      final origin =
                          Coordinate(lat, long); // Example coordinates
                      final destination = Coordinate(dropOff.latitude,
                          dropOff.longitude); // Example coordinates

                      final travelTime =
                          TravelTimeCalculator.estimateTravelTime(
                              origin, destination);

                      // update the from and to

                      await FirebaseFirestore.instance
                          .collection('Records')
                          .doc(
                              '${widget.type}-${DateTime.now().day}-${DateTime.now().month}-${DateTime.now().year}')
                          .update({
                        'from': '',
                        'to': drop,
                        'time': '$travelTime minutes'
                      });

                      update1();

                      setState(() {
                        hasclicked = true;
                      });
                      showToast('Routes Updated!');
                    },
                    label: const Text('Update'),
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

  final activityRecognition = FlutterActivityRecognition.instance;

  Future<bool> isPermissionGrants() async {
    await activityRecognition.requestPermission();
    // Check if the user has granted permission. If not, request permission.
    PermissionRequestResult reqResult;
    reqResult = await activityRecognition.checkPermission();
    if (reqResult == PermissionRequestResult.PERMANENTLY_DENIED) {
      return false;
    } else if (reqResult == PermissionRequestResult.DENIED) {
      reqResult = await activityRecognition.requestPermission();
      if (reqResult != PermissionRequestResult.GRANTED) {
        return false;
      }
    }

    return true;
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.inactive) {}

    /* if (isBackground) {
      // service.stop();
    } else {
      // service.start();
    }*/
  }
}
