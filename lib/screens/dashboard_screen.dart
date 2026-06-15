import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/analyzer_provider.dart';
import '../widgets/metric_card.dart';
import '../widgets/glass_card.dart';
import 'detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AnalyzerProvider>(context);
    final data = provider.dashboardData;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Insights Dashboard',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 22.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            'High-level overview of "${provider.activeKeyword}" publications',
            style: const TextStyle(
              color: Color(0xFF64748B),
              fontSize: 13.0,
            ),
          ),
          const SizedBox(height: 20.0),

          // 2x2 Grid for standard numeric metrics
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 12.0,
            mainAxisSpacing: 12.0,
            childAspectRatio: 1.25,
            children: [
              MetricCard(
                title: 'TOTAL WORKS',
                value: data.totalPublications.toString(),
                subtitle: 'Analyzed publications',
                icon: Icons.article_rounded,
                iconColor: const Color(0xFF6366F1),
              ),
              MetricCard(
                title: 'AVG CITATIONS',
                value: data.averageCitationCount.toStringAsFixed(1),
                subtitle: 'Citations per paper',
                icon: Icons.star_rounded,
                iconColor: const Color(0xFFF59E0B),
              ),
              MetricCard(
                title: 'ACTIVE YEAR',
                value: data.mostActiveYear > 0 ? data.mostActiveYear.toString() : 'N/A',
                subtitle: 'Peak publication volume',
                icon: Icons.trending_up_rounded,
                iconColor: const Color(0xFF10B981),
              ),
              MetricCard(
                title: 'TOP AUTHOR',
                value: data.topAuthor,
                subtitle: '${data.topAuthorCount} contributions',
                icon: Icons.person_rounded,
                iconColor: const Color(0xFFEC4899),
              ),
            ],
          ),
          const SizedBox(height: 12.0),

          // Full width Top Journal Card
          GlassCard(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10.0),
                  decoration: BoxDecoration(
                    color: const Color(0xFF06B6D4).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.source_rounded, color: Color(0xFF06B6D4), size: 22.0),
                ),
                const SizedBox(width: 14.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DOMINANT JOURNAL / VENUE',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 10.0,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        data.topJournal,
                        style: const TextStyle(
                          color: Color(0xFF0F172A),
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2.0),
                      Text(
                        'Total of ${data.topJournalCount} papers in recent results',
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20.0),

          // Most Influential Paper Card
          if (data.mostInfluentialPaper != null) ...[
            const Text(
              'Most Influential Publication',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10.0),
            GlassCard(
              padding: const EdgeInsets.all(16.0),
              borderColor: const Color(0xFFF59E0B).withOpacity(0.3),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DetailScreen(work: data.mostInfluentialPaper!),
                  ),
                );
              },
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.workspace_premium_rounded, color: Color(0xFFF59E0B), size: 20.0),
                      const SizedBox(width: 8.0),
                      Text(
                        '${data.mostInfluentialPaper!.citationCount} Citations',
                        style: const TextStyle(
                          color: Color(0xFFF59E0B),
                          fontWeight: FontWeight.bold,
                          fontSize: 13.0,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10.0),
                  Text(
                    data.mostInfluentialPaper!.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 14.0,
                      fontWeight: FontWeight.bold,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 6.0),
                  Text(
                    data.mostInfluentialPaper!.authors.isNotEmpty
                        ? data.mostInfluentialPaper!.authors.join(', ')
                        : 'Unknown Authors',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF6366F1),
                      fontSize: 12.0,
                    ),
                  ),
                  const SizedBox(height: 10.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          data.mostInfluentialPaper!.journalName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11.0,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Read paper details →',
                        style: TextStyle(
                          color: Color(0xFF6366F1),
                          fontSize: 11.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
