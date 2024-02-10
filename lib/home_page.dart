import 'dart:async';
import 'dart:developer';
// import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:wifi_conn/wifi_connector.dart';
// import 'package:flutter_blue/flutter_blue.dart';
import 'package:wifi_scan/wifi_scan.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  List<WiFiAccessPoint> wifiList = [];
  bool isWifiConnecting = false;

  Future<void> _startScan() async {
    isWifiConnecting = false;
    setState(() {});
    final can = await WiFiScan.instance.canStartScan(askPermissions: true);
    switch(can) {
      case CanStartScan.yes:
        wifiList = await WiFiScan.instance.getScannedResults();
        isWifiConnecting = true;
        setState(() {});
        break;
      case CanStartScan.notSupported:
        await WiFiScan.instance.getScannedResults().then((value) {
          value.forEach((element) {
            log("notSupported: $element");
          });
        });
        isWifiConnecting = false;
        setState(() {});
        Future.delayed(Duration.zero).then((value) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("notSupported")));
        });
        break;
      case CanStartScan.noLocationPermissionRequired:
        isWifiConnecting = false;
        await WiFiScan.instance.getScannedResults().then((value) {
          value.forEach((element) {
            log("noLocationPermissionRequired: $element");
          });
        });
        setState(() {});
        Future.delayed(Duration.zero).then((value) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("noLocationPermissionRequired")));
        });
        break;
      case CanStartScan.noLocationPermissionDenied:
        isWifiConnecting = false;
        await WiFiScan.instance.getScannedResults().then((value) {
          value.forEach((element) {
            log("noLocationPermissionDenied: $element");
          });
        });
        setState(() {});
        Future.delayed(Duration.zero).then((value) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("noLocationPermissionDenied")));
        });
        break;
      case CanStartScan.noLocationPermissionUpgradeAccuracy:
        isWifiConnecting = false;
        await WiFiScan.instance.getScannedResults().then((value) {
          value.forEach((element) {
            log("noLocationPermissionUpgradeAccuracy: $element");
          });
        });
        setState(() {});
        Future.delayed(Duration.zero).then((value) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("noLocationPermissionUpgradeAccuracy")));
        });
        break;
      case CanStartScan.noLocationServiceDisabled:
        isWifiConnecting = false;
        await WiFiScan.instance.getScannedResults().then((value) {
          value.forEach((element) {
            log("noLocationServiceDisabled: $element");
          });
        });
        setState(() {});
        Future.delayed(Duration.zero).then((value) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("noLocationServiceDisabled")));
        });
        break;
      case CanStartScan.failed:
        isWifiConnecting = false;
        await WiFiScan.instance.getScannedResults().then((value) {
          value.forEach((element) {
            log("failed: $element");
          });
        });
        setState(() {});
        Future.delayed(Duration.zero).then((value) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("failed")));
        });
        break;
    }
  }

  Future<void>connect(String ssid, String password)async{
    await WifiConnector.connectToWifi(ssid: ssid, password: password, isWEP: true);
  }

  @override
  void initState() {
    super.initState();
    _startScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isWifiConnecting ?ListView.builder(
        itemCount: wifiList.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return Card(

            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(15),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              child: MaterialButton(
                onPressed: ()async{
                  showDialog(
                    context: context,
                    builder: (context){
                      TextEditingController controller = TextEditingController();
                      return AlertDialog(
                        content: TextField(
                          controller: controller,
                          decoration: const InputDecoration(
                            hintText: "Password",
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () async {
                              await connect(wifiList[index].ssid, controller.text.trim().toString());
                              Navigator.pop(context);
                            },
                            child: const Text("Connect"),
                          )
                        ],
                      );
                    }
                  );
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Name:        [${wifiList[index].ssid}]"),
                    Text("bssid:       [${wifiList[index].bssid}]"),
                    Text("Frequency:       [${wifiList[index].frequency}]"),
                    Text("Level:       [${wifiList[index].level.toString()}]"),
                    Text("Capabilities:        [${wifiList[index].capabilities}]"),
                    Text("ChannelWidth index:     [${wifiList[index].channelWidth?.index.toString() ?? "---"}]"),
                  ],
                ),
              ),
            ),
          );
        },
      ):const Center(
        child: CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // await WiFiScan.instance.startScan();
          await _startScan();
        },
        child: const Text("Scan"),
      ),
    );
  }
}
