package com.example.shake2share

import android.annotation.SuppressLint
import android.content.Context
import android.os.Build
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import android.app.Activity
import android.content.Intent
import android.util.Log
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.plugin.common.PluginRegistry
import android.Manifest
import android.content.pm.PackageManager
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.EventChannel


class Shake2sharePlugin : FlutterPlugin, MethodCallHandler, ActivityAware,
        PluginRegistry.ActivityResultListener {
    private lateinit var activity: Activity
    private val enableBluetoothRequestCode = 1879842617;


    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        initializePlugin(
                flutterPluginBinding.binaryMessenger,
                flutterPluginBinding.applicationContext,
                this
        )
    }

    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {

    }

    companion object {
        @SuppressLint("StaticFieldLeak")
        private lateinit var bleManager: BleManager;

        @SuppressLint("StaticFieldLeak")
        private lateinit var myContext: Context


        @JvmStatic
        private fun initializePlugin(
                messenger: BinaryMessenger,
                context: Context,
                plugin: Shake2sharePlugin
        ) {
            val channel = MethodChannel(messenger, "shake2share/methods")
            val connectionChannel =
                    EventChannel(messenger, "shake2share/connectionEvents")
            val eventChannel =
                    EventChannel(messenger, "shake2share/events")
            bleManager = BleManager(context);
            myContext = context
            channel.setMethodCallHandler(plugin)
            eventChannel.setStreamHandler(ScanResultHandler)
            connectionChannel.setStreamHandler(ConnectionHandler)
        }


    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivity() {
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {
    }


    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        bleManager.result = result;
        when (call.method) {
            "start" -> {
                bleManager.startBluetoothScan()
                result.success(null);
            }

            "setAdvertise" -> {
                requestBluetoothPermissions()
                bleManager.startAdvertiser(
                        call.argument("uuid"),
                        call.argument("timeOut"),
                        call.argument("localName"),
                        call.argument("receiver"),
                );
            }

            "connectToDevise" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    bleManager.connectToDevice(call.argument("address"))
                    result.success(null);
                };
            }

            "write" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    bleManager.writeChar(call.argument("data"), false)
                };
            }

            "read" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    bleManager.readChar()
                    result.success(null);
                };
            }

            "isEnabled" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    result.success(bleManager.bluetoothIsEnabled());
                };
            }

            "turnOn" -> {
                requestBluetoothPermissions()
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    bleManager.turnOn(activity, enableBluetoothRequestCode)
                };
            }

            "dispose" -> {
                if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                    bleManager.onCancel();
                };
            }

            else -> {
                result.error("UNAVAILABLE", "Method nod found", null)
            }
        }

    }


    private fun requestBluetoothPermissions() {
        val permissions = arrayOf(
                Manifest.permission.ACCESS_FINE_LOCATION,
                Manifest.permission.ACCESS_COARSE_LOCATION,
                Manifest.permission.BLUETOOTH_SCAN,
                Manifest.permission.BLUETOOTH_CONNECT,
                Manifest.permission.BLUETOOTH_ADVERTISE,
                Manifest.permission.BLUETOOTH_ADMIN,
        )

        var permissionRequestCode = 0
        for (permission in
        permissions) {
            permissionRequestCode++;
            if (ContextCompat.checkSelfPermission(
                            myContext,
                            permission
                    ) != PackageManager.PERMISSION_GRANTED
            ) {
                ActivityCompat.requestPermissions(activity, permissions, permissionRequestCode)
                break
            }
        }
    }


    object ConnectionHandler : EventChannel.StreamHandler {

        override fun onListen(p0: Any?, sink: EventChannel.EventSink) {
            bleManager.connectSink = sink;
        }

        override fun onCancel(p0: Any?) {
            bleManager.connectSink = null
        }
    }


    object ScanResultHandler : EventChannel.StreamHandler {
        override fun onListen(p0: Any?, sink: EventChannel.EventSink) {
            println("---> scan sink $sink")
            bleManager.scanSink = sink;
        }

        override fun onCancel(p0: Any?) {
            bleManager.scanSink = null
        }
    }


    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == enableBluetoothRequestCode) {
            Log.d("ActivityResult", "ActivityResult $requestCode")
            bleManager.turnOnResult()
        }
        return false
    }


}






