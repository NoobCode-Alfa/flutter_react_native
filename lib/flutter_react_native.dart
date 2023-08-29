import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

class FlutterReactNative {
  static MethodChannel reactChannel =
      const MethodChannel("flutter_react_native");
  static List<Map<String, Function>> methodQueue = [];
  static bool _initialized = false;
  
  static _init() {
    reactChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "reactNativeCallback":
          for (var queue in methodQueue) {
            if (queue.keys.first == call.arguments["requestId"]) {
              queue.values.first.call(call.arguments["value"]);
            }
          }
          break;
        default:
      }
    });

    _initialized = true;
  }

  static call(
      {required String method,
      dynamic params,
      Function(dynamic value)? callback}) {
    if (!_initialized) {
      _init();
    }

    String requestId = const Uuid().v4().toString();
    if (callback != null) {
      methodQueue.add(
        {
          requestId: callback,
        },
      );
    }

    reactChannel.invokeMethod("reactNativeChannel", {
      "requestId": requestId,
      "method": method,
      "params": params,
    });
  }
}
