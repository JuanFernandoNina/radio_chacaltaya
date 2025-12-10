import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/carousel_item.dart';

class CarouselBanner extends StatefulWidget {
  final List<CarouselItem> items;

  const CarouselBanner({super.key, required this.items});

  @override
  State<CarouselBanner> createState() => _CarouselBannerState();
}

class _CarouselBannerState extends State<CarouselBanner> {
  late PageController _pageController;
  int _currentPage = 0;
  bool _isAutoPlaying = true;
  Timer? _autoPlayTimer;

  // Design constants
  static const double _kHeight = 220;
  static const double _kViewportFraction = 0.85;
  static const Color _kAccent = Colors.amber;
  static const Color _kOnAccent = Colors.white;
  static const Color _kInactiveDot = Color(0xFF616161);

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      viewportFraction: _kViewportFraction,
      initialPage: 0,
    );

    if (widget.items.isNotEmpty) {
      _startAutoPlay();
    }
  }

  void _startAutoPlay() {
    // Use a cancellable Timer instead of recursive Future.delayed
    _autoPlayTimer?.cancel();
    _autoPlayTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_isAutoPlaying) return;

      setState(() {
        if (_currentPage < widget.items.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }
      });

      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _isAutoPlaying = false;
    _autoPlayTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return const SizedBox.shrink();

    return Column(
      children: [
        SizedBox(
          height: _kHeight,
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.items.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double value = 1.0;
                  if (_pageController.position.haveDimensions) {
                    value = (_pageController.page ?? 0) - index;
                    value = (1 - (value.abs() * 0.15)).clamp(0.85, 1.0);
                  }

                  return Center(
                    child: SizedBox(
                      height: Curves.easeOut.transform(value) * _kHeight,
                      child: child,
                    ),
                  );
                },
                child: _buildCarouselItem(widget.items[index], index),
              );
            },
          ),
        ),

        // Indicadores de página
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            widget.items.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentPage == index ? _kAccent : _kInactiveDot,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCarouselItem(CarouselItem item, int index) {
    final isActive = _currentPage == index;

    return GestureDetector(
      onTap: () {
        // TODO: Navegar al enlace si existe
        if (item.linkUrl != null) {
          debugPrint('Navegar a: ${item.linkUrl}');
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: isActive
                    ? const Color.fromARGB(255, 255, 249, 199).withOpacity(0.4)
                    : Colors.black.withOpacity(0.3),
                blurRadius: isActive ? 20 : 10,
                spreadRadius: isActive ? 2 : 0,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Imagen con acceso semántico y caché
                Transform.scale(
                  scale: 1.06,
                  child: Semantics(
                    label: item.title,
                    child: CachedNetworkImage(
                      imageUrl: item.imageUrl,
                      fit: BoxFit.cover,
                      fadeInDuration: const Duration(milliseconds: 300),
                      memCacheWidth: 1000,
                      memCacheHeight: 800,
                      placeholder: (context, url) => Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber,
                              Colors.amberAccent,
                            ],
                          ),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: _kOnAccent,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey.shade900,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 44,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Gradiente mejorado
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.9),
                      ],
                      stops: const [0.3, 0.6, 1.0],
                    ),
                  ),
                ),

                // Badge "NUEVO" si es reciente
                if (_isNewItem(item))
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: _kAccent,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: _kAccent.withOpacity(0.5),
                            blurRadius: 8,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.stars,
                              size: 14,
                              color: Color.fromARGB(255, 255, 225, 225)),
                          SizedBox(width: 4),
                          Text(
                            'NUEVO',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Contenido con animación
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isActive ? 1.0 : 0.8,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Título con sombra
                          Text(
                            item.title,
                            style: TextStyle(
                              color: _kOnAccent,
                              fontSize: isActive ? 20 : 18,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.8),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),

                          if (item.description != null && isActive) ...[
                            const SizedBox(height: 8),
                            Text(
                              item.description!,
                              style: TextStyle(
                                color: _kOnAccent.withOpacity(0.9),
                                fontSize: 14,
                                height: 1.3,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.8),
                                    offset: const Offset(0, 1),
                                    blurRadius: 3,
                                  ),
                                ],
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],

                          // Botón de acción
                          // if (isActive && item.linkUrl != null) ...[
                          //   const SizedBox(height: 12),
                          //   Container(
                          //     padding: const EdgeInsets.symmetric(
                          //       horizontal: 16,
                          //       vertical: 8,
                          //     ),
                          //     decoration: BoxDecoration(
                          //       color: _kAccent,
                          //       borderRadius: BorderRadius.circular(20),
                          //     ),
                          //     //child: const Row(
                          //     //  mainAxisSize: MainAxisSize.min,
                          //     //  children: [
                          //     //    Text(
                          //     //      'Ver más',
                          //     //      style: TextStyle(
                          //     //        color: Colors.black,
                          //     //        fontSize: 13,
                          //     //        fontWeight: FontWeight.bold,
                          //     //      ),
                          //     //    ),
                          //     //    SizedBox(width: 4),
                          //     //    Icon(
                          //     //      Icons.arrow_forward,
                          //     //      size: 16,
                          //     //      color: Colors.black,
                          //     //    ),
                          //     //  ],
                          //     //),
                          //   ),
                          // ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isNewItem(CarouselItem item) {
    // Considera nuevo si fue creado hace menos de 7 días
    final daysSinceCreation = DateTime.now().difference(item.createdAt).inDays;
    return daysSinceCreation < 7;
  }
}
