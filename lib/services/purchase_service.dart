import 'dart:async';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

/// Service for managing in-app purchases
class PurchaseService {
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;
  PurchaseService._internal();

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isInitialized = false;

  // Callbacks for purchase events
  Function(bool)? onPremiumStatusChanged;
  Function(String)? onPurchaseError;
  Function()? onPurchaseSuccess;
  Function()? onPurchasePending;
  Function()? onPurchaseCanceled;

  /// Initialize purchase service and set up listeners
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final bool available = await _iap.isAvailable();
      if (!available) {
        print('✗ In-app purchases not available');
        return;
      }

      // Listen to purchase stream
      _subscription = _iap.purchaseStream.listen(
        _handlePurchaseUpdates,
        onDone: () => print('Purchase stream done'),
        onError: (error) => print('✗ Purchase stream error: $error'),
      );

      _isInitialized = true;
      print('✓ Purchase service initialized');

      // Check for pending purchases
      await _checkPendingPurchases();
    } catch (e) {
      print('✗ Error initializing purchase service: $e');
    }
  }

  /// Handle purchase updates from stream
  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    for (final PurchaseDetails purchase in purchases) {
      if (purchase.productID == AppConstants.premiumProductId) {
        await _handlePremiumPurchase(purchase);
      }

      // Complete purchase if needed
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  /// Handle premium unlock purchase
  Future<void> _handlePremiumPurchase(PurchaseDetails purchase) async {
    switch (purchase.status) {
      case PurchaseStatus.purchased:
        print('✓ Premium purchase successful');
        await _savePremiumStatus(true);
        onPurchaseSuccess?.call();
        onPremiumStatusChanged?.call(true);
        break;

      case PurchaseStatus.restored:
        print('✓ Premium purchase restored');
        await _savePremiumStatus(true);
        onPurchaseSuccess?.call();
        onPremiumStatusChanged?.call(true);
        break;

      case PurchaseStatus.error:
        print('✗ Purchase error: ${purchase.error}');
        onPurchaseError?.call(purchase.error?.message ?? 'Purchase failed');
        break;

      case PurchaseStatus.pending:
        print('⏳ Purchase pending');
        onPurchasePending?.call();
        break;

      case PurchaseStatus.canceled:
        print('Purchase canceled by user');
        onPurchaseCanceled?.call();
        break;
    }
  }

  /// Check for pending purchases on app start
  Future<void> _checkPendingPurchases() async {
    try {
      final QueryPurchaseDetailsResponse response = await _iap.restorePurchases();

      for (final PurchaseDetails purchase in response.pastPurchases) {
        if (purchase.productID == AppConstants.premiumProductId) {
          if (purchase.status == PurchaseStatus.purchased ||
              purchase.status == PurchaseStatus.restored) {
            await _savePremiumStatus(true);
            print('✓ Found existing premium purchase');
          }
        }
      }
    } catch (e) {
      print('✗ Error checking pending purchases: $e');
    }
  }

  /// Check if user is premium
  Future<bool> isPremiumUser() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      final bool isPremium = prefs.getBool(AppConstants.keyIsPremium) ?? false;

      // Cross-verify with Play Store
      if (isPremium) {
        await _verifyPremiumWithStore();
      }

      return isPremium;
    } catch (e) {
      print('✗ Error checking premium status: $e');
      return false;
    }
  }

  /// Verify premium status with store
  Future<void> _verifyPremiumWithStore() async {
    try {
      final QueryPurchaseDetailsResponse response = await _iap.restorePurchases();
      bool foundPremium = false;

      for (final PurchaseDetails purchase in response.pastPurchases) {
        if (purchase.productID == AppConstants.premiumProductId &&
            (purchase.status == PurchaseStatus.purchased ||
                purchase.status == PurchaseStatus.restored)) {
          foundPremium = true;
          break;
        }
      }

      if (!foundPremium) {
        print('⚠️ Premium status mismatch - local says premium but store says not');
        // Trust the store
        await _savePremiumStatus(false);
        onPremiumStatusChanged?.call(false);
      }
    } catch (e) {
      print('✗ Error verifying premium with store: $e');
    }
  }

  /// Save premium status to SharedPreferences
  Future<void> _savePremiumStatus(bool isPremium) async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool(AppConstants.keyIsPremium, isPremium);
      print('✓ Saved premium status: $isPremium');
    } catch (e) {
      print('✗ Error saving premium status: $e');
    }
  }

  /// Purchase premium upgrade
  Future<void> purchasePremium() async {
    try {
      // Query product details
      final ProductDetailsResponse response = await _iap.queryProductDetails(
        {AppConstants.premiumProductId},
      );

      if (response.notFoundIDs.isNotEmpty) {
        print('✗ Premium product not found');
        onPurchaseError?.call('Premium product not available');
        return;
      }

      if (response.productDetails.isEmpty) {
        print('✗ No product details available');
        onPurchaseError?.call('Unable to load product details');
        return;
      }

      final ProductDetails productDetails = response.productDetails.first;

      // Create purchase param
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      // Initiate purchase (non-consumable)
      print('Initiating premium purchase...');
      final bool success = await _iap.buyNonConsumable(
        purchaseParam: purchaseParam,
      );

      if (!success) {
        print('✗ Failed to initiate purchase');
        onPurchaseError?.call('Failed to initiate purchase');
      }
    } catch (e) {
      print('✗ Error purchasing premium: $e');
      onPurchaseError?.call('Error: ${e.toString()}');
    }
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    try {
      print('Restoring purchases...');
      await _iap.restorePurchases();

      // Check if premium was restored
      final bool isPremium = await isPremiumUser();

      if (isPremium) {
        print('✓ Premium restored successfully');
        onPurchaseSuccess?.call();
        onPremiumStatusChanged?.call(true);
      } else {
        print('No premium purchase found to restore');
        onPurchaseError?.call('No past purchases found');
      }
    } catch (e) {
      print('✗ Error restoring purchases: $e');
      onPurchaseError?.call('Error restoring purchases');
    }
  }

  /// Get product details for display
  Future<ProductDetails?> getProductDetails() async {
    try {
      final ProductDetailsResponse response = await _iap.queryProductDetails(
        {AppConstants.premiumProductId},
      );

      if (response.productDetails.isNotEmpty) {
        return response.productDetails.first;
      }
      return null;
    } catch (e) {
      print('✗ Error fetching product details: $e');
      return null;
    }
  }

  /// Dispose service
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _isInitialized = false;
  }
}
