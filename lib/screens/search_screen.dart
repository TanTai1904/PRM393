import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../providers/analyzer_provider.dart';
import 'settings_screen.dart';
import 'detail_screen.dart';
import 'dashboard_screen.dart';
import 'trend_screen.dart';
import '../widgets/glass_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  int _currentTabIndex = 0;

  final List<String> _suggestedTopics = [
    'Artificial Intelligence',
    'Software Engineering',
    'Data Science',
    'Cybersecurity',
    'Internet of Things',
    'Blockchain',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize provider and load settings
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AnalyzerProvider>(context, listen: false).initialize();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _triggerSearch(String keyword) {
    if (keyword.trim().isEmpty) return;
    FocusScope.of(context).unfocus();
    _searchController.text = keyword;
    Provider.of<AnalyzerProvider>(context, listen: false).searchTopic(keyword);
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<AnalyzerProvider>(context);

    // If a search is active, show the tabbed navigation interface
    if (provider.activeKeyword.isNotEmpty && !provider.isLoading && provider.errorMessage == null) {
      return Scaffold(
        appBar: AppBar(
          elevation: 1.5,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                provider.activeKeyword,
                style: const TextStyle(
                  color: Color(0xFF0F172A),
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
              const Text(
                'OpenAlex Analytical Dashboard',
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11.0,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.settings_rounded, color: Color(0xFF0F172A)),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Color(0xFFEF4444)),
              onPressed: () {
                provider.clearSearch();
                setState(() {
                  _currentTabIndex = 0;
                });
              },
            ),
          ],
        ),
        body: IndexedStack(
          index: _currentTabIndex,
          children: [
            _buildResultsList(provider),
            const DashboardScreen(),
            const TrendScreen(),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: const Color(0xFFE2E8F0),
                width: 1.0,
              ),
            ),
          ),
          child: BottomNavigationBar(
            currentIndex: _currentTabIndex,
            onTap: (index) {
              setState(() {
                _currentTabIndex = index;
              });
            },
            backgroundColor: Colors.white,
            selectedItemColor: const Color(0xFF6366F1),
            unselectedItemColor: const Color(0xFF64748B),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.library_books_rounded),
                label: 'Publications',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_rounded),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.insights_rounded),
                label: 'Trend Analysis',
              ),
            ],
          ),
        ),
      );
    }

    // Default screen: Search inputs & history
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.auto_graph_rounded, color: Color(0xFF6366F1)),
            SizedBox(width: 8.0),
            Text(
              'Journal Trend Analyzer',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Color(0xFF0F172A)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12.0),
              // Search Input Box
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(
                    color: const Color(0xFFCBD5E1),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 16.0),
                    const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        style: const TextStyle(color: Color(0xFF0F172A)),
                        textInputAction: TextInputAction.search,
                        onSubmitted: (val) => _triggerSearch(val),
                        decoration: const InputDecoration(
                          hintText: 'Search topic or keyword (e.g. IoT)...',
                          hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(vertical: 16.0),
                        ),
                      ),
                    ),
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear_rounded, color: Color(0xFF64748B)),
                        onPressed: () {
                          setState(() {
                            _searchController.clear();
                          });
                        },
                      ),
                    const SizedBox(width: 4.0),
                    IconButton(
                      icon: const Icon(Icons.arrow_forward_rounded, color: Color(0xFF6366F1)),
                      onPressed: () => _triggerSearch(_searchController.text),
                    ),
                    const SizedBox(width: 8.0),
                  ],
                ),
              ),
              const SizedBox(height: 24.0),

              // Dynamic Main View (Loader, Error, History, Suggestions)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (provider.isLoading) ...[
                        const SizedBox(height: 100),
                        Center(
                          child: GlassCard(
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const SpinKitRing(
                                  color: Color(0xFF6366F1),
                                  size: 50.0,
                                  lineWidth: 4.0,
                                ),
                                const SizedBox(height: 20.0),
                                Text(
                                  'Analyzing topic:\n"${provider.activeKeyword}"',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8.0),
                                const Text(
                                  'Retrieving data from OpenAlex...',
                                  style: TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ] else if (provider.errorMessage != null) ...[
                        const SizedBox(height: 40),
                        _buildErrorCard(provider),
                      ] else ...[
                        _buildTopicSuggestions(),
                        const SizedBox(height: 30.0),
                        _buildRecentHistory(provider),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Topics',
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 16.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12.0),
        Wrap(
          spacing: 10.0,
          runSpacing: 10.0,
          children: _suggestedTopics.map((topic) {
            return InkWell(
              onTap: () => _triggerSearch(topic),
              borderRadius: BorderRadius.circular(30.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(30.0),
                  border: Border.all(
                    color: const Color(0xFF6366F1).withOpacity(0.25),
                    width: 1.0,
                  ),
                ),
                child: Text(
                  topic,
                  style: const TextStyle(
                    color: Color(0xFF4F46E5),
                    fontSize: 13.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecentHistory(AnalyzerProvider provider) {
    if (provider.recentSearches.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recent Searches',
              style: TextStyle(
                color: Color(0xFF0F172A),
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () => provider.clearHistory(),
              child: const Text(
                'Clear All',
                style: TextStyle(color: Color(0xFFEF4444), fontSize: 13.0),
              ),
            ),
          ],
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: provider.recentSearches.length,
          separatorBuilder: (context, index) => const Divider(color: Color(0xFFE2E8F0)),
          itemBuilder: (context, index) {
            final item = provider.recentSearches[index];
            return ListTile(
              leading: const Icon(Icons.history_rounded, color: Color(0xFF64748B)),
              title: Text(
                item,
                style: const TextStyle(color: Color(0xFF334155), fontSize: 14.0),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8)),
              onTap: () => _triggerSearch(item),
              contentPadding: EdgeInsets.zero,
            );
          },
        ),
      ],
    );
  }

  Widget _buildErrorCard(AnalyzerProvider provider) {
    final isApiKeyError = provider.errorMessage!.contains('API Key');

    return GlassCard(
      borderColor: const Color(0xFFEF4444).withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: Color(0xFFEF4444),
            size: 48,
          ),
          const SizedBox(height: 16.0),
          const Text(
            'Analysis Request Failed',
            style: TextStyle(
              color: Color(0xFF0F172A),
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12.0),
          Text(
            provider.errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF475569),
              fontSize: 14.0,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24.0),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    provider.clearSearch();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    foregroundColor: const Color(0xFF475569),
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  child: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    if (isApiKeyError) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const SettingsScreen()),
                      );
                    } else {
                      provider.searchTopic(provider.activeKeyword);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  ),
                  child: Text(isApiKeyError ? 'Go to Settings' : 'Retry'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList(AnalyzerProvider provider) {
    if (provider.works.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.hourglass_empty_rounded, color: Color(0xFF64748B), size: 48),
            const SizedBox(height: 16),
            const Text(
              'No publications found for this topic.',
              style: TextStyle(color: Color(0xFF0F172A), fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => provider.clearSearch(),
              child: const Text('Search again'),
            )
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: provider.works.length,
      itemBuilder: (context, index) {
        final work = provider.works[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12.0),
          child: GlassCard(
            padding: const EdgeInsets.all(16.0),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailScreen(work: work),
                ),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  work.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF0F172A),
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 8.0),
                if (work.authors.isNotEmpty) ...[
                  Text(
                    work.authors.join(', '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF4F46E5),
                      fontSize: 12.0,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12.0),
                ],
                Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(Icons.source_rounded, size: 14.0, color: Color(0xFF64748B)),
                          const SizedBox(width: 4.0),
                          Expanded(
                            child: Text(
                              work.journalName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF64748B),
                                fontSize: 11.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Row(
                      children: [
                        const Icon(Icons.calendar_month_rounded, size: 14.0, color: Color(0xFF64748B)),
                        const SizedBox(width: 4.0),
                        Text(
                          work.publicationYear > 0 ? work.publicationYear.toString() : 'N/A',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 11.0,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 12.0),
                    Row(
                      children: [
                        const Icon(Icons.star_rounded, size: 14.0, color: Color(0xFFF59E0B)),
                        const SizedBox(width: 4.0),
                        Text(
                          work.citationCount.toString(),
                          style: const TextStyle(
                            color: Color(0xFFF59E0B),
                            fontSize: 11.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
