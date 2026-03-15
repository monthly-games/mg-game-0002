import 'package:mg_common_game/systems/balancing/balancing.dart';

/// Default balancing configuration for MG-0002: Cat Alchemy.
///
/// Placeholder values for v1.2.0 pilot integration.
/// In production, override via RemoteConfig using
/// [BalancingManager.loadFromRemote].
const kDefaultBalancingConfig = BalancingConfig(
  gameId: 'mg-0002',
  version: 1,
  currencies: [
    CurrencyConfig(id: 'gold', baseEarnRate: 10.0),
    CurrencyConfig(
      id: 'gems',
      baseEarnRate: 1.0,
      earnCurve: CurveType.logarithmic,
      earnGrowthFactor: 0.5,
    ),
  ],
  xpCurve: XpCurveConfig(baseXp: 100, maxLevel: 100),
  difficultyScaling: DifficultyScalingConfig(),
  customParams: {
    'reward_multiplier': 1.0,
    'merge_bonus': 1.0,
    'idle_rate_base': 1.0,
  },
);
