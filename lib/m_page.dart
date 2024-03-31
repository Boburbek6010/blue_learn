// import 'dart:async';
// import 'dart:developer';
// import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
// import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
// // import 'package:flutter_reactive_ble/flutter_reactive_ble.dart';
//
// class BluetoothScreen extends StatefulWidget {
//   const BluetoothScreen({super.key});
//
//   @override
//   BluetoothScreenState createState() => BluetoothScreenState();
// }
//
// class BluetoothScreenState extends State<BluetoothScreen> {
//   final flutterReactiveBle = FlutterReactiveBle();
//   late StreamSubscription<DiscoveredDevice> scanSubscription;
//   late DiscoveredDevice devices;
//   // List<ScanResult> deviceList = [];
//   bool isLoading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     scanForDevices();
//   }
//
//   void scanForDevices() {
//     isLoading = false;
//     FlutterBluePlus.startScan(
//         withServices: [Guid("fc32ae3c-0000-1000-8000-00805f9b34fb")]);
//     FlutterBluePlus.scanResults.listen((event) async {
//       // List<BluetoothService> list = await event.first.device.discoverServices();
//       // list.first.characteristics;
//       deviceList = event;
//       log(deviceList.toString());
//       isLoading = true;
//       setState(() {});
//     });
//
//     scanSubscription = flutterReactiveBle.scanForDevices(withServices: [Uuid.parse("fc32ae3c-0000-1000-8000-00805f9b34fb")], scanMode: ScanMode.lowLatency).listen((DiscoveredDevice device) {
//       setState(() {
//         // log(device.serviceUuids.toString());
//         devices = device;
//         isLoading = true;
//         return;
//       });
//     }, onError: (e) {
//     });
//   }
//
//   // void connect()async{
//   //   flutterReactiveBle.connectToDevice(id: devices.id).listen((event) async {
//   //     log(event.connectionState.name);
//   //     if(event.connectionState == DeviceConnectionState.connected){
//   //       final char = QualifiedCharacteristic(characteristicId: Uuid.parse("a0d74f92-7eff-4a55-b699-381422ddae75"), serviceId: Uuid.parse("fc32ae3c-0000-1000-8000-00805f9b34fb"), deviceId: devices.id);
//   //       List<int> a = await flutterReactiveBle.readCharacteristic(char);
//   //       log("List: $a");
//   //     }
//   //   },
//   //     onDone: (){
//   //     log("onDone");
//   //     },
//   //     cancelOnError: false,
//   //
//   //     onError: (e){
//   //     log("error: $e");
//   //     },
//   //   );
//   // }
//
//   // Future<List<int>> readData({required Uuid serviceId, required Uuid characteristicId, required String deviceId}) async {
//   //   final characteristic = QualifiedCharacteristic(serviceId: serviceId, characteristicId: characteristicId, deviceId: deviceId);
//   //   final response = await flutterReactiveBle.readCharacteristic(characteristic);
//   //   log(response.toString());
//   //   return response;
//   // }
//
//   @override
//   void dispose() {
//     // scanSubscription.cancel();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: isLoading
//           ? ListView.builder(
//         itemCount: deviceList.length,
//         itemBuilder: (context, index) {
//           return ListTile(
//             title: Text(deviceList[index].device.advName),
//             subtitle: Text(deviceList[index].device.remoteId.toString() ??
//                 'Unknown'),
//             onTap: () async {
//               await deviceList[index].device.connect();
//               deviceList[index]
//                   .device
//                   .connectionState
//                   .listen((event) async {
//                 if (event == BluetoothConnectionState.connected) {
//                   log("connected");
//
//                   // deviceList[index].device.servicesList.first;
//                   List<BluetoothService> list =  await deviceList[index].device.discoverServices();
//                   for (var service in list) {
//                     var characteristics = service.characteristics;
//                     for (BluetoothCharacteristic c in characteristics) {
//                       for(var element in c.descriptors){
//                         element.read();
//                         List<int> value = await element.read();
//                         String a = String.fromCharCodes(value);
//                         log("\n=========dddddd============$a");
//                       }
//                       if (c.properties.read) {
//                         List<int> value = await c.read();
//                         String a = String.fromCharCodes(value);
//                         log("=====================$a");
//                       }
//                     }
//                   }
//
//                 } else if (event ==
//                     BluetoothConnectionState.disconnected) {
//                   log("disconnected");
//                 }
//               });
//             },
//           );
//         },
//       )
//           : const Center(
//         child: CircularProgressIndicator(),
//       ),
//     );
//   }
// }
