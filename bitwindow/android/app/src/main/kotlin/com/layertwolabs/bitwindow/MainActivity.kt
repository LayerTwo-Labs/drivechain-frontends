package com.layertwolabs.bitwindow

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.webkit.MimeTypeMap
import androidx.core.content.FileProvider
import java.io.File
import java.io.IOException
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
                "shareFile" -> try {
                    shareFile(call.arguments as String)
                    result.success(null)
                } catch (e: IOException) {
                    result.error("share_failed", e.message, null)
                } catch (e: IllegalArgumentException) {
                    result.error("share_failed", e.message, null)
                } catch (e: ActivityNotFoundException) {
                    result.error("no_handler", e.message, null)
                }
                else -> result.notImplemented()
            }
        }
    }

    // The share sheet reads a copy in cache/share, so the FileProvider never exposes the data folder.
    private fun shareFile(path: String) {
        val source = File(path)
        if (!source.isFile) {
            throw IOException("no file at $path")
        }
        val shareDir = File(cacheDir, "share")
        shareDir.deleteRecursively()
        if (!shareDir.mkdirs()) {
            throw IOException("could not create ${shareDir.path}")
        }
        val copy = source.copyTo(File(shareDir, source.name))
        val uri = FileProvider.getUriForFile(this, "$packageName.share", copy)
        val type = MimeTypeMap.getSingleton().getMimeTypeFromExtension(copy.extension.lowercase())
            ?: "application/octet-stream"
        val send = Intent(Intent.ACTION_SEND).apply {
            setType(type)
            putExtra(Intent.EXTRA_STREAM, uri)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
        }
        startActivity(Intent.createChooser(send, null))
    }
}
