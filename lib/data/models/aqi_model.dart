class AqiData {
  final int aqi;

  AqiData({required this.aqi});

  factory AqiData.fromJson(Map<String, dynamic> json) {
    final list = json['list'] as List?;
    if (list == null || list.isEmpty) return AqiData(aqi: 1);

    final main = list.first['main'] ?? {};
    return AqiData(aqi: main['aqi'] ?? 1);
  }
}
