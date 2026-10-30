enum ReciprocityCurve {
  fujiAcros,
  ilfordHp5,
  ilfordDeltaFp4,
  kodakPortra,
  kodakTmax,
  kodakTriX,
  fomapan,
  cinestill,
  generic,
}

class FilmStock {
  final String id;
  final String brand;
  final String name;
  final int boxIso;
  final String type;
  final ReciprocityCurve reciprocityCurve;

  const FilmStock({
    required this.id,
    required this.brand,
    required this.name,
    required this.boxIso,
    required this.type,
    required this.reciprocityCurve,
  });

  String get displayName => '$brand $name (ISO $boxIso)';

  Map<String, dynamic> toJson() => {
        'id': id,
        'brand': brand,
        'name': name,
        'boxIso': boxIso,
        'type': type,
        'reciprocityCurve': reciprocityCurve.name,
      };

  factory FilmStock.fromJson(Map<String, dynamic> json) => FilmStock(
        id: json['id'] as String,
        brand: json['brand'] as String,
        name: json['name'] as String,
        boxIso: json['boxIso'] as int,
        type: json['type'] as String,
        reciprocityCurve: ReciprocityCurve.values.firstWhere(
          (e) => e.name == json['reciprocityCurve'],
          orElse: () => ReciprocityCurve.generic,
        ),
      );
}

final List<FilmStock> defaultFilmStocks = [
  const FilmStock(
    id: 'portra-400',
    brand: 'Kodak',
    name: 'Portra 400',
    boxIso: 400,
    type: 'Color Negative',
    reciprocityCurve: ReciprocityCurve.kodakPortra,
  ),
  const FilmStock(
    id: 'tri-x-400',
    brand: 'Kodak',
    name: 'Tri-X 400',
    boxIso: 400,
    type: 'Black & White',
    reciprocityCurve: ReciprocityCurve.kodakTriX,
  ),
  const FilmStock(
    id: 'hp5-plus',
    brand: 'Ilford',
    name: 'HP5 Plus 400',
    boxIso: 400,
    type: 'Black & White',
    reciprocityCurve: ReciprocityCurve.ilfordHp5,
  ),
  const FilmStock(
    id: 'acros-ii',
    brand: 'Fujifilm',
    name: 'Neopan 100 Acros II',
    boxIso: 100,
    type: 'Black & White',
    reciprocityCurve: ReciprocityCurve.fujiAcros,
  ),
  const FilmStock(
    id: 'cinestill-800t',
    brand: 'CineStill',
    name: '800T Tungsten',
    boxIso: 800,
    type: 'Color Negative',
    reciprocityCurve: ReciprocityCurve.cinestill,
  ),
  const FilmStock(
    id: 'tmax-400',
    brand: 'Kodak',
    name: 'T-Max 400',
    boxIso: 400,
    type: 'Black & White',
    reciprocityCurve: ReciprocityCurve.kodakTmax,
  ),
  const FilmStock(
    id: 'fomapan-400',
    brand: 'Foma',
    name: 'Fomapan 400',
    boxIso: 400,
    type: 'Black & White',
    reciprocityCurve: ReciprocityCurve.fomapan,
  ),
];
