import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/app_state_provider.dart';
import '../services/database_service.dart';
import '../services/user_data_service.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

/// Settings screen for language, theme, and app preferences
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  PackageInfo? _packageInfo;
  int _dbSize = 0;
  int _userDbSize = 0;

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
    _loadDatabaseSizes();
  }

  Future<void> _loadAppInfo() async {
    final info = await PackageInfo.fromPlatform();
    if (mounted) {
      setState(() {
        _packageInfo = info;
      });
    }
  }

  Future<void> _loadDatabaseSizes() async {
    final dbService = DatabaseService();
    final userDbService = UserDataService();

    final dbSize = await dbService.getDatabaseSize();
    // final userDbSize = await userDbService.getDatabaseSize();

    if (mounted) {
      setState(() {
        _dbSize = dbSize;
        _userDbSize = 0; // userDbSize;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          _buildSection(
            title: 'Language',
            children: [
              _buildLanguageTile(),
            ],
          ),
          _buildSection(
            title: 'Display',
            children: [
              _buildDarkModeTile(),
            ],
          ),
          _buildSection(
            title: 'Storage',
            children: [
              _buildStorageTile(),
            ],
          ),
          _buildSection(
            title: 'Premium',
            children: [
              _buildPremiumStatusTile(),
            ],
          ),
          _buildSection(
            title: 'About',
            children: [
              _buildVersionTile(),
              _buildRateTile(),
              _buildShareTile(),
              _buildPrivacyTile(),
              _buildContactTile(),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              fontWeight: AppConstants.fontBold,
              color: AppConstants.deepOceanBlue,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...children,
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildLanguageTile() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, _) {
        final languageNames = {
          'en': 'English',
          'si': 'සිංහල (Sinhala)',
          'ta': 'தமிழ் (Tamil)',
        };

        return ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Language'),
          subtitle: Text(languageNames[appState.languageCode] ?? 'English'),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: () => _showLanguageDialog(),
        );
      },
    );
  }

  Widget _buildDarkModeTile() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, _) {
        return SwitchListTile(
          secondary: Icon(
            appState.isDarkMode ? Icons.dark_mode : Icons.light_mode,
          ),
          title: const Text('Dark Mode'),
          subtitle: Text(appState.isDarkMode ? 'Enabled' : 'Disabled'),
          value: appState.isDarkMode,
          onChanged: (value) {
            appState.toggleDarkMode();
          },
        );
      },
    );
  }

  Widget _buildStorageTile() {
    return ListTile(
      leading: const Icon(Icons.storage),
      title: const Text('App Storage'),
      subtitle: Text(
        'Attractions DB: ${Helpers.formatFileSize(_dbSize)}\n'
        'User Data: ${Helpers.formatFileSize(_userDbSize)}',
      ),
      isThreeLine: true,
    );
  }

  Widget _buildPremiumStatusTile() {
    return Consumer<AppStateProvider>(
      builder: (context, appState, _) {
        if (appState.isPremium) {
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppConstants.premiumGold, Colors.orange],
              ),
              borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
            ),
            child: Row(
              children: const [
                Icon(Icons.star, color: Colors.white, size: 32),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '✨ Premium User',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Thank you for your support!',
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          return ListTile(
            leading: const Icon(Icons.star, color: AppConstants.premiumGold),
            title: const Text('Upgrade to Premium'),
            subtitle: const Text('Unlock all features for \$14.99'),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              // TODO: Navigate to premium screen
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Premium upgrade coming soon!')),
              );
            },
          );
        }
      },
    );
  }

  Widget _buildVersionTile() {
    return ListTile(
      leading: const Icon(Icons.info),
      title: const Text('Version'),
      subtitle: Text(
        _packageInfo != null
            ? '${_packageInfo!.version} (${_packageInfo!.buildNumber})'
            : 'Loading...',
      ),
    );
  }

  Widget _buildRateTile() {
    return ListTile(
      leading: const Icon(Icons.star_rate),
      title: const Text('Rate on Play Store'),
      subtitle: const Text('Help us grow with a 5-star review'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _launchUrl(AppConstants.playStoreUrl),
    );
  }

  Widget _buildShareTile() {
    return ListTile(
      leading: const Icon(Icons.share),
      title: const Text('Share App'),
      subtitle: const Text('Tell your friends about Serendib Guide'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () {
        Share.share(
          'Discover Sri Lanka with Serendib Guide - Complete offline travel guide!\n\n'
          'Download now: ${AppConstants.playStoreUrl}',
        );
      },
    );
  }

  Widget _buildPrivacyTile() {
    return ListTile(
      leading: const Icon(Icons.privacy_tip),
      title: const Text('Privacy Policy'),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _launchUrl(AppConstants.privacyPolicyUrl),
    );
  }

  Widget _buildContactTile() {
    return ListTile(
      leading: const Icon(Icons.email),
      title: const Text('Contact Us'),
      subtitle: Text(AppConstants.supportEmail),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: () => _launchUrl('mailto:${AppConstants.supportEmail}'),
    );
  }

  void _showLanguageDialog() {
    final appState = context.read<AppStateProvider>();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Language'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile<String>(
                title: const Text('English'),
                value: 'en',
                groupValue: appState.languageCode,
                onChanged: (value) {
                  appState.setLocale(Locale(value!));
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('සිංහල (Sinhala)'),
                value: 'si',
                groupValue: appState.languageCode,
                onChanged: (value) {
                  appState.setLocale(Locale(value!));
                  Navigator.pop(context);
                },
              ),
              RadioListTile<String>(
                title: const Text('தமிழ் (Tamil)'),
                value: 'ta',
                groupValue: appState.languageCode,
                onChanged: (value) {
                  appState.setLocale(Locale(value!));
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open $url')),
      );
    }
  }
}
