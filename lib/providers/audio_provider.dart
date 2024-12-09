import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:play_sounds/audio_repository_impl.dart';

// Provider for the AudioRepositoryImpl
final audioProvider =
    Provider<AudioRepositoryImpl>((ref) => AudioRepositoryImpl());
// StateProvider for managing the current file name
final currentFileNameProvider =
    StateProvider<String>((ref) => ''); // Default value can be an empty string

// State provider for managing the player state
final playerStateProvider =
    StateProvider<PlayerState>((ref) => PlayerState.stopped);

// Stream provider for the audio player's current position
final positionProvider = StreamProvider<Duration>((ref) {
  final audioRepo = ref.watch(audioProvider);
  return audioRepo.positionStream;
});

// Stream provider for the audio player's total duration
final durationProvider = StreamProvider<Duration>((ref) {
  final audioRepo = ref.watch(audioProvider);
  return audioRepo.durationStream;
});
