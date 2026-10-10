import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';

import '../../../../core/di/providers.dart';
import '../../../player/presentation/providers/player_controller.dart';
import '../../../player/presentation/screens/player_screen.dart';

/// Persistent mini player shown on HomeScreen while audio/video plays in
/// the background. Tapping reopens the full player without reloading.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uiState = ref.watch(playerControllerProvider);
    final video = uiState.video;
    if (uiState.status != PlayerStatus.ready || video == null) {
      return const SizedBox.shrink();
    }
    final notifier = ref.read(playerControllerProvider.notifier);
    final player = ref.watch(mediaKitPlayerProvider);

    return Container(
      color: const Color(0xFF121212),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ProgressLine(player: player),
            ListTile(
              dense: true,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) =>
                        PlayerScreen(videoId: video.id)),
              ),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: CachedNetworkImage(
                  imageUrl: video.thumbnailUrl,
                  width: 64,
                  height: 36,
                  fit: BoxFit.cover,
                  errorWidget: (_, __, ___) =>
                      Container(color: Colors.black),
                ),
              ),
              title: Text(video.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 13)),
              subtitle: Text(video.author,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11, color: Colors.grey)),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  StreamBuilder<bool>(
                    stream: player.stream.playing,
                    builder: (context, snap) {
                      final playing = snap.data ?? false;
                      return IconButton(
                        icon: Icon(playing
                            ? Icons.pause
                            : Icons.play_arrow),
                        onPressed:
                            notifier.togglePlayPause,
                      );
                    },
                  ),
                  IconButton(
                    icon:
                        const Icon(Icons.close, size: 20),
                    onPressed: notifier.stop,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProgressLine extends StatelessWidget {
  final Player player;
  const _ProgressLine({required this.player});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Duration>(
      stream: player.stream.duration,
      builder: (context, durSnap) {
        final total = durSnap.data?.inMilliseconds ?? 0;
        return StreamBuilder<Duration>(
          stream: player.stream.position,
          builder: (context, posSnap) {
            final pos = posSnap.data?.inMilliseconds ?? 0;
            return LinearProgressIndicator(
              value:
                  total > 0 ? (pos / total).clamp(0.0, 1.0) : 0,
              minHeight: 2,
              backgroundColor: Colors.white12,
              color: const Color(0xFF6200EA),
            );
          },
        );
      },
    );
  }
}
