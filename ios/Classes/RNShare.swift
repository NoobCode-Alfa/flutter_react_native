//
//  RNShare.swift
//  Runner
//
//  Created by Yustan Julmakap on 04/08/23.
//

import Foundation

@objc(RNShare)
class RNShare : NSObject {
    @objc static func requiresMainQueueSetup() -> Bool {
        return false
    }
    
    @objc func callback(_ options: NSDictionary) -> Void {
        DispatchQueue.main.async {
            self._callback(options: options)
        }
    }
    func _callback(options: NSDictionary) -> Void {
        FlutterReactNativePlugin.reactChannel?.invokeMethod("reactNativeCallback", arguments: options)
    }
    
    @objc func call(_ options: NSDictionary) -> Void {
        DispatchQueue.main.async {
            self._call(options: options)
        }
    }
    func _call(options: NSDictionary) -> Void {
        FlutterReactNativePlugin.flutterChannel?.invokeMethod("flutterChannel", arguments: options)
    }
}
