class ScenePreset {
  final String id;
  final String name;
  final String icon;
  final double compensationEv;
  final String description;
  final String why;

  const ScenePreset({
    required this.id,
    required this.name,
    required this.icon,
    required this.compensationEv,
    required this.description,
    required this.why,
  });
}

const List<ScenePreset> scenePresets = [
  ScenePreset(
    id: 'neutral',
    name: 'Normal (18% Gray)',
    icon: '🟩',
    compensationEv: 0.0,
    description: 'Average balanced scenes',
    why: 'Standard reflective meter assumption. No compensation needed.',
  ),
  ScenePreset(
    id: 'snow',
    name: 'Snow / White Sand',
    icon: '❄️',
    compensationEv: 2.0,
    description: 'Snow landscapes, ski slopes, white beach',
    why: 'Camera meters turn bright snow into murky gray. +2 stops restores true snow brilliance.',
  ),
  ScenePreset(
    id: 'backlit',
    name: 'Backlit Subject',
    icon: '☀️',
    compensationEv: 1.5,
    description: 'Subject against bright sun or sky',
    why: 'Bright background causes the camera to underexpose your subject into a dark silhouette.',
  ),
  ScenePreset(
    id: 'highkey',
    name: 'High-Key Studio',
    icon: '⚪',
    compensationEv: 1.7,
    description: 'White seamless backdrops',
    why: 'Renders the background crisp white rather than neutral cement gray.',
  ),
  ScenePreset(
    id: 'sunset',
    name: 'Sunset / Twilight',
    icon: '🌅',
    compensationEv: -1.0,
    description: 'Direct sun setting, golden hour horizon',
    why: 'Prevents the meter from overexposing dark ground, keeping sky colors saturated.',
  ),
  ScenePreset(
    id: 'stage',
    name: 'Spotlit Stage / Concert',
    icon: '🎭',
    compensationEv: -1.5,
    description: 'Performer under spotlight on black stage',
    why: 'Deep darkness causes meter to blow out the performer\'s skin into stark white.',
  ),
  ScenePreset(
    id: 'overcast',
    name: 'Overcast Bright Sky',
    icon: '☁️',
    compensationEv: 0.7,
    description: 'Diffuse milky white clouds',
    why: 'Compensates for high-key sky glare reducing ground exposure.',
  ),
];
