// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import '../communication/auto_discovery.dart';
import 'package:hycop_light/hycop.dart';
import '../model/host_model.dart';
//import 'frame_manager.dart';
//import 'contents_manager.dart';

class HostManager extends AbsExModelManager {
  AutoDiscovery autoDiscovery = AutoDiscovery();

  HostManager({String tableName = 'creta_host'}) : super(tableName) {
    saveManagerHolder?.registerManager('host', this);
  }

  @override
  AbsExModel newModel(String mid) {
    return HostModel(
      parent: mid,
      hostName: '',
      ip: '',
    );
  }

  @override
  void realTimeCallback(
      String listenerId, String directive, String userId, Map<String, dynamic> dataMap) {
    return;
  }

  HostModel? findModel(String hostName) {
    for (var each in modelList) {
      HostModel host = each as HostModel;
      if (host.hostName == hostName) {
        return host;
      }
    }
    return null;
  }

  void udpCallback(String message) {
    Map<String, String> jsonMap = jsonDecode(message);

    HostModel model = HostModel();
    model.fromMap(jsonMap);

    HostModel? existModel = findModel(model.hostName);

    if (existModel != null) {
      existModel.updateFrom(model);
    } else {
      modelList.add(model);
    }
    notifyListeners();
  }
}
