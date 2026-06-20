import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../services/ad_service.dart';
import '../services/purchase_service.dart';

/// A self-managing anchored banner. Renders nothing when ads are disabled
/// (e.g. after the "Remove Ads" purchase) or while/if the ad fails to load.
/// Listens to the purchase state so it disappears immediately after the user
/// removes ads, even without leaving the current screen.
class AdBanner extends StatefulWidget {
  const AdBanner({super.key});

  @override
  State<AdBanner> createState() => _AdBannerState();
}

class _AdBannerState extends State<AdBanner> {
  BannerAd? _banner;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    PurchaseService().adsRemoved.addListener(_onAdsRemovedChanged);
    _createBanner();
  }

  void _createBanner() {
    _banner = AdService().createBanner(
      onLoaded: () {
        if (mounted) setState(() => _loaded = true);
      },
    );
  }

  void _onAdsRemovedChanged() {
    if (PurchaseService().adsRemoved.value && mounted) {
      setState(() {
        _banner?.dispose();
        _banner = null;
        _loaded = false;
      });
    }
  }

  @override
  void dispose() {
    PurchaseService().adsRemoved.removeListener(_onAdsRemovedChanged);
    _banner?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ad = _banner;
    if (ad == null || !_loaded) return const SizedBox.shrink();
    return SafeArea(
      top: false,
      child: SizedBox(
        width: ad.size.width.toDouble(),
        height: ad.size.height.toDouble(),
        child: AdWidget(ad: ad),
      ),
    );
  }
}
