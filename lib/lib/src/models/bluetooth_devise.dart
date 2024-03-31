class BluetoothDevice {
  String? name;
  String? id;
  String? uuid;
  bool? isConnected;

  BluetoothDevice({this.id, this.isConnected = false, this.name, this.uuid});

  BluetoothDevice.fromMap(Map? map) {
    id = map?['id'];
    name = map?['name'];
    isConnected = map?['isConnected'];
    uuid = map?['uuid'];
  }

  @override
  bool operator ==(Object other) {
    return (other is BluetoothDevice) && other.id == id;
  }
}
