import 'package:flutter_test/flutter_test.dart';
import 'package:journal_trend_analyzer/models/work.dart';
import 'package:journal_trend_analyzer/models/dashboard_data.dart';

void main() {
  group('Journal Trend Analyzer Unit Tests', () {
    test('Work Model - Reconstructs abstract from inverted index correctly', () {
      final sampleJson = {
        'id': 'https://openalex.org/W12345678',
        'title': 'Test Scholarly Work Title',
        'publication_year': 2024,
        'cited_by_count': 42,
        'doi': 'https://doi.org/10.1000/xyz123',
        'primary_location': {
          'source': {
            'display_name': 'Journal of Mobile Development',
          }
        },
        'authorships': [
          {
            'author': {
              'display_name': 'John Doe',
            }
          },
          {
            'author': {
              'display_name': 'Jane Smith',
            }
          }
        ],
        'abstract_inverted_index': {
          'Flutter': [0, 4],
          'is': [1],
          'great': [2],
          'for': [3],
          'apps.': [5]
        }
      };

      final work = Work.fromJson(sampleJson);

      expect(work.title, 'Test Scholarly Work Title');
      expect(work.publicationYear, 2024);
      expect(work.citationCount, 42);
      expect(work.journalName, 'Journal of Mobile Development');
      expect(work.authors, containsAll(['John Doe', 'Jane Smith']));
      expect(work.doi, 'https://doi.org/10.1000/xyz123');
      
      // Verification of reconstructed abstract
      // Index mapping:
      // 0: Flutter
      // 1: is
      // 2: great
      // 3: for
      // 4: Flutter
      // 5: apps.
      expect(work.abstractText, 'Flutter is great for Flutter apps.');
    });

    test('DashboardData - Computes aggregations accurately', () {
      final work1 = Work(
        id: '1',
        title: 'Paper A',
        publicationYear: 2022,
        citationCount: 10,
        doi: 'doi1',
        journalName: 'IEEE Transactions',
        authors: ['Author 1', 'Author 2'],
        abstractText: 'Abstract A',
      );

      final work2 = Work(
        id: '2',
        title: 'Paper B',
        publicationYear: 2022,
        citationCount: 20,
        doi: 'doi2',
        journalName: 'ACM Queue',
        authors: ['Author 2', 'Author 3'],
        abstractText: 'Abstract B',
      );

      final work3 = Work(
        id: '3',
        title: 'Paper C',
        publicationYear: 2023,
        citationCount: 30,
        doi: 'doi3',
        journalName: 'IEEE Transactions',
        authors: ['Author 1', 'Author 3', 'Author 4'],
        abstractText: 'Abstract C',
      );

      final dashboard = DashboardData.fromWorks([work1, work2, work3]);

      expect(dashboard.totalPublications, 3);
      expect(dashboard.averageCitationCount, 20.0); // (10 + 20 + 30) / 3
      expect(dashboard.mostActiveYear, 2022); // 2022 has 2 papers, 2023 has 1
      expect(dashboard.topJournal, 'IEEE Transactions'); // appears 2 times
      expect(dashboard.topJournalCount, 2);
      
      // Top author can be Author 1, 2, or 3 (they all appear twice).
      // Let's assert they are in the list of contributors.
      expect(['Author 1', 'Author 2', 'Author 3'], contains(dashboard.topAuthor));
      expect(dashboard.topAuthorCount, 2);
      
      // Most influential should be Paper C (30 citations)
      expect(dashboard.mostInfluentialPaper?.title, 'Paper C');
    });
  });
}
