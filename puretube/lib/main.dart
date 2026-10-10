import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app.dart';
import 'core/database/hive_setup.dart';
import 'core/di/providers.dart';
import 'features/player/data/services/audio_player_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  await initHive();
  await _ensureNotificationPermission();

  // The handler (and its media_kit Player) is created once here and lives
  // for the whole process, so audio keeps playing with the UI gone.
  final audioHandler = await AudioService.init(
    builder: () => PureTubeAudioHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.puretube.channel.audio',
      androidNotificationChannelName: 'PureTube playback',
      androidNotificationOngoing: true,
      androidShowNotificationBadge: false,
      androidStopForegroundOnPause: true,
    ),
  ) as PureTubeAudioHandler;

  runApp(
    ProviderScope(
      overrides: [
        audioHandlerProvider.overrideWithValue(audioHandler),
      ],
      child: const PureTubeApp(),
    ),
  );
}

/// Android 13+ needs a runtime grant before the playback notification
/// (and its controls) can appear. Audio itself works regardless.
Future<void> _ensureNotificationPermission() async {
  if (!Platform.isAndroid) return;
  try {
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }
  } catch (_) {
    // Best effort; never block startup.
  }
}
