import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FlutterBlue flutterBlue = FlutterBlue.instance;
  bool _isScanning = true;
  List<ScanResult> resultList = [];
  bool _isConnecting = false;
  BluetoothDevice? connectedDevice;

  void initBlue() {
    flutterBlue.isScanning.listen((event) {
      setState(() {
        _isScanning = event;
      });
    });
  }

  Future<void> scan() async {
    _isConnecting = false;
    setState(() {});
    if (!_isScanning) {
      resultList.clear();
      await flutterBlue.startScan(timeout: const Duration(seconds: 4));
      flutterBlue.scanResults.listen((event) {
        setState(() {
          resultList = event;
        });
      });
    } else {
      await flutterBlue.stopScan();
    }
  }

  Future<void> connectToDevice(int index) async {
    try {
      _isConnecting = true;
      setState(() {});
      log("Connecting...");
      await resultList[index].device.connect();
      connectedDevice = resultList[index].device;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Successfully Connected")));
    } catch (e) {
      log("Connection error: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Connection Failed")));
    } finally {
      _isConnecting = false;
      setState(() {});
    }
  }

  Future<void> disconnectFromDevice(int index) async {
    try {
      await resultList[index].device.disconnect();
      connectedDevice = null;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Disconnected")));
    } catch (e) {
      log("Disconnection error: $e");
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Disconnection Failed")));
    }
  }

  Color getCardColor(int index) {
    if (resultList[index].device == connectedDevice) {
      return Colors.green;
    } else {
      return Colors.white;
    }
  }

  @override
  void initState() {
    super.initState();
    initBlue();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ListView.builder(
            itemCount: resultList.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Card(
                color: getCardColor(index),
                child: ListTile(
                  onTap: () async {
                    if (!_isConnecting) {
                      await connectToDevice(index);
                    }
                  },
                  onLongPress: () async {
                    await disconnectFromDevice(index);
                  },
                  title: Text("Name: ${resultList[index].device.name ?? "Unknown"}"),
                  subtitle: Text("ID: ${resultList[index].device.id.id}"),
                  trailing: Text("Connectable: ${resultList[index].advertisementData.connectable}"),
                ),
              );
            },
          ),
          if (_isConnecting)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await scan();
        },
        child: const Text("Scan"),
      ),
    );
  }
}
