// import '../models/bluetooth_devise.dart';
// import '../implt/shake2share_method_channel.dart';
//
// abstract class Shake2sharePlatform extends PlatformInterface {
//   Shake2sharePlatform() : super(token: _token);
//
//   static final Object _token = Object();
//
//   static Shake2sharePlatform _instance = MethodChannelShake2share();
//
//   static Shake2sharePlatform get instance => _instance;
//
//   static set instance(Shake2sharePlatform instance) {
//     PlatformInterface.verifyToken(instance, _token);
//     _instance = instance;
//   }
//
//   Future<bool?> setAdvertise(
//       {required String uuid,
//       String? localName,
//       String? receiver,
//       Duration? timeOut});
//
//   Stream<BluetoothDevice?> startScan({String? serviceUuid});
//
//
//   Future<String?> connectToDevice(String id);
//
//   Future<String?> readData(String? id);
//
//   Future<bool> writeData(String? data);
//
//   Future<bool> isEnabled();
//
//   Future<bool> turnOn();
//
//   Future<bool> turnOnLocation();
//
//   Future<void> dispose();
// }
