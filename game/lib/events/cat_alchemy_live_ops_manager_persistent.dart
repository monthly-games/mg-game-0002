/// Cat Alchemy Live Ops Manager with Firestore Persistence
///
/// mg_common_game의 EventManager를 사용하여 Firebase Firestore에
/// 이벤트 데이터를 저장하고 불러오는 기능을 제공합니다.
library;

import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:mg_common_game/systems/events/event_manager.dart';

/// Firestore 기반 Live Ops Manager
class CatAlchemyLiveOpsManagerPersistent extends ChangeNotifier {
  final EventManager _eventManager = EventManager();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  CollectionReference get _eventsCollection =>
      _firestore.collection('cat_alchemy_events');
  CollectionReference get _playerStatesCollection =>
      _firestore.collection('cat_alchemy_player_event_states');

  // User identification
  String? _currentUserId;
  String? get currentUserId => _currentUserId;

  // Sync state
  Timer? _syncTimer;
  bool _isSyncing = false;
  static const Duration _syncInterval = Duration(minutes: 5);

  CatAlchemyLiveOpsManagerPersistent() {
    _initializeEventCallbacks();
  }

  /// 현재 사용자 ID 설정
  Future<void> initialize(String userId) async {
    if (_currentUserId == userId) return;

    _currentUserId = userId;
    await _loadEventsFromFirestore();
    await _loadPlayerStateFromFirestore();

    // 주기적 동기화 시작
    _startPeriodicSync();

    notifyListeners();
  }

  void _initializeEventCallbacks() {
    _eventManager.onLifecycleChanged = (eventId, newState) {
      debugPrint('📅 Event $eventId lifecycle changed: $newState');
      _syncEventToFirestore(eventId);
    };

    _eventManager.onRewardClaimed = (eventId, reward) {
      debugPrint('🎁 Reward claimed from $eventId: ${reward.goldReward}g');
      _syncPlayerStateToFirestore();
    };

    _eventManager.onEventStarted = (eventId) {
      debugPrint('🚀 Event started: $eventId');
      _syncEventToFirestore(eventId);
    };

    _eventManager.onEventEnded = (eventId) {
      debugPrint('🏁 Event ended: $eventId');
      _syncEventToFirestore(eventId);
    };
  }

  /// Firestore에서 이벤트 로드
  Future<void> _loadEventsFromFirestore() async {
    try {
      final snapshot = await _eventsCollection
          .where('isActive', isEqualTo: true)
          .orderBy('startDate')
          .get();

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final config = _convertToGameEventConfig(data);
        if (config != null) {
          _eventManager.registerEvent(config);
        }
      }

      debugPrint('📅 Loaded ${snapshot.docs.length} events from Firestore');
    } catch (e) {
      debugPrint('❌ Error loading events from Firestore: $e');
    }
  }

  /// Firestore에서 플레이어 상태 로드
  Future<void> _loadPlayerStateFromFirestore() async {
    if (_currentUserId == null) return;

    try {
      final doc = await _playerStatesCollection.doc(_currentUserId).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        final registryJson = data['eventsRegistry'] as String?;

        if (registryJson != null) {
          // EventManager의 내부 메서드 사용 (리플렉션 또는 공개 API 필요)
          // 여기서는 기존 방식대로 SharedPreferences 로드 사용
          await _eventManager.loadFromPreferences();
        }

        debugPrint('📅 Loaded player state from Firestore');
      }
    } catch (e) {
      debugPrint('❌ Error loading player state from Firestore: $e');
    }
  }

  /// 이벤트를 Firestore에 동기화
  Future<void> _syncEventToFirestore(String eventId) async {
    if (_isSyncing) return;

    try {
      _isSyncing = true;
      final config = _eventManager.getEvent(eventId);
      if (config == null) return;

      final data = _convertEventConfigToMap(config);
      await _eventsCollection.doc(eventId).set(data, SetOptions(merge: true));

      debugPrint('📅 Synced event $eventId to Firestore');
    } catch (e) {
      debugPrint('❌ Error syncing event to Firestore: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// 플레이어 상태를 Firestore에 동기화
  Future<void> _syncPlayerStateToFirestore() async {
    if (_currentUserId == null || _isSyncing) return;

    try {
      _isSyncing = true;

      // 먼저 SharedPreferences에 저장
      await _eventManager.saveToPreferences();

      // Firestore에 메타데이터만 저장 (전체 데이터는 SharedPreferences 사용)
      final now = DateTime.now();
      await _playerStatesCollection.doc(_currentUserId).set({
        'lastSyncTime': now.toIso8601String(),
        'userId': _currentUserId,
        'lastUpdateTime': now.toIso8601String(),
      }, SetOptions(merge: true));

      debugPrint('📅 Synced player state to Firestore');
    } catch (e) {
      debugPrint('❌ Error syncing player state to Firestore: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// 주기적 동기화 시작
  void _startPeriodicSync() {
    _syncTimer?.cancel();
    _syncTimer = Timer.periodic(_syncInterval, (_) {
      _syncAllToFirestore();
    });
  }

  /// 모든 데이터 동기화
  Future<void> _syncAllToFirestore() async {
    if (_isSyncing) return;

    try {
      _isSyncing = true;

      // 활성 이벤트 동기화
      for (final event in _eventManager.getActiveEvents()) {
        await _syncEventToFirestore(event.eventId);
      }

      // 플레이어 상태 동기화
      await _syncPlayerStateToFirestore();

      debugPrint('📅 Completed periodic sync to Firestore');
    } catch (e) {
      debugPrint('❌ Error in periodic sync: $e');
    } finally {
      _isSyncing = false;
    }
  }

  /// GameEventConfig를 Map으로 변환
  Map<String, dynamic> _convertEventConfigToMap(GameEventConfig config) {
    return {
      'eventId': config.eventId,
      'title': config.title,
      'description': config.description,
      'type': config.type.name,
      'startDate': config.startDate.toIso8601String(),
      'endDate': config.endDate.toIso8601String(),
      'previewDurationMs': config.previewDuration.inMilliseconds,
      'endingSoonThresholdMs': config.endingSoonThreshold.inMilliseconds,
      'rules': config.rules,
      'rewardTiers': config.rewardTiers.map((tier) => tier.toJson()).toList(),
      'maxParticipations': config.maxParticipations,
      'isActive': true,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Map을 GameEventConfig로 변환
  GameEventConfig? _convertToGameEventConfig(Map<String, dynamic> data) {
    try {
      final typeName = data['type'] as String? ?? '';
      final type = EventManagerType.values.firstWhere(
        (e) => e.name == typeName,
        orElse: () => EventManagerType.timeLimitedChallenge,
      );

      return GameEventConfig(
        eventId: data['eventId'] as String? ?? '',
        title: data['title'] as String? ?? '',
        description: data['description'] as String? ?? '',
        type: type,
        startDate: DateTime.parse(data['startDate'] as String? ?? ''),
        endDate: DateTime.parse(data['endDate'] as String? ?? ''),
        previewDuration: Duration(
          milliseconds: data['previewDurationMs'] as int? ?? 0,
        ),
        endingSoonThreshold: Duration(
          milliseconds: data['endingSoonThresholdMs'] as int? ?? 0,
        ),
        rules: Map<String, dynamic>.from(data['rules'] as Map? ?? const {}),
        rewardTiers: (data['rewardTiers'] as List<dynamic>? ?? const [])
            .map((tier) => EventRewardTier.fromJson(
                  Map<String, dynamic>.from(tier as Map),
                ))
            .toList(),
        maxParticipations: data['maxParticipations'] as int? ?? -1,
      );
    } catch (e) {
      debugPrint('❌ Error converting event config: $e');
      return null;
    }
  }

  /// 새 이벤트 등록 (Firestore에도 저장)
  Future<void> registerEvent(GameEventConfig config) async {
    _eventManager.registerEvent(config);
    await _syncEventToFirestore(config.eventId);
    notifyListeners();
  }

  /// 이벤트 진행도 추가
  void addEventProgress(String eventId, int amount) {
    _eventManager.addEventProgress(eventId, amount);
    _syncPlayerStateToFirestore();
    notifyListeners();
  }

  /// 이벤트 보상 수령
  EventRewardTier? claimEventReward(String eventId, int tierIndex) {
    final reward = _eventManager.claimEventReward(eventId, tierIndex);
    if (reward != null) {
      _syncPlayerStateToFirestore();
      notifyListeners();
    }
    return reward;
  }

  /// 수령 가능한 보상 목록
  List<EventRewardTier> getClaimableRewards(String eventId) {
    return _eventManager.getClaimableRewards(eventId);
  }

  /// 활성 이벤트 목록
  List<GameEventConfig> get activeEvents => _eventManager.getActiveEvents();

  /// 다가오는 이벤트 목록
  List<GameEventConfig> get upcomingEvents => _eventManager.getUpcomingEvents();

  /// 전체 이벤트 목록
  List<GameEventConfig> get allEvents => _eventManager.getAllEvents();

  /// 특정 이벤트 조회
  GameEventConfig? getEvent(String eventId) => _eventManager.getEvent(eventId);

  /// 이벤트 상태 조회
  EventLifecycleState getEventState(String eventId) =>
      _eventManager.getEventState(eventId);

  /// 이벤트 진행 상황 조회
  PlayerEventState? getEventProgress(String eventId) =>
      _eventManager.getEventProgress(eventId);

  /// 라이프사이클 전환 체크
  void checkLifecycleTransitions() {
    _eventManager.checkLifecycleTransitions();
    notifyListeners();
  }

  /// 보상 분배 완료 표시
  void markRewardsDistributed(String eventId) {
    _eventManager.markRewardsDistributed(eventId);
    _syncEventToFirestore(eventId);
    notifyListeners();
  }

  /// 수동 동기화
  Future<void> syncNow() async {
    await _syncAllToFirestore();
  }

  /// 저장
  Future<void> save() async {
    await _eventManager.saveToPreferences();
    await _syncPlayerStateToFirestore();
  }

  /// 불러오기
  Future<void> load() async {
    await _eventManager.loadFromPreferences();
    await _loadPlayerStateFromFirestore();
    notifyListeners();
  }

  /// 리소스 정리
  @override
  void dispose() {
    _syncTimer?.cancel();
    super.dispose();
  }

  /// Cat Alchemy 이벤트 생성 헬퍼
  static GameEventConfig createCatAlchemyEvent({
    required String eventId,
    required String title,
    required String description,
    required DateTime startDate,
    required Duration duration,
    required List<EventRewardTier> rewards,
    EventManagerType type = EventManagerType.timeLimitedChallenge,
  }) {
    return GameEventConfig(
      eventId: eventId,
      title: title,
      description: description,
      type: type,
      startDate: startDate,
      endDate: startDate.add(duration),
      previewDuration: const Duration(days: 3),
      rewardTiers: rewards,
      rules: {
        'gameId': 'MG-0002',
        'category': 'cat_alchemy',
      },
    );
  }

  /// 기본 보상 티어 생성
  static List<EventRewardTier> createDefaultRewardTiers() {
    return [
      const EventRewardTier(
        requiredProgress: 100,
        goldReward: 500,
        xpReward: 100,
        gemReward: 10,
      ),
      const EventRewardTier(
        requiredProgress: 500,
        goldReward: 2000,
        xpReward: 500,
        gemReward: 50,
      ),
      const EventRewardTier(
        requiredProgress: 1000,
        goldReward: 5000,
        xpReward: 1000,
        gemReward: 100,
        itemId: 'rare_material_pack',
      ),
      const EventRewardTier(
        requiredProgress: 2000,
        goldReward: 10000,
        xpReward: 2000,
        gemReward: 200,
        itemId: 'sr_recipe_ticket',
      ),
      const EventRewardTier(
        requiredProgress: 5000,
        goldReward: 25000,
        xpReward: 5000,
        gemReward: 500,
        itemId: 'exclusive_cat_skin',
      ),
    ];
  }
}
