package com.example.tinatrip_app

import android.content.Intent
import android.net.Uri
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "tinatrip")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "sendEmail" -> {
                        val to = call.argument<String>("to")
                        val subject = call.argument<String>("subject")
                        val body = call.argument<String>("body")
                        val uri = Uri.Builder()
                            .scheme("mailto")
                            .authority(to.orEmpty())
                            .appendQueryParameter("subject", subject.orEmpty())
                            .appendQueryParameter("body", body.orEmpty())
                            .build()
                        launch(Intent(Intent.ACTION_SENDTO, uri), "ارسال ایمیل", result)
                    }
                    "openUrl" -> {
                        val url = call.argument<String>("url").orEmpty()
                        launch(Intent(Intent.ACTION_VIEW, Uri.parse(url)), "باز کردن لینک", result)
                    }
                    "dial" -> {
                        val number = call.argument<String>("number").orEmpty()
                        launch(Intent(Intent.ACTION_DIAL, Uri.parse("tel:$number")), null, result)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun launch(intent: Intent, title: String?, result: MethodChannel.Result) {
        try {
            if (title != null) {
                startActivity(Intent.createChooser(intent, title))
            } else {
                startActivity(intent)
            }
            result.success(true)
        } catch (e: Exception) {
            result.success(false)
        }
    }
}
