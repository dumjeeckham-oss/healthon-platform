import 'package:audioplayers/audioplayers.dart';

class SoundService {
  SoundService._();

  static final SoundService instance = SoundService._();

  final AudioPlayer _player = AudioPlayer();

  Future<void> _play(String file) async {
    await _player.stop();

    await _player.play(
      AssetSource("sounds/$file"),
      mode: PlayerMode.lowLatency,
    );
  }

  Future<void> playLevelUp() async {
    await _play("level_up.mp3");
  }

  Future<void> playBadge() async {
    await _play("badge.mp3");
  }

  Future<void> playForestGrow() async {
    await _play("forest.mp3");
  }

  Future<void> playClick() async {
    await _play("click.mp3");
  }

  Future<void> playSuccess() async {
    await _play("success.mp3");
  }
}
