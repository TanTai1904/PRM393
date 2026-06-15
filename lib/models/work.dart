class Work {
  final String id;
  final String title;
  final int publicationYear;
  final int citationCount;
  final String doi;
  final String journalName;
  final List<String> authors;
  final String abstractText;

  Work({
    required this.id,
    required this.title,
    required this.publicationYear,
    required this.citationCount,
    required this.doi,
    required this.journalName,
    required this.authors,
    required this.abstractText,
  });

  factory Work.fromJson(Map<String, dynamic> json) {
    // 1. Reconstruct Abstract from inverted index
    final invertedIndex = json['abstract_inverted_index'] as Map<String, dynamic>?;
    final reconstructedAbstract = _reconstructAbstract(invertedIndex);

    // 2. Extract Journal/Source name
    String sourceName = 'Unknown Source';
    final primaryLocation = json['primary_location'] as Map<String, dynamic>?;
    if (primaryLocation != null) {
      final source = primaryLocation['source'] as Map<String, dynamic>?;
      if (source != null && source['display_name'] != null) {
        sourceName = source['display_name'].toString();
      }
    }

    // 3. Extract Authors
    final List<String> authorList = [];
    final authorships = json['authorships'] as List<dynamic>?;
    if (authorships != null) {
      for (var auth in authorships) {
        final author = auth['author'] as Map<String, dynamic>?;
        if (author != null && author['display_name'] != null) {
          authorList.add(author['display_name'].toString());
        }
      }
    }

    return Work(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled',
      publicationYear: json['publication_year'] as int? ?? 0,
      citationCount: json['cited_by_count'] as int? ?? 0,
      doi: json['doi']?.toString() ?? '',
      journalName: sourceName,
      authors: authorList,
      abstractText: reconstructedAbstract,
    );
  }

  static String _reconstructAbstract(Map<String, dynamic>? invertedIndex) {
    if (invertedIndex == null || invertedIndex.isEmpty) {
      return 'No abstract available.';
    }

    int maxIndex = -1;
    invertedIndex.forEach((word, indices) {
      if (indices is List) {
        for (var index in indices) {
          if (index is int && index > maxIndex) {
            maxIndex = index;
          }
        }
      }
    });

    if (maxIndex == -1) return 'No abstract available.';

    final List<String?> words = List.filled(maxIndex + 1, null);
    invertedIndex.forEach((word, indices) {
      if (indices is List) {
        for (var index in indices) {
          if (index is int && index >= 0 && index <= maxIndex) {
            words[index] = word;
          }
        }
      }
    });

    return words.map((w) => w ?? '').join(' ').trim();
  }
}
