import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  AudioPlayer? _audioPlayer;
  bool _isPlaying = false;

  // AudioPlayer 생성 또는 재사용
  AudioPlayer _getPlayer() {
    if (_audioPlayer == null) {
      _audioPlayer = AudioPlayer();
    }
    return _audioPlayer!;
  }

  Future<void> playSound(String assetPath) async {
    try {
      if (_isPlaying) {
        await stopSound();
      }

      // assetPath에서 assets/ 접두사 제거 (AssetSource는 자동으로 assets/ 경로를 사용함)
      String soundPath = assetPath;
      if (soundPath.startsWith('assets/')) {
        soundPath = soundPath.substring(7); // 'assets/' 부분을 제거
      }

      final player = _getPlayer();
      await player.play(AssetSource(soundPath));
      _isPlaying = true;
    } catch (e) {
      print('사운드 재생 중 오류 발생: $e');
    }
  }

  Future<void> stopSound() async {
    try {
      if (_audioPlayer != null) {
        await _audioPlayer!.stop();
        _isPlaying = false;
      }
    } catch (e) {
      print('사운드 중지 중 오류 발생: $e');
    }
  }

  void dispose() {
    try {
      if (_audioPlayer != null) {
        _audioPlayer!.dispose();
        _audioPlayer = null;
        _isPlaying = false;
      }
    } catch (e) {
      print('오디오 플레이어 해제 중 오류 발생: $e');
    }
  }

  // 안전하게 사운드 서비스를 초기화
  void reset() {
    dispose();
  }
}
