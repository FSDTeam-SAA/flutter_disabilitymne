import 'package:app_pigeon/app_pigeon.dart';
import 'package:disabilitymne/core/api_handler/base_repository.dart';
import 'package:disabilitymne/core/constants/api_endpoints.dart';
import 'package:disabilitymne/core/helpers/typedefs.dart';
import 'package:disabilitymne/features/home/model/home_banner_model.dart';
import 'package:flutter/foundation.dart';

base class HomeBannerRepository extends BaseRepository {
  HomeBannerRepository(this._pigeon);

  final AppPigeon _pigeon;

  FutureRequest<List<HomeBannerModel>> fetchBanners() async {
    return asyncTryCatch(
      tryFunc: () async {
        final response = await _pigeon.get(ApiEndpoints.homeBanners);
        debugPrint('GET HOME BANNERS => ${response.data}');
        final data = extractBodyData(response);
        if (data is! List) return <HomeBannerModel>[];
        return data
            .map((item) {
              if (item is String) {
                return HomeBannerModel(
                  id: item,
                  imageUrl: item,
                  sortOrder: 0,
                  isActive: true,
                );
              }
              return HomeBannerModel.fromJson(
                item as Map<String, dynamic>? ?? const {},
              );
            })
            .where((banner) => banner.hasImage)
            .toList();
      },
    );
  }
}
