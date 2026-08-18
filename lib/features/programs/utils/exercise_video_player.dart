import 'package:video_player/video_player.dart';

/// Initializes exercise demo videos muted so uploaded audio tracks are never played.
Future<void> initializeMutedExerciseVideo(VideoPlayerController controller) async {
  await controller.initialize();
  await controller.setVolume(0.0);
}
