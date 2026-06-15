import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analyzer_provider.dart';
import '../widgets/trend_chart.dart';
import '../widgets/glass_card.dart';

class TrendScreen extends StatelessWidget {
  const TrendScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AnalyzerProvider>(context);

    // 1. Compute Top Journals locally from search results
    final Map<String, int> journalCounts = {};
    for (var w in provider.works) {
      if (w.journalName.isNotEmpty && w.journalName != 'Unknown Source') {
        journalCounts[w.journalName] = (journalCounts[w.journalName] ?? 0) + 1;
      }
    }
    final sortedJournals = journalCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topJournals = sortedJournals.take(5).toList();

    // 2. Compute Top Authors locally from search results
    final Map<String, int> authorCounts = {};
    for (var w in provider.works) {
      for (var author in w.authors) {
        if (author.isNotEmpty) {
          authorCounts[author] = (authorCounts[author] ?? 0) + 1;
        }
      }
    }
    final sortedAuthors = authorCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final topAuthors = sortedAuthors.take(5).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Trend & Aggregations',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'Visualized publication data for "${provider.activeKeyword}"',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13.0,
            ),
          ),
          const SizedBox(height: 20.0),

          // 1. Publication Trend Graph
          TrendChart(trendData: provider.trendData),
          const SizedBox(height: 24.0),

          // 2. Top Contributing Authors Section
          const Text(
            'Top Contributing Authors',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12.0),
          if (topAuthors.isEmpty)
            const GlassCard(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No authors found.', style: TextStyle(color: Color(0xFF64748B))),
                ),
              ),
            )
          else
            _buildRankedList(topAuthors, isAuthor: true),

          const SizedBox(height: 24.0),

          // 3. Top Journals Section
          const Text(
            'Top Research Venues / Journals',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12.0),
          if (topJournals.isEmpty)
            const GlassCard(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text('No journals found.', style: TextStyle(color: Color(0xFF64748B))),
                ),
              ),
            )
          else
            _buildRankedList(topJournals, isAuthor: false),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  Widget _buildRankedList(List<MapEntry<String, int>> items, {required bool isAuthor}) {
    final maxVal = items.first.value;

    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: items.length,
        separatorBuilder: (context, index) => const Divider(color: Color(0xFFE2E8F0), height: 16),
        itemBuilder: (context, index) {
          final entry = items[index];
          final rank = index + 1;
          
          // Color badge based on rank (1st Gold, 2nd Silver, 3rd Bronze, others Slate)
          Color rankBadgeColor;
          if (rank == 1) {
            rankBadgeColor = const Color(0xFFF59E0B); // Gold
          } else if (rank == 2) {
            rankBadgeColor = const Color(0xFF94A3B8); // Silver
          } else if (rank == 3) {
            rankBadgeColor = const Color(0xFFB45309); // Bronze
          } else {
            rankBadgeColor = const Color(0xFFE2E8F0);
          }

          final pct = maxVal > 0 ? entry.value / maxVal : 0.0;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Rank Badge
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: rankBadgeColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          rank.toString(),
                          style: TextStyle(
                            color: rank <= 3 ? Colors.black : const Color(0xFF475569),
                            fontWeight: FontWeight.bold,
                            fontSize: 12.0,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    // Item Name
                    Expanded(
                      child: Text(
                        entry.key,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    // Count indicator
                    Text(
                      '${entry.value} ${isAuthor ? 'papers' : 'works'}',
                      style: TextStyle(
                        color: isAuthor ? const Color(0xFFEC4899) : const Color(0xFF06B6D4),
                        fontWeight: FontWeight.bold,
                        fontSize: 13.0,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8.0),
                // Premium horizontal relative distribution indicator bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    height: 5,
                    width: double.infinity,
                    color: const Color(0xFFF1F5F9),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: FractionallySizedBox(
                        widthFactor: pct,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: isAuthor
                                  ? [const Color(0xFFEC4899), const Color(0xFF8B5CF6)]
                                  : [const Color(0xFF06B6D4), const Color(0xFF6366F1)],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
