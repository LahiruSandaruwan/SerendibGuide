import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_state_provider.dart';
import '../services/purchase_service.dart';
import '../utils/constants.dart';

/// Premium upgrade screen with purchase flow
class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _setupPurchaseCallbacks();
  }

  void _setupPurchaseCallbacks() {
    final purchaseService = context.read<PurchaseService>();
    final appState = context.read<AppStateProvider>();

    purchaseService.onPurchaseSuccess = () {
      if (!mounted) return;
      _showSuccessDialog();
    };

    purchaseService.onPurchaseError = (error) {
      if (!mounted) return;
      setState(() {
        _error = error;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppConstants.errorRed,
        ),
      );
    };

    purchaseService.onPurchasePending = () {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });
    };

    purchaseService.onPurchaseCanceled = () {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    };

    purchaseService.onPremiumStatusChanged = (isPremium) {
      if (!mounted) return;
      appState.setPremiumStatus(isPremium);
    };
  }

  Future<void> _handlePurchase() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final purchaseService = context.read<PurchaseService>();
      await purchaseService.purchasePremium();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _handleRestore() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final purchaseService = context.read<PurchaseService>();
      await purchaseService.restorePurchases();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Restore failed: ${e.toString()}')),
      );
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Upgrade to Premium'),
        backgroundColor: AppConstants.premiumGold,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppConstants.deepOceanBlue,
              AppConstants.sunsetOrange,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.spacing24),
            child: Column(
              children: [
                const Icon(
                  Icons.workspace_premium,
                  size: 100,
                  color: AppConstants.premiumGold,
                ),
                const SizedBox(height: 24),
                const Text(
                  'Unlock the Complete Experience',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Discover all of Sri Lanka',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Features List
                _buildFeature(
                  icon: Icons.explore,
                  title: 'Access All 300+ Attractions',
                  subtitle: 'Currently: 100 in free version',
                ),
                _buildFeature(
                  icon: Icons.map,
                  title: 'Complete Offline Maps',
                  subtitle: 'All zoom levels, no data needed',
                ),
                _buildFeature(
                  icon: Icons.ads_click,
                  title: 'Remove All Advertisements',
                  subtitle: 'Enjoy clean, distraction-free experience',
                ),
                _buildFeature(
                  icon: Icons.language,
                  title: 'All 3 Languages Available',
                  subtitle: 'English, සිංහල, தமிழ்',
                ),
                _buildFeature(
                  icon: Icons.favorite,
                  title: 'Unlimited Favorites & Trips',
                  subtitle: 'Currently: 20 favorites, 3 trips max',
                ),
                _buildFeature(
                  icon: Icons.update,
                  title: 'Lifetime Access',
                  subtitle: 'One payment, all future updates free',
                ),
                _buildFeature(
                  icon: Icons.support_agent,
                  title: 'Priority Support',
                  subtitle: 'Email support with 24h response',
                ),

                const SizedBox(height: 32),

                // Price Box
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Text(
                        'ONE-TIME PAYMENT',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '\$14.99',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: AppConstants.successGreen,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'No subscriptions, pay once forever',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Purchase Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handlePurchase,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppConstants.premiumGold,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                      ),
                    ),
                    child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 2,
                          ),
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_open),
                            SizedBox(width: 8),
                            Text(
                              'Unlock Premium Now',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                  ),
                ),

                const SizedBox(height: 16),

                // Restore Button
                TextButton(
                  onPressed: _isLoading ? null : _handleRestore,
                  child: const Text(
                    'Restore Purchases',
                    style: TextStyle(color: Colors.white),
                  ),
                ),

                const SizedBox(height: 32),

                // FAQ
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Frequently Asked Questions',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildFAQ(
                        'Will I be charged monthly?',
                        'No, it\'s a one-time payment. Pay once, use forever.',
                      ),
                      _buildFAQ(
                        'Can I use on multiple devices?',
                        'Yes, tied to your Google account. Install on any device and restore purchases.',
                      ),
                      _buildFAQ(
                        'What if I get a new phone?',
                        'Simply reinstall the app and tap "Restore Purchases".',
                      ),
                      _buildFAQ(
                        'Is payment secure?',
                        'Yes, all payments processed securely by Google Play.',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Join 5,000+ Premium Users ⭐⭐⭐⭐⭐',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeature({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAQ(String question, String answer) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            answer,
            style: const TextStyle(
              fontSize: 13,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: AppConstants.successGreen, size: 32),
              SizedBox(width: 12),
              Text('Welcome to Premium! 🎉'),
            ],
          ),
          content: const Text(
            'You now have access to all 300+ attractions, offline maps, and ad-free experience. Enjoy exploring Sri Lanka!',
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to previous screen
              },
              child: const Text('Start Exploring'),
            ),
          ],
        );
      },
    );
  }
}
