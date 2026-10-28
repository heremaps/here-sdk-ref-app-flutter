/*
 * Copyright (C) 2026 HERE Europe B.V.
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

import 'dart:async';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';

/// Queues navigation messages and speaks them with Flutter TTS.
///
/// Create one instance for a navigation session and call [announce] as messages
/// arrive. Use [waitUntilAnnouncementsFinish] when the flow must wait for speech
/// to finish, and call [dispose] when the session ends. Pending waits complete
/// with `false` if speech is canceled, errors, or times out.
class VoiceAnouncer {
  final FlutterTts _flutterTts = FlutterTts();
  final List<String> _announcerQueue = [];
  late final Future<void> _ready = _initialize();
  Completer<bool>? _announcementsFinished;
  bool _soundEnabled = true;
  bool _disposed = false;

  VoiceAnouncer() {
    _flutterTts.setCompletionHandler(_onAnnouncementCompleted);
    _flutterTts.setCancelHandler(_cancelAnnouncements);
    _flutterTts.setErrorHandler(_onTtsError);
  }

  bool get soundEnabled => _soundEnabled;

  Future<void> _initialize() async {
    if (Platform.isIOS) {
      await _flutterTts.setSharedInstance(true);
      await _flutterTts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        <IosTextToSpeechAudioCategoryOptions>[
          IosTextToSpeechAudioCategoryOptions.mixWithOthers,
          IosTextToSpeechAudioCategoryOptions.duckOthers,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );
    }
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.awaitSpeakCompletion(false);
  }

  /// Adds [message] to the queue to be spoken in order when sound is enabled.
  void announce(String message) {
    if (_disposed || !_soundEnabled) return;
    _announcerQueue.add(message);
    // If there is only one message in the queue now, the speaker was idle and we should start speaking immediately.
    if (_announcerQueue.length == 1) {
      _speakNextAnnouncement();
    }
  }

  Future<void> _speakNextAnnouncement() async {
    if (_disposed || !_soundEnabled || _announcerQueue.isEmpty) return;
    await _ready;
    if (_disposed || !_soundEnabled || _announcerQueue.isEmpty) return;
    _flutterTts.speak(_announcerQueue.first);
  }

  /// Waits for the queue to empty, returning `false` if canceled, errored, or
  /// still active after 10 seconds.
  Future<bool> waitUntilAnnouncementsFinish() {
    if (_announcerQueue.isEmpty) return Future<bool>.value(true);
    final Completer<bool> announcementsFinished = _announcementsFinished ??= Completer<bool>();
    return announcementsFinished.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        if (identical(_announcementsFinished, announcementsFinished)) {
          _cancelAnnouncements();
        }
        return false;
      },
    );
  }

  /// Toggles speech on or off and cancels any currently queued announcements.
  Future<void> toggleSound() async {
    if (_disposed) return;
    _soundEnabled = !_soundEnabled;
    _cancelAnnouncements();
    await _flutterTts.stop();
  }

  void _cancelAnnouncements() {
    _announcerQueue.clear();
    _announcementsFinished?.complete(false);
    _announcementsFinished = null;
  }

  void _onTtsError(dynamic _) {
    _cancelAnnouncements();
  }

  // Called when each announcement is completed.
  void _onAnnouncementCompleted() {
    if (_disposed) return;

    // Remove the completed announcement from the queue.
    if (_announcerQueue.isNotEmpty) {
      _announcerQueue.removeAt(0);
    }
    if (_announcerQueue.isNotEmpty) {
      _speakNextAnnouncement();
    } else {
      _announcementsFinished?.complete(true);
      _announcementsFinished = null;
    }
  }

  /// Stops speech and releases this announcer when its navigation session ends.
  void dispose() {
    _disposed = true;
    _cancelAnnouncements();
    _flutterTts.stop();
  }
}
