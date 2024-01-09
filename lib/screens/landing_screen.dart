import 'package:flutter/material.dart';
import 'package:smarttra/widgets/button_widget.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

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
            onPressed: () {},
          ),
        ],
      )),
    );
  }
}
