import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smarttra/utlis/colors.dart';
import 'package:smarttra/widgets/button_widget.dart';
import 'package:smarttra/widgets/text_widget.dart';

class BusesScreen extends StatefulWidget {
  const BusesScreen({super.key});

  @override
  State<BusesScreen> createState() => BusesScreenState();
}

class BusesScreenState extends State<BusesScreen> {
  final searchController = TextEditingController();
  String nameSearched = '';

  final searchController1 = TextEditingController();
  String nameSearched1 = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          foregroundColor: primary,
          title: TextWidget(text: 'Available Buses', fontSize: 18),
          backgroundColor: Colors.white,
          centerTitle: true,
        ),
        body: ListView.builder(
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: Card(
                elevation: 3,
                child: Container(
                  width: 500,
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(left: 50, right: 50),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.bus_alert_outlined,
                                  size: 48,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                TextWidget(text: '001', fontSize: 18),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.timelapse_rounded,
                                  size: 48,
                                ),
                                const SizedBox(
                                  height: 5,
                                ),
                                TextWidget(text: '45min', fontSize: 18),
                              ],
                            ),
                          ],
                        ),
                        Divider(
                          color: primary,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextWidget(text: 'Passengers:', fontSize: 18),
                            TextWidget(text: '17', fontSize: 24),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ));
  }
}
