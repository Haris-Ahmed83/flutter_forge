import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

// --- Constants and Theme ---

/// Define responsive breakpoints for different screen sizes.
const double _kMobileBreakpoint = 600.0;
const double _kTabletBreakpoint = 1000.0;

/// Custom color scheme for the portfolio.
/// Using a dark theme with a vibrant primary color.
final ColorScheme _customColorScheme = ColorScheme.fromSeed(
  seedColor: const Color(0xFF6200EE), // A vibrant purple
  brightness: Brightness.dark,
  primary: const Color(0xFFBB86FC), // Lighter purple for primary elements
  onPrimary: Colors.black,
  secondary: const Color(0xFF03DAC6), // Teal for secondary elements
  onSecondary: Colors.black,
  surface: const Color(0xFF121212), // Dark surface
  onSurface: Colors.white,
  background: const Color(0xFF121212), // Dark background
  onBackground: Colors.white,
  error: const Color(0xFFCF6679), // Red for errors
  onError: Colors.black,
);

/// The main entry point of the application.
void main() {
  runApp(const MyApp());
}

/// The root widget of the application, setting up the Material app and theme.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'My Portfolio',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: _customColorScheme,
        appBarTheme: AppBarTheme(
          backgroundColor: _customColorScheme.surface,
          foregroundColor: _customColorScheme.onSurface,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: _customColorScheme.surface,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        textTheme: TextTheme(
          displayLarge: TextStyle(
            fontSize: 57,
            fontWeight: FontWeight.bold,
            color: _customColorScheme.onSurface,
          ),
          displayMedium: TextStyle(
            fontSize: 45,
            fontWeight: FontWeight.bold,
            color: _customColorScheme.onSurface,
          ),
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: _customColorScheme.onSurface,
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: _customColorScheme.onSurface,
          ),
          titleLarge: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _customColorScheme.onSurface,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: _customColorScheme.onSurface,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: _customColorScheme.onSurface.withOpacity(0.9),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: _customColorScheme.onSurface.withOpacity(0.8),
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: _customColorScheme.onPrimary,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _customColorScheme.primary,
            foregroundColor: _customColorScheme.onPrimary,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _customColorScheme.onPrimary,
            ),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: _customColorScheme.primary,
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _customColorScheme.primary,
            ),
          ),
        ),
      ),
      home: const PortfolioHomePage(),
    );
  }
}

// --- Data Models ---

/// Represents a portfolio project.
class Project {
  final String title;
  final String description;
  final String imageUrl;
  final String? githubLink;
  final String? liveLink;

  const Project({
    required this.title,
    required this.description,
    required this.imageUrl,
    this.githubLink,
    this.liveLink,
  });
}

/// Represents a skill with a name and proficiency level.
class Skill {
  final String name;
  final double progress; // 0.0 to 1.0

  const Skill({required this.name, required this.progress});
}

// --- Sample Data ---

/// Sample data for the portfolio projects section.
final List<Project> _sampleProjects = [
  const Project(
    title: 'E-commerce Platform',
    description:
        'A full-stack e-commerce solution with user authentication, product listings, shopping cart, and payment integration.',
    imageUrl: 'https://via.placeholder.com/400x300/4CAF50/FFFFFF?text=E-commerce',
    githubLink: 'https://github.com/flutter-dev/ecommerce-app',
    liveLink: 'https://ecommerce.example.com',
  ),
  const Project(
    title: 'Task Management App',
    description:
        'A clean and intuitive task manager with drag-and-drop reordering, due dates, and reminders, built with Flutter.',
    imageUrl: 'https://via.placeholder.com/400x300/2196F3/FFFFFF?text=Task+Manager',
    githubLink: 'https://github.com/flutter-dev/task-manager',
    liveLink: 'https://taskmanager.example.com',
  ),
  const Project(
    title: 'Weather Forecast App',
    description:
        'Real-time weather application consuming a public API to display current conditions and a 5-day forecast.',
    imageUrl: 'https://via.placeholder.com/400x300/FFC107/FFFFFF?text=Weather+App',
    githubLink: 'https://github.com/flutter-dev/weather-app',
    liveLink: 'https://weather.example.com',
  ),
  const Project(
    title: 'Recipe Sharing Platform',
    description:
        'A community-driven platform for sharing and discovering recipes, with features like ratings and comments.',
    imageUrl: 'https://via.placeholder.com/400x300/9C27B0/FFFFFF?text=Recipe+App',
    githubLink: 'https://github.com/flutter-dev/recipe-app',
    liveLink: 'https://recipes.example.com',
  ),
  const Project(
    title: 'Personal Blog Site',
    description:
        'A responsive blog website with a custom CMS for content management and search engine optimization.',
    imageUrl: 'https://via.placeholder.com/400x300/FF5722/FFFFFF?text=Blog+Site',
    githubLink: 'https://github.com/flutter-dev/blog-site',
    liveLink: 'https://blog.example.com',
  ),
  const Project(
    title: 'Fitness Tracker',
    description:
        'An app to track workouts, monitor progress, and set fitness goals, integrated with health APIs.',
    imageUrl: 'https://via.placeholder.com/400x300/00BCD4/FFFFFF?text=Fitness+Tracker',
    githubLink: 'https://github.com/flutter-dev/fitness-tracker',
    liveLink: 'https://fitness.example.com',
  ),
];

/// Sample data for the skills section.
final List<Skill> _sampleSkills = [
  const Skill(name: 'Flutter & Dart', progress: 0.95),
  const Skill(name: 'Frontend Development', progress: 0.90),
  const Skill(name: 'Backend Development', progress: 0.80),
  const Skill(name: 'UI/UX Design', progress: 0.85),
  const Skill(name: 'State Management (Provider/Riverpod)', progress: 0.90),
  const Skill(name: 'RESTful APIs', progress: 0.88),
  const Skill(name: 'Database (SQL/NoSQL)', progress: 0.75),
  const Skill(name: 'Git & GitHub', progress: 0.92),
];

// --- Utility Functions ---

/// Launches a URL in the browser.
Future<void> _launchUrl(String url) async {
  final Uri uri = Uri.parse(url);
  if (!await launchUrl(uri)) {
    // ignore: avoid_print
    print('Could not launch $url'); // For debugging purposes
  }
}

// --- Portfolio Home Page ---

/// The main page of the portfolio, containing all sections and handling responsiveness and animations.
class PortfolioHomePage extends StatefulWidget {
  const PortfolioHomePage({super.key});

  @override
  State<PortfolioHomePage> createState() => _PortfolioHomePageState();
}

class _PortfolioHomePageState extends State<PortfolioHomePage>
    with TickerProviderStateMixin {
  late AnimationController _heroTextController;
  late Animation<Offset> _headingSlideAnimation;
  late Animation<Offset> _subheadingSlideAnimation;
  late Animation<double> _opacityAnimation;

  late AnimationController _skillsController;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    // Hero section animations
    _heroTextController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _headingSlideAnimation = Tween<Offset>(
      begin: const Offset(-0.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _heroTextController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOutCubic),
      ),
    );
    _subheadingSlideAnimation = Tween<Offset>(
      begin: const Offset(0.5, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _heroTextController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeOutCubic),
      ),
    );
    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _heroTextController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeIn),
      ),
    );

    // Skills section animation controller
    _skillsController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    // Start hero animation on initial load
    _heroTextController.forward();
  }

  @override
  void dispose() {
    _heroTextController.dispose();
    _skillsController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  /// Builds the navigation buttons for desktop layout.
  Widget _buildNavigationButtons(TextTheme textTheme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildNavButton(textTheme, 'About', '#about'),
        _buildNavButton(textTheme, 'Skills', '#skills'),
        _buildNavButton(textTheme, 'Projects', '#projects'),
        _buildNavButton(textTheme, 'Contact', '#contact'),
      ],
    );
  }

  /// Helper to create a navigation button.
  Widget _buildNavButton(TextTheme textTheme, String text, String sectionId) {
    return TextButton(
      onPressed: () {
        // Scroll to section logic
        final RenderBox? renderBox =
            GlobalKey(debugLabel: sectionId).currentContext?.findRenderObject()
                as RenderBox?;
        if (renderBox != null) {
          final offset = renderBox.localToGlobal(Offset.zero);
          _scrollController.animateTo(
            offset.dy + _scrollController.offset - AppBar().preferredSize.height,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      },
      child: Text(
        text,
        style: textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }

  /// Builds the hero section with animated text.
  Widget _buildHeroSection(TextTheme textTheme, bool isMobile) {
    return Container(
      key: GlobalKey(debugLabel: '#hero'),
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(
        vertical: isMobile ? 80 : 120,
        horizontal: isMobile ? 24 : 48,
      ),
      constraints: const BoxConstraints(minHeight: 500),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FadeTransition(
            opacity: _opacityAnimation,
            child: SlideTransition(
              position: _headingSlideAnimation,
              child: Text(
                'Hi, I\'m [Your Name]',
                textAlign: TextAlign.center,
                style: isMobile
                    ? textTheme.displayMedium
                    : textTheme.displayLarge,
              ),
            ),
          ),
          const SizedBox(height: 16),
          FadeTransition(
            opacity: _opacityAnimation,
            child: SlideTransition(
              position: _subheadingSlideAnimation,
              child: Text(
                'A Passionate Flutter Developer & UI/UX Enthusiast',
                textAlign: TextAlign.center,
                style: isMobile
                    ? textTheme.headlineMedium
                    : textTheme.headlineLarge?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 32),
          FadeTransition(
            opacity: _opacityAnimation,
            child: ElevatedButton.icon(
              onPressed: () => _launchUrl('https://github.com/your-profile'),
              icon: const Icon(Icons.code),
              label: const Text('View My Work'),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the "About Me" section.
  Widget _buildAboutSection(TextTheme textTheme, bool isMobile) {
    return Container(
      key: GlobalKey(debugLabel: '#about'),
      padding: EdgeInsets.symmetric(
        vertical: 64,
        horizontal: isMobile ? 24 : 48,
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'About Me',
            style: isMobile ? textTheme.headlineMedium : textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Text(
              'I\'m a dedicated Flutter developer with a strong passion for crafting beautiful and functional mobile and web applications. '
              'My journey in development began with a curiosity for how digital experiences are built, '
              'and since then, I\'ve been committed to learning and mastering new technologies. '
              'I specialize in creating intuitive user interfaces and robust, scalable backend solutions. '
              'When I\'m not coding, you can find me exploring new design patterns, contributing to open source, or enjoying a good book.',
              style: textTheme.bodyLarge,
              textAlign: isMobile ? TextAlign.justify : TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the "Skills" section with animated progress bars.
  Widget _buildSkillsSection(TextTheme textTheme, bool isMobile) {
    return Container(
      key: GlobalKey(debugLabel: '#skills'),
      padding: EdgeInsets.symmetric(
        vertical: 64,
        horizontal: isMobile ? 24 : 48,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'My Skills',
            style: isMobile ? textTheme.headlineMedium : textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: isMobile ? 1 : (MediaQuery.of(context).size.width < _kTabletBreakpoint ? 2 : 3),
                childAspectRatio: isMobile ? 4 : 5,
                crossAxisSpacing: 24,
                mainAxisSpacing: 24,
              ),
              itemCount: _sampleSkills.length,
              itemBuilder: (context, index) {
                // Stagger skill bar animations
                final Interval interval = Interval(
                  index / _sampleSkills.length,
                  (index + 1) / _sampleSkills.length,
                  curve: Curves.easeOutCubic,
                );
                return _SkillBar(
                  skill: _sampleSkills[index],
                  animation: CurvedAnimation(
                    parent: _skillsController,
                    curve: interval,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Trigger skill animation on button press
              _skillsController.reset();
              _skillsController.forward();
            },
            child: const Text('Animate Skills'),
          ),
        ],
      ),
    );
  }

  /// Builds the "Projects" section with a responsive grid of project cards.
  Widget _buildProjectsSection(TextTheme textTheme, bool isMobile) {
    return Container(
      key: GlobalKey(debugLabel: '#projects'),
      padding: EdgeInsets.symmetric(
        vertical: 64,
        horizontal: isMobile ? 24 : 48,
      ),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'My Projects',
            style: isMobile ? textTheme.headlineMedium : textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: isMobile ? 350 : 400, // Max width of each item
              childAspectRatio: 0.8, // Aspect ratio of each project card
              crossAxisSpacing: 24,
              mainAxisSpacing: 24,
            ),
            itemCount: _sampleProjects.length,
            itemBuilder: (context, index) {
              return ProjectCard(project: _sampleProjects[index]);
            },
          ),
        ],
      ),
    );
  }

  /// Builds the "Contact" section.
  Widget _buildContactSection(TextTheme textTheme, bool isMobile) {
    return Container(
      key: GlobalKey(debugLabel: '#contact'),
      padding: EdgeInsets.symmetric(
        vertical: 64,
        horizontal: isMobile ? 24 : 48,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Get in Touch',
            style: isMobile ? textTheme.headlineMedium : textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Text(
              'I\'m always open to new opportunities and collaborations. Feel free to reach out!',
              style: textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 48),
          Wrap(
            spacing: 24,
            runSpacing: 24,
            alignment: WrapAlignment.center,
            children: [
              _ContactButton(
                icon: Icons.email,
                label: 'Email Me',
                onPressed: () => _launchUrl('mailto:your.email@example.com'),
              ),
              _ContactButton(
                icon: Icons.link,
                label: 'LinkedIn',
                onPressed: () =>
                    _launchUrl('https://linkedin.com/in/your-profile'),
              ),
              _ContactButton(
                icon: Icons.code,
                label: 'GitHub',
                onPressed: () =>
                    _launchUrl('https://github.com/your-profile'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the footer section.
  Widget _buildFooter(TextTheme textTheme) {
    return Container(
      padding: const EdgeInsets.all(24),
      color: Theme.of(context).colorScheme.surface,
      child: Center(
        child: Text(
          '© ${DateTime.now().year} [Your Name]. All rights reserved.',
          style: textTheme.bodySmall,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final bool isMobile = screenSize.width < _kMobileBreakpoint;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('My Portfolio', style: textTheme.titleLarge),
        centerTitle: false,
        actions: isMobile ? null : [_buildNavigationButtons(textTheme)],
      ),
      drawer: isMobile
          ? Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  DrawerHeader(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    child: Text(
                      'Navigation',
                      style: textTheme.headlineMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                  _buildNavListTile(textTheme, 'About', '#about'),
                  _buildNavListTile(textTheme, 'Skills', '#skills'),
                  _buildNavListTile(textTheme, 'Projects', '#projects'),
                  _buildNavListTile(textTheme, 'Contact', '#contact'),
                ],
              ),
            )
          : null,
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          children: [
            _buildHeroSection(textTheme, isMobile),
            _buildAboutSection(textTheme, isMobile),
            _buildSkillsSection(textTheme, isMobile),
            _buildProjectsSection(textTheme, isMobile),
            _buildContactSection(textTheme, isMobile),
            _buildFooter(textTheme),
          ],
        ),
      ),
    );
  }

  /// Helper to create a navigation list tile for the drawer.
  ListTile _buildNavListTile(TextTheme textTheme, String title, String sectionId) {
    return ListTile(
      title: Text(title, style: textTheme.titleMedium),
      onTap: () {
        Navigator.pop(context); // Close the drawer
        // Scroll to section logic, similar to desktop nav buttons
        final RenderBox? renderBox =
            GlobalKey(debugLabel: sectionId).currentContext?.findRenderObject()
                as RenderBox?;
        if (renderBox != null) {
          final offset = renderBox.localToGlobal(Offset.zero);
          _scrollController.animateTo(
            offset.dy + _scrollController.offset - AppBar().preferredSize.height,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        }
      },
    );
  }
}

// --- Reusable Widgets ---

/// A card widget to display individual portfolio projects.
class ProjectCard extends StatefulWidget {
  final Project project;

  const ProjectCard({super.key, required this.project});

  @override
  State<ProjectCard> createState() => _ProjectCardState();
}

class _ProjectCardState extends State<ProjectCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.03).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    _elevationAnimation = Tween<double>(begin: 4.0, end: 16.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onHover(bool isHovering) {
    if (isHovering) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Card(
            elevation: _elevationAnimation.value,
            child: InkWell(
              onTap: () => _launchUrl(widget.project.liveLink ??
                  widget.project.githubLink ??
                  'https://example.com'), // Fallback link
              onHover: _onHover,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.project.imageUrl,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                            color: colorScheme.surfaceVariant,
                            alignment: Alignment.center,
                            child: Icon(
                              Icons.broken_image,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.project.title,
                      style: textTheme.titleLarge,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      flex: 2,
                      child: Text(
                        widget.project.description,
                        style: textTheme.bodyMedium,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (widget.project.githubLink != null)
                          IconButton(
                            icon: const Icon(Icons.code),
                            color: colorScheme.primary,
                            tooltip: 'View on GitHub',
                            onPressed: () =>
                                _launchUrl(widget.project.githubLink!),
                          ),
                        if (widget.project.liveLink != null)
                          IconButton(
                            icon: const Icon(Icons.open_in_new),
                            color: colorScheme.secondary,
                            tooltip: 'View Live Demo',
                            onPressed: () =>
                                _launchUrl(widget.project.liveLink!),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// A widget to display a skill with an animated progress bar.
class _SkillBar extends StatelessWidget {
  final Skill skill;
  final Animation<double> animation;

  const _SkillBar({required this.skill, required this.animation});

  @override
  Widget build(BuildContext context) {
    final TextTheme textTheme = Theme.of(context).textTheme;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              skill.name,
              style: textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: animation.value * skill.progress,
                minHeight: 12,
                backgroundColor: colorScheme.onSurface.withOpacity(0.1),
                valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// A styled button for contact links.
class _ContactButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 20),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: colorScheme.secondary,
        foregroundColor: colorScheme.onSecondary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: textTheme.labelLarge?.copyWith(
          color: colorScheme.onSecondary,
        ),
      ),
    );
  }
}
