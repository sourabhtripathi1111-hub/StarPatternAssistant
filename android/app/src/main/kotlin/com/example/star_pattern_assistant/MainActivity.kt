
package com.example.star_pattern_assistant

import android.content.Intent
import android.net.Uri
import android.os.Build
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val channelName = "star_pattern_assistant/live"
    private var liveRunning = false
    private var lastWatch = "Wait"
    private var lastRisk = "Low"
    private var lastReason = "Live assistant ready"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasOverlayPermission" -> {
                    result.success(if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) Settings.canDrawOverlays(this) else true)
                }
                "requestOverlayPermission" -> {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(this)) {
                        val intent = Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION, Uri.parse("package:$packageName"))
                        startActivity(intent)
                    }
                    result.success(null)
                }
                "startLiveAssistant" -> {
                    liveRunning = true
                    result.success(mapOf("ok" to true, "message" to "Live assistant base started. Overlay/screen-capture service next module me active hoga.", "data" to mapOf<String, Any>()))
                }
                "stopLiveAssistant" -> {
                    liveRunning = false
                    result.success(mapOf("ok" to true, "message" to "Live assistant stopped.", "data" to mapOf<String, Any>()))
                }
                "captureOnce" -> {
                    // V2 base stub. Next module will use MediaProjection + crop + OCR/image matching.
                    result.success(mapOf("ok" to true, "message" to "Capture hook called. Real game-screen capture next native service me add hoga.", "data" to mapOf("running" to liveRunning)))
                }
                "updateOverlay" -> {
                    lastWatch = call.argument<String>("watch") ?: "Wait"
                    lastRisk = call.argument<String>("risk") ?: "Low"
                    lastReason = call.argument<String>("reason") ?: ""
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }
}
