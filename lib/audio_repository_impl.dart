// lib/audio_repository/audio_repository_impl.dart
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'audio_repository.dart';

class AudioRepositoryImpl implements AudioRepository {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final List<String> _tracks = []; // List of audio tracks
  int _currentTrackIndex = 0; // Current track index

  AudioRepositoryImpl() {
    _audioPlayer.setReleaseMode(ReleaseMode.stop);
  }

  @override
  Future<void> play() async {
    if (_tracks.isNotEmpty) {
      try {
        // Check if the player is playing and the current track is loaded
        if (_audioPlayer.state == PlayerState.playing &&
            _currentTrackIndex < _tracks.length) {
          // Resume if already playing
          await _audioPlayer.resume();
        } else {
          // If not playing, set the source and play
          await _audioPlayer.setSource(UrlSource(_tracks[_currentTrackIndex]));
          await _audioPlayer.resume();
        }
      } catch (e) {
        print("Error playing audio: $e");
      }
    }
  }

  @override
  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
    } catch (e) {
      print("Error pausing audio: $e");
    }
  }

  @override
  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
    } catch (e) {
      print("Error stopping audio: $e");
    }
  }

  @override
  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      print("Error seeking audio: $e");
    }
  }

  @override
  Stream<Duration> get positionStream => _audioPlayer.onPositionChanged;

  @override
  Stream<Duration> get durationStream => _audioPlayer.onDurationChanged;

  Stream<PlayerState> get playerStateStream =>
      _audioPlayer.onPlayerStateChanged;

  @override
  Future<void> playFile(String filePath) async {
    try {
      final file = File(filePath);
      if (await file.exists()) {
        // Stop any currently playing audio
        await _audioPlayer.stop();
        // Clear previous tracks and add the new one
        _tracks.clear();
        _tracks.add(filePath);
        _currentTrackIndex = 0; // Reset to the first track
        await _audioPlayer.setSource(UrlSource(file.uri.toString()));
        await _audioPlayer.resume();
      } else {
        print("Error: File does not exist at $filePath");
      }
    } catch (e) {
      print("Error playing file: $e");
    }
  }

  @override
  Future<void> nextTrack() async {
    if (_tracks.isNotEmpty && _currentTrackIndex < _tracks.length - 1) {
      _currentTrackIndex++;
      await _audioPlayer.stop(); // Stop the current track
      await play(); // Play the next track
    }
  }

  @override
  Future<void> previousTrack() async {
    if (_tracks.isNotEmpty && _currentTrackIndex > 0) {
      _currentTrackIndex--;
      await _audioPlayer.stop(); // Stop the current track
      await play(); // Play the previous track
    }
  }
}
