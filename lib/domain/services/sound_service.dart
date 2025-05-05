import 'package:audioplayers/audioplayers.dart';

class SoundService {
  static final SoundService _instance = SoundService._internal();
  factory SoundService() => _instance;
  SoundService._internal();

  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;

  Future<void> playSound(String assetPath) async {
    try {
      if (_isPlaying) {
        await stopSound();
      }
      await _audioPlayer.play(AssetSource(assetPath));
      _isPlaying = true;
    } catch (e) {
      print('사운드 재생 중 오류 발생: $e');
    }
  }

  Future<void> stopSound() async {
    try {
      await _audioPlayer.stop();
      _isPlaying = false;
    } catch (e) {
      print('사운드 중지 중 오류 발생: $e');
    }
  }

  void dispose() {
    _audioPlayer.dispose();
  }
}
