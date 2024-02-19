import 'dart:convert';
import 'dart:io';
//import 'dart:async';

//import 'package:flutter/material.dart';
import 'package:hycop_light/common/util/logger.dart';

class AutoDiscovery {
  //Timer? _autoDiscoveryTimer;
  RawDatagramSocket? _socket;

  void startBroadcast() {
    logger.info('startBroadcast');
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 0).then((RawDatagramSocket socket) {
      socket.broadcastEnabled = true;
      logger.info('UDP Broadcast started on ${socket.address.address}:${socket.port}');
      _socket = socket;
      //_autoDiscoveryTimer?.cancel();
      //_autoDiscoveryTimer = Timer.periodic(const Duration(seconds: 5), (Timer timer) {
      String message = 'flexi:discovery';
      List<int> data = const Utf8Encoder().convert(message);
      socket.send(data, InternetAddress('255.255.255.255'), 8888);
      logger.info('Broadcasting: $message');
      //});
    });
  }

  void stopBroadcast() {
    //_autoDiscoveryTimer?.cancel();
    _socket?.close();
  }

  void listenForResponses({required void Function(String message) callback}) {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 8888).then((RawDatagramSocket socket) {
      logger.info('Listening on ${socket.address.address}:${socket.port}');
      socket.listen((RawSocketEvent e) {
        Datagram? datagram = socket.receive();

        if (datagram != null) {
          String message = String.fromCharCodes(datagram.data);
          logger.info('Data received from ${datagram.address.address}: $message');
          // 여기서 UI 업데이트 로직을 추가하세요.
          callback.call(message);
        }
      });
    });
  }

  void listenAndRespond({String? hostName, void Function(String message)? callback}) {
    RawDatagramSocket.bind(InternetAddress.anyIPv4, 8888).then((RawDatagramSocket socket) {
      logger.info('Listening on ${socket.address.address}:${socket.port}');
      socket.broadcastEnabled = true;
      socket.listen((RawSocketEvent e) {
        Datagram? datagram = socket.receive();
        if (datagram != null) {
          String received = String.fromCharCodes(datagram.data);
          logger.info('Data received from ${datagram.address.address}: $received');
          String host = hostName ?? Platform.localHostname;
          String send =
              '{"ip": "${socket.address.address}", "hostName": "$host", "isConnected" : false}';
          List<int> data = const Utf8Encoder().convert(send);
          socket.send(data, datagram.address, datagram.port);
          logger.info('Responded with: $send');
          callback?.call(send);
        }
      });
    });
  }
}
