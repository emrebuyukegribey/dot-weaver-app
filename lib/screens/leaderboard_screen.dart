import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../l10n/app_localizations.dart';
import '../models/leaderboard.dart';
import '../services/api_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  bool _loading = true;
  LeaderboardData? _data;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final data = await ApiService().fetchLeaderboard();
    if (!mounted) return;
    setState(() {
      _data = data;
      _loading = false;
    });
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
          t.leaderboardTitle,
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
        child: SafeArea(child: _body(t)),
      ),
    );
  }

  Widget _body(AppLocalizations t) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator(color: Colors.cyanAccent));
    }
    final data = _data;
    if (data == null) {
      return _message(t.leaderboardOffline, showRetry: true, t: t);
    }
    if (data.top.isEmpty) {
      return _message(t.leaderboardEmpty, showRetry: false, t: t);
    }

    // If the player isn't visible in the fetched top list, pin their rank on top.
    final you = data.you;
    final youInList = data.top.any((e) => e.isYou);

    return Column(
      children: [
        if (you != null && !youInList) _youHeader(t, you),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Row(
            children: [
              SizedBox(width: 44, child: _hdr(t.rank)),
              Expanded(child: _hdr(t.player)),
              _hdr(t.stars),
            ],
          ),
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: _load,
            color: Colors.cyanAccent,
            backgroundColor: const Color(0xFF141426),
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
              itemCount: data.top.length,
              itemBuilder: (_, i) => _row(data.top[i], t),
            ),
          ),
        ),
      ],
    );
  }

  Widget _hdr(String s) => Text(
        s.toUpperCase(),
        style: GoogleFonts.orbitron(
          color: Colors.white38,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1,
        ),
      );

  Widget _youHeader(AppLocalizations t, LeaderboardEntry you) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: Colors.cyan.withValues(alpha: 0.12),
        border: Border.all(color: Colors.cyanAccent.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Text('${t.yourRank}: ',
              style: GoogleFonts.poppins(color: Colors.white70, fontSize: 14)),
          Text('#${you.rank}',
              style: GoogleFonts.orbitron(
                  color: Colors.cyanAccent, fontWeight: FontWeight.w800, fontSize: 16)),
          const Spacer(),
          Text('${you.totalStars}',
              style: GoogleFonts.orbitron(
                  color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 16)),
          const SizedBox(width: 4),
          const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 18),
        ],
      ),
    );
  }

  Widget _row(LeaderboardEntry e, AppLocalizations t) {
    final highlight = e.isYou;
    final medal = e.rank <= 3;
    final medalColor = e.rank == 1
        ? const Color(0xFFFFD700)
        : e.rank == 2
            ? const Color(0xFFB0BEC5)
            : const Color(0xFFCD7F32);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: highlight ? Colors.cyan.withValues(alpha: 0.15) : Colors.white.withValues(alpha: 0.04),
        border: Border.all(
          color: highlight ? Colors.cyanAccent.withValues(alpha: 0.5) : Colors.white.withValues(alpha: 0.06),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: medal
                ? Icon(Icons.emoji_events_rounded, color: medalColor, size: 22)
                : Text('${e.rank}',
                    style: GoogleFonts.orbitron(
                        color: Colors.white60, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              highlight ? '${e.username}  (${t.you})' : e.username,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 15,
                fontWeight: highlight ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Text('${e.totalStars}',
              style: GoogleFonts.orbitron(
                  color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(width: 4),
          const Icon(Icons.star_rounded, color: Color(0xFFFFD700), size: 18),
        ],
      ),
    );
  }

  Widget _message(String msg, {required bool showRetry, required AppLocalizations t}) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.leaderboard_rounded, color: Colors.white24, size: 56),
            const SizedBox(height: 16),
            Text(msg,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white70, fontSize: 15)),
            if (showRetry) ...[
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _load,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.cyan.shade700,
                  foregroundColor: Colors.white,
                ),
                child: Text(t.retry),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
