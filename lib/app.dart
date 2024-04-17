// ignore_for_file: avoid_print

import 'package:location/location.dart';

final Location location = Location();
double latitude = 0.0;
double longitude = 0.0;

Future<void> requestLocation() async {
  try {
    bool serviceEnabled;
    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    PermissionStatus permission = await location.hasPermission();
    if (permission == PermissionStatus.denied) {
      permission = await location.requestPermission();
      if (permission != PermissionStatus.granted) {
        return;
      }
    }
  } catch (e) {
    print('Error getting location: $e');
  }
}
