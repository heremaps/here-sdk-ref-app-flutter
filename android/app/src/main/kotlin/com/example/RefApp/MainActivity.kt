/*
 * Copyright (C) 2020-2022 HERE Europe B.V.
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

import android.content.Intent
import android.os.Build
import android.os.Bundle
import androidx.core.view.WindowCompat
import com.example.RefApp.FlutterForegroundService.Companion.START_FOREGROUND_ACTION
import com.example.RefApp.FlutterForegroundService.Companion.STOP_FOREGROUND_ACTION
import com.example.RefApp.FlutterForegroundService.Companion.UPDATE_FOREGROUND_ACTION
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    companion object {
        private const val CHANNEL = "com.example.RefApp/foreground_service_channel"
        private const val START_SERVICE = "startService"
        private const val STOP_SERVICE = "stopService"
        private const val UPDATE_SERVICE = "updateService"
    }

    override fun onCreate(savedInstanceState: Bundle?) {

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            splashScreen.setOnExitAnimationListener { splashScreenView -> splashScreenView.remove() }
        }

        super.onCreate(savedInstanceState)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                START_SERVICE -> launchForegroundService(createIntent(call))

                STOP_SERVICE -> stopForegroundService(createIntent(call))

                UPDATE_SERVICE -> updateForegroundService(createIntent(call))

                else -> result.notImplemented()
            }
        }
    }

    private fun createIntent(call: MethodCall): Intent {
        val intent = Intent(context, FlutterForegroundService::class.java)

        val title = call.argument<String>(FlutterForegroundService.TITLE_ARG)
        if (title != null) {
            intent.putExtra(FlutterForegroundService.TITLE_ARG, title)
        }

        val content = call.argument<String>(FlutterForegroundService.CONTENT_ARG)
        if (content != null) {
            intent.putExtra(FlutterForegroundService.CONTENT_ARG, content)
        }

        val largeIcon = call.argument<String>(FlutterForegroundService.LARGE_ICON_ARG)
        if (largeIcon != null) {
            intent.putExtra(FlutterForegroundService.LARGE_ICON_ARG, largeIcon)
        }

        val soundEnabled = call.argument<Boolean>(FlutterForegroundService.SOUND_ENABLED_ARG)
        if (soundEnabled != null) {
            intent.putExtra(FlutterForegroundService.SOUND_ENABLED_ARG, soundEnabled)
        }

        return intent
    }

    private fun launchForegroundService(intent: Intent) {
        intent.action = START_FOREGROUND_ACTION
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            context.startForegroundService(intent)
        } else {
            context.startService(intent)
        }
    }

    private fun updateForegroundService(intent: Intent) {
        intent.action = UPDATE_FOREGROUND_ACTION
        context.startService(intent)
    }

    private fun stopForegroundService(intent: Intent) {
        intent.action = STOP_FOREGROUND_ACTION
        context.startService(intent)
    }
}
