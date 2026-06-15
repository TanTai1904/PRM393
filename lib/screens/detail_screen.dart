import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/work.dart';
import '../widgets/glass_card.dart';

class DetailScreen extends StatelessWidget {
  final Work work;

  const DetailScreen({Key? key, required this.work}) : super(key: key);

  Future<void> _launchDOI(BuildContext context) async {
    if (work.doi.isEmpty) return;
    
    final Uri url = Uri.parse(work.doi);
    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
        throw Exception('Could not launch DOI link');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open DOI link: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Publication Details',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Publication Title
              Text(
                work.title,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16.0),

              // 2. Metadata Cards (Year, Citations)
              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'PUBLISHED IN',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          Text(
                            work.publicationYear > 0 ? work.publicationYear.toString() : 'N/A',
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'CITATIONS',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6.0),
                          Text(
                            work.citationCount.toString(),
                            style: const TextStyle(
                              color: Color(0xFFF59E0B),
                              fontSize: 16.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // 3. Journal Info
              GlassCard(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                        color: const Color(0xFF06B6D4).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.source_rounded, color: Color(0xFF06B6D4), size: 20.0),
                    ),
                    const SizedBox(width: 14.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'JOURNAL / SOURCE',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 10.0,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4.0),
                          Text(
                            work.journalName,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16.0),

              // 4. Authors section
              if (work.authors.isNotEmpty) ...[
                const Text(
                  'Authors',
                  style: TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                GlassCard(
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: work.authors.length,
                    separatorBuilder: (context, index) => const Divider(color: Color(0xFFE2E8F0)),
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0),
                        child: Row(
                          children: [
                            const Icon(Icons.person_outline_rounded, color: Color(0xFF818CF8), size: 18.0),
                            const SizedBox(width: 10.0),
                            Expanded(
                              child: Text(
                                work.authors[index],
                                style: const TextStyle(
                                  color: Color(0xFF334155),
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 20.0),
              ],

              // 5. Abstract
              const Text(
                'Abstract',
                style: TextStyle(
                  color: Color(0xFF0F172A),
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              GlassCard(
                child: Text(
                  work.abstractText,
                  style: const TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 14.0,
                    height: 1.6,
                  ),
                ),
              ),
              const SizedBox(height: 24.0),

              // 6. DOI Link Button
              if (work.doi.isNotEmpty) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _launchDOI(context),
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('Open Publisher Link (DOI)', style: TextStyle(fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
