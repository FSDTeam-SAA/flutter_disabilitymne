import 'package:disabilitymne/features/home/model/home_banner_model.dart';
import 'package:disabilitymne/features/home/services/home_banner_repository.dart';
import 'package:get/get.dart';

class HomeBannerController extends GetxController {
  HomeBannerController({required HomeBannerRepository repository})
    : _repository = repository;

  final HomeBannerRepository _repository;

  final RxList<HomeBannerModel> banners = <HomeBannerModel>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBanners();
  }

  Future<void> fetchBanners({bool showLoader = true}) async {
    if (showLoader && banners.isEmpty) {
      isLoading.value = true;
    }

    final result = await _repository.fetchBanners();
    result.fold((failure) {
      banners.clear();
    }, (items) {
      banners.assignAll(items);
    });

    isLoading.value = false;
  }
}
