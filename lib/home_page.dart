import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';

class BluetoothScreen extends StatefulWidget {
  const BluetoothScreen({super.key});

  @override
  BluetoothScreenState createState() => BluetoothScreenState();
}

class BluetoothScreenState extends State<BluetoothScreen> {
  // final flutterReactiveBle = FlutterReactiveBle();
  // late StreamSubscription<DiscoveredDevice> scanSubscription;
  // late DiscoveredDevice devices;
  List<ScanResult> deviceList = [];
  bool isLoading = false;
  bool isConnected = false;
  String char = "";

  @override
  void initState() {
    super.initState();
    scanForDevices();
  }

  void scanForDevices() {
    isConnected = false;
    isLoading = false;
    FlutterBluePlus.startScan(withServices: [Guid("fc32ae3c-0000-1000-8000-00805f9b34fb")]);
    FlutterBluePlus.scanResults.listen((event) async {
      deviceList = event;
      await deviceList.first.device.connect();
      deviceList.first.device.connectionState.listen((event) async {
        if(event == BluetoothConnectionState.connected){
          isConnected = true;
          setState(() {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Connected")));
          });

          log("\n\n");
          deviceList.first.advertisementData.manufacturerData.forEach((key, value) {
            log("Key: $key, \nValue: $value");
          });
          log("\n\n");

          for (var element in deviceList.first.advertisementData.msd) {
            log("msd: $element");
          }
          log("\n\n");

          log("ADV NAME: ${deviceList.first.advertisementData.advName}");
          log("\n\n");

          log("Appearance: ${deviceList.first.advertisementData.appearance}");
          log("\n\n");

          log("ServiceData: ${deviceList.first.advertisementData.serviceData}");
          log("\n\n");

          log("ServiceUuids: ${deviceList.first.advertisementData.serviceUuids}");
          log("\n\n");

          log("txPowerLevel: ${deviceList.first.advertisementData.txPowerLevel}");
          log("\n\n");

          log("Connectable: ${deviceList.first.advertisementData.connectable}");
          log("\n\n");

          log("LocalName: ${deviceList.first.advertisementData.localName}");
          log("\n\n");

          log("\n\n\n\n\n=============================\n\n\n\n");


          log(deviceList.first.device.isConnected.toString());

          deviceList.first.device.bondState.listen((event) {
            log("BondState name of the device: ${event.name}");
          });

          log("\n\n");

          List<BluetoothService> discoverServices = await deviceList.first.device.discoverServices();
          // log("========\n\n$discoverServices\n\n");
          for (var element in discoverServices) {
            for (var char in element.characteristics) {
              if(char.properties.notify || char.properties.indicate){
                char.setNotifyValue(true);
                char.onValueReceived.listen((event) async {
                  // this.char += "=> ${String.fromCharCodes(event)}\n\n";
                  // setState(() {});
                  log(String.fromCharCodes(event));
                });
              }
            }
          }
        }

      });
      isLoading = true;
      setState(() {});
    });

    // scanSubscription = flutterReactiveBle.scanForDevices(withServices: [Uuid.parse("fc32ae3c-0000-1000-8000-00805f9b34fb")], scanMode: ScanMode.lowLatency).listen((DiscoveredDevice device) {
    //   setState(() {
    //     // log(device.serviceUuids.toString());
    //     devices = device;
    //     isLoading = true;
    //     return;
    //   });
    // }, onError: (e) {
    // });
  }

  // void connect()async{
  //   flutterReactiveBle.connectToDevice(id: devices.id).listen((event) async {
  //     log(event.connectionState.name);
  //     if(event.connectionState == DeviceConnectionState.connected){
  //       final char = QualifiedCharacteristic(characteristicId: Uuid.parse("a0d74f92-7eff-4a55-b699-381422ddae75"), serviceId: Uuid.parse("fc32ae3c-0000-1000-8000-00805f9b34fb"), deviceId: devices.id);
  //       List<int> a = await flutterReactiveBle.readCharacteristic(char);
  //       log("List: $a");
  //     }
  //   },
  //     onDone: (){
  //     log("onDone");
  //     },
  //     cancelOnError: false,
  //
  //     onError: (e){
  //     log("error: $e");
  //     },
  //   );
  // }

  // Future<List<int>> readData({required Uuid serviceId, required Uuid characteristicId, required String deviceId}) async {
  //   final characteristic = QualifiedCharacteristic(serviceId: serviceId, characteristicId: characteristicId, deviceId: deviceId);
  //   final response = await flutterReactiveBle.readCharacteristic(characteristic);
  //   log(response.toString());
  //   return response;
  // }

  // @override
  // void dispose() {
  //   // scanSubscription.cancel();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading && isConnected
          ? ListView.builder(
              itemCount: deviceList.length,
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    ListTile(
                      title: Text(deviceList[index].device.advName),
                      subtitle: Text(deviceList[index].device.remoteId.toString() ?? 'Unknown'),
                      onTap: () async {

                        deviceList[index].device.connectionState.listen((event) async {
                          if (event == BluetoothConnectionState.connected) {
                            log("\n\n========connected========\n\n\n");
                            // deviceList[index].device.servicesList.first;
                            // deviceList[index].device.mtu.listen((event)async {
                            //   log("\n\n\n\nEvent: ================ $event");
                            //   List<BluetoothService> list =  await deviceList[index].device.discoverServices();
                            //   for (var service in list) {
                            //     var characteristics = service.characteristics;
                            //     for (BluetoothCharacteristic c in characteristics) {
                            //
                            //       for(var element in c.descriptors){
                            //         List<int> value = await element.read();
                            //         String a = String.fromCharCodes(value);
                            //         log("\n=========dddddd============$a");
                            //       }
                            //
                            //       if (c.properties.read) {
                            //         List<int> value = await c.read();
                            //         String a = String.fromCharCodes(value);
                            //         log("=====================$a");
                            //       }
                            //       // BmDescriptorData data =
                            //
                            //       log('last data ${c.serviceUuid.str}');
                            //       // log('last data ${c.onValueReceived.first.ignore}');
                            //     }
                            //   }
                            // });
                          }
                          else if (event == BluetoothConnectionState.disconnected) {
                            log("disconnected");
                          }
                        });
                      },
                    ),
                    Text(char, style: const TextStyle(
                      fontSize: 16
                    ),),
                  ],
                );
              },
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
