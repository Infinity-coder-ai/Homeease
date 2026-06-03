import '../models/category_service_item.dart';

/// Returns the static service list for a category name (Cleaning, Repairs, etc.).
List<CategoryServiceItem> servicesForCategory(String category) {
  final lower = category.toLowerCase();
  if (lower.contains('repair') || lower.contains('repairs')) {
    return _repairServices;
  }
  if (lower.contains('electric') || lower.contains('electrical')) {
    return _electricalServices;
  }
  if (lower.contains('plumb')) {
    return _plumbingServices;
  }
  if (lower.contains('carpent') || lower.contains('wood')) {
    return _carpenterServices;
  }
  if (lower.contains('paint')) {
    return _paintingServices;
  }
  if (lower.contains('move') || lower.contains('moving') || lower.contains('labour')) {
    return _movingServices;
  }
  if (lower.contains('maint') || lower.contains('maintenance')) {
    return _maintenanceServices;
  }
  return _cleaningServices;
}

const _repairServices = [
  CategoryServiceItem(
    serviceId: 9,
    title: 'Washing Machine Repair',
    subtitle: 'Fast & reliable appliance repair',
    rating: 4.6,
    reviews: 40,
    price: '\$35',
    image: 'assets/Washing Machine Repair.jpg',
  ),
  CategoryServiceItem(
    serviceId: 10,
    title: 'Refrigerator Repair',
    subtitle: 'Cooling issues fixed',
    rating: 4.5,
    reviews: 28,
    price: '\$45',
    image: 'assets/Refrigerator repair.jpg',
  ),
  CategoryServiceItem(
    serviceId: 11,
    title: 'Geyser Repair',
    subtitle: 'Water heating solutions',
    rating: 4.4,
    reviews: 12,
    price: '\$40',
    image: 'assets/Geyser Repair.jpg',
  ),
  CategoryServiceItem(
    serviceId: 4,
    title: 'AC Technician',
    subtitle: 'AC servicing & gas refill',
    rating: 4.7,
    reviews: 55,
    price: '\$60',
    image: 'assets/AC Technician.jpg',
  ),
];

const _electricalServices = [
  CategoryServiceItem(
    serviceId: 1,
    title: 'Fan Installation',
    subtitle: 'Ceiling fan fitting and repair',
    rating: 4.5,
    reviews: 34,
    price: '\$22',
    image: 'assets/Electrician.jpg',
  ),
  CategoryServiceItem(
    serviceId: 1,
    title: 'Switch Board Repair',
    subtitle: 'Safe wiring and switch fixes',
    rating: 4.6,
    reviews: 41,
    price: '\$18',
    image: 'assets/Electrician.jpg',
  ),
  CategoryServiceItem(
    serviceId: 1,
    title: 'House Wiring',
    subtitle: 'New wiring and load checks',
    rating: 4.7,
    reviews: 56,
    price: '\$35',
    image: 'assets/Electrician.jpg',
  ),
  CategoryServiceItem(
    serviceId: 1,
    title: 'Inverter Setup',
    subtitle: 'Power backup installation',
    rating: 4.4,
    reviews: 19,
    price: '\$30',
    image: 'assets/Electrician.jpg',
  ),
];

const _plumbingServices = [
  CategoryServiceItem(
    serviceId: 2,
    title: 'Tap Leakage Fix',
    subtitle: 'Quick leak and faucet repair',
    rating: 4.6,
    reviews: 52,
    price: '\$16',
    image: 'assets/Plumber.jpg',
  ),
  CategoryServiceItem(
    serviceId: 2,
    title: 'Pipe Fitting',
    subtitle: 'New pipe and joint fitting',
    rating: 4.5,
    reviews: 33,
    price: '\$24',
    image: 'assets/Plumber.jpg',
  ),
  CategoryServiceItem(
    serviceId: 2,
    title: 'Bathroom Plumbing',
    subtitle: 'Toilet and bathroom plumbing',
    rating: 4.4,
    reviews: 27,
    price: '\$28',
    image: 'assets/Plumber.jpg',
  ),
  CategoryServiceItem(
    serviceId: 2,
    title: 'Kitchen Drain Cleaning',
    subtitle: 'Drain blockage removal',
    rating: 4.5,
    reviews: 21,
    price: '\$20',
    image: 'assets/Plumber.jpg',
  ),
];

const _carpenterServices = [
  CategoryServiceItem(
    serviceId: 3,
    title: 'Door Repair',
    subtitle: 'Hinges, locks and frame repair',
    rating: 4.5,
    reviews: 24,
    price: '\$26',
    image: 'assets/Carpenter.jpg',
  ),
  CategoryServiceItem(
    serviceId: 3,
    title: 'Cupboard Repair',
    subtitle: 'Wardrobe and cupboard fixes',
    rating: 4.4,
    reviews: 18,
    price: '\$30',
    image: 'assets/Carpenter.jpg',
  ),
  CategoryServiceItem(
    serviceId: 3,
    title: 'Furniture Assembly',
    subtitle: 'Bed, table and chair assembly',
    rating: 4.7,
    reviews: 39,
    price: '\$22',
    image: 'assets/Carpenter.jpg',
  ),
  CategoryServiceItem(
    serviceId: 3,
    title: 'Wood Polish',
    subtitle: 'Furniture polish and touch-up',
    rating: 4.3,
    reviews: 14,
    price: '\$19',
    image: 'assets/Carpenter.jpg',
  ),
];

const _paintingServices = [
  CategoryServiceItem(
    serviceId: 5,
    title: 'Interior Painting',
    subtitle: 'Room and wall painting',
    rating: 4.6,
    reviews: 46,
    price: '\$55',
    image: 'assets/Painter.jpg',
  ),
  CategoryServiceItem(
    serviceId: 5,
    title: 'Exterior Painting',
    subtitle: 'Outdoor wall coating',
    rating: 4.5,
    reviews: 31,
    price: '\$70',
    image: 'assets/Painter.jpg',
  ),
  CategoryServiceItem(
    serviceId: 5,
    title: 'Wall Touch-Up',
    subtitle: 'Small patch and paint fixes',
    rating: 4.4,
    reviews: 20,
    price: '\$28',
    image: 'assets/Painter.jpg',
  ),
  CategoryServiceItem(
    serviceId: 5,
    title: 'Full Home Paint',
    subtitle: 'Complete paint refresh',
    rating: 4.7,
    reviews: 15,
    price: '\$99',
    image: 'assets/Painter.jpg',
  ),
];

const _movingServices = [
  CategoryServiceItem(
    serviceId: 13,
    title: 'Labour',
    subtitle: 'Skilled & unskilled labour',
    rating: 4.3,
    reviews: 22,
    price: '\$25',
    image: 'assets/Labour.jpg',
  ),
  CategoryServiceItem(
    serviceId: 14,
    title: 'Loading & Unloading',
    subtitle: 'Safe handling & transport',
    rating: 4.4,
    reviews: 18,
    price: '\$39',
    image: 'assets/Loading & Unloading.avif',
  ),
];

const _maintenanceServices = [
  CategoryServiceItem(
    serviceId: 1,
    title: 'Electrician',
    subtitle: 'Wiring & fixtures',
    rating: 4.5,
    reviews: 75,
    price: '\$30',
    image: 'assets/Electrician.jpg',
  ),
  CategoryServiceItem(
    serviceId: 2,
    title: 'Plumber',
    subtitle: 'Leaks & fittings',
    rating: 4.4,
    reviews: 62,
    price: '\$28',
    image: 'assets/Plumber.jpg',
  ),
  CategoryServiceItem(
    serviceId: 3,
    title: 'Carpenter',
    subtitle: 'Furniture & fixtures',
    rating: 4.3,
    reviews: 34,
    price: '\$35',
    image: 'assets/Carpenter.jpg',
  ),
  CategoryServiceItem(
    serviceId: 5,
    title: 'Painter',
    subtitle: 'Interior & exterior',
    rating: 4.2,
    reviews: 29,
    price: '\$45',
    image: 'assets/Painter.jpg',
  ),
];

const _cleaningServices = [
  CategoryServiceItem(
    serviceId: 6,
    title: 'House Cleaning',
    subtitle: 'Thorough care, spotless home.',
    rating: 4.9,
    reviews: 210,
    price: '\$49',
    image: 'assets/house cleaning.jpg',
  ),
  CategoryServiceItem(
    serviceId: 8,
    title: 'Kitchen Cleaning',
    subtitle: 'Hygienic & shining kitchen.',
    rating: 4.8,
    reviews: 120,
    price: '\$49',
    image: 'assets/Kitchen cleaning.jpg',
  ),
  CategoryServiceItem(
    serviceId: 7,
    title: 'Bathroom Cleaning',
    subtitle: 'Sparkling clean, fresh bathroom.',
    rating: 4.8,
    reviews: 150,
    price: '\$59',
    image: 'assets/house cleaning.jpg',
  ),
  CategoryServiceItem(
    serviceId: 12,
    title: 'Sofa Carpet Clean',
    subtitle: 'Fresh look, spotless comfort.',
    rating: 4.7,
    reviews: 98,
    price: '\$59',
    image: 'assets/Sofa & Carpet Cleaning.jpg',
  ),
];
