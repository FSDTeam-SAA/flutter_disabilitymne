import 'package:flutter/material.dart';
import 'package:disabilitymne/features/programs/model/library_model.dart';
import 'package:disabilitymne/features/programs/services/program_interface.dart';
import 'package:disabilitymne/features/programs/utils/video_url_selector.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class ExerciseDetailController extends GetxController {
  ExerciseDetailController({
    required this.programInterface,
    required this.exerciseId,
  });

  final ProgramInterface programInterface;

  final RxBool isLoading = true.obs;
  final Rx<LibraryModel?> exercise = Rx<LibraryModel?>(null);

  final String exerciseId;

  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;
  final RxBool isVideoInitialized = false.obs;
  final RxBool isPlayingVideo = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchExerciseDetail();
  }

  @override
  void onClose() {
    disposeVideoPlayer();
    super.onClose();
  }

  Future<void> disposeVideoPlayer() async {
    await videoPlayerController?.dispose();
    chewieController?.dispose();
    videoPlayerController = null;
    chewieController = null;
    isVideoInitialized.value = false;
    isPlayingVideo.value = false;
  }

  Future<void> initializeVideoPlayer(String url) async {
    if (url.isEmpty) return;

    isLoading.value = true;
    try {
      videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(url));
      await videoPlayerController!.initialize();

      chewieController = ChewieController(
        videoPlayerController: videoPlayerController!,
        autoPlay: true,
        looping: false,
        aspectRatio: videoPlayerController!.value.aspectRatio,
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Text(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
          );
        },
      );

      isVideoInitialized.value = true;
      isPlayingVideo.value = true;
    } catch (e) {
      Get.snackbar("Error", "Could not load video: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void playVideo() {
    final videoUrl = selectPreferredVideoUrl(
      demoVideo: exercise.value?.demoVideo,
      demoVideos: exercise.value?.demoVideos,
    );
    if (videoUrl.isNotEmpty) {
      initializeVideoPlayer(videoUrl);
    } else {
      Get.snackbar("Error", "No video URL available");
    }
  }

  Future<void> fetchExerciseDetail() async {
    isLoading.value = true;

    final response = await programInterface.getLibraryDetail(
      LibraryModel(id: exerciseId),
    );

    response.fold(
      (error) {
        isLoading.value = false;
        Get.snackbar("Error", error.uiMessage);
      },
      (success) {
        exercise.value = success.data;
        isLoading.value = false;
      },
    );
  }
}
