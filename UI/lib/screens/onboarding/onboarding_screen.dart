import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../signup/signup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  final List<_OnboardingPage> _pages = const [
    _OnboardingPage(
      title: 'Smart Home,\nSmooth Services',
      subtitle:
          'Professional services at your fingertips.\nBook trusted experts in minutes.',
      imageAsset: 'assets/onboarding 1.jpg',
      isFullBleed: true,
    ),
    _OnboardingPage(
      title: 'Trusted\nProfessionals',
      subtitle: 'Background verified, highly rated\nexperts you can rely on.',
      imageAsset: 'assets/onboarding 2.jpg',
    ),
    _OnboardingPage(
      title: 'Easy Booking,\nInstant Service',
      subtitle: 'Choose a service, pick a time and\nrelax. We will take care of the rest.',
      imageAsset: 'assets/onboarding 4.jpg',
    ),
  ];

  void _goToNext() {
    if (_index < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _goToSignup();
    }
  }

  void _goToSignup() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignupScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6F2),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (_, i) => _OnboardingCard(
                  page: _pages[i],
                  index: i,
                  total: _pages.length,
                  onSkip: _goToSignup,
                  onNext: _goToNext,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingCard extends StatelessWidget {
  final _OnboardingPage page;
  final int index;
  final int total;
  final VoidCallback onSkip;
  final VoidCallback onNext;

  const _OnboardingCard({
    required this.page,
    required this.index,
    required this.total,
    required this.onSkip,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    if (page.isFullBleed) {
      return Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              page.imageAsset,
              fit: BoxFit.cover,
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            top: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    TextButton(
                      onPressed: onSkip,
                      child:
                          const Text('Skip', style: AppTextStyles.bodyMedium),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.inputBorder),
                        ),
                        child: const Icon(Icons.home_rounded,
                            color: AppColors.primary, size: 34),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'HomeEase',
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 20),
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                            height: 1.2,
                          ),
                          children: [
                            TextSpan(text: 'Your Home,\n'),
                            TextSpan(
                              text: 'Our Priority',
                              style: TextStyle(color: AppColors.primary),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      const Text(
                        'Professional services at your fingertips.\n'
                        'Book trusted experts in minutes.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textMedium,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                total,
                (i) => _Dot(isActive: i == index),
              ),
            ),
          ),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: TextButton(
              onPressed: onSkip,
              child: const Text('Skip', style: AppTextStyles.bodyMedium),
            ),
          ),
          const SizedBox(height: 6),
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(26),
                child: Image.asset(
                  page.imageAsset,
                  height: 390,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
              Positioned(
                right: 14,
                top: 14,
                child: Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          Text(
            page.title.split('\n').first,
            style: const TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          if (page.title.contains('\n')) ...[
            const SizedBox(height: 2),
            Text(
              page.title.split('\n')[1],
              style: const TextStyle(
                fontSize: 35,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ],
          const SizedBox(height: 9),
          Text(
            page.subtitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.textMedium,
              height: 1.4,
            ),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              total,
              (i) => _Dot(isActive: i == index),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final bool isActive;

  const _Dot({required this.isActive});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: isActive ? 18 : 6,
      height: 6,
      decoration: BoxDecoration(
        color: isActive ? AppColors.primary : AppColors.inputBorder,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}

class _OnboardingPage {
  final String title;
  final String subtitle;
  final String imageAsset;
  final bool isFullBleed;

  const _OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.imageAsset,
    this.isFullBleed = false,
  });
}
