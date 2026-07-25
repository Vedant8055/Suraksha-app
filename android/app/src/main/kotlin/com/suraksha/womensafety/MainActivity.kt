package com.suraksha.womensafety

import android.telephony.SmsManager
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val smsChannel = "suraksha/sms"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, smsChannel).setMethodCallHandler { call, result ->
            if (call.method != "sendSms") {
                result.notImplemented()
                return@setMethodCallHandler
            }

            val phoneNumber = call.argument<String>("phoneNumber")
            val message = call.argument<String>("message")

            if (phoneNumber.isNullOrBlank() || message.isNullOrBlank()) {
                result.error("INVALID_SMS_ARGS", "Phone number and message are required.", null)
                return@setMethodCallHandler
            }

            try {
                val smsManager = SmsManager.getDefault()
                val parts = smsManager.divideMessage(message)
                // Sent/delivery intents are omitted intentionally so SOS stays fast.
                // "queued" means handed to SmsManager — not carrier delivery confirmation.
                smsManager.sendMultipartTextMessage(phoneNumber, null, parts, null, null)
                result.success(
                    mapOf(
                        "queued" to true,
                        "delivered" to false,
                    ),
                )
            } catch (error: Exception) {
                result.error("SMS_SEND_FAILED", error.message, null)
            }
        }
    }
}
