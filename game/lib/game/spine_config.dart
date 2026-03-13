import 'package:mg_common_game/core/assets/asset_types.dart';

/// Spine 통합 플래그. `--dart-define=SPINE_ENABLED=true`로 활성화.
const kSpineEnabled = bool.fromEnvironment(
  'SPINE_ENABLED',
  defaultValue: false,
);

// ── Alchemist Cat ────────────────────────────────────────────

const kAlchemistCatMeta = SpineAssetMeta(
  key: 'alchemist_cat',
  path: 'spine/characters/alchemist_cat',
  atlasPath:
      'assets/spine/characters/alchemist_cat/alchemist_cat.atlas',
  skeletonPath:
      'assets/spine/characters/alchemist_cat/alchemist_cat.skel',
  animations: ['idle', 'walk', 'attack', 'hit'],
  defaultAnimation: 'idle',
  defaultMix: 0.2,
);

// ── Fire Cat ─────────────────────────────────────────────────

const kFireCatMeta = SpineAssetMeta(
  key: 'fire_cat',
  path: 'spine/characters/fire_cat',
  atlasPath: 'assets/spine/characters/fire_cat/fire_cat.atlas',
  skeletonPath: 'assets/spine/characters/fire_cat/fire_cat.skel',
  animations: ['idle', 'walk', 'attack', 'hit'],
  defaultAnimation: 'idle',
  defaultMix: 0.2,
);

// ── Ice Cat ──────────────────────────────────────────────────

const kIceCatMeta = SpineAssetMeta(
  key: 'ice_cat',
  path: 'spine/characters/ice_cat',
  atlasPath: 'assets/spine/characters/ice_cat/ice_cat.atlas',
  skeletonPath: 'assets/spine/characters/ice_cat/ice_cat.skel',
  animations: ['idle', 'walk', 'attack', 'hit'],
  defaultAnimation: 'idle',
  defaultMix: 0.2,
);
