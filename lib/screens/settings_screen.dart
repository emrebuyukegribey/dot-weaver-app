import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/game_data_manager.dart';
import '../services/purchase_service.dart';

/// _TODO_REAL_IDS: replace with your hosted privacy policy URL before release.
const String kPrivacyPolicyUrl = 'https://example.com/dot-weaver/privacy';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _soundEnabled;
  String _version = '';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _soundEnabled = GameDataManager().soundEnabled;
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() => _version = 'v${info.version} (${info.buildNumber})');
      }
    } catch (_) {
      if (mounted) setState(() => _version = '');
    }
  }

  Future<void> _toggleSound(bool value) async {
    setState(() => _soundEnabled = value);
    await GameDataManager().setSoundEnabled(value);
  }

  Future<void> _buyRemoveAds() async {
    setState(() => _busy = true);
    final ps = PurchaseService();
    final started = await ps.buyRemoveAds();
    if (mounted) setState(() => _busy = false);
    if (!started && mounted) {
      _showSnack(ps.storeAvailable
          ? 'Purchase could not be started. Please try again.'
          : 'Store is unavailable right now.');
    }
  }

  Future<void> _restore() async {
    setState(() => _busy = true);
    await PurchaseService().restorePurchases();
    if (mounted) {
      setState(() => _busy = false);
      _showSnack('Restore requested. Purchases will update automatically.');
    }
  }

  Future<void> _openPrivacy() async {
    final uri = Uri.parse(kPrivacyPolicyUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) _showSnack('Could not open the privacy policy.');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.blueGrey.shade900,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'SETTINGS',
          style: GoogleFonts.orbitron(
            fontWeight: FontWeight.w800,
            letterSpacing: 2,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topCenter,
            radius: 1.4,
            colors: [Color(0xFF11203A), Color(0xFF050510)],
          ),
        ),
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _sectionTitle('MONETIZATION'),
              _buildRemoveAdsCard(),
              const SizedBox(height: 24),
              _sectionTitle('PREFERENCES'),
              _buildCard(
                child: SwitchListTile(
                  value: _soundEnabled,
                  onChanged: _toggleSound,
                  activeThumbColor: Colors.cyanAccent,
                  contentPadding: EdgeInsets.zero,
                  secondary: Icon(
                    _soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                    color: Colors.cyanAccent,
                  ),
                  title: _tileText('Sound effects'),
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle('ABOUT'),
              _buildCard(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.privacy_tip_rounded, color: Colors.cyanAccent),
                      title: _tileText('Privacy policy'),
                      trailing: const Icon(Icons.open_in_new_rounded,
                          color: Colors.white54, size: 18),
                      onTap: _openPrivacy,
                    ),
                    const Divider(color: Colors.white12, height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.info_outline_rounded, color: Colors.cyanAccent),
                      title: _tileText('Version'),
                      trailing: Text(
                        _version,
                        style: GoogleFonts.orbitron(color: Colors.white54, fontSize: 13),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRemoveAdsCard() {
    return ValueListenableBuilder<bool>(
      valueListenable: PurchaseService().adsRemoved,
      builder: (context, removed, _) {
        if (removed) {
          return _buildCard(
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, color: Colors.greenAccent),
                const SizedBox(width: 12),
                Expanded(child: _tileText('Ads removed. Thank you!')),
              ],
            ),
          );
        }
        final price = PurchaseService().removeAdsPrice;
        return _buildCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.block_rounded, color: Colors.amberAccent),
                  const SizedBox(width: 12),
                  Expanded(child: _tileText('Remove Ads')),
                  if (price.isNotEmpty)
                    Text(
                      price,
                      style: GoogleFonts.orbitron(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _busy ? null : _buyRemoveAds,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.cyan.shade700,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _busy
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white),
                            )
                          : const Text('Buy'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _busy ? null : _restore,
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white24),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('Restore'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        text,
        style: GoogleFonts.orbitron(
          color: Colors.white38,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          letterSpacing: 2,
        ),
      ),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      // Give ListTiles their own (transparent) Material ancestor so their ink
      // splashes aren't hidden by the card's decorated background.
      child: Material(
        type: MaterialType.transparency,
        child: child,
      ),
    );
  }

  Widget _tileText(String text) {
    return Text(
      text,
      style: GoogleFonts.poppins(
        color: Colors.white,
        fontSize: 15,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
