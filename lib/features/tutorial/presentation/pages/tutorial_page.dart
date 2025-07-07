import 'package:flutter/material.dart';
import 'package:polyglot_puzzle/core/themes/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TutorialPage extends StatefulWidget {
  const TutorialPage({Key? key}) : super(key: key);

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<TutorialStep> _tutorialSteps = [
    TutorialStep(
      title: 'Welcome to\nPolyglot Puzzle!',
      description: 'Learn languages while playing a fun puzzle game combining Tetris mechanics with vocabulary learning.',
      icon: Icons.language,
      color: AppTheme.primaryBlue,
    ),
    TutorialStep(
      title: 'Place Tetris Pieces',
      description: 'Drag and drop Tetris pieces onto the 8x8 game board. Each piece contains a vocabulary word to learn.',
      icon: Icons.extension,
      color: AppTheme.accentCyan,
    ),
    TutorialStep(
      title: 'Clear Lines & Learn',
      description: 'Fill complete rows or columns to clear them and earn points. Remember the words on cleared pieces!',
      icon: Icons.clear_all,
      color: AppTheme.successGreen,
    ),
    TutorialStep(
      title: 'Discover Word Meanings',
      description: 'Long press any piece to see the word translation, pronunciation, and example usage.',
      icon: Icons.touch_app,
      color: AppTheme.warningOrange,
    ),
    TutorialStep(
      title: 'Level Up & Progress',
      description: 'Gain XP for playing, clearing lines, and learning words. Level up to unlock new features!',
      icon: Icons.trending_up,
      color: Colors.purple,
    ),
    TutorialStep(
      title: 'Smart Learning',
      description: 'Our AI uses spaced repetition to show you words at the perfect time for maximum retention.',
      icon: Icons.psychology,
      color: Colors.pink,
    ),
    TutorialStep(
      title: 'Ready to Play!',
      description: 'You\'re all set! Start your language learning journey with Polyglot Puzzle.',
      icon: Icons.play_arrow,
      color: AppTheme.primaryBlue,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _completeTutorial,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
            
            // Tutorial content
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _tutorialSteps.length,
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemBuilder: (context, index) {
                  return _buildTutorialPage(_tutorialSteps[index]);
                },
              ),
            ),
            
            // Navigation
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Page indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _tutorialSteps.length,
                      (index) => _buildPageIndicator(index),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Navigation buttons
                  Row(
                    children: [
                      // Previous button
                      if (_currentPage > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousPage,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: BorderSide(color: AppTheme.primaryBlue),
                            ),
                            child: const Text('Previous'),
                          ),
                        ),
                      
                      if (_currentPage > 0) const SizedBox(width: 16),
                      
                      // Next/Get Started button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _currentPage == _tutorialSteps.length - 1
                              ? _completeTutorial
                              : _nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryBlue,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: Text(
                            _currentPage == _tutorialSteps.length - 1
                                ? 'Get Started'
                                : 'Next',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorialPage(TutorialStep step) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: step.color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              step.icon,
              size: 60,
              color: step.color,
            ),
          ),
          
          const SizedBox(height: 48),
          
          // Title
          Text(
            step.title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 24),
          
          // Description
          Text(
            step.description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Colors.grey[300],
              height: 1.6,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 48),
          
          // Visual demonstration (for specific steps)
          if (_currentPage == 1) _buildGameBoardDemo(),
          if (_currentPage == 2) _buildLineClearDemo(),
          if (_currentPage == 3) _buildWordRevealDemo(),
          if (_currentPage == 4) _buildProgressDemo(),
        ],
      ),
    );
  }

  Widget _buildPageIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: _currentPage == index ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: _currentPage == index 
            ? AppTheme.primaryBlue 
            : Colors.grey[600],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _buildGameBoardDemo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Game Board (8x8)',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          // Mini game board visualization
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              crossAxisSpacing: 1,
              mainAxisSpacing: 1,
            ),
            itemCount: 64,
            itemBuilder: (context, index) {
              final isHighlighted = [18, 19, 26, 27].contains(index);
              return Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: isHighlighted 
                      ? AppTheme.accentCyan.withOpacity(0.8)
                      : Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLineClearDemo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            'Clear Complete Lines',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_forward, color: AppTheme.successGreen),
              const SizedBox(width: 8),
              Text(
                '+100 XP',
                style: TextStyle(
                  color: AppTheme.successGreen,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWordRevealDemo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentCyan,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Hello',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Icon(Icons.touch_app, color: Colors.grey[400]),
          const SizedBox(height: 8),
          Text(
            'Translation: Merhaba',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDemo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                backgroundColor: AppTheme.primaryBlue,
                child: const Text('L2', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward, color: Colors.white),
              const SizedBox(width: 8),
              CircleAvatar(
                backgroundColor: Colors.purple,
                child: const Text('L3', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: 0.8,
            backgroundColor: Colors.grey[700],
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryBlue),
          ),
          const SizedBox(height: 4),
          Text(
            '80% to Level 3',
            style: TextStyle(
              color: Colors.grey[400],
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _nextPage() {
    if (_currentPage < _tutorialSteps.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeTutorial() async {
    // Mark tutorial as completed
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('tutorial_completed', true);
    
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  // Check if tutorial should be shown
  static Future<bool> shouldShowTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool('tutorial_completed') ?? false);
  }
}

class TutorialStep {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  TutorialStep({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}

// Interactive Tutorial Overlay Widget
class TutorialOverlay extends StatefulWidget {
  final Widget child;
  final String message;
  final VoidCallback onNext;
  final VoidCallback? onPrevious;
  final bool isLastStep;

  const TutorialOverlay({
    Key? key,
    required this.child,
    required this.message,
    required this.onNext,
    this.onPrevious,
    this.isLastStep = false,
  }) : super(key: key);

  @override
  State<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends State<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Dark overlay
        AnimatedBuilder(
          animation: _fadeAnimation,
          builder: (context, child) {
            return Container(
              color: Colors.black.withOpacity(0.8 * _fadeAnimation.value),
            );
          },
        ),
        
        // Highlighted widget
        widget.child,
        
        // Tutorial message
        Positioned(
          bottom: 100,
          left: 20,
          right: 20,
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.scale(
                scale: _scaleAnimation.value,
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.message,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                            height: 1.4,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (widget.onPrevious != null) ...[
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: widget.onPrevious,
                                  child: const Text('Previous'),
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: ElevatedButton(
                                onPressed: widget.onNext,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryBlue,
                                ),
                                child: Text(
                                  widget.isLastStep ? 'Got it!' : 'Next',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}