package com.example.star_pattern_assistant

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.os.Build
import android.os.IBinder

class ScreenCaptureService : Service() {

    override fun onCreate() {
        super.onCreate()
        startForeground(1002, createNotification())
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        return START_STICKY
    }

    private fun createNotification(): Notification {
        val channelId = "star_capture_channel"

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                channelId,
                "Star Pattern Capture",
                NotificationManager.IMPORTANCE_LOW
            )
            val manager = getSystemService(NotificationManager::class.java)
            manager.createNotificationChannel(channel)
        }

        return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            Notification.Builder(this, channelId)
                .setContentTitle("Star Pattern Assistant")
                .setContentText("Live screen helper running")
                .setSmallIcon(android.R.drawable.ic_menu_camera)
                .build()
        } else {
            Notification.Builder(this)
                .setContentTitle("Star Pattern Assistant")
                .setContentText("Live screen helper running")
                .setSmallIcon(android.R.drawable.ic_menu_camera)
                .build()
        }
    }
}
