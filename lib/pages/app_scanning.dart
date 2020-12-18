import 'package:contact_tracing/stores/login_store.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io' show Platform;

import 'package:beacons_plugin/beacons_plugin.dart';

import 'package:flutter_beacon/flutter_beacon.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import '../controller/requirement_state_controller.dart';
import 'dart:convert';

// class TabScanning extends StatefulWidget {
//   @override
//   _TabScanningState createState() => _TabScanningState();
// }
//
// class _TabScanningState extends State<TabScanning> {
//   StreamSubscription<RangingResult> _streamRanging;
//   final _regionBeacons = <Region, List<Beacon>>{};
//   final _beacons = <Beacon>[];
//   final controller = Get.find<RequirementStateController>();
//
//   @override
//   void initState() {
//     super.initState();
//
//     controller.startStream.listen((flag) {
//       if (flag == true) {
//         initScanBeacon();
//       }
//     });
//
//     controller.pauseStream.listen((flag) {
//       if (flag == true) {
//         pauseScanBeacon();
//       }
//     });
//   }
//
//   initScanBeacon() async {
//     await flutterBeacon.initializeScanning;
//     if (!controller.authorizationStatusOk ||
//         !controller.locationServiceEnabled ||
//         !controller.bluetoothEnabled) {
//       print(
//           'RETURNED, authorizationStatusOk=${controller.authorizationStatusOk}, '
//           'locationServiceEnabled=${controller.locationServiceEnabled}, '
//           'bluetoothEnabled=${controller.bluetoothEnabled}');
//       return;
//     }
//     final regions = <Region>[
//       Region(
//         identifier: 'iBeacon',
//         proximityUUID: '39ED98FF-2900-441A-802F-9C398FC199D2',
//       ),
//     ];
//
//     if (_streamRanging != null) {
//       if (_streamRanging.isPaused) {
//         _streamRanging.resume();
//         return;
//       }
//     }
//
//     _streamRanging =
//         flutterBeacon.ranging(regions).listen((RangingResult result) {
//       print(result.beacons);
//       if (result != null && mounted) {
//         setState(() {
//           _regionBeacons[result.region] = result.beacons;
//           _beacons.clear();
//           _regionBeacons.values.forEach((list) {
//             _beacons.addAll(list);
//           });
//           _beacons.sort(_compareParameters);
//         });
//       }
//     });
//   }
//
//   pauseScanBeacon() async {
//     _streamRanging?.pause();
//     if (_beacons.isNotEmpty) {
//       setState(() {
//         _beacons.clear();
//       });
//     }
//   }
//
//   int _compareParameters(Beacon a, Beacon b) {
//     int compare = a.proximityUUID.compareTo(b.proximityUUID);
//
//     if (compare == 0) {
//       compare = a.major.compareTo(b.major);
//     }
//
//     if (compare == 0) {
//       compare = a.minor.compareTo(b.minor);
//     }
//
//     return compare;
//   }
//
//   @override
//   void dispose() {
//     _streamRanging?.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       height: MediaQuery.of(context).size.height*0.3,
//       child: (_beacons == null || _beacons.isEmpty)
//           ? Container()
//           : ListView(
//               children: ListTile.divideTiles(
//                 context: context,
//                 tiles: _beacons.map(
//                   (beacon) {
//                     return ListTile(
//                       title: Text(
//                         beacon.proximityUUID,
//                         style: TextStyle(fontSize: 15.0),
//                       ),
//                       subtitle: new Row(
//                         mainAxisSize: MainAxisSize.max,
//                         children: <Widget>[
//                           Flexible(
//                             child: Text(
//                               'Major: ${beacon.major}\nMinor: ${beacon.minor}',
//                               style: TextStyle(fontSize: 13.0),
//                             ),
//                             flex: 1,
//                             fit: FlexFit.tight,
//                           ),
//                           Flexible(
//                             child: Text(
//                               'Accuracy: ${beacon.accuracy}m\nRSSI: ${beacon.rssi}',
//                               style: TextStyle(fontSize: 13.0),
//                             ),
//                             flex: 2,
//                             fit: FlexFit.tight,
//                           ),
//                           Flexible(
//                             child: Text(
//                               'Mac: ${beacon.macAddress}\nProx: ${beacon.proximity}',
//                               style: TextStyle(fontSize: 13.0),
//                             ),
//                             flex: 2,
//                             fit: FlexFit.tight,
//                           )
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ).toList(),
//             ),
//     );
//   }
// }

class Scan extends StatefulWidget {
  @override
  _ScanState createState() => _ScanState();
}

class _ScanState extends State<Scan> {
  var _beaconResult = new Map();
  int _nrMessaggesReceived = 0;
  var isRunning = true;

  final StreamController<String> beaconEventsController =
      StreamController<String>.broadcast();

  final controller = Get.find<RequirementStateController>();

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    beaconEventsController.close();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {

    var obj = LoginStore();
    var s = obj.getUser();


    await BeaconsPlugin.startMonitoring;

    BeaconsPlugin.listenToBeacons(beaconEventsController);

    // await BeaconsPlugin.addRegion(
    //     "BeaconType1", "909c3cf9-fc5c-4841-b695-380958a51a5a");
    // await BeaconsPlugin.addRegion(
    //     "BeaconType2", "6a84c716-0f2a-1ce9-f210-6a63bd873dd9");

    beaconEventsController.stream.listen(
        (data) {
          if (data.isNotEmpty) {
            setState(() {
              _beaconResult = json.decode(data);
              _nrMessaggesReceived++;
            });
            print("Beacons DataReceived: " +
                (data));
          }
        },
        onDone: () {},
        onError: (error) {
          print("Error: $error");
        });

    //Send 'true' to run in background
    await BeaconsPlugin.runInBackground(true);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginStore>(
        builder: (_, loginStore, __) {
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text('$_beaconResult'),
                Padding(
                  padding: EdgeInsets.all(10.0),
                ),
                Text('$_nrMessaggesReceived'),
              ],
            ),
          );
        }
    );
  }
}
