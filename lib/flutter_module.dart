import 'package:flutter/services.dart';
import 'package:flutter_react_native/flutter_react_native.dart';

class FlutterModule {
  static MethodChannel flutterChannel =
      const MethodChannel("react_native_flutter");
  static final List<_FlutterModuleComponent> _functionList = [];
  static bool _initialized = false;
  static _init() {
    flutterChannel.setMethodCallHandler((call) async {
      switch (call.method) {
        case "flutterChannel":
          for (var function in _functionList) {
            if (function.name == call.arguments["method"]) {
              var result = await function.action(call.arguments["params"]);
              var data = {
                "requestId": call.arguments["requestId"],
                "value": result
              };
              FlutterReactNative.reactChannel
                  .invokeMethod("flutterCallback", data);
            }
          }
          break;
        default:
      }
    });

    _initialized = true;
  }

  static define(String functionName, Function(dynamic params) action) {
    if (!_initialized) {
      _init();
    }
    _functionList.add(_FlutterModuleComponent(functionName, action));
  }
}

class _FlutterModuleComponent {
  String name;
  Function(dynamic) action;
  _FlutterModuleComponent(this.name, this.action);
}
