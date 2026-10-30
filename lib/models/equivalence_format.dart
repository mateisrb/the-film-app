class FilmFormat {
  final String id;
  final String name;
  final String category;
  final double sensorWidthMm;
  final double sensorHeightMm;
  final double cropFactorVs35mm;

  const FilmFormat({
    required this.id,
    required this.name,
    required this.category,
    required this.sensorWidthMm,
    required this.sensorHeightMm,
    required this.cropFactorVs35mm,
  });
}

const List<FilmFormat> defaultFormats = [
  FilmFormat(
    id: '35mm',
    name: '35mm Full Frame (24x36)',
    category: '35mm',
    sensorWidthMm: 36,
    sensorHeightMm: 24,
    cropFactorVs35mm: 1.0,
  ),
  FilmFormat(
    id: '120_645',
    name: 'Medium Format 6x4.5 (56x42)',
    category: 'Medium Format',
    sensorWidthMm: 56,
    sensorHeightMm: 42,
    cropFactorVs35mm: 0.62,
  ),
  FilmFormat(
    id: '120_6x6',
    name: 'Medium Format 6x6 (56x56)',
    category: 'Medium Format',
    sensorWidthMm: 56,
    sensorHeightMm: 56,
    cropFactorVs35mm: 0.55,
  ),
  FilmFormat(
    id: '120_6x7',
    name: 'Medium Format 6x7 (56x70)',
    category: 'Medium Format',
    sensorWidthMm: 70,
    sensorHeightMm: 56,
    cropFactorVs35mm: 0.48,
  ),
  FilmFormat(
    id: '120_6x9',
    name: 'Medium Format 6x9 (56x84)',
    category: 'Medium Format',
    sensorWidthMm: 84,
    sensorHeightMm: 56,
    cropFactorVs35mm: 0.43,
  ),
  FilmFormat(
    id: '4x5',
    name: 'Large Format 4x5 inch (102x127)',
    category: 'Large Format',
    sensorWidthMm: 127,
    sensorHeightMm: 102,
    cropFactorVs35mm: 0.26,
  ),
];
