import 'package:flutter/material.dart';

/// Full-screen image viewer with pinch-to-zoom and swipe-down-to-dismiss.
///
/// Usage:
///   FullScreenImageViewer.open(context, imageUrl: '...', title: '...');
class FullScreenImageViewer extends StatefulWidget {
  final String imageUrl;
  final String title;

  const FullScreenImageViewer({
    super.key,
    required this.imageUrl,
    required this.title,
  });

  /// Convenience method to open the viewer as a full-screen route.
  static void open(
    BuildContext context, {
    required String imageUrl,
    String title = 'Document',
  }) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        opaque: false,
        barrierColor: Colors.transparent,
        pageBuilder: (_, __, ___) => FullScreenImageViewer(
          imageUrl: imageUrl,
          title: title,
        ),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(
          opacity: animation,
          child: child,
        ),
      ),
    );
  }

  @override
  State<FullScreenImageViewer> createState() => _FullScreenImageViewerState();
}

class _FullScreenImageViewerState extends State<FullScreenImageViewer>
    with SingleTickerProviderStateMixin {
  final TransformationController _transformCtrl = TransformationController();
  late final AnimationController _dismissCtrl;

  // Drag-to-dismiss tracking
  double _dragY = 0;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    _dismissCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _transformCtrl.dispose();
    _dismissCtrl.dispose();
    super.dispose();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    // Only allow drag-to-dismiss when not zoomed in
    if (_transformCtrl.value != Matrix4.identity()) return;
    setState(() => _dragY += details.delta.dy);
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    if (_isDismissing) return;
    final velocity = details.primaryVelocity ?? 0;
    if (_dragY.abs() > 120 || velocity.abs() > 800) {
      _isDismissing = true;
      Navigator.of(context).pop();
    } else {
      setState(() => _dragY = 0);
    }
  }

  double get _backgroundOpacity {
    final drag = _dragY.abs();
    return (1.0 - (drag / 350)).clamp(0.4, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        color: Colors.black.withValues(alpha: _backgroundOpacity),
        child: Stack(
          children: [
            // ── Pinch-zoom image ──────────────────────────────────
            GestureDetector(
              onVerticalDragUpdate: _onVerticalDragUpdate,
              onVerticalDragEnd: _onVerticalDragEnd,
              child: Transform.translate(
                offset: Offset(0, _dragY),
                child: Center(
                  child: InteractiveViewer(
                    transformationController: _transformCtrl,
                    minScale: 0.5,
                    maxScale: 5.0,
                    child: Hero(
                      tag: widget.imageUrl,
                      child: Image.network(
                        widget.imageUrl,
                        fit: BoxFit.contain,
                        loadingBuilder: (_, child, progress) =>
                            progress == null
                                ? child
                                : Center(
                                    child: CircularProgressIndicator(
                                      value: progress.expectedTotalBytes != null
                                          ? progress.cumulativeBytesLoaded /
                                              progress.expectedTotalBytes!
                                          : null,
                                      color: Colors.white,
                                    ),
                                  ),
                        errorBuilder: (_, __, ___) => const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.broken_image_rounded,
                                color: Colors.white54, size: 64),
                            SizedBox(height: 12),
                            Text('Unable to load image',
                                style: TextStyle(color: Colors.white54)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── Top bar: title + close ────────────────────────────
            SafeArea(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    // Close button
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(99),
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.close_rounded,
                              color: Colors.white, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Title
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          shadows: [
                            Shadow(
                                color: Colors.black54,
                                blurRadius: 4,
                                offset: Offset(0, 1))
                          ],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Reset zoom button (visible when zoomed in)
                    AnimatedBuilder(
                      animation: _transformCtrl,
                      builder: (_, __) {
                        final zoomed =
                            _transformCtrl.value != Matrix4.identity();
                        return AnimatedOpacity(
                          opacity: zoomed ? 1 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(99),
                              onTap: zoomed
                                  ? () => _transformCtrl.value =
                                      Matrix4.identity()
                                  : null,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.45),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.zoom_out_rounded,
                                    color: Colors.white, size: 20),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ── Swipe hint at bottom ──────────────────────────────
            const Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  'Swipe down to close  •  Pinch to zoom',
                  style: TextStyle(
                      color: Colors.white54,
                      fontSize: 11,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A tappable image thumbnail that opens [FullScreenImageViewer] on tap.
///
/// Drop-in replacement for Image.network when you want full-screen preview.
class TappableDocumentImage extends StatelessWidget {
  final String imageUrl;
  final String title;
  final double height;
  final BoxFit fit;
  final BorderRadius borderRadius;

  const TappableDocumentImage({
    super.key,
    required this.imageUrl,
    required this.title,
    this.height = 160,
    this.fit = BoxFit.cover,
    this.borderRadius = const BorderRadius.all(Radius.circular(13)),
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FullScreenImageViewer.open(context,
          imageUrl: imageUrl, title: title),
      child: Stack(
        children: [
          // Thumbnail
          Hero(
            tag: imageUrl,
            child: ClipRRect(
              borderRadius: borderRadius,
              child: Image.network(
                imageUrl,
                height: height,
                width: double.infinity,
                fit: fit,
                loadingBuilder: (_, child, progress) => progress == null
                    ? child
                    : SizedBox(
                        height: height,
                        child: const Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF6F4DE8))),
                      ),
                errorBuilder: (_, __, ___) => SizedBox(
                  height: height,
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.broken_image_rounded,
                            color: Colors.grey, size: 36),
                        SizedBox(height: 6),
                        Text('Unable to load image',
                            style:
                                TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Tap-to-expand overlay badge
          Positioned(
            right: 8,
            bottom: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(99),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.fullscreen_rounded,
                      color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text('Tap to expand',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
