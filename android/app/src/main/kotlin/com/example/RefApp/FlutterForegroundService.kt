/*
 * Copyright (C) 2020-2024 HERE Europe B.V.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * SPDX-License-Identifier: Apache-2.0
 * License-Filename: LICENSE
 */

package com.example.RefApp


import android.annotation.SuppressLint
import android.app.*
import android.content.Intent
import android.content.pm.ServiceInfo.FOREGROUND_SERVICE_TYPE_LOCATION
import android.graphics.BitmapFactory
import android.os.Build
import android.os.Bundle
import android.os.IBinder
import android.util.Log
import androidx.core.app.NotificationCompat
import androidx.core.app.NotificationManagerCompat
import androidx.core.app.ServiceCompat

class FlutterForegroundService : Service() {
    companion object {
        const val START_FOREGROUND_ACTION = "com.example.RefApp.flutter_foreground_service.action.start_foreground"
        const val UPDATE_FOREGROUND_ACTION = "com.example.RefApp.flutter_foreground_service.action.update_foreground"
        const val STOP_FOREGROUND_ACTION = "com.example.RefApp.flutter_foreground_service.action.stop_foreground"
        const val NOTIFICATION_CHANNEL_ID = "flutter_channel_id"
        const val NOTIFICATION_CHANNEL_NAME = "flutter_foreground_service_channel"
        const val ONGOING_NOTIFICATION_ID = 1

        const val TITLE_ARG = "title"
        const val CONTENT_ARG = "content"
        const val LARGE_ICON_ARG = "large_icon"
        const val SOUND_ENABLED_ARG = "sound_enabled"
    }

    override fun onCreate() {
        super.onCreate()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                NOTIFICATION_CHANNEL_ID, NOTIFICATION_CHANNEL_NAME,
                NotificationManager.IMPORTANCE_HIGH
            )
            (getSystemService(NOTIFICATION_SERVICE) as NotificationManager).createNotificationChannel(
                channel
            )
        }
    }

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        if (intent == null || intent.action == null) {
            return START_NOT_STICKY
        }

        when (intent.action) {
            START_FOREGROUND_ACTION -> {
                val bundle = intent.extras ?: return START_NOT_STICKY
                try {
                    if (Build.VERSION.SDK_INT >= 34) {
                        ServiceCompat.startForeground(
                            this,
                            ONGOING_NOTIFICATION_ID,
                            createNotification(bundle),
                            FOREGROUND_SERVICE_TYPE_LOCATION,
                        )
                    } else {
                        startForeground(ONGOING_NOTIFICATION_ID, createNotification(bundle))
                    }
                } catch (e: Exception) {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S && e is ForegroundServiceStartNotAllowedException) {
                        // App not in a valid state to start foreground service
                        // (e.g. started from bg)
                        Log.e("RefApp FGS Not Allowed: ", e.message.toString())
                    } else {
                        Log.e("RefApp", e.message + "")
                    }
                }
            }

            UPDATE_FOREGROUND_ACTION -> {
                val bundle = intent.extras ?: return START_NOT_STICKY
                val nm = NotificationManagerCompat.from(this)
                nm.notify(ONGOING_NOTIFICATION_ID, createNotification(bundle))
            }

            STOP_FOREGROUND_ACTION -> {
                if (Build.VERSION.SDK_INT >= 34) {
                    stopForeground(STOP_FOREGROUND_REMOVE)
                } else {
                    stopForeground(true)
                }
                stopSelf()
            }
        }

        return START_NOT_STICKY
    }

    @SuppressLint("UnspecifiedImmutableFlag")
    private fun createNotification(bundle: Bundle): Notification {
        val pm = applicationContext.packageManager
        val notificationIntent = pm.getLaunchIntentForPackage(applicationContext.packageName)
        val pendingIntent = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
            PendingIntent.getActivity(this, 0, notificationIntent, PendingIntent.FLAG_IMMUTABLE)
        } else {
            PendingIntent.getActivity(this, 0, notificationIntent, 0)
        }

        val builder = NotificationCompat.Builder(this, NOTIFICATION_CHANNEL_ID)
            .setSmallIcon(R.mipmap.ic_launcher_notification)
            .setContentTitle(bundle.getString(TITLE_ARG))
            .setContentText(bundle.getString(CONTENT_ARG))
            .setCategory(NotificationCompat.CATEGORY_SERVICE)
            .setContentIntent(pendingIntent)
            .setOngoing(true)
            .setLocalOnly(true)
            .setPriority(NotificationCompat.PRIORITY_MAX)

        if (bundle.getString(LARGE_ICON_ARG) != null) {
            val bitmap = BitmapFactory.decodeFile(bundle.getString(LARGE_ICON_ARG))
            builder.setLargeIcon(bitmap)
        }

        if (!bundle.getBoolean(SOUND_ENABLED_ARG, false)) {
            builder.setSilent(true)
        }

        return builder.build()
    }

    override fun onBind(intent: Intent?): IBinder? {
        return null
    }
}
