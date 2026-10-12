int levenshtein(String a, String b) {
  a = a.toLowerCase().trim();
  b = b.toLowerCase().trim();
  if (a == b) return 0;
  if (a.isEmpty) return b.length;
  if (b.isEmpty) return a.length;
  var prev = List<int>.generate(b.length + 1, (j) => j);
  for (var i = 1; i <= a.length; i++) {
    final cur = List<int>.filled(b.length + 1, 0)..[0] = i;
    for (var j = 1; j <= b.length; j++) {
      final cost = a[i - 1] == b[j - 1] ? 0 : 1;
      final best = [prev[j] + 1, cur[j - 1] + 1, prev[j - 1] + cost]
          .reduce((x, y) => x < y ? x : y);
      cur[j] = best;
    }
    prev = cur;
  }
  return prev[b.length];
}

/// Mengurutkan item dari yang paling mirip dengan [query].
List<MapEntry<T, int>> rankByDistance<T>(
  String query,
  Iterable<T> items,
  String Function(T) label,
) {
  final ranked = [for (final i in items) MapEntry(i, levenshtein(query, label(i)))];
  ranked.sort((a, b) => a.value.compareTo(b.value));
  return ranked;
}
