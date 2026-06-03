import 'package:flutter/material.dart';
import '../../../theme/app_theme.dart';
import '../../provider_search/provider_search_screen.dart';

// ─────────────────────────────────────────────────────────────────
// SEARCH BAR — lets user search for a service category
// Sits near the top of HomeScreen, above the services grid
// ─────────────────────────────────────────────────────────────────
class HomeSearchBar extends StatefulWidget {
  const HomeSearchBar({super.key});

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  final _controller = TextEditingController();

  static const List<_ServiceSearchItem> _services = [
    _ServiceSearchItem(1, 'Electrician', 'assets/Electrician.jpg', ['electric', 'electrical', 'wiring', 'fan', 'switch', 'inverter']),
    _ServiceSearchItem(2, 'Plumber', 'assets/Plumber.jpg', ['plumb', 'leak', 'tap', 'pipe', 'drain']),
    _ServiceSearchItem(3, 'Carpenter', 'assets/Carpenter.jpg', ['carpentry', 'wood', 'door', 'cupboard', 'furniture']),
    _ServiceSearchItem(4, 'AC Technician', 'assets/AC Technician.jpg', ['ac', 'air conditioning', 'cooling', 'gas refill']),
    _ServiceSearchItem(5, 'Painter', 'assets/Painter.jpg', ['paint', 'wall', 'interior painting', 'exterior painting']),
    _ServiceSearchItem(6, 'House Cleaning', 'assets/house cleaning.jpg', ['clean', 'cleaning', 'house cleaning', 'home cleaning', 'deep clean']),
    _ServiceSearchItem(7, 'Bathroom Cleaning', 'assets/house cleaning.jpg', ['bathroom', 'toilet cleaning', 'bath cleaning']),
    _ServiceSearchItem(8, 'Kitchen Cleaning', 'assets/Kitchen cleaning.jpg', ['kitchen', 'kitchen cleaning', 'grease']),
    _ServiceSearchItem(9, 'Washing Machine Repair', 'assets/Washing Machine Repair.jpg', ['washing machine', 'laundry', 'appliance repair']),
    _ServiceSearchItem(10, 'Refrigerator Repair', 'assets/Refrigerator repair.jpg', ['fridge', 'refrigerator', 'cooler']),
    _ServiceSearchItem(11, 'Geyser Repair', 'assets/Geyser Repair.jpg', ['geyser', 'heater', 'water heater']),
    _ServiceSearchItem(12, 'Sofa & Carpet Cleaning', 'assets/Sofa & Carpet Cleaning.jpg', ['sofa', 'carpet', 'furniture cleaning']),
    _ServiceSearchItem(13, 'Labour', 'assets/Labour.jpg', ['labour', 'helper', 'worker']),
    _ServiceSearchItem(14, 'Loading & Unloading', 'assets/Loading & Unloading.avif', ['moving', 'shift', 'packers', 'unloading']),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _normalize(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  void _searchAndNavigate(String rawQuery) {
    final query = _normalize(rawQuery);
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Type a service to search.')),
      );
      return;
    }

    final match = _services.firstWhere(
      (service) => service.matches(query),
      orElse: () => const _ServiceSearchItem(-1, '', 'assets/interior.webp', []),
    );

    if (match.serviceId <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No matching service found.')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProviderSearchScreen(
          serviceId: match.serviceId,
          serviceName: match.name,
          imageAsset: bannerAssetForService(match.serviceId),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = (screenWidth / 390).clamp(0.85, 1.15);
    final barRadius = 18 * scale;
    final fieldHeight = 40 * scale;
    final iconBoxSize = 40 * scale;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(barRadius),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(horizontal: 6 * scale, vertical: 6 * scale),
      child: Row(
        children: [
          SizedBox(width: 10 * scale),
          Icon(Icons.search_rounded, color: AppColors.textLight, size: 20 * scale),
          SizedBox(width: 10 * scale),
          Expanded(
            child: Container(
              height: fieldHeight,
              decoration: BoxDecoration(
                color: const Color(0xFFF2EEE6),
                borderRadius: BorderRadius.circular(14 * scale),
              ),
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.symmetric(horizontal: 4 * scale),
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                onSubmitted: _searchAndNavigate,
                decoration: const InputDecoration(
                  hintText: 'Search for services...',
                  hintStyle: AppTextStyles.hint,
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ),
          SizedBox(width: 10 * scale),
          InkWell(
            onTap: () => _searchAndNavigate(_controller.text),
            borderRadius: BorderRadius.circular(14 * scale),
            child: Container(
              width: iconBoxSize,
              height: iconBoxSize,
              decoration: BoxDecoration(
                color: const Color(0xFFF5F3ED),
                borderRadius: BorderRadius.circular(14 * scale),
              ),
              child: Icon(
                Icons.search_rounded,
                size: 20 * scale,
                color: AppColors.textDark,
              ),
            ),
          ),
          SizedBox(width: 8 * scale),
        ],
      ),
    );
  }
}

class _ServiceSearchItem {
  final int serviceId;
  final String name;
  final String imageAsset;
  final List<String> keywords;

  const _ServiceSearchItem(this.serviceId, this.name, this.imageAsset, this.keywords);

  bool matches(String query) {
    final normalizedName = _normalizeText(name);
    if (normalizedName.contains(query) || query.contains(normalizedName)) {
      return true;
    }
    return keywords.any((keyword) {
      final normalizedKeyword = _normalizeText(keyword);
      return normalizedKeyword.contains(query) || query.contains(normalizedKeyword);
    });
  }
}

String _normalizeText(String value) {
  return value.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
}
