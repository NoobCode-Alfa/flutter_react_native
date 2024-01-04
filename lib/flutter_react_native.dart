import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

class FlutterReactNative {
  static MethodChannel reactChannel =
      const MethodChannel("flutter_react_native");
  static List<QueueData> queue = [];
  static bool _initialized = false;

  static _init() {
    reactChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "reactNativeCallback":
          for (var queueData in queue) {
            if (queueData.requestId == call.arguments["requestId"]) {
              queueData.value = call.arguments["value"];
              queueData.finish = true;
            }
          }
          break;
        default:
      }
    });

    _initialized = true;
  }

  static Future<dynamic> call(
      {required String method,
      dynamic params,
      bool returningValue = false}) async {
    if (!_initialized) {
      _init();
    }

    await SystemChannels.textInput.invokeMethod('TextInput.hide');

    String requestId = const Uuid().v4().toString();
    if (returningValue) {
      queue.add(QueueData(requestId: requestId));
    }

    reactChannel.invokeMethod("reactNativeChannel", {
      "requestId": requestId,
      "method": method,
      "params": params,
    });

    if (returningValue) {
      while (!queue
          .firstWhere((element) => element.requestId == requestId)
          .finish) {
        await Future.delayed(const Duration(seconds: 1));
      }
      return queue
          .firstWhere((element) => element.requestId == requestId)
          .value;
    }
  }
}

class QueueData {
  String requestId;
  dynamic value;
  bool finish;
  QueueData({required this.requestId, this.value, this.finish = false});
}
