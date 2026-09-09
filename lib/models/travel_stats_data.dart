import '../services/continent_service.dart';
import 'visit.dart';

// Pulled out of the TravelStats widget so the same countries/states/
// continents/%world computation can be reused by the share cards (which
// need it scoped to a single year, not just "all visits").
class TravelStatsData {
  final int countries;
  final int states;
  final int continents;
  final double worldPercent;

  const TravelStatsData({
    required this.countries,
    required this.states,
    required this.continents,
    required this.worldPercent,
  });

  // Nominatim's "state" field is just OSM's admin_level=4 tag, which plenty
  // of non-US countries also populate (German Bundesländer, Mexican
  // estados, Australian states, etc.) — so the "States" stat only makes
  // sense scoped to the US, not any visit that happens to have a state.
  static const _usAliases = {
    'united states',
    'united states of america',
    'usa',
    'us',
  };

  factory TravelStatsData.compute(List<Visit> visits) {
    final countries = visits
        .map((v) => v.country)
        .where((c) => c.isNotEmpty)
        .toSet();
    final states = visits
        .where(
          (v) =>
              v.state != null &&
              v.state!.isNotEmpty &&
              _usAliases.contains(v.country.trim().toLowerCase()),
        )
        .map((v) => v.state!)
        .toSet();
    final continents = countries
        .map(ContinentService.continentForCountry)
        .whereType<String>()
        .toSet();
    final worldPercent = countries.isEmpty
        ? 0.0
        : countries.length / ContinentService.totalWorldCountries * 100;

    return TravelStatsData(
      countries: countries.length,
      states: states.length,
      continents: continents.length,
      worldPercent: worldPercent,
    );
  }
}
