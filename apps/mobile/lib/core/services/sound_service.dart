import 'package:audioplayers/audioplayers.dart';

class SoundService {

  SoundService._();

  static final instance = SoundService._();

  final AudioPlayer _player = AudioPlayer();

  Future<void> playLevelUp() async {

    await _player.play(
      AssetSource("sounds/level_up.mp3"),
    );
  }

  Future<void> playBadge() async {

    await _player.play(
      AssetSource("sounds/badge.mp3"),
    );
  }

  Future<void> playForest() async {

    await _player.play(
      AssetSource("sounds/forest.mp3"),
    );
  }

}
