package com.example.shipkia_app

import android.app.Activity
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var documentBytes: ByteArray? = null
    private var documentResult: MethodChannel.Result? = null
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "shipkia/documents").setMethodCallHandler { call, result ->
            if (call.method != "exportPdf") { result.notImplemented(); return@setMethodCallHandler }
            if (documentResult != null) { result.error("busy", "A document picker is already open", null); return@setMethodCallHandler }
            val bytes = call.argument<ByteArray>("bytes")
            val name = call.argument<String>("name") ?: "order.pdf"
            if (bytes == null) { result.error("invalid", "Missing PDF", null); return@setMethodCallHandler }
            documentBytes = bytes
            documentResult = result
            try {
                val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
                    addCategory(Intent.CATEGORY_OPENABLE)
                    type = "application/pdf"
                    putExtra(Intent.EXTRA_TITLE, name)
                }
                startActivityForResult(intent, 7214)
            } catch (error: Exception) {
                documentBytes = null; documentResult = null
                result.error("export_failed", error.message, null)
            }
        }
    }
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode != 7214) return
        val result = documentResult ?: return
        val bytes = documentBytes
        documentResult = null; documentBytes = null
        if (resultCode != Activity.RESULT_OK || data?.data == null || bytes == null) { result.success(false); return }
        try {
            val stream = contentResolver.openOutputStream(data.data!!) ?: throw IllegalStateException("Cannot open destination")
            stream.use { it.write(bytes) }
            result.success(true)
        } catch (error: Exception) { result.error("export_failed", error.message, null) }
    }
}
