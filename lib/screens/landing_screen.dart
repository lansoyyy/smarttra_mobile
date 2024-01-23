import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:smarttra/screens/map_screen.dart';
import 'package:smarttra/widgets/button_widget.dart';
import 'package:smarttra/widgets/text_widget.dart';

class LandingScreen extends StatefulWidget {
  const LandingScreen({super.key});

  @override
  State<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends State<LandingScreen> {
  List<String> values = ['C3', 'B2', 'A1', 'D4'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange[50],
      body: Center(
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
                      title: TextWidget(text: 'Scanned devices', fontSize: 18),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          for (int i = 0; i < values.length; i++)
                            Column(
                              children: [
                                ListTile(
                                  onTap: () {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                            builder: (context) => MapScreen(
                                                  nums: FlutterBluePlus
                                                      .connectedDevices.length,
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
      )),
    );
  }
}
