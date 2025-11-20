bool isPersianText(String value) {
  return RegExp(r'[اآءؤئپچژکگ‌ی]').hasMatch(value);
}

String normalizeCityText(String value) {
  return value
      .trim()
      .toLowerCase()
      .replaceAll('ي', 'ی')
      .replaceAll('ك', 'ک')
      .replaceAll(RegExp(r'\s+'), ' ');
}

String buildCityLabel(Map<String, dynamic> city, {String lang = 'en'}) {
  final name = lang == 'fa' 
    ? (city['local_names']?['fa'] ?? city['name'] ?? '').toString()
    : (city['name'] ?? '').toString();
  final country = (city['country'] ?? '').toString();
  final state = (city['state'] ?? '').toString();

  final parts = <String>[];
  if (name.isNotEmpty) parts.add(name);
  if (state.isNotEmpty && state != name) parts.add(state);
  if (country.isNotEmpty) parts.add(country);

  return parts.join(', ');
}

int scoreCityCandidate(Map<String, dynamic> city, String query) {
  final normalizedQuery = normalizeCityText(query);
  final name = normalizeCityText((city['name'] ?? '').toString());
  final localFa = normalizeCityText((city['local_names']?['fa'] ?? '').toString());
  final state = normalizeCityText((city['state'] ?? '').toString());
  final country = (city['country'] ?? '').toString().toLowerCase();

  int score = 0;

  bool matches(String value) => value.contains(normalizedQuery) && normalizedQuery.isNotEmpty;

  if (normalizedQuery.isNotEmpty) {
    if (name == normalizedQuery || (localFa.isNotEmpty && localFa == normalizedQuery)) {
      score += 1000;
    } else if (name.startsWith(normalizedQuery) || (localFa.isNotEmpty && localFa.startsWith(normalizedQuery))) {
      score += 600;
    } else if (matches(name) || matches(localFa)) {
      score += 300;
    }
  }

  if (state.isNotEmpty && normalizedQuery.contains(state)) {
    score += 120;
  }
  if (country.isNotEmpty && normalizedQuery.contains(country)) {
    score += 80;
  }

  final population = (city['population'] as num?)?.toInt();
  if (population != null) {
    score += (population ~/ 100000).clamp(0, 200);
  }

  final distance = (city['distance'] ?? city['distance_km']) as num?;
  if (distance != null) {
    score -= distance.clamp(0, 500).toInt();
  }

  return score;
}

List<Map<String, dynamic>> sortAndDeduplicateCities(
  List<Map<String, dynamic>> cities,
  String query, {
  int maxItems = 10,
}) {
  if (cities.isEmpty || maxItems <= 0) return const [];

  final normalizedQuery = normalizeCityText(query);
  final Map<String, Map<String, dynamic>> bestCandidates = {};

  for (final city in cities) {
    final key = '${(city['name'] ?? '').toString().toLowerCase()}|${(city['country'] ?? '').toString().toLowerCase()}';
    final score = scoreCityCandidate(city, normalizedQuery);
    final candidate = Map<String, dynamic>.from(city)..['_score'] = score;

    final existing = bestCandidates[key];
    final existingScore = existing?['_score'] as int? ?? -1;
    if (existing == null || score > existingScore) {
      bestCandidates[key] = candidate;
    }
  }

  final sorted = bestCandidates.values.toList()
    ..sort((a, b) => ((b['_score'] as int?) ?? 0).compareTo((a['_score'] as int?) ?? 0));

  return sorted.take(maxItems).map((city) {
    city.remove('_score');
    return city;
  }).toList(growable: false);
}
