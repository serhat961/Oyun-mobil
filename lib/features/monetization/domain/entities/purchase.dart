import 'package:equatable/equatable.dart';

enum PurchaseType {
  removeAds,
  premiumLanguages,
  hintBundle,
  monthlySubscription,
}

enum PurchaseStatus {
  pending,
  purchased,
  restored,
  failed,
  cancelled,
}

class Purchase extends Equatable {
  final String id;
  final PurchaseType type;
  final String productId;
  final double price;
  final String currency;
  final PurchaseStatus status;
  final DateTime purchaseDate;
  final DateTime? expiryDate;
  final String? transactionId;
  final String? receipt;
  final bool isConsumable;
  final int? quantity;

  const Purchase({
    required this.id,
    required this.type,
    required this.productId,
    required this.price,
    required this.currency,
    required this.status,
    required this.purchaseDate,
    this.expiryDate,
    this.transactionId,
    this.receipt,
    required this.isConsumable,
    this.quantity,
  });

  static const Map<PurchaseType, String> productIds = {
    PurchaseType.removeAds: 'com.polyglot.remove_ads',
    PurchaseType.premiumLanguages: 'com.polyglot.premium_languages',
    PurchaseType.hintBundle: 'com.polyglot.hint_bundle_10',
    PurchaseType.monthlySubscription: 'com.polyglot.monthly_subscription',
  };

  static const Map<PurchaseType, double> prices = {
    PurchaseType.removeAds: 4.99,
    PurchaseType.premiumLanguages: 9.99,
    PurchaseType.hintBundle: 1.99,
    PurchaseType.monthlySubscription: 7.99,
  };

  static const Map<PurchaseType, bool> consumables = {
    PurchaseType.removeAds: false,
    PurchaseType.premiumLanguages: false,
    PurchaseType.hintBundle: true,
    PurchaseType.monthlySubscription: false,
  };

  bool get isActive {
    if (status != PurchaseStatus.purchased) return false;
    
    if (type == PurchaseType.monthlySubscription && expiryDate != null) {
      return DateTime.now().isBefore(expiryDate!);
    }
    
    return true;
  }

  bool get needsRenewal {
    if (type != PurchaseType.monthlySubscription) return false;
    if (expiryDate == null) return false;
    
    final daysUntilExpiry = expiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 3;
  }

  Purchase copyWith({
    String? id,
    PurchaseType? type,
    String? productId,
    double? price,
    String? currency,
    PurchaseStatus? status,
    DateTime? purchaseDate,
    DateTime? expiryDate,
    String? transactionId,
    String? receipt,
    bool? isConsumable,
    int? quantity,
  }) {
    return Purchase(
      id: id ?? this.id,
      type: type ?? this.type,
      productId: productId ?? this.productId,
      price: price ?? this.price,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      expiryDate: expiryDate ?? this.expiryDate,
      transactionId: transactionId ?? this.transactionId,
      receipt: receipt ?? this.receipt,
      isConsumable: isConsumable ?? this.isConsumable,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  List<Object?> get props => [
        id,
        type,
        productId,
        price,
        currency,
        status,
        purchaseDate,
        expiryDate,
        transactionId,
        receipt,
        isConsumable,
        quantity,
      ];
}

class AdConfig extends Equatable {
  final bool showBannerAds;
  final bool showInterstitialAds;
  final bool showRewardedAds;
  final DateTime? lastInterstitialShown;
  final int interstitialCooldownMinutes;

  const AdConfig({
    this.showBannerAds = true,
    this.showInterstitialAds = true,
    this.showRewardedAds = true,
    this.lastInterstitialShown,
    this.interstitialCooldownMinutes = 5,
  });

  bool get canShowInterstitial {
    if (!showInterstitialAds) return false;
    if (lastInterstitialShown == null) return true;
    
    final timeSinceLastAd = DateTime.now().difference(lastInterstitialShown!);
    return timeSinceLastAd.inMinutes >= interstitialCooldownMinutes;
  }

  AdConfig copyWith({
    bool? showBannerAds,
    bool? showInterstitialAds,
    bool? showRewardedAds,
    DateTime? lastInterstitialShown,
    int? interstitialCooldownMinutes,
  }) {
    return AdConfig(
      showBannerAds: showBannerAds ?? this.showBannerAds,
      showInterstitialAds: showInterstitialAds ?? this.showInterstitialAds,
      showRewardedAds: showRewardedAds ?? this.showRewardedAds,
      lastInterstitialShown: lastInterstitialShown ?? this.lastInterstitialShown,
      interstitialCooldownMinutes: interstitialCooldownMinutes ?? this.interstitialCooldownMinutes,
    );
  }

  @override
  List<Object?> get props => [
        showBannerAds,
        showInterstitialAds,
        showRewardedAds,
        lastInterstitialShown,
        interstitialCooldownMinutes,
      ];
}