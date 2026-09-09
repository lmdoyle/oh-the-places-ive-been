import 'package:flutter/material.dart';
import '../models/travel_stats_data.dart';
import '../models/visit.dart';

class TravelStats extends StatelessWidget {
  final List<Visit> visits;

  const TravelStats({super.key, required this.visits});

  @override
  Widget build(BuildContext context) {
    final stats = TravelStatsData.compute(visits);

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 20,
      runSpacing: 8,
      children: [
        _Stat(label: 'Countries', value: '${stats.countries}'),
        _Stat(label: 'States', value: '${stats.states}'),
        _Stat(label: 'Continents', value: '${stats.continents}'),
        _Stat(
          label: '% of World',
          value: '${stats.worldPercent.toStringAsFixed(1)}%',
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;

  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: Theme.of(context).textTheme.titleMedium),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
