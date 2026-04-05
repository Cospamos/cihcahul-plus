package com.constinox.cihcahul_plus

import android.app.Notification
import android.widget.RemoteViews
import androidx.core.app.NotificationCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build
import android.util.Log
import android.os.Bundle
import android.view.WindowManager
import android.os.Handler
import android.os.Looper
import android.app.AlarmManager
import android.app.PendingIntent
import android.content.Intent
import android.content.Context
import android.provider.Settings

class MainActivity : FlutterActivity() {

    private val CHANNEL = "app.channel.notifications"
    private var flutterEngineRef: FlutterEngine? = null
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        createNotificationChannel()
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        flutterEngineRef = flutterEngine

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "showNotification") {
                    val title = call.argument<String>("title") ?: "Default"
                    val text = call.argument<String>("text") ?: "Text"
                    val delay = when (val d = call.argument<Any>("delay")) {
                        is Int -> d.toLong()
                        is Long -> d
                        else -> 0L
                    }

                    showNotification(title, text, delay)

                    result.success(null)
                } else if (call.method == "canScheduleExactAlarms") {
                    val alarmManager = getSystemService(ALARM_SERVICE) as AlarmManager
                    result.success(alarmManager.canScheduleExactAlarms())
                } else if (call.method == "requestExactAlarmPermission") {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                        val intent = Intent(Settings.ACTION_REQUEST_SCHEDULE_EXACT_ALARM)
                        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                        startActivity(intent)
                    }
                    result.success(null)
                }
                else {
                    result.notImplemented()
                }
            }
    }
    
    private fun createNotificationChannel() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                "lesson_channel",
                "Lessons",
                NotificationManager.IMPORTANCE_HIGH
            )

            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }
    }

    private fun showNotification(title: String, text: String, targetTimeMillis: Long) {
        
        val notificationManager = getSystemService(Context.NOTIFICATION_SERVICE) as NotificationManager
        notificationManager.cancelAll()
        
        if (targetTimeMillis <= System.currentTimeMillis()) {
            return
        }

        val notificationIntent  = Intent(this, NotificationReceiver::class.java).apply {
            putExtra("title", title)
            putExtra("text", text)
        }

        val requestCode = targetTimeMillis.toInt()

        val pendingIntent = PendingIntent.getBroadcast(
            this,
            requestCode,
            notificationIntent,
            PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
        )

        val alarmManager = getSystemService(ALARM_SERVICE) as AlarmManager
        alarmManager.setExactAndAllowWhileIdle(
            AlarmManager.RTC_WAKEUP,
            targetTimeMillis,
            pendingIntent
        )
        // Log.d("MyApp", "Show notification from kt is working")
    }

}