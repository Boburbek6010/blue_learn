// import 'package:blue_learn/lib/src/interfaces/shake2share_platform_interface.dart';
// import 'package:blue_learn/lib/src/models/bluetooth_devise.dart';
//
// class Shake2Share {
//   final _shake2share = Shake2sharePlatform.instance;
//
//   Future<bool?> setAdvertise(
//       {required String uuid,
//       String? localName,
//       String? receiver,
//       Duration? timeOut}) {
//     return _shake2share.setAdvertise(
//         uuid: uuid, localName: localName, receiver: receiver, timeOut: timeOut);
//   }
//
//   Stream<BluetoothDevice?> startScan({String? serviceUuid}) {
//     return _shake2share.startScan(serviceUuid: serviceUuid);
//   }
//
//   Future<String?> connectToDevice(String id) {
//     return _shake2share.connectToDevice(id);
//   }
//
//   Future<String?> readData(String? id) {
//     return _shake2share.readData(id);
//   }
//
//   Future<bool> writeData(String? data) {
//     return _shake2share.writeData(data);
//   }
//
//   Future<bool> isEnabled() {
//     return _shake2share.isEnabled();
//   }
//
//   Future<bool> turnOn() {
//     return _shake2share.turnOn();
//   }
//
//   Future<bool> turnOnLocation() {
//     return _shake2share.turnOnLocation();
//   }
//
//   Future<void> dispose() {
//     return _shake2share.dispose();
//   }
// }
