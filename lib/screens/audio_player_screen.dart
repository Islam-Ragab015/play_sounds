import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:play_sounds/audio_repository_impl.dart';
import '../providers/audio_provider.dart';

class AudioPlayerScreen extends ConsumerWidget {
  const AudioPlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audioRepo = ref.watch(audioProvider);
    final playerState = ref.watch(playerStateProvider);
    final positionAsync = ref.watch(positionProvider);
    final durationAsync = ref.watch(durationProvider);
    final currentFileName = ref.watch(currentFileNameProvider);

    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Gradient Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF4A148C), Color(0xFF1A237E)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
            // Foreground Content
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenWidth * 0.1,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 50),
                  // App Title
                  Text(
                    'Audio Player',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: Colors.white.withOpacity(0.9),
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 40),
                  // Now Playing
                  _buildNowPlaying(currentFileName),
                  const Spacer(),
                  // Controls
                  _buildControls(context, ref, audioRepo, playerState),
                  const SizedBox(height: 30),
                  // Progress Bar
                  _buildProgressBar(ref, positionAsync, durationAsync),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNowPlaying(String currentFileName) {
    return Column(
      children: [
        // Icon
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 10,
                spreadRadius: 1,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(
            Icons.music_note,
            size: 100,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 20),
        // Track Title (only show if a file is selected)
        if (currentFileName.isNotEmpty) // Show only if a file is chosen
          Text(
            'Now Playing: $currentFileName',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
      ],
    );
  }

  Widget _buildControls(BuildContext context, WidgetRef ref,
      AudioRepositoryImpl repo, PlayerState state) {
    final isPlaying = state == PlayerState.playing;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Play Button
        ElevatedButton(
          style: _buttonStyle(context, Colors.green),
          onPressed: isPlaying ? null : () => repo.play(),
          child: const Icon(Icons.play_arrow, size: 30),
        ),
        // Stop Button
        ElevatedButton(
          style: _buttonStyle(context, Colors.red),
          onPressed: () => repo.stop(),
          child: const Icon(Icons.stop, size: 30),
        ),
        // File Picker to Choose Audio File
        ElevatedButton(
          style: _buttonStyle(context, Colors.blue),
          onPressed: () async {
            await requestStoragePermission();
            final result = await FilePicker.platform.pickFiles(
              type: FileType.custom,
              allowedExtensions: ['mp3', 'wav', 'flac', 'm4a'],
            );
            if (result != null) {
              final filePath = result.files.single.path;
              if (filePath != null) {
                repo.playFile(filePath);
                ref.read(currentFileNameProvider.notifier).state =
                    filePath.split('/').last;
              }
            }
          },
          child: const Icon(Icons.folder_open, size: 30),
        ),
      ],
    );
  }

  ButtonStyle _buttonStyle(BuildContext context, Color color) {
    return ElevatedButton.styleFrom(
      backgroundColor: color,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      padding: const EdgeInsets.all(20),
    );
  }

  Widget _buildProgressBar(WidgetRef ref, AsyncValue<Duration> positionAsync,
      AsyncValue<Duration> durationAsync) {
    return positionAsync.when(
      data: (position) {
        final duration = durationAsync.value ?? Duration.zero;

        return Column(
          children: [
            Slider(
              value: position.inSeconds.toDouble(),
              max: duration.inSeconds.toDouble(),
              onChanged: (value) {
                final repo = ref.read(audioProvider);
                repo.seek(Duration(seconds: value.toInt()));
              },
              activeColor: Colors.white,
              inactiveColor: Colors.white.withOpacity(0.5),
            ),
            Text(
              '${_formatDuration(position)} / ${_formatDuration(duration)}',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        );
      },
      loading: () {
        return Column(
          children: [
            Slider(
              value: 0,
              max: 1,
              onChanged: (value) {},
              activeColor: Colors.white,
              inactiveColor: Colors.white.withOpacity(0.5),
            ),
            const Text(
              '00:00 / 00:00',
              style: TextStyle(color: Colors.white),
            ),
          ],
        );
      },
      error: (err, _) => Text(
        'Error: $err',
        style: const TextStyle(color: Colors.red),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  Future<void> requestStoragePermission() async {
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) {
      print('Storage permission granted');
    } else {
      print('Storage permission denied');
    }
  }
}
