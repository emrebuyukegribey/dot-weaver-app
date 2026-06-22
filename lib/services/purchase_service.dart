import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'ad_service.dart';
import 'game_data_manager.dart';

/// Handles the single non-consumable "Remove Ads" in-app purchase, including
/// restoring previous purchases.
///
/// _TODO_REAL_IDS: create a non-consumable product with this exact ID in both
/// Google Play Console and App Store Connect.
class PurchaseService {
  PurchaseService._internal();
  static final PurchaseService _instance = PurchaseService._internal();
  factory PurchaseService() => _instance;

  static const String removeAdsProductId = 'remove_ads';

  final InAppPurchase _iap = InAppPurchase.instance;
  StreamSubscription<List<PurchaseDetails>>? _sub;
  ProductDetails? _removeAdsProduct;
  bool _available = false;

  /// Notifies listeners (e.g. settings screen, banner) when the ad-removal state
  /// changes. Reflects the unified [GameDataManager.adFree] (IAP OR remote grant).
  final ValueNotifier<bool> adsRemoved =
      ValueNotifier<bool>(GameDataManager().adFree);

  bool get storeAvailable => _available;
  ProductDetails? get removeAdsProduct => _removeAdsProduct;

  /// Human-readable localized price, or a sensible fallback.
  String get removeAdsPrice => _removeAdsProduct?.price ?? '';

  Future<void> initialize() async {
    try {
      _available = await _iap.isAvailable();
      if (!_available) return;

      _sub = _iap.purchaseStream.listen(
        _onPurchaseUpdated,
        onError: (Object e) => debugPrint('Purchase stream error: $e'),
      );

      final response =
          await _iap.queryProductDetails({removeAdsProductId});
      if (response.productDetails.isNotEmpty) {
        _removeAdsProduct = response.productDetails.first;
      }

      // Silently restore non-consumable purchases on launch so a reinstall (or
      // a fresh device) re-grants "Remove Ads" without the user having to tap
      // Restore manually. Restored purchases arrive via [_onPurchaseUpdated].
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('PurchaseService init failed: $e');
      _available = false;
    }
  }

  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchases) async {
    for (final purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        if (purchase.productID == removeAdsProductId) {
          await _grantRemoveAds();
        }
      }
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
    }
  }

  Future<void> _grantRemoveAds() async {
    await GameDataManager().setRemoveAds(true);
    adsRemoved.value = true;
    AdService().onAdsRemoved();
  }

  /// Applies a server-granted entitlement (from the admin panel) for this device.
  /// Updates the cached flag and notifies listeners. An existing IAP purchase is
  /// preserved (the unified [GameDataManager.adFree] is an OR), so a remote
  /// `false` never re-enables ads for someone who paid.
  Future<void> applyRemoteEntitlement(bool premium) async {
    if (GameDataManager().remotePremium == premium) return;
    await GameDataManager().setRemotePremium(premium);
    final adFree = GameDataManager().adFree;
    adsRemoved.value = adFree;
    if (adFree) AdService().onAdsRemoved();
  }

  /// Starts the purchase flow for "Remove Ads". Returns false if it could not
  /// be started (store unavailable / product missing).
  Future<bool> buyRemoveAds() async {
    if (!_available || _removeAdsProduct == null) return false;
    try {
      final param = PurchaseParam(productDetails: _removeAdsProduct!);
      return await _iap.buyNonConsumable(purchaseParam: param);
    } catch (e) {
      debugPrint('buyRemoveAds failed: $e');
      return false;
    }
  }

  /// Restores previous non-consumable purchases.
  Future<void> restorePurchases() async {
    if (!_available) return;
    try {
      await _iap.restorePurchases();
    } catch (e) {
      debugPrint('restorePurchases failed: $e');
    }
  }

  void dispose() {
    _sub?.cancel();
  }
}
