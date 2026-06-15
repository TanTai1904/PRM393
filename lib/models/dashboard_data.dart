import 'work.dart';

class DashboardData {
  final int totalPublications;
  final double averageCitationCount;
  final int mostActiveYear;
  final String topJournal;
  final int topJournalCount;
  final String topAuthor;
  final int topAuthorCount;
  final Work? mostInfluentialPaper;

  DashboardData({
    required this.totalPublications,
    required this.averageCitationCount,
    required this.mostActiveYear,
    required this.topJournal,
    required this.topJournalCount,
    required this.topAuthor,
    required this.topAuthorCount,
    this.mostInfluentialPaper,
  });

  factory DashboardData.fromWorks(List<Work> works) {
    if (works.isEmpty) {
      return DashboardData(
        totalPublications: 0,
        averageCitationCount: 0.0,
        mostActiveYear: 0,
        topJournal: 'N/A',
        topJournalCount: 0,
        topAuthor: 'N/A',
        topAuthorCount: 0,
        mostInfluentialPaper: null,
      );
    }

    final total = works.length;

    // Citations
    int totalCitations = 0;
    Work? influentialPaper;
    int maxCitations = -1;

    for (var w in works) {
      totalCitations += w.citationCount;
      if (w.citationCount > maxCitations) {
        maxCitations = w.citationCount;
        influentialPaper = w;
      }
    }
    final avgCitations = total > 0 ? totalCitations / total : 0.0;

    // Years
    final Map<int, int> yearCounts = {};
    for (var w in works) {
      if (w.publicationYear > 0) {
        yearCounts[w.publicationYear] = (yearCounts[w.publicationYear] ?? 0) + 1;
      }
    }
    int activeYear = 0;
    int maxYearCount = -1;
    yearCounts.forEach((year, count) {
      if (count > maxYearCount) {
        maxYearCount = count;
        activeYear = year;
      }
    });

    // Journals
    final Map<String, int> journalCounts = {};
    for (var w in works) {
      if (w.journalName.isNotEmpty && w.journalName != 'Unknown Source') {
        journalCounts[w.journalName] = (journalCounts[w.journalName] ?? 0) + 1;
      }
    }
    String topJ = 'N/A';
    int maxJCount = 0;
    journalCounts.forEach((jName, count) {
      if (count > maxJCount) {
        maxJCount = count;
        topJ = jName;
      }
    });

    // Authors
    final Map<String, int> authorCounts = {};
    for (var w in works) {
      for (var author in w.authors) {
        if (author.isNotEmpty) {
          authorCounts[author] = (authorCounts[author] ?? 0) + 1;
        }
      }
    }
    String topAuth = 'N/A';
    int maxAuthCount = 0;
    authorCounts.forEach((aName, count) {
      if (count > maxAuthCount) {
        maxAuthCount = count;
        topAuth = aName;
      }
    });

    return DashboardData(
      totalPublications: total,
      averageCitationCount: avgCitations,
      mostActiveYear: activeYear,
      topJournal: topJ,
      topJournalCount: maxJCount,
      topAuthor: topAuth,
      topAuthorCount: maxAuthCount,
      mostInfluentialPaper: influentialPaper,
    );
  }
}
