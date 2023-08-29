import Flutter
import UIKit
import React

public class FlutterReactNativePlugin: NSObject, FlutterPlugin {
    static var reactChannel : FlutterMethodChannel?;
    static var flutterChannel : FlutterMethodChannel?;
    static var rootView : RCTRootView?;
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        reactChannel = FlutterMethodChannel(name: "flutter_react_native", binaryMessenger: registrar.messenger())
        flutterChannel = FlutterMethodChannel(name: "react_native_flutter", binaryMessenger: registrar.messenger())
        
        let jsCodeLocation = URL(string: "http://localhost:8081/index.bundle?platform=ios")
        
        rootView = RCTRootView(
            bundleURL: jsCodeLocation!,
            moduleName: "reactModule",
            initialProperties: nil
        )
        
        let instance = FlutterReactNativePlugin()
        registrar.addMethodCallDelegate(instance, channel: reactChannel!)
    }
    
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let controller = UIApplication.shared.keyWindow?.rootViewController as? FlutterViewController {
            switch call.method {
            case "reactNativeChannel":
                FlutterReactNativePlugin.rootView?.appProperties = call.arguments as? [AnyHashable : Any]
                FlutterReactNativePlugin.rootView?.appProperties?.updateValue("module", forKey: "type")
                controller.view.addSubview(FlutterReactNativePlugin.rootView!)
            case "flutterCallback":
                FlutterReactNativePlugin.rootView?.appProperties = call.arguments as? [AnyHashable : Any]
                FlutterReactNativePlugin.rootView?.appProperties?.updateValue("callback", forKey: "type")
                controller.view.addSubview(FlutterReactNativePlugin.rootView!)
            default:
                break;
            }
        }
        
    }
}
