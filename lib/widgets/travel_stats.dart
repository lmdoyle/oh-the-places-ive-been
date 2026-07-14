import 'package:flutter/material.dart';
import '../models/visit.dart';
import '../services/continent_service.dart';

class TravelStats extends StatelessWidget {
  final List<Visit> visits;

  const TravelStats({super.key, required this.visits});

  @override
  Widget build(BuildContext context) {
    final countries = visits
        .map((v) => v.country)
        .where((c) => c.isNotEmpty)
        .toSet();
    // Keyed by state+country so identically-named states in different
    // countries (rare, but possible) aren't counted as one.
    final states = visits
        .where((v) => v.state != null && v.state!.isNotEmpty)
        .map((v) => '${v.state}|${v.country}')
        .toSet();
    final continents = countries
        .map(ContinentService.continentForCountry)
        .whereType<String>()
        .toSet();
    final worldPercent = countries.isEmpty
        ? 0.0
        : countries.length / ContinentService.totalWorldCountries * 100;

    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 20,
      runSpacing: 8,
      children: [
        _Stat(label: 'Countries', value: '${countries.length}'),
        _Stat(label: 'States', value: '${states.length}'),
        _Stat(label: 'Continents', value: '${continents.length}'),
        _Stat(
          label: '% of World',
          value: '${worldPercent.toStringAsFixed(1)}%',
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
