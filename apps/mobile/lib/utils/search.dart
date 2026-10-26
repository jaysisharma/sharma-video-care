/// Lower-cases and turns punctuation into spaces. Devanagari letters are kept
/// so Nepali text can be searched too.
String normalizeSearch(String text) =>
    text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9ऀ-ॿ]+'), ' ').trim();

/// Like [normalizeSearch] but with no separators at all, so model numbers match
/// however they're typed: "F1.8", "f/1.8" and "f 1.8" all become "f18".
String _compact(String text) => text.toLowerCase().replaceAll(RegExp(r'[^a-z0-9ऀ-ॿ]+'), '');

/// The words of a query, split on whitespace only so "f/1.8" stays one word.
List<String> searchTerms(String query) =>
    query.trim().split(RegExp(r'\s+')).where((t) => _compact(t).isNotEmpty).toList();

/// Relevance of an item for [query]; 0 means it doesn't match.
///
/// Every word of the query must appear somewhere in [fields] (plural words
/// also match their singular, so "lenses" finds "Lens"). The first field is
/// the item's name: words found there, especially at the start of a word,
/// rank the item higher.
int searchScore(String query, List<String?> fields) {
  final terms = searchTerms(query);
  if (terms.isEmpty || fields.isEmpty) return 0;
  final name = ' ${normalizeSearch(fields.first ?? '')}';
  final all = ' ${fields.map((f) => normalizeSearch(f ?? '')).join(' ')}';
  final compactName = _compact(fields.first ?? '');
  final compactAll = fields.map((f) => _compact(f ?? '')).join(' ');

  var score = 0;
  for (final term in terms) {
    final variant = _matchingVariant(normalizeSearch(term), all);
    if (variant != null) {
      if (name.startsWith(' $variant')) {
        score += 4;
      } else if (name.contains(' $variant')) {
        score += 3;
      } else if (name.contains(variant)) {
        score += 2;
      } else {
        score += 1;
      }
      continue;
    }
    // Fall back to ignoring separators (model numbers like f/1.8, A7-IV)
    final compactTerm = _compact(term);
    if (compactName.contains(compactTerm)) {
      score += 2;
    } else if (compactAll.contains(compactTerm)) {
      score += 1;
    } else {
      return 0;
    }
  }
  return score;
}

String? _matchingVariant(String term, String haystack) {
  if (haystack.contains(term)) return term;
  if (term.length > 3) {
    if (term.endsWith('es') && haystack.contains(term.substring(0, term.length - 2))) {
      return term.substring(0, term.length - 2);
    }
    if (term.endsWith('s') && haystack.contains(term.substring(0, term.length - 1))) {
      return term.substring(0, term.length - 1);
    }
  }
  return null;
}

/// Items matching [query], best first. Ties keep their original order.
List<T> rankSearch<T>(String query, Iterable<T> items, List<String?> Function(T) fields) {
  final scored = <({T item, int score, int index})>[];
  var index = 0;
  for (final item in items) {
    final score = searchScore(query, fields(item));
    if (score > 0) scored.add((item: item, score: score, index: index));
    index++;
  }
  scored.sort((a, b) => b.score != a.score ? b.score.compareTo(a.score) : a.index.compareTo(b.index));
  return [for (final s in scored) s.item];
}
