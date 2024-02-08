import 'dart:math';

import '../models/coordinate_model.dart';

class TravelTimeCalculator {
  static const double AVERAGE_JEEPNEY_SPEED_KMPH =
      20.0; // Average speed of jeepneys in kilometers per hour

  static double calculateDistance(Coordinate origin, Coordinate destination) {
    const double earthRadiusKm = 6371.0;

    final double lat1Rad = degreesToRadians(origin.latitude);
    final double lon1Rad = degreesToRadians(origin.longitude);
    final double lat2Rad = degreesToRadians(destination.latitude);
    final double lon2Rad = degreesToRadians(destination.longitude);

    final double dLat = lat2Rad - lat1Rad;
    final double dLon = lon2Rad - lon1Rad;

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final double distance = earthRadiusKm * c;

    return distance;
  }

  static int estimateTravelTime(Coordinate origin, Coordinate destination) {
    final double distanceKm = calculateDistance(origin, destination);
    final double travelTimeHours = distanceKm / AVERAGE_JEEPNEY_SPEED_KMPH;
    return (travelTimeHours * 60).toInt(); // Convert hours to minutes
  }

  static double degreesToRadians(double degrees) {
    return degrees * pi / 180.0;
  }
}
