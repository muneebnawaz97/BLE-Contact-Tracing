// import 'package:contact_tracing/controller/requirement_state_controller.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:contact_tracing/stores/login_store.dart';
import 'package:get/get.dart';
//
// class TabBroadcasting extends StatefulWidget {
//   @override
//   _TabBroadcastingState createState() => _TabBroadcastingState();
// }
//
// class _TabBroadcastingState extends State<TabBroadcasting> {
//   final controller = Get.find<RequirementStateController>();
//   final clearFocus = FocusNode();
//   bool broadcasting = false;
//
//   final regexUUID = RegExp(
//       r'[0-9a-fA-F]{8}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{4}\-[0-9a-fA-F]{12}');
//   final uuidController = '39ED98FF-2900-441A-802F-9C398FC199D2';
//   final majorController = 0;
//   final minorController = 0;
//
//   bool get broadcastReadyAuthorization => controller.authorizationStatusOk == true;
//   bool get broadcastReadyLocation => controller.locationServiceEnabled == true;
//   bool get broadcastReadyBluetooth => controller.bluetoothEnabled == true;
//
//   @override
//   void initState() {
//     super.initState();
//     initBroadcastBeacon();
//   }
//
//   initBroadcastBeacon() async {
//     await flutterBeacon.initializeScanning;
//     await flutterBeacon.startBroadcast(BeaconBroadcast(
//         proximityUUID: uuidController,
//         major: majorController,
//         minor: minorController));
//
//     final isBroadcasting = await flutterBeacon.isBroadcasting();
//
//     setState(() {
//       broadcasting = isBroadcasting;
//     });
//   }
//
//   @override
//   void dispose() {
//     clearFocus.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height * 0.5,
//       child: Column(
//         children: [
//           Obx(
//             () => broadcastReadyAuthorization != true
//                 ? Center(child: Text('No Authorization...'))
//                 : Container()
//           ),
//           Obx(
//               () => broadcastReadyBluetooth != true
//                   ? Center(child: Text('Enable Bluetooth'),)
//                   : Container()
//           ),
//           Obx(
//                   () => broadcastReadyLocation != true
//                   ? Center(child: Text('Enable Location'),)
//                   : Container()
//           )
//         ],
//       ),
//     );
//   }
//
// }

import 'dart:async';
import "dart:typed_data";
import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:flutter/material.dart';
import 'package:contact_tracing/controller/requirement_state_controller.dart';

class Broadcast extends StatefulWidget {
  @override
  _BroadcastState createState() => _BroadcastState();
}

class _BroadcastState extends State<Broadcast> {
  static const String uuid = '39ED98FF-2900-441A-802F-9C398FC199D2';
  var majorId = 20;
  static const int minorId = 100;
  static const int transmissionPower = -59;
  static const String identifier = 'com.example.myDeviceRegion';
  static const AdvertiseMode advertiseMode = AdvertiseMode.lowPower;
  static const String layout = "m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24";
  static const int manufacturerId = 0x0118;
  static const List<int> extraData = [100];

  BeaconBroadcast beaconBroadcast = BeaconBroadcast();

  final controller = Get.find<RequirementStateController>();
  final clearFocus = FocusNode();
  bool broadcasting = false;

  BeaconStatus _isTransmissionSupported;
  bool _isAdvertising = true;
  StreamSubscription<bool> _isAdvertisingSubscription;

  bool get broadcastReadyAuthorization => controller.authorizationStatusOk == true;
  bool get broadcastReadyLocation => controller.locationServiceEnabled == true;
  bool get broadcastReadyBluetooth => controller.bluetoothEnabled == true;

  @override
  void initState() {
    super.initState();

    beaconBroadcast
        .checkTransmissionSupported()
        .then((isTransmissionSupported) {
      setState(() {
        _isTransmissionSupported = isTransmissionSupported;
      });
    });


    beaconBroadcast
        .setUUID(uuid)
        .setMajorId(majorId)
        .setMinorId(minorId)
        .setTransmissionPower(transmissionPower)
        .setAdvertiseMode(advertiseMode)
        .setIdentifier(identifier)
        .setLayout(layout)
        .setManufacturerId(manufacturerId)
        .setExtraData([0x1])
        .start();

    _isAdvertisingSubscription =
        beaconBroadcast.getAdvertisingStateChange().listen((isAdvertising) {
          setState(() {
            _isAdvertising = isAdvertising;
          });
        });

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Obx(
            () => broadcastReadyAuthorization != true
                ? Center(child: Text('No Authorization...'))
                : Container()
          ),
          Obx(
              () => broadcastReadyBluetooth != true
                  ? Center(child: Text('Enable Bluetooth'),)
                  : Container()
          ),
          Obx(
                  () => broadcastReadyLocation != true
                  ? Center(child: Text('Enable Location'),)
                  : Container()
          ),
          Text('Beacon Data',
              style: Theme.of(context).textTheme.headline5),
          Text('Major id: $majorId'),
          Text('Minor id: $minorId'),
          // Text('Tx Power: $transmissionPower'),
          // Text('Manufacturer Id: $manufacturerId'),
          Text('Extra data: $extraData'),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    if (_isAdvertisingSubscription != null) {
      _isAdvertisingSubscription.cancel();
    }
  }
}