class LeaderboardEntry {
  final int rank;
  final String username;
  final int totalStars;
  final bool isYou;

  const LeaderboardEntry({
    required this.rank,
    required this.username,
    required this.totalStars,
    this.isYou = false,
  });

  factory LeaderboardEntry.fromJson(Map<String, dynamic> j) => LeaderboardEntry(
        rank: (j['rank'] as num).toInt(),
        username: (j['username'] ?? '') as String,
        totalStars: (j['totalStars'] as num).toInt(),
        isYou: j['isYou'] == true,
      );
}

class LeaderboardData {
  final List<LeaderboardEntry> top;
  final LeaderboardEntry? you;

  const LeaderboardData({required this.top, this.you});

  factory LeaderboardData.fromJson(Map<String, dynamic> j) => LeaderboardData(
        top: ((j['top'] as List?) ?? [])
            .map((e) => LeaderboardEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
        you: j['you'] == null
            ? null
            : LeaderboardEntry.fromJson(j['you'] as Map<String, dynamic>),
      );
}
