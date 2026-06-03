/// One row in [CategoryServicesScreen] (static catalog until backend categories exist).
class CategoryServiceItem {
  final int serviceId;
  final String title;
  final String subtitle;
  final double rating;
  final int reviews;
  final String price;
  final String image;

  const CategoryServiceItem({
    required this.serviceId,
    required this.title,
    required this.subtitle,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.image,
  });
}
