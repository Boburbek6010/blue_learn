// import 'dart:async';
// import 'package:flutter/services.dart';
//
// import '../interfaces/shake2share_platform_interface.dart';
// import '../models/bluetooth_devise.dart';
// import '../utils/stream_buffer.dart';
//
// class MethodChannelShake2share extends Shake2sharePlatform {
//   final _channel = const MethodChannel('shake2share/methods');
//   final _eventChannel = const EventChannel('shake2share/events');
//   final _connectionChannel = const EventChannel('shake2share/connectionEvents');
//
//   @override
//   Future<bool?> setAdvertise(
//       {required String uuid,
//       String? localName,
//       String? receiver,
//       Duration? timeOut}) async {
//     return await _channel.invokeMethod('setAdvertise', {
//       'uuid': uuid,
//       'localName': localName,
//       'receiver': receiver,
//       'timeOut': timeOut?.inMilliseconds,
//     });
//   }
//
//   @override
//   Future<String?> connectToDevice(String id) async {
//     await _channel.invokeMethod('connectToDevise', {"address": id});
//
//     Stream<String?> connectionResult =
//         _connectionChannel.receiveBroadcastStream().cast();
//
//     final buffer = BufferStream.listen(connectionResult);
//
//     await for (final item in buffer.stream) {
//       return item;
//     }
//     return null;
//   }
//
//   @override
//   Future<bool> isEnabled() async {
//     return await _channel.invokeMethod('isEnabled') ?? false;
//   }
//
//   @override
//   Future<bool> writeData(String? data) async {
//     return await _channel.invokeMethod('write', {"data": data}) ?? false;
//   }
//
//   @override
//   Future<String?> readData(String? id) async {
//     await _channel.invokeMethod('read', {"address":id});
//
//     Stream<String?> connectionResult =
//     _connectionChannel.receiveBroadcastStream().cast();
//
//     final buffer = BufferStream.listen(connectionResult);
//
//     await for (final item in buffer.stream) {
//       return item;
//     }
//     return null;
//   }
//
//   @override
//   Future<bool> turnOn() async {
//     return await _channel.invokeMethod('turnOn');
//   }
//
//   @override
//   Future<void> dispose() async {
//     await _channel.invokeMethod('dispose');
//   }
//
//   @override
//   Stream<BluetoothDevice?> startScan({String? serviceUuid}) async* {
//
//     Stream<Map?> scanResultsStream =
//         _eventChannel.receiveBroadcastStream().cast();
//
//     final buffer = BufferStream.listen(scanResultsStream);
//
//     await for (final item in buffer.stream) {
//       yield BluetoothDevice.fromMap(item);
//     }
//   }
//
//   @override
//   Future<bool> turnOnLocation() async {
//     return await _channel.invokeMethod('locationTurnOn');
//   }
// }
