import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseManager {
  static final PurchaseManager instance = PurchaseManager._internal();
  final _iap = InAppPurchase.instance;
  final _entitlementStorage = const FlutterSecureStorage();

  static const _removeAdsId = 'remove_ads';
  static const _premiumPackId = 'premium_pack';
  static const _hintBundleId = 'hints_10';
  static const _monthlySubId = 'monthly_sub';

  final Queue<String> _purchaseQueue = Queue();
  bool _processing = false;

  final Map<String, ProductDetails> _productDetails = {};

  PurchaseManager._internal();

  Future<void> initialize() async {
    final bool available = await _iap.isAvailable();
    if (!available) return;
    _iap.purchaseStream.listen(_onPurchaseUpdated, onDone: () {}, onError: (e) {
      debugPrint('Purchase stream error: $e');
    });

    // Fetch product details
    final ProductDetailsResponse response = await _iap.queryProductDetails({_removeAdsId, _premiumPackId, _hintBundleId, _monthlySubId});
    if (response.error != null) {
      debugPrint('Product detail error: ${response.error}');
    } else {
      for (final d in response.productDetails) {
        _productDetails[d.id] = d;
      }
    }

    await _restorePurchases();
  }

  Future<void> buyRemoveAds() async => _enqueue(_removeAdsId);
  Future<void> buyPremiumPack() async => _enqueue(_premiumPackId);
  Future<void> buyHintBundle() async => _enqueue(_hintBundleId);
  Future<void> buyMonthlySub() async => _enqueue(_monthlySubId);

  bool isEntitled(String productId) => _entitlements.contains(productId);

  // Secure storage entitlements
  final Set<String> _entitlements = {};

  Future<void> _restorePurchases() async {
    await _iap.restorePurchases();
    final cached = await _entitlementStorage.read(key: 'entitlements');
    if (cached != null) {
      _entitlements.addAll(cached.split(','));
    }
  }

  void _saveEntitlements() {
    _entitlementStorage.write(key: 'entitlements', value: _entitlements.join(','));
  }

  void _enqueue(String productId) {
    _purchaseQueue.add(productId);
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_processing) return;
    if (_purchaseQueue.isEmpty) return;
    _processing = true;
    final productId = _purchaseQueue.removeFirst();
    final details = _productDetails[productId];
    if (details == null) {
      debugPrint('Unknown product: $productId');
      _processing = false;
      return;
    }
    final param = PurchaseParam(productDetails: details);
    await _iap.buyNonConsumable(purchaseParam: param);
    _processing = false;
    if (_purchaseQueue.isNotEmpty) _processQueue();
  }

  void _onPurchaseUpdated(List<PurchaseDetails> detailsList) {
    for (final details in detailsList) {
      switch (details.status) {
        case PurchaseStatus.purchased:
        case PurchaseStatus.restored:
          _verifyPurchase(details);
          break;
        case PurchaseStatus.error:
          debugPrint('Purchase error: ${details.error}');
          break;
        case PurchaseStatus.canceled:
        case PurchaseStatus.pending:
          break;
      }
    }
  }

  Future<void> _verifyPurchase(PurchaseDetails details) async {
    // TODO: implement receipt validation with server if needed.
    debugPrint('Verified purchase: ${details.productID}');
    _entitlements.add(details.productID);
    _saveEntitlements();
    if (details.pendingCompletePurchase) {
      await _iap.completePurchase(details);
    }
  }
}