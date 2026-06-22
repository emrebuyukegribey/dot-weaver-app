import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/game_data_manager.dart';
import '../services/purchase_service.dart';

/// How many ad-free level completions before the FIRST "Remove Ads" upsell.
const int _firstPromoAfter = 3;

/// After the first one, show it again every this many ad-free completions.
const int _promoEveryN = 10;

/// DEBUG ONLY: when true, the modal is allowed to appear even if no purchasable
/// product is configured (the store-availability gate is skipped) so it can be
/// previewed on an emulator/simulator. MUST be false for release builds.
const bool _debugForcePromo = true;

/// Shows the "Remove Ads" upsell modal occasionally, respecting a cadence so the
/// user isn't nagged. Call this on a level completion ONLY when an interstitial
/// was not shown (to avoid stacking two popups). No-op when ads are already
/// removed or the store/product isn't available.
Future<void> maybeShowRemoveAdsPromo(BuildContext context) async {
  if (GameDataManager().removeAds) return;

  final ps = PurchaseService();
  final storeReady = ps.storeAvailable && ps.removeAdsProduct != null;
  if (!storeReady && !_debugForcePromo) return;

  await GameDataManager().incrementPromoCompletions();
  final completions = GameDataManager().promoCompletions;
  final shownBefore = GameDataManager().promoShownCount;
  final threshold = shownBefore == 0 ? _firstPromoAfter : _promoEveryN;
  if (completions < threshold) return;

  await GameDataManager().markPromoShown();
  if (!context.mounted) return;
  await showRemoveAdsPromo(context);
}

/// Shows the upsell modal immediately (used by [maybeShowRemoveAdsPromo]).
Future<void> showRemoveAdsPromo(BuildContext context) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black87,
    builder: (_) => const _RemoveAdsPromoDialog(),
  );
}

class _RemoveAdsPromoDialog extends StatefulWidget {
  const _RemoveAdsPromoDialog();

  @override
  State<_RemoveAdsPromoDialog> createState() => _RemoveAdsPromoDialogState();
}

class _RemoveAdsPromoDialogState extends State<_RemoveAdsPromoDialog> {
  bool _busy = false;

  Future<void> _buy() async {
    setState(() => _busy = true);
    final started = await PurchaseService().buyRemoveAds();
    if (!mounted) return;
    setState(() => _busy = false);
    // The actual grant arrives asynchronously via the purchase stream; closing
    // here keeps the flow snappy. If it couldn't start, tell the user.
    if (started) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Purchase could not be started. Please try again.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final price = PurchaseService().removeAdsPrice;
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Container(
        padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const RadialGradient(
            center: Alignment.topCenter,
            radius: 1.4,
            colors: [Color(0xFF1B2A4A), Color(0xFF0A0A18)],
          ),
          border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.3), width: 1.5),
          boxShadow: [
            BoxShadow(color: Colors.cyanAccent.withValues(alpha: 0.2), blurRadius: 30, spreadRadius: 2),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.amberAccent.withValues(alpha: 0.12),
              ),
              child: const Icon(Icons.block_rounded, color: Colors.amberAccent, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              'GO AD-FREE',
              style: GoogleFonts.orbitron(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enjoy Dot Weaver with no banners and no interruptions.',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 18),
            _benefit('Remove the bottom banner'),
            _benefit('No full-screen ads between levels'),
            _benefit('One-time purchase, forever'),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _busy ? null : _buy,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _busy
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(
                        price.isNotEmpty ? 'Remove Ads  •  $price' : 'Remove Ads',
                        style: GoogleFonts.orbitron(fontWeight: FontWeight.w700, fontSize: 15),
                      ),
              ),
            ),
            TextButton(
              onPressed: _busy ? null : () => Navigator.of(context).pop(),
              child: Text(
                'Maybe later',
                style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _benefit(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(text, style: GoogleFonts.poppins(color: Colors.white, fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
