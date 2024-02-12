import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smarttra/screens/map_screen.dart';

import '../../../widgets/textfield_widget.dart';
import '../../../widgets/toast_widget.dart';

import '../services/add_record.dart';
import '../utlis/app_constants.dart';
import '../utlis/colors.dart';
import '../widgets/app_text_form_field.dart';
import '../widgets/text_widget.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isObscure = true;

  Random random = Random();
  List<String> values = ['C3', 'A1', 'D4'];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: hasloaded
          ? SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                      height: 350,
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Image.asset(
                              'assets/images/default_logo.png',
                              width: 200,
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          const Text(
                            'Sign in to your\nAccount',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                            ),
                          ),
                          const SizedBox(
                            height: 6,
                          ),
                          const Text(
                            'Sign in to your Account',
                            style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w200,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 30),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AppTextFormField(
                            labelText: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            onChanged: (value) {
                              _formKey.currentState?.validate();
                            },
                            validator: (value) {
                              return value!.isEmpty
                                  ? 'Please, Enter Email Address'
                                  : AppConstants.emailRegex.hasMatch(value)
                                      ? null
                                      : 'Invalid Email Address';
                            },
                            controller: emailController,
                          ),
                          AppTextFormField(
                            labelText: 'Password',
                            keyboardType: TextInputType.visiblePassword,
                            textInputAction: TextInputAction.done,
                            onChanged: (value) {
                              _formKey.currentState?.validate();
                            },
                            controller: passwordController,
                            obscureText: isObscure,
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isObscure = !isObscure;
                                  });
                                },
                                style: ButtonStyle(
                                  minimumSize: MaterialStateProperty.all(
                                    const Size(48, 48),
                                  ),
                                ),
                                icon: Icon(
                                  isObscure
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: ((context) {
                                  final formKey = GlobalKey<FormState>();
                                  final TextEditingController emailController =
                                      TextEditingController();

                                  return AlertDialog(
                                    title: TextWidget(
                                      text: 'Forgot Password',
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                    content: Form(
                                      key: formKey,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          TextFieldWidget(
                                            hint: 'Email',
                                            textCapitalization:
                                                TextCapitalization.none,
                                            inputType:
                                                TextInputType.emailAddress,
                                            label: 'Email',
                                            controller: emailController,
                                            validator: (value) {
                                              if (value == null ||
                                                  value.isEmpty) {
                                                return 'Please enter an email address';
                                              }
                                              final emailRegex = RegExp(
                                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                                              if (!emailRegex.hasMatch(value)) {
                                                return 'Please enter a valid email address';
                                              }
                                              return null;
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: (() {
                                          Navigator.pop(context);
                                        }),
                                        child: TextWidget(
                                          text: 'Cancel',
                                          fontSize: 12,
                                          color: Colors.black,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: (() async {
                                          if (formKey.currentState!
                                              .validate()) {
                                            try {
                                              Navigator.pop(context);
                                              await FirebaseAuth.instance
                                                  .sendPasswordResetEmail(
                                                      email:
                                                          emailController.text);
                                              showToast(
                                                  'Password reset link sent to ${emailController.text}');
                                            } catch (e) {
                                              String errorMessage = '';

                                              if (e is FirebaseException) {
                                                switch (e.code) {
                                                  case 'invalid-email':
                                                    errorMessage =
                                                        'The email address is invalid.';
                                                    break;
                                                  case 'user-not-found':
                                                    errorMessage =
                                                        'The user associated with the email address is not found.';
                                                    break;
                                                  default:
                                                    errorMessage =
                                                        'An error occurred while resetting the password.';
                                                }
                                              } else {
                                                errorMessage =
                                                    'An error occurred while resetting the password.';
                                              }

                                              showToast(errorMessage);
                                              Navigator.pop(context);
                                            }
                                          }
                                        }),
                                        child: TextWidget(
                                          text: 'Continue',
                                          fontSize: 14,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ],
                                  );
                                }),
                              );
                            },
                            style: Theme.of(context).textButtonTheme.style,
                            child: Text(
                              'Forgot Password?',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ),
                          const SizedBox(
                            height: 15,
                          ),
                          FilledButton(
                            onPressed: () {
                              login(context);
                            },
                            style: const ButtonStyle().copyWith(
                              backgroundColor: MaterialStateProperty.all(
                                Colors.blue,
                              ),
                            ),
                            child: const Text('Login'),
                          ),
                          const SizedBox(
                            height: 100,
                          ),
                          // Row(
                          //   children: [
                          //     Expanded(
                          //       child: Divider(
                          //         color: Colors.grey.shade200,
                          //       ),
                          //     ),
                          //     Padding(
                          //       padding: const EdgeInsets.symmetric(
                          //         horizontal: 20,
                          //       ),
                          //       child: Text(
                          //         'Or login with',
                          //         style: Theme.of(context)
                          //             .textTheme
                          //             .bodySmall
                          //             ?.copyWith(color: Colors.black),
                          //       ),
                          //     ),
                          //     Expanded(
                          //       child: Divider(
                          //         color: Colors.grey.shade200,
                          //       ),
                          //     ),
                          //   ],
                          // ),
                          // const SizedBox(
                          //   height: 30,
                          // ),
                          // Row(
                          //   children: [
                          //     Expanded(
                          //       child: OutlinedButton.icon(
                          //         onPressed: () {},
                          //         style: Theme.of(context).outlinedButtonTheme.style,
                          //         icon: SvgPicture.asset(
                          //           Vectors.googleIcon,
                          //           width: 14,
                          //         ),
                          //         label: const Text(
                          //           'Google',
                          //           style: TextStyle(color: Colors.black),
                          //         ),
                          //       ),
                          //     ),
                          //     const SizedBox(
                          //       width: 20,
                          //     ),
                          //     Expanded(
                          //       child: OutlinedButton.icon(
                          //         onPressed: () {},
                          //         style: Theme.of(context).outlinedButtonTheme.style,
                          //         icon: SvgPicture.asset(
                          //           Vectors.facebookIcon,
                          //           width: 14,
                          //         ),
                          //         label: const Text(
                          //           'Facebook',
                          //           style: TextStyle(color: Colors.black),
                          //         ),
                          //       ),
                          //     ),
                          //   ],
                          // ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  login(context) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text, password: passwordController.text);

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
                                .then((DocumentSnapshot documentSnapshot) {
                              if (documentSnapshot.exists) {
                                print('Document exists on the database');
                              } else {
                                addRecord(values[i], lat, long, '', '', 0,
                                    '${random.nextInt(14) + 7} mins');
                              }
                            });
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => MapScreen(
                                      nums: FlutterBluePlus
                                          .connectedDevices.length,
                                      type: values[i],
                                    )));

                            showToast('Logged in succesfully!');
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
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        showToast("No user found with that email.");
      } else if (e.code == 'wrong-password') {
        showToast("Wrong password provided for that user.");
      } else if (e.code == 'invalid-email') {
        showToast("Invalid email provided.");
      } else if (e.code == 'user-disabled') {
        showToast("User account has been disabled.");
      } else {
        showToast("An error occurred: ${e.message}");
      }
    } on Exception catch (e) {
      showToast("An error occurred: $e");
    }
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
