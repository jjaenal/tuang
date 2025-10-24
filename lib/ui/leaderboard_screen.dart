import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/leaderboard_service.dart';
import '../state/app_settings_cubit.dart';
import 'components/neumorphic_button.dart';
import 'theme/app_theme.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// Screen untuk menampilkan leaderboard dengan top scores
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  String _query = '';
  bool _showAll = false; // false = top 10, true = top 50

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final leaderboard = LeaderboardService();
    final currentPlayerId = context.read<AppSettingsCubit>().state.playerName;
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<void>(
      future: leaderboard.ensureLoaded(),
      builder: (context, snapshot) {
        final loaded = snapshot.connectionState == ConnectionState.done;
        final fullTop50 =
            loaded
                ? leaderboard.topScores(limit: 50)
                : const <LeaderboardEntry>[];
        List<LeaderboardEntry> visible = const <LeaderboardEntry>[];
        if (loaded) {
          visible = _showAll ? fullTop50 : fullTop50.take(10).toList();
          if (_query.isNotEmpty) {
            final qLower = _query.toLowerCase();
            visible =
                visible
                    .where((e) => e.playerId.toLowerCase().contains(qLower))
                    .toList();
          }
        }
        final currentRank = loaded ? leaderboard.rankOf(currentPlayerId) : null;
        final lastSubmittedId =
            loaded ? leaderboard.lastSubmittedPlayerId : null;

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.leaderboardTitle),
            backgroundColor: AppTheme.darkBase,
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                child: SizedBox(
                  width: 120,
                  child: NeumorphicButton(
                    label:
                        _showAll
                            ? l10n.leaderboardToggleTop50
                            : l10n.leaderboardToggleTop10,
                    icon: _showAll ? Icons.list_alt : Icons.filter_1,
                    onPressed:
                        loaded
                            ? () => setState(() => _showAll = !_showAll)
                            : null,
                    primary: false,
                    size: ButtonSize.compact,
                    // width: 120,
                    // height: 36,
                  ),
                ),
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(gradient: AppTheme.darkGradient),
            child:
                !loaded
                    ? const Center(
                      child: CircularProgressIndicator(color: Colors.amber),
                    )
                    : fullTop50.isEmpty
                    ? const Center(
                      child: Text(
                        'Belum ada skor yang tercatat',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    )
                    : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: TextField(
                            controller: _searchCtrl,
                            onChanged: (v) => setState(() => _query = v.trim()),
                            style: const TextStyle(color: Colors.white),
                            decoration: InputDecoration(
                              hintText: l10n.leaderboardSearchHint,
                              hintStyle: TextStyle(
                                color: Colors.white.withAlpha(153),
                              ),
                              filled: true,
                              fillColor: AppTheme.darkBase.withAlpha(200),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: AppTheme.lightBorderColor,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: AppTheme.lightBorderColor,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: const BorderSide(
                                  color: Colors.lightBlueAccent,
                                ),
                              ),
                              suffixIcon:
                                  _query.isNotEmpty
                                      ? IconButton(
                                        icon: const Icon(
                                          Icons.clear,
                                          color: Colors.white70,
                                        ),
                                        onPressed: () {
                                          _searchCtrl.clear();
                                          setState(() => _query = '');
                                        },
                                      )
                                      : const Icon(
                                        Icons.search,
                                        color: Colors.white70,
                                      ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: visible.length,
                            itemBuilder: (context, index) {
                              final entry = visible[index];
                              // Rank global dihitung dari posisi di fullTop50
                              final globalRank =
                                  fullTop50.indexWhere(
                                    (e) => e.playerId == entry.playerId,
                                  ) +
                                  1;
                              final initial =
                                  entry.playerId.isNotEmpty
                                      ? entry.playerId[0].toUpperCase()
                                      : '?';
                              final isTop3 = globalRank <= 3;
                              final isCurrent =
                                  entry.playerId == currentPlayerId;
                              final isLastSubmitted =
                                  entry.playerId == lastSubmittedId;

                              final medalColor = _getMedalColor(globalRank - 1);
                              final borderColor =
                                  isCurrent
                                      ? Colors.lightBlueAccent
                                      : isLastSubmitted
                                      ? Colors.greenAccent
                                      : medalColor;
                              final bgColor =
                                  isCurrent
                                      ? Colors.deepPurple.shade700
                                      : isLastSubmitted
                                      ? Colors.green.shade700
                                      : Colors.black54;

                              return Card(
                                margin: const EdgeInsets.symmetric(vertical: 8),
                                color: bgColor,
                                elevation:
                                    (isTop3 || isCurrent || isLastSubmitted)
                                        ? 8
                                        : 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  side: BorderSide(
                                    color: borderColor,
                                    width:
                                        (isTop3 || isCurrent || isLastSubmitted)
                                            ? 2
                                            : 1,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: medalColor,
                                    foregroundColor: Colors.white,
                                    child: Text(
                                      initial,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  title: Text(
                                    '#$globalRank · ${entry.playerId}',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                  subtitle: Text(
                                    _buildSubtitle(
                                      l10n: l10n,
                                      isCurrent: isCurrent,
                                      isLastSubmitted: isLastSubmitted,
                                      lastUpdatedMs: entry.lastUpdatedMs,
                                    ),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                  trailing: Text(
                                    '${entry.score}',
                                    style: TextStyle(
                                      color: medalColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        if (!_showAll &&
                            currentRank != null &&
                            currentRank > 10)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Card(
                              color: Colors.black87,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: const BorderSide(
                                  color: Colors.lightBlueAccent,
                                  width: 2,
                                ),
                              ),
                              child: ListTile(
                                leading: const CircleAvatar(
                                  backgroundColor: Colors.lightBlueAccent,
                                  foregroundColor: Colors.white,
                                  child: Text('•'),
                                ),
                                title: Text(
                                  currentPlayerId,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  l10n.leaderboardYourPosition(currentRank),
                                  style: const TextStyle(color: Colors.white70),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
          ),
        );
      },
    );
  }

  String _buildSubtitle({
    required AppLocalizations l10n,
    required bool isCurrent,
    required bool isLastSubmitted,
    required int lastUpdatedMs,
  }) {
    final updated = _formatDate(lastUpdatedMs);
    if (isCurrent && isLastSubmitted) {
      return l10n.leaderboardSubtitleYouLastUpdated(updated);
    }
    if (isCurrent) {
      return l10n.leaderboardSubtitleYouLastUpdated(updated);
    }
    if (isLastSubmitted) {
      return l10n.leaderboardSubtitleLastSubmitted(updated);
    }
    return l10n.leaderboardSubtitleLastUpdated(updated);
  }

  String _formatDate(int ms) {
    final dt = DateTime.fromMillisecondsSinceEpoch(ms).toLocal();
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hh = dt.hour.toString().padLeft(2, '0');
    final mm = dt.minute.toString().padLeft(2, '0');
    return '$y-$m-$d $hh:$mm';
  }

  /// Mendapatkan warna medal berdasarkan posisi (0-based untuk top 3)
  Color _getMedalColor(int position) {
    switch (position) {
      case 0:
        return Colors.amber; // Gold
      case 1:
        return Colors.grey.shade300; // Silver
      case 2:
        return Colors.brown.shade300; // Bronze
      default:
        return Colors.deepPurple.shade300; // Regular
    }
  }
}
