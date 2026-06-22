import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import '../services/device_id_service.dart';
import '../services/game_data_manager.dart';
import '../services/locale_controller.dart';
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
  String _deviceId = '';
  String _username = '';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _soundEnabled = GameDataManager().soundEnabled;
    _username = GameDataManager().username;
    _loadVersion();
    _loadDeviceId();
  }

  Future<void> _loadDeviceId() async {
    final id = await DeviceIdService().getDeviceId();
    if (mounted) setState(() => _deviceId = id);
  }

  void _copyDeviceId() {
    if (_deviceId.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _deviceId));
    _showSnack(AppLocalizations.of(context).deviceIdCopied);
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
    final t = AppLocalizations.of(context);
    setState(() => _busy = true);
    final ps = PurchaseService();
    final started = await ps.buyRemoveAds();
    if (mounted) setState(() => _busy = false);
    if (!started && mounted) {
      _showSnack(ps.storeAvailable ? t.purchaseCouldNotStart : t.storeUnavailable);
    }
  }

  Future<void> _restore() async {
    final t = AppLocalizations.of(context);
    setState(() => _busy = true);
    await PurchaseService().restorePurchases();
    if (mounted) {
      setState(() => _busy = false);
      _showSnack(t.restoreRequested);
    }
  }

  Future<void> _openPrivacy() async {
    final t = AppLocalizations.of(context);
    final uri = Uri.parse(kPrivacyPolicyUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) _showSnack(t.couldNotOpenPrivacy);
  }

  Future<void> _editUsername() async {
    final t = AppLocalizations.of(context);
    final controller = TextEditingController(text: _username);
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF141426),
        title: Text(t.changeUsername, style: GoogleFonts.orbitron(color: Colors.white, fontSize: 16)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 16,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            counterStyle: const TextStyle(color: Colors.white38),
            hintText: t.usernameInvalid,
            hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
            enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
            focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.cyanAccent)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.cancel)),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(t.save),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty || name == _username) return;

    setState(() => _busy = true);
    final err = await ApiService().setUsername(name);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (err == null) _username = GameDataManager().username;
    });
    _showSnack(switch (err) {
      null => t.usernameUpdated,
      'taken' => t.usernameTaken,
      'invalid' => t.usernameInvalid,
      _ => t.usernameOffline,
    });
  }

  /// Supported languages shown in their own native name. `null` = follow device.
  static const Map<String, String> _languageNames = {
    'en': 'English',
    'tr': 'Türkçe',
    'es': 'Español',
    'de': 'Deutsch',
    'fr': 'Français',
    'pt': 'Português',
    'it': 'Italiano',
  };

  Future<void> _pickLanguage() async {
    final t = AppLocalizations.of(context);
    final current = GameDataManager().localeCode;
    final choice = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: const Color(0xFF141426),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _langTile(ctx, t.languageSystem, '__system__', current == null),
              for (final e in _languageNames.entries)
                _langTile(ctx, e.value, e.key, current == e.key),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
    if (choice == null) return;
    await LocaleController().setLocale(choice == '__system__' ? null : choice);
    if (mounted) setState(() {});
  }

  Widget _langTile(BuildContext ctx, String label, String value, bool selected) {
    return ListTile(
      title: Text(label, style: GoogleFonts.poppins(color: Colors.white, fontSize: 15)),
      trailing: selected ? const Icon(Icons.check_rounded, color: Colors.cyanAccent) : null,
      onTap: () => Navigator.pop(ctx, value),
    );
  }

  String _languageLabel(AppLocalizations t) =>
      _languageNames[GameDataManager().localeCode] ?? t.languageSystem;

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
    final t = AppLocalizations.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF050510),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          t.settingsTitle,
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
              _sectionTitle(t.sectionMonetization),
              _buildRemoveAdsCard(t),
              const SizedBox(height: 24),
              _sectionTitle(t.sectionAccount),
              _buildCard(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.person_rounded, color: Colors.cyanAccent),
                      title: _tileText(t.username),
                      subtitle: Text(
                        _username.isEmpty ? '—' : _username,
                        style: GoogleFonts.orbitron(color: Colors.white54, fontSize: 13),
                      ),
                      trailing: const Icon(Icons.edit_rounded, color: Colors.white54, size: 18),
                      onTap: _busy ? null : _editUsername,
                    ),
                    const Divider(color: Colors.white12, height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.perm_device_information_rounded, color: Colors.cyanAccent),
                      title: _tileText(t.deviceId),
                      subtitle: Text(
                        _deviceId.isEmpty ? '…' : _deviceId,
                        style: GoogleFonts.robotoMono(color: Colors.white54, fontSize: 12),
                      ),
                      trailing: const Icon(Icons.copy_rounded, color: Colors.white54, size: 18),
                      onTap: _copyDeviceId,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle(t.sectionPreferences),
              _buildCard(
                child: Column(
                  children: [
                    SwitchListTile(
                      value: _soundEnabled,
                      onChanged: _toggleSound,
                      activeThumbColor: Colors.cyanAccent,
                      contentPadding: EdgeInsets.zero,
                      secondary: Icon(
                        _soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                        color: Colors.cyanAccent,
                      ),
                      title: _tileText(t.soundEffects),
                    ),
                    const Divider(color: Colors.white12, height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.language_rounded, color: Colors.cyanAccent),
                      title: _tileText(t.language),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_languageLabel(t),
                              style: GoogleFonts.poppins(color: Colors.white54, fontSize: 13)),
                          const SizedBox(width: 4),
                          const Icon(Icons.chevron_right_rounded, color: Colors.white38),
                        ],
                      ),
                      onTap: _pickLanguage,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _sectionTitle(t.sectionAbout),
              _buildCard(
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.privacy_tip_rounded, color: Colors.cyanAccent),
                      title: _tileText(t.privacyPolicy),
                      trailing: const Icon(Icons.open_in_new_rounded,
                          color: Colors.white54, size: 18),
                      onTap: _openPrivacy,
                    ),
                    const Divider(color: Colors.white12, height: 1),
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.info_outline_rounded, color: Colors.cyanAccent),
                      title: _tileText(t.version),
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

  Widget _buildRemoveAdsCard(AppLocalizations t) {
    return ValueListenableBuilder<bool>(
      valueListenable: PurchaseService().adsRemoved,
      builder: (context, removed, _) {
        if (removed) {
          return _buildCard(
            child: Row(
              children: [
                const Icon(Icons.verified_rounded, color: Colors.greenAccent),
                const SizedBox(width: 12),
                Expanded(child: _tileText(t.adsRemovedThanks)),
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
                  Expanded(child: _tileText(t.removeAds)),
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
                          : Text(t.buy),
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
                      child: Text(t.restore),
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
