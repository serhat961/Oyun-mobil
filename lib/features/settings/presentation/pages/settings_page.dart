import 'package:flutter/material.dart';
import 'package:polyglot_puzzle/core/themes/app_theme.dart';
import 'package:polyglot_puzzle/core/services/audio_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final AudioService _audioService = AudioService();
  
  bool _soundEnabled = true;
  bool _musicEnabled = true;
  bool _vibrationEnabled = true;
  bool _notificationsEnabled = true;
  double _soundVolume = 0.7;
  double _musicVolume = 0.5;
  String _selectedLanguage = 'Turkish';
  String _selectedDifficulty = 'Medium';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _soundEnabled = _audioService.soundEnabled;
      _musicEnabled = _audioService.musicEnabled;
      _soundVolume = _audioService.soundVolume;
      _musicVolume = _audioService.musicVolume;
      _vibrationEnabled = prefs.getBool('vibration_enabled') ?? true;
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
      _selectedLanguage = prefs.getString('selected_language') ?? 'Turkish';
      _selectedDifficulty = prefs.getString('selected_difficulty') ?? 'Medium';
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: Text(
          'Settings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.grey[850],
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Audio Settings
          _buildSectionHeader('Audio Settings'),
          _buildAudioSettings(),
          
          const SizedBox(height: 24),
          
          // Game Settings
          _buildSectionHeader('Game Settings'),
          _buildGameSettings(),
          
          const SizedBox(height: 24),
          
          // Language Settings
          _buildSectionHeader('Language Settings'),
          _buildLanguageSettings(),
          
          const SizedBox(height: 24),
          
          // Notifications
          _buildSectionHeader('Notifications'),
          _buildNotificationSettings(),
          
          const SizedBox(height: 24),
          
          // Data & Privacy
          _buildSectionHeader('Data & Privacy'),
          _buildDataSettings(),
          
          const SizedBox(height: 24),
          
          // About
          _buildSectionHeader('About'),
          _buildAboutSettings(),
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: AppTheme.primaryBlue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAudioSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Sound Effects Toggle
            SwitchListTile(
              title: const Text('Sound Effects'),
              subtitle: const Text('Enable game sound effects'),
              value: _soundEnabled,
              onChanged: (value) async {
                setState(() => _soundEnabled = value);
                await _audioService.setSoundEnabled(value);
                if (value) _audioService.playButtonClick();
              },
            ),
            
            // Sound Volume Slider
            if (_soundEnabled) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.volume_down, color: Colors.white70),
                  Expanded(
                    child: Slider(
                      value: _soundVolume,
                      onChanged: (value) {
                        setState(() => _soundVolume = value);
                        _audioService.setSoundVolume(value);
                      },
                      onChangeEnd: (value) {
                        _audioService.playButtonClick();
                      },
                    ),
                  ),
                  const Icon(Icons.volume_up, color: Colors.white70),
                ],
              ),
            ],
            
            const Divider(),
            
            // Background Music Toggle
            SwitchListTile(
              title: const Text('Background Music'),
              subtitle: const Text('Enable background music'),
              value: _musicEnabled,
              onChanged: (value) async {
                setState(() => _musicEnabled = value);
                await _audioService.setMusicEnabled(value);
              },
            ),
            
            // Music Volume Slider
            if (_musicEnabled) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.music_note, color: Colors.white70),
                  Expanded(
                    child: Slider(
                      value: _musicVolume,
                      onChanged: (value) {
                        setState(() => _musicVolume = value);
                        _audioService.setMusicVolume(value);
                      },
                    ),
                  ),
                  const Icon(Icons.music_note, color: Colors.white70),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGameSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Vibration Toggle
            SwitchListTile(
              title: const Text('Vibration'),
              subtitle: const Text('Enable haptic feedback'),
              value: _vibrationEnabled,
              onChanged: (value) async {
                setState(() => _vibrationEnabled = value);
                await _saveSetting('vibration_enabled', value);
              },
            ),
            
            const Divider(),
            
            // Difficulty Setting
            ListTile(
              title: const Text('Difficulty'),
              subtitle: Text('Current: $_selectedDifficulty'),
              trailing: DropdownButton<String>(
                value: _selectedDifficulty,
                dropdownColor: Colors.grey[800],
                items: ['Easy', 'Medium', 'Hard', 'Expert']
                    .map((difficulty) => DropdownMenuItem(
                          value: difficulty,
                          child: Text(difficulty),
                        ))
                    .toList(),
                onChanged: (value) async {
                  if (value != null) {
                    setState(() => _selectedDifficulty = value);
                    await _saveSetting('selected_difficulty', value);
                  }
                },
              ),
            ),
            
            const Divider(),
            
            // Auto-pause setting
            SwitchListTile(
              title: const Text('Auto-pause'),
              subtitle: const Text('Pause game when app goes to background'),
              value: true, // This would be a setting
              onChanged: (value) {
                // Implement auto-pause setting
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // UI Language
            ListTile(
              title: const Text('App Language'),
              subtitle: Text('Current: $_selectedLanguage'),
              trailing: DropdownButton<String>(
                value: _selectedLanguage,
                dropdownColor: Colors.grey[800],
                items: ['English', 'Turkish', 'Spanish', 'French', 'German']
                    .map((language) => DropdownMenuItem(
                          value: language,
                          child: Text(language),
                        ))
                    .toList(),
                onChanged: (value) async {
                  if (value != null) {
                    setState(() => _selectedLanguage = value);
                    await _saveSetting('selected_language', value);
                  }
                },
              ),
            ),
            
            const Divider(),
            
            // Learning language pair selector
            ListTile(
              title: const Text('Learning Languages'),
              subtitle: const Text('Choose your language learning pair'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // Navigate to language pair selection
                _showLanguagePairDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SwitchListTile(
              title: const Text('Push Notifications'),
              subtitle: const Text('Receive game reminders and updates'),
              value: _notificationsEnabled,
              onChanged: (value) async {
                setState(() => _notificationsEnabled = value);
                await _saveSetting('notifications_enabled', value);
              },
            ),
            
            const Divider(),
            
            ListTile(
              title: const Text('Daily Reminder'),
              subtitle: const Text('Get reminded to practice daily'),
              trailing: const Text('8:00 PM'),
              onTap: () {
                _showTimePickerDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: const Text('Reset Game Data'),
              subtitle: const Text('Clear all progress and start over'),
              trailing: const Icon(Icons.warning, color: Colors.orange),
              onTap: () {
                _showResetDataDialog();
              },
            ),
            
            const Divider(),
            
            ListTile(
              title: const Text('Export Data'),
              subtitle: const Text('Backup your progress'),
              trailing: const Icon(Icons.download),
              onTap: () {
                _exportData();
              },
            ),
            
            const Divider(),
            
            ListTile(
              title: const Text('Privacy Policy'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                _showPrivacyPolicy();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutSettings() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              title: const Text('Version'),
              subtitle: const Text('1.0.0'),
              trailing: const Text('Latest'),
            ),
            
            const Divider(),
            
            ListTile(
              title: const Text('Rate App'),
              trailing: const Icon(Icons.star),
              onTap: () {
                _rateApp();
              },
            ),
            
            const Divider(),
            
            ListTile(
              title: const Text('Contact Support'),
              trailing: const Icon(Icons.email),
              onTap: () {
                _contactSupport();
              },
            ),
            
            const Divider(),
            
            ListTile(
              title: const Text('Licenses'),
              trailing: const Icon(Icons.info),
              onTap: () {
                showLicensePage(context: context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePairDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Language Learning Pair'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Choose your learning language pair:'),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Turkish → English'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('English → Turkish'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Spanish → English'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showTimePickerDialog() {
    showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 20, minute: 0),
    );
  }

  void _showResetDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Game Data'),
        content: const Text(
          'This will permanently delete all your progress, including:\n'
          '• Player level and XP\n'
          '• High scores\n'
          '• Learning progress\n'
          '• Statistics\n\n'
          'This action cannot be undone. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _resetGameData();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Reset All Data'),
          ),
        ],
      ),
    );
  }

  Future<void> _resetGameData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Game data has been reset'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _exportData() {
    // Implement data export functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Data export feature coming soon'),
      ),
    );
  }

  void _showPrivacyPolicy() {
    // Show privacy policy
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'Polyglot Puzzle Privacy Policy\n\n'
            '1. Data Collection: We only collect data necessary for game functionality.\n'
            '2. Local Storage: Game progress is stored locally on your device.\n'
            '3. No Personal Data: We do not collect personal information.\n'
            '4. Analytics: Anonymous usage statistics may be collected to improve the game.\n'
            '5. Third-party Services: We may use third-party services for ads and analytics.\n\n'
            'For questions, contact: support@polyglotpuzzle.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _rateApp() {
    // Open app store for rating
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Thank you! Opening app store...'),
      ),
    );
  }

  void _contactSupport() {
    // Open email client or support page
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening email client...'),
      ),
    );
  }
}