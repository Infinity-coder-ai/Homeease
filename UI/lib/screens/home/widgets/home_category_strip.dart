import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';

typedef CategoryTap = void Function(int serviceId, String label);

class HomeCategoryStrip extends StatelessWidget {
  final double scale;
  final CategoryTap onTap;

  const HomeCategoryStrip({
    super.key,
    required this.scale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final gap = 10 * scale;
        final minItemWidth = 64 * scale;
        final maxItemWidth = 84 * scale;
        final itemWidth = (constraints.maxWidth - gap * 5) / 6;
        final chipWidth = itemWidth.clamp(minItemWidth, maxItemWidth);

        return SizedBox(
          height: 90 * scale,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final item = _categoryItems[index];
                return SizedBox(
                width: chipWidth,
                child: _CategoryChip(
                  item: item,
                  onTap: () => onTap(item.serviceId, item.label),
                ),
              );
            },
            separatorBuilder: (_, __) => SizedBox(width: gap),
            itemCount: _categoryItems.length,
          ),
        );
      },
    );
  }
}

class _CategoryItem {
  final String label;
  final IconData icon;
  final int serviceId;
  final Color iconColor;
  final Color backgroundColor;

  const _CategoryItem({
    required this.label,
    required this.icon,
    required this.serviceId,
    this.iconColor = AppColors.primary,
    this.backgroundColor = Colors.white,
  });
}

class _CategoryChip extends StatelessWidget {
  final _CategoryItem item;
  final VoidCallback? onTap;

  const _CategoryChip({required this.item, this.onTap});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = (screenWidth / 390).clamp(0.85, 1.15);
    final chipSize = 55 * scale;
    final chipRadius = 16 * scale;
    final bgColor = item.backgroundColor;
    final iconColor = item.iconColor;
    const textColor = AppColors.textDark;

    return _PressableCategoryChip(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: chipSize,
            height: chipSize,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(chipRadius),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x12000000),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Icon(item.icon, color: iconColor, size: 26 * scale),
          ),
          SizedBox(height: 6 * scale),
          Text(
            item.label,
            style: TextStyle(
              fontSize: 12 * scale,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _PressableCategoryChip extends StatefulWidget {
  final VoidCallback? onTap;
  final Widget child;

  const _PressableCategoryChip({required this.onTap, required this.child});

  @override
  State<_PressableCategoryChip> createState() => _PressableCategoryChipState();
}

class _PressableCategoryChipState extends State<_PressableCategoryChip> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value) return;
    setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.onTap == null ? null : (_) => _setPressed(true),
      onTapUp: widget.onTap == null
          ? null
          : (_) {
              _setPressed(false);
              widget.onTap?.call();
            },
      onTapCancel: widget.onTap == null ? null : () => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? 0.94 : 1.0,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

const List<_CategoryItem> _categoryItems = [
  _CategoryItem(
    label: 'Cleaning',
    icon: Icons.cleaning_services_rounded,
    serviceId: 1,
    iconColor: Color(0xFF2F9E62),
    backgroundColor: Color(0xFFEAF6EF),
  ),
  _CategoryItem(
    label: 'Repairs',
    icon: Icons.build_rounded,
    serviceId: 2,
    iconColor: Color(0xFF6C5CE7),
    backgroundColor: Color(0xFFEDE9FF),
  ),
  _CategoryItem(
    label: 'Maintenance',
    icon: Icons.home_repair_service_rounded,
    serviceId: 3,
    iconColor: Color(0xFF5E60CE),
    backgroundColor: Color(0xFFE9ECFF),
  ),
  _CategoryItem(
    label: 'Moving',
    icon: Icons.local_shipping_rounded,
    serviceId: 4,
    iconColor: Color(0xFFFF7A59),
    backgroundColor: Color(0xFFFFEEE7),
  ),
  _CategoryItem(
    label: 'All',
    icon: Icons.grid_view_rounded,
    serviceId: -1,
    iconColor: Colors.white,
    backgroundColor: AppColors.primary,
  ),
];
