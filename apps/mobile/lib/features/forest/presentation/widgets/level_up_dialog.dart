import '../../../../core/services/sound_service.dart';

ConfettiOverlay(
    play:true,
    child:AlertDialog(...)
)
    
@override
void initState() {
  super.initState();

  SoundService.instance.playLevelUp();
}
