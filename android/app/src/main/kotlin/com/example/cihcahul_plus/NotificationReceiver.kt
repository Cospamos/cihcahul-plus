package com.constinox.cihcahul_plus

import android.app.NotificationManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.core.app.NotificationCompat
import android.util.Log

class NotificationReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        val title = intent?.getStringExtra("title") ?: "Title"
        val text = intent?.getStringExtra("text") ?: "Text"
        val NOTIFICATION_ID = 10001
        
        val manager = context?.getSystemService(NotificationManager::class.java)

        val builder = NotificationCompat.Builder(context!!, "lesson_channel")
            .setSmallIcon(R.mipmap.ic_launcher)
            .setContentTitle(title)
            .setContentText(text)
            .setPriority(NotificationCompat.PRIORITY_HIGH)
            .setAutoCancel(true)
            .setDefaults(NotificationCompat.DEFAULT_ALL)

        manager?.notify(NOTIFICATION_ID, builder.build())
        // Log.d("MyApp", "manager is null? ${manager == null}")
    }
}