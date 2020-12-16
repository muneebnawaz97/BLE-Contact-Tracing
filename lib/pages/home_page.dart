import 'dart:async';
import 'dart:convert';

import 'package:beacon_broadcast/beacon_broadcast.dart';
import 'package:contact_tracing/stores/login_store.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'package:beacons_plugin/beacons_plugin.dart';

import '../theme.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _beaconResult = 'Not Scanned Yet.';
  int _nrMessaggesReceived = 0;
  var isRunning = false;

  final StreamController<String> beaconEventsController = StreamController<String>.broadcast();

  static const UUID = '39ED98FF-2900-441A-802F-9C398FC199D2';
  static const MAJOR_ID = 2;
  static const MINOR_ID = 100;
  static const TRANSMISSION_POWER = -59;
  static const IDENTIFIER = 'com.example.myDeviceRegion';
  static const LAYOUT = "m:2-3=0215,i:4-19,i:20-21,i:22-23,p:24-24";
  static const MANUFACTURER_ID = 0x0118;


  BeaconBroadcast beaconBroadcast = BeaconBroadcast();

  BeaconStatus _isTransmissionSupported;
  bool _isAdvertising = false;
  StreamSubscription<bool> _isAdvertisingSubscription;

  Timer timer;

  List<int> getBytes(String id){
    return utf8.encode(id);
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    beaconBroadcast.checkTransmissionSupported().then((isTransmissionSupported) {
      setState(() {
        _isTransmissionSupported = isTransmissionSupported;
      });
    });

    _isAdvertisingSubscription =
        beaconBroadcast.getAdvertisingStateChange().listen((isAdvertising) {
          setState(() {
            _isAdvertising = isAdvertising;
          });
        });

    // WidgetsBinding.instance
    //     .addPostFrameCallback((_) => beaconBroadcast
    //     .setUUID(UUID)
    //     .setMajorId(MAJOR_ID)
    //     .setMinorId(MINOR_ID)
    //     .setTransmissionPower(-59)
    //     .setIdentifier(IDENTIFIER)
    //     .setLayout(LAYOUT)
    //     .setManufacturerId(MANUFACTURER_ID)
    //     .setExtraData([0xA])
    //     .start());

    // timer = Timer.periodic(Duration(seconds: 15), (Timer t) => beaconBroadcast
    //     .setUUID(UUID)
    //     .setMajorId(MAJOR_ID)
    //     .setMinorId(MINOR_ID)
    //     .setTransmissionPower(-59)
    //     .setIdentifier(IDENTIFIER)
    //     .setLayout(LAYOUT)
    //     .setManufacturerId(MANUFACTURER_ID)
    //     .setExtraData([0xA])
    //     .start());

    // BeaconsPlugin.startMonitoring;
  }


  @override
  void dispose() {
    beaconEventsController.close();
    super.dispose();
    if (_isAdvertisingSubscription != null) {
      _isAdvertisingSubscription.cancel();
    }
  }

  Future<void> initPlatformState() async {
    BeaconsPlugin.listenToBeacons(beaconEventsController);

    await BeaconsPlugin.addRegion(
        "BeaconType1", "909c3cf9-fc5c-4841-b695-380958a51a5a");
    await BeaconsPlugin.addRegion(
        "BeaconType2", "6a84c716-0f2a-1ce9-f210-6a63bd873dd9");

    beaconEventsController.stream.listen(
            (data) {
          if (data.isNotEmpty) {
            setState(() {
              _beaconResult = data;
              _nrMessaggesReceived++;
            });
            print("Beacons DataReceived: " + data);
          }
        },
        onDone: () {},
        onError: (error) {
          print("Error: $error");
        });

    //Send 'true' to run in background
    await BeaconsPlugin.runInBackground(true);

    if (Platform.isAndroid) {
      BeaconsPlugin.channel.setMethodCallHandler((call) async {
        if (call.method == 'scannerReady') {
          await BeaconsPlugin.startMonitoring;
          setState(() {
            isRunning = true;
          });
        }
      });
    } else if (Platform.isIOS) {
      await BeaconsPlugin.startMonitoring;
      setState(() {
        isRunning = true;
      });
    }

    if (!mounted) return;
  }





  @override
  Widget build(BuildContext context) {

    return Consumer<LoginStore>(
      builder: (_, loginStore, __) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: MyColors.primaryColor,
            title: Text('Contact Tracing'),
            automaticallyImplyLeading: false,
            actions: <Widget>[
              FlatButton.icon(
                icon: Icon(Icons.logout, color: Colors.white,),
                label: Text('Sign Out', style:TextStyle(color: Colors.white)),
                onPressed: () {
                  loginStore.signOut(context);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Text('Is transmission supported?',
                  //     style: Theme.of(context).textTheme.headline5),
                  // Text('$_isTransmissionSupported',
                  //     style: Theme.of(context).textTheme.subtitle1),
                  // Container(height: 16.0),
                  Text('Is beacon started?', style: Theme.of(context).textTheme.headline5),
                  Text('$_isAdvertising', style: Theme.of(context).textTheme.subtitle1),
                  SizedBox(height: 10.0),
                  Text('My Beacon Details', style: Theme.of(context).textTheme.headline5),
                  Text('UUID: $UUID'),
                  Text('User ID: $MAJOR_ID'),
                  //Text('Minor id: $MINOR_ID'),
                  Text('Tx Power: $TRANSMISSION_POWER'),
                  // Text('Identifier: $IDENTIFIER'),
                  Text('Layout: $LAYOUT'),
                  Text('Manufacturer Id: $MANUFACTURER_ID'),
                  Container(height: 16.0),
                  Row(
                    children: [
                      Center(
                        child: RaisedButton(
                          onPressed: () {
                            beaconBroadcast
                                .setUUID(UUID)
                                .setMajorId(MAJOR_ID)
                                .setMinorId(MINOR_ID)
                                .setTransmissionPower(-59)
                                .setIdentifier(IDENTIFIER)
                                .setLayout(LAYOUT)
                                .setManufacturerId(MANUFACTURER_ID)
                                .setExtraData([0xA])
                                .start();
                          },
                          child: Text('Start Advertising'),
                        ),
                      ),
                      Center(
                        child: RaisedButton(
                          onPressed: () {
                            beaconBroadcast.stop();
                          },
                          child: Text('Stop Advertising'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.0,),
                  Text('Nearby Beacons', style: Theme.of(context).textTheme.headline5),
                  Text('$_beaconResult'),
                  Padding(
                    padding: EdgeInsets.all(10.0),
                  ),
                  Text('$_nrMessaggesReceived'),
                  SizedBox(
                    height: 10.0,
                  ),
                  Visibility(
                    visible: isRunning,
                    child: RaisedButton(
                      onPressed: () async {
                        if (Platform.isAndroid) {
                          await BeaconsPlugin.stopMonitoring;

                          setState(() {
                            isRunning = false;
                          });
                        }
                      },
                      child: Text('Stop Discovery'),
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  Visibility(
                    visible: !isRunning,
                    child: RaisedButton(
                      onPressed: () async {
                        initPlatformState();
                        await BeaconsPlugin.startMonitoring;

                        setState(() {
                          isRunning = true;
                        });
                      },
                      child: Text('Start Discovery'),
                    ),
                  ),

                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
