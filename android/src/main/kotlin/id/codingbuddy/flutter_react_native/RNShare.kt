package id.codingbuddy.flutter_react_native
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.ReadableMap


class RNShare(reactContext: ReactApplicationContext) : ReactContextBaseJavaModule(reactContext) {
    override fun getName() = "RNShare"

    @ReactMethod
    fun callback(options : ReadableMap) {
        Handler(Looper.getMainLooper()).post(Runnable {
            FlutterReactNativePlugin.reactChannel.invokeMethod("reactNativeCallback", options.toHashMap())
        })
    }

    @ReactMethod
    fun call(options : ReadableMap) {
        Handler(Looper.getMainLooper()).post(Runnable {
            FlutterReactNativePlugin.flutterChannel.invokeMethod("flutterChannel", options.toHashMap())
        })
    }
}