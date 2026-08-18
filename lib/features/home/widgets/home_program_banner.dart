import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:disabilitymne/features/programs/presentation/widgets/explore_program_widget.dart';
import 'package:flutter/material.dart';

class HomeProgramBanner extends StatefulWidget {
  final List<String> imageUrls;
  final bool isLoading;
  final VoidCallback? onTap;

  const HomeProgramBanner({
    super.key,
    required this.imageUrls,
    this.isLoading = false,
    this.onTap,
  });

  @override
  State<HomeProgramBanner> createState() => _HomeProgramBannerState();
}

class _HomeProgramBannerState extends State<HomeProgramBanner> {
  late final PageController _pageController;
  Timer? _autoPlayTimer;
  int _currentIndex = 0;

  List<String> get _imageUrls =>
      widget.imageUrls.where((url) => url.trim().isNotEmpty).toList();

  bool get _isCarousel => _imageUrls.length > 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _startAutoPlay();
  }

  @override
  void didUpdateWidget(covariant HomeProgramBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_sameUrls(oldWidget.imageUrls, widget.imageUrls)) {
      _currentIndex = 0;
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
      _restartAutoPlay();
    }
  }

  bool _sameUrls(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _startAutoPlay() {
    _autoPlayTimer?.cancel();
    if (!_isCarousel) return;

    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_pageController.hasClients || !_isCarousel) return;
      final nextPage = (_currentIndex + 1) % _imageUrls.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  void _restartAutoPlay() {
    _autoPlayTimer?.cancel();
    _startAutoPlay();
  }

  @override
  void dispose() {
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: double.infinity,
          height: ProgramCard.bannerHeight,
          child: widget.isLoading && _imageUrls.isEmpty
              ? _buildLoading()
              : _isCarousel
              ? _buildCarousel()
              : _buildSingleImage(),
        ),
      ),
    );
  }

  Widget _buildSingleImage() {
    final url = _imageUrls.isEmpty ? null : _imageUrls.first;
    return url == null ? _buildEmptyState() : _buildNetworkImage(url);
  }

  Widget _buildCarousel() {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        PageView.builder(
          controller: _pageController,
          itemCount: _imageUrls.length,
          onPageChanged: (index) {
            setState(() => _currentIndex = index);
          },
          itemBuilder: (context, index) {
            return _buildNetworkImage(_imageUrls[index]);
          },
        ),
        Positioned(
          bottom: 10,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(_imageUrls.length, (index) {
              final selected = index == _currentIndex;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 3),
                width: selected ? 18 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white
                      : Colors.white.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(999),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildNetworkImage(String url) {
    return ColoredBox(
      color: const Color(0xFF0C0C0C),
      child: CachedNetworkImage(
        imageUrl: url,
        fit: BoxFit.cover,
        width: double.infinity,
        height: ProgramCard.bannerHeight,
        alignment: Alignment.center,
        placeholder: (_, _) => _buildLoading(),
        errorWidget: (_, _, _) => _buildEmptyState(),
      ),
    );
  }

  Widget _buildLoading() {
    return const ColoredBox(
      color: Color(0xFF0C0C0C),
      child: Center(
        child: CircularProgressIndicator(
          color: Color(0xff6FA8DC),
          strokeWidth: 2,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const ColoredBox(
      color: Color(0xFF0C0C0C),
      child: Center(
        child: Icon(Icons.image_outlined, color: Colors.white38, size: 48),
      ),
    );
  }
}
