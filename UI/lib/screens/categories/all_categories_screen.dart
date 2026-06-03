import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../provider_search/provider_search_screen.dart';

class AllCategoriesScreen extends StatefulWidget {
  const AllCategoriesScreen({super.key});

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final scale = (screenWidth / 390).clamp(0.85, 1.15);
    final padding = 18 * scale;
    final filteredServices = _services
      .where((item) => item.label.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8FC),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('All Services', style: AppTextStyles.heading3),
        centerTitle: true,
        
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(padding, 8 * scale, padding, 24 * scale),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SearchHeader(
                scale: scale,
                query: _searchQuery,
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
              ),
              SizedBox(height: 14 * scale),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: filteredServices.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 14 * scale,
                  crossAxisSpacing: 14 * scale,
                  childAspectRatio: 1.0,
                ),
                itemBuilder: (context, index) {
                  final item = filteredServices[index];
                  return _ServiceCard(
                    item: item,
                    scale: scale,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ProviderSearchScreen(
                            serviceId: item.serviceId,
                            serviceName: item.label,
                            imageAsset: bannerAssetForService(item.serviceId),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 18 * scale),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceItem {
  final int serviceId;
  final String label;
  final IconData icon;
  final Color iconColor;
  final Color backgroundColor;

  const _ServiceItem({
    required this.serviceId,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.backgroundColor,
  });
}

class _ServiceCard extends StatelessWidget {
  final _ServiceItem item;
  final double scale;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.item,
    required this.scale,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18 * scale),
      child: Container(
        decoration: BoxDecoration(
          color: item.backgroundColor,
          borderRadius: BorderRadius.circular(18 * scale),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12 * scale, vertical: 14 * scale),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 46 * scale,
              height: 46 * scale,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(item.icon, color: item.iconColor, size: 24 * scale),
              ),
            ),
            SizedBox(height: 12 * scale),
            Text(
              item.label,
              style: TextStyle(
                fontSize: 12.5 * scale,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
                height: 1.15,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4 * scale),
            Text(
              'View providers',
              style: TextStyle(
                fontSize: 10 * scale,
                color: AppColors.textMedium,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  final double scale;
  final String query;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchHeader({
    required this.scale,
    required this.query,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 14 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 14,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.search_rounded, color: AppColors.textLight, size: 22 * scale),
          hintText: 'Browse all services in one place',
          hintStyle: TextStyle(
            fontSize: 13 * scale,
            color: AppColors.textMedium,
            fontWeight: FontWeight.w500,
          ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: EdgeInsets.symmetric(horizontal: 16 * scale, vertical: 12 * scale),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}

 

const List<_ServiceItem> _services = [
  _ServiceItem(
    serviceId: 1,
    label: 'Electrician',
    icon: Icons.electrical_services_rounded,
    iconColor: Color(0xFFFF9F1C),
    backgroundColor: Color(0xFFFFF3E0),
  ),
  _ServiceItem(
    serviceId: 2,
    label: 'Plumber',
    icon: Icons.plumbing_rounded,
    iconColor: Color(0xFF3A76FF),
    backgroundColor: Color(0xFFEAF1FF),
  ),
  _ServiceItem(
    serviceId: 3,
    label: 'Carpenter',
    icon: Icons.carpenter_rounded,
    iconColor: Color(0xFFFF7A59),
    backgroundColor: Color(0xFFFFEEE7),
  ),
  _ServiceItem(
    serviceId: 4,
    label: 'AC Technician',
    icon: Icons.ac_unit_rounded,
    iconColor: Color(0xFF2F9E62),
    backgroundColor: Color(0xFFEAF6EF),
  ),
  _ServiceItem(
    serviceId: 5,
    label: 'Painter',
    icon: Icons.format_paint_rounded,
    iconColor: Color(0xFFFF4D4D),
    backgroundColor: Color(0xFFFFEAEA),
  ),
  _ServiceItem(
    serviceId: 6,
    label: 'House Cleaning',
    icon: Icons.cleaning_services_rounded,
    iconColor: Color(0xFF2F9E62),
    backgroundColor: Color(0xFFEAF6EF),
  ),
  _ServiceItem(
    serviceId: 7,
    label: 'Bathroom Cleaning',
    icon: Icons.bathtub_rounded,
    iconColor: Color(0xFF3A76FF),
    backgroundColor: Color(0xFFEAF1FF),
  ),
  _ServiceItem(
    serviceId: 8,
    label: 'Kitchen Cleaning',
    icon: Icons.kitchen_rounded,
    iconColor: Color(0xFFFF7A59),
    backgroundColor: Color(0xFFFFEEE7),
  ),
  _ServiceItem(
    serviceId: 9,
    label: 'Washing Machine Repair',
    icon: Icons.local_laundry_service_rounded,
    iconColor: Color(0xFFFF9F1C),
    backgroundColor: Color(0xFFFFF3E0),
  ),
  _ServiceItem(
    serviceId: 10,
    label: 'Refrigerator Repair',
    icon: Icons.kitchen_rounded,
    iconColor: Color(0xFF3A76FF),
    backgroundColor: Color(0xFFEAF1FF),
  ),
  _ServiceItem(
    serviceId: 11,
    label: 'Geyser Repair',
    icon: Icons.hot_tub_rounded,
    iconColor: Color(0xFFFF7A59),
    backgroundColor: Color(0xFFFFEEE7),
  ),
  _ServiceItem(
    serviceId: 12,
    label: 'Sofa & Carpet Cleaning',
    icon: Icons.weekend_rounded,
    iconColor: Color(0xFF6C5CE7),
    backgroundColor: Color(0xFFEDE9FF),
  ),
  _ServiceItem(
    serviceId: 13,
    label: 'Labour',
    icon: Icons.engineering_rounded,
    iconColor: Color(0xFFFF7A59),
    backgroundColor: Color(0xFFFFEEE7),
  ),
  _ServiceItem(
    serviceId: 14,
    label: 'Loading & Unloading',
    icon: Icons.local_shipping_rounded,
    iconColor: Color(0xFFFF9F1C),
    backgroundColor: Color(0xFFFFF3E0),
  ),
];

