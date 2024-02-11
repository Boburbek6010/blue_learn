import 'dart:async';
import 'dart:convert';
import 'dart:io'; // Import for socket programming
import 'dart:developer';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:network_info_plus/network_info_plus.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool isLoading = false;
  final info = NetworkInfo();
  String str = "";
  String? wifiName = "";
  String? wifiIP = "";
  bool isNetworkWifi = false;

  // Variables for socket programming
  late ServerSocket serverSocket;
  Socket? clientSocket;
  final int port = 12345; // Choose a port number for communication

  Future<void> checkConnectivity() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.wifi) {
      str = connectivityResult.toString();
      log("I am connected to a wifi network.");
      isNetworkWifi = true;
      setState(() {});
    } else {
      str = connectivityResult.toString();
      log("Not connected to a wifi network.");
      isNetworkWifi = false;
    }
  }

  Future<void> getNameOfConnection() async {
    wifiName = await info.getWifiName(); // "FooNetwork"
    wifiIP = await info.getWifiIP(); // 192.168.1.43
  }

  void startServer() async {
    try {
      serverSocket = await ServerSocket.bind(InternetAddress.anyIPv4, port, shared: true);
      log('Server listening on port $port');
      serverSocket.listen((Socket socket) {
        log('Client connected: ${socket.remoteAddress.address}');
        clientSocket = socket;
        clientSocket!.listen((List<int> data) {
          final message = utf8.decode(data);
          log('Received message from client: $message');
          // Process received message as needed
        });
      });
    } catch (e) {
      log('Failed to start server: $e');
    }
  }


  void sendMessage(String message) {
    if (clientSocket != null) {
      clientSocket!.write(utf8.encode(message));
      log('Sent message to client: $message');
    }
  }

  @override
  void initState() {
    super.initState();
    checkConnectivity().then((_) {
      if (isNetworkWifi) {
        getNameOfConnection().then((_) {
          startServer();
          isLoading = true;
          setState(() {});
        });
      }
    });
  }

  @override
  void dispose() {
    serverSocket.close();
    clientSocket?.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? ListView.builder(
        itemCount: 1,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          return isNetworkWifi
              ? Container(
            color: Colors.green,
            width: double.infinity,
            padding: const EdgeInsets.all(15),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: ListTile(
              title: const Text("You have connected:"),
              subtitle: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Name: ${wifiName ?? ""}"),
                  Text("IP: $wifiIP"),
                ],
              ),
            ),
          )
              : null;
        },
      )
          : const Center(
        child: CircularProgressIndicator(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          sendMessage("hello");
          await checkConnectivity();
          if (isNetworkWifi) {
            await getNameOfConnection();
            startServer();
            isLoading = true;
            setState(() {});
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Wifi not connected")));
          }
        },
        child: const Text("Scan"),
      ),
    );
  }
}
