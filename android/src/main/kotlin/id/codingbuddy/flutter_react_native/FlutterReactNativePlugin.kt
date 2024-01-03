package id.codingbuddy.flutter_react_native

import android.app.Activity
import android.content.Context
import android.os.Bundle
import android.view.ViewGroup

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import com.facebook.react.BuildConfig
import com.facebook.react.PackageList
import com.facebook.react.ReactInstanceManager
import com.facebook.react.ReactPackage
import com.facebook.react.ReactRootView
import com.facebook.react.common.LifecycleState
import com.facebook.soloader.SoLoader
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding

/** FlutterReactNativePlugin */
class FlutterReactNativePlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var reactInstanceManager: ReactInstanceManager

    private lateinit var context: Context
    private lateinit var activity: Activity

    companion object {
        lateinit var reactChannel: MethodChannel;
        lateinit var flutterChannel: MethodChannel;

        private lateinit var parentView: ViewGroup;
        private lateinit var reactRootView: ReactRootView;

        var processCount: Int = 0;

        fun finishRequest(){
            parentView = ((reactRootView.parent as? ViewGroup)!!)
            parentView.removeView(reactRootView)
        }
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        reactChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_react_native")
        flutterChannel = MethodChannel(flutterPluginBinding.binaryMessenger, "react_native_flutter")
        reactChannel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "reactNativeChannel") {
            reactRootView = ReactRootView(context)
            val bundle = paramBuilder(call.arguments as java.io.Serializable)
            bundle.putSerializable("type", "module")
            reactRootView.startReactApplication(reactInstanceManager, "reactModule", bundle)
            parentView.addView(reactRootView, 0)
            processCount++;
        } else if (call.method == "flutterCallback") {
            var reactRootView = ReactRootView(context)
            val bundle = paramBuilder(call.arguments as java.io.Serializable)
            bundle.putSerializable("type", "callback")
            reactRootView.startReactApplication(reactInstanceManager, "reactModule", bundle)
            parentView.addView(reactRootView, 0)
        } else {
            result.notImplemented()
        }
    }

    fun paramBuilder(data: java.io.Serializable): Bundle {
        var result = Bundle();
        for (args in data as HashMap<*, *>) {
            if (args.value is HashMap<*, *>) {
                result.putBundle(
                    args.key.toString(),
                    paramBuilder(args.value as java.io.Serializable)
                )
            } else {
                result.putSerializable(args.key.toString(), args.value as java.io.Serializable?);
            }
        }
        return result
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        reactChannel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        try{
            activity = binding.activity
            context = binding.activity.applicationContext

            // React Native Setup
            SoLoader.init(context, false)

    //        reactRootView = ReactRootView(context)
    //        reactRootView.unmountReactApplication()

            var packages: List<ReactPackage> =
                PackageList(activity.application).packages.apply { add(MyReactPackage()) }

            reactInstanceManager = ReactInstanceManager.builder()
                .setApplication(activity.application)
                .setCurrentActivity(activity)
                .setBundleAssetName("index.android.bundle")
                .setJSMainModulePath("index")
                .addPackages(packages)
                .setUseDeveloperSupport(BuildConfig.DEBUG)
                .setInitialLifecycleState(LifecycleState.RESUMED)
                .build()

            val lp = ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
            )
            reactRootView = ReactRootView(context)

            activity.addContentView(reactRootView, lp)
            parentView = ((reactRootView.parent as? ViewGroup)!!)
            parentView.removeView(reactRootView)
        } catch (ex: Exception) { }
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
    }
}
