package com.layertwolabs.bitwindow

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.system.Os
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    // Dart and the daemons resolve every data path against HOME, as on Linux.
    override fun onCreate(savedInstanceState: Bundle?) {
        Os.setenv("HOME", filesDir.absolutePath, true)
        Os.setenv("BITWINDOW_HOME", filesDir.absolutePath, true)
        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.layertwolabs.bitwindow/native").setMethodCallHandler { call, result ->
            when (call.method) {
                "openUrl" -> try {
                    startActivity(Intent(Intent.ACTION_VIEW, Uri.parse(call.arguments as String)))
                    result.success(null)
                } catch (e: ActivityNotFoundException) {
                    result.error("no_handler", e.message, null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
