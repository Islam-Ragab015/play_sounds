abstract class AudioRepository {
  Stream<Duration> get positionStream;
  Stream<Duration> get durationStream;

  Future<void> play();
  Future<void> pause();
  Future<void> stop();
  Future<void> nextTrack();
  Future<void> previousTrack();
  Future<void> playFile(String filePath);
  Future<void> seek(Duration position);
}
