import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future addRecord(type, lat, long, from, to, passengers) async {
  final docUser = FirebaseFirestore.instance.collection('Records').doc();

  final json = {
    'type': type,
    'lat': lat,
    'long': long,
    'from': from,
    'to': to,
    'passengers': passengers != 0 ? passengers : 1,
    'docId': docUser.id,
    'dateTime': DateTime.now(),
    'day': DateTime.now().day,
    'month': DateTime.now().month,
    'year': DateTime.now().year,
    'status': 'Moving'
  };

  await docUser.set(json);
}
