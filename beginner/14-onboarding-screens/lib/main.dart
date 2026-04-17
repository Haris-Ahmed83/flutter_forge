import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Onboarding App',
      theme: ThemeData(
        // Using a seed color for Material 3 dynamic color generation
        colorSchemeSeed: Colors.blue,
        useMaterial3: true,
        // Customize text theme for better readability
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold),
          headlineMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
          headlineSmall: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(fontSize: 18.0),
          bodyMedium: TextStyle(fontSize: 16.0),
        ),
      ),
      home: const OnboardingScreen(),
    );
  }
}

/// Data model for each onboarding page's content.
class OnboardingPageData {
  const OnboardingPageData({
    required this.icon,
    required this.title,
    required this.description,
    this.color,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color? color; // Optional background color for the icon
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Sample data for the onboarding pages.
  final List<OnboardingPageData> _pages = const [
    OnboardingPageData(
      icon: Icons.lightbulb_outline,
      title: 'Discover New Ideas',
      description: 'Explore a world of innovation and creativity right at your fingertips.',
      color: Color(0xFF81C784), // Light green
    ),
    OnboardingPageData(
      icon: Icons.rocket_launch_outlined,
      title: 'Launch Your Projects',
      description: 'Turn your ideas into reality with powerful tools and resources.',
      color: Color(0xFF64B5F6), // Light blue
    ),
    OnboardingPageData(
      icon: Icons.people_outline,
      title: 'Connect with Community',
      description: 'Join a vibrant community of like-minded individuals and collaborate.',
      color: Color(0xFFFFB74D), // Orange
    ),
    OnboardingPageData(
      icon: Icons.check_circle_outline,
      title: 'Achieve Your Goals',
      description: 'Set your targets, track your progress, and celebrate your successes.',
      color: Color(0xFFE57373), // Red
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Navigates to the next page in the PageView or finishes onboarding if on the last page.
  void _onNextPressed() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  /// Skips directly to the end of onboarding and navigates to the main app screen.
  void _onSkipPressed() {
    _finishOnboarding();
  }

  /// Navigates to the main application screen, replacing the onboarding screens.
  void _finishOnboarding() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainAppScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Skip button positioned at the top right.
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: _onSkipPressed,
                  child: Text(
                    // Text changes based on whether it's the last page.
                    _currentPage == _pages.length - 1 ? 'Get Started' : 'Skip',
                    style: TextStyle(
                      color: colorScheme.onBackground,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            // PageView takes up most of the screen space.
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (int index) {
                  // Update the current page index to reflect dot indicator state.
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  final pageData = _pages[index];
                  return OnboardingPageWidget(
                    icon: pageData.icon,
                    title: pageData.title,
                    description: pageData.description,
                    // Use page-specific color or fallback to primaryContainer.
                    iconBackgroundColor: pageData.color ?? colorScheme.primaryContainer,
                  );
                },
              ),
            ),
            // Controls section: Dots indicator and Next/Get Started button.
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Page indicator dots.
                  Row(
                    children: List.generate(
                      _pages.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        height: 8.0,
                        // Highlight the current page's dot by making it wider.
                        width: _currentPage == index ? 24.0 : 8.0,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? colorScheme.primary
                              : colorScheme.onBackground.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4.0),
                        ),
                      ),
                    ),
                  ),
                  // Next/Get Started button.
                  FilledButton.tonal(
                    onPressed: _onNextPressed,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: Text(
                      // Text changes based on whether it's the last page.
                      _currentPage == _pages.length - 1 ? 'Get Started' : 'Next',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A stateless widget to display the content of a single onboarding page.
class OnboardingPageWidget extends StatelessWidget {
  const OnboardingPageWidget({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.iconBackgroundColor,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color iconBackgroundColor;

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon displayed within a circular background.
          Container(
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: iconBackgroundColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 80.0,
              color: colorScheme.onPrimary, // Icon color for contrast
            ),
          ),
          const SizedBox(height: 48.0),
          // Title of the onboarding page.
          Text(
            title,
            textAlign: TextAlign.center,
            style: textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onBackground,
            ),
          ),
          const SizedBox(height: 16.0),
          // Description of the onboarding page.
          Text(
            description,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onBackground.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

/// A simple placeholder screen shown after onboarding is completed.
class MainAppScreen extends StatelessWidget {
  const MainAppScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome!'),
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.thumb_up_alt,
                size: 100,
                color: colorScheme.secondary,
              ),
              const SizedBox(height: 24),
              Text(
                'You\'ve successfully completed the onboarding!',
                textAlign: TextAlign.center,
                style: textTheme.headlineSmall?.copyWith(color: colorScheme.onBackground),
              ),
              const SizedBox(height: 16),
              Text(
                'This is where your amazing app content would go.',
                textAlign: TextAlign.center,
                style: textTheme.bodyLarge?.copyWith(color: colorScheme.onBackground.withOpacity(0.7)),
              ),
              const SizedBox(height: 48),
              FilledButton(
                onPressed: () {
                  // In a real application, this button might navigate to a specific
                  // feature, or simply close this welcome message.
                  // For this demo, it just serves as a visual cue.
                },
                child: const Text('Start Exploring'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
