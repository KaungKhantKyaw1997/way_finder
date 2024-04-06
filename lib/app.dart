// ignore_for_file: unnecessary_null_comparison

import 'package:location/location.dart';

final Location location = Location();
double latitude = 16.84630;
double longitude = 96.13210;

Future<void> getLocation() async {
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

    LocationData? locationData = await location.getLocation();
    if (locationData != null) {
      latitude = locationData.latitude!;
      longitude = locationData.longitude!;
    }
  } catch (e) {
    print('Error getting location: $e');
  }
}
