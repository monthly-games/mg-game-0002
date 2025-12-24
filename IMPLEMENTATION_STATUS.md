# MG-0002 고양이 연금술 공방 - 구현 상태

> 마지막 업데이트: 2025-12-18
> 전체 진행률: **85%**

---

## 📊 전체 요약

| 영역 | 완료율 | 상태 |
|------|--------|------|
| 데이터 모델 | 100% | ✅ 완료 |
| 코어 시스템 | 95% | ✅ 거의 완료 |
| UI/UX | 80% | 🔄 진행 중 |
| 에셋 | 0% | ⏳ 대기 |
| 테스트 | 10% | ⏳ 대기 |

---

## ✅ 완료된 기능 (Completed Features)

### 1. 데이터 모델 (100%)

#### 재료 시스템 (Material System)
- ✅ 16개 재료 정의 (Tier 1-4)
  - Tier 1: 들풀, 맑은 물, 돌멩이, 나뭇가지
  - Tier 2: 야생화, 샘물, 광석, 참나무
  - Tier 3: 희귀 허브, 성수, 보석, 마법 목재
  - Tier 4: 달빛 꽃, 불사조 깃털, 별가루, 공허의 정수
- ✅ 재료별 생산 속도 (productionRate) 설정
- ✅ 최대 저장 용량 (maxStorage) 설정
- ✅ 레벨별 잠금 해제 (unlockLevel) 시스템
- ✅ 획득 방법 (obtainMethod) 분류

**파일**: `lib/core/models/material.dart`, `assets/data/materials.json`

#### 레시피 시스템 (Recipe System)
- ✅ 레시피 데이터 모델 (Ingredient, CraftResult, DiscoveryBonus)
- ✅ 10+ 레시피 정의 (포션, 폭탄, 특수품)
  - 하급 치유 물약 (30초)
  - 하급 마나 물약 (45초)
  - 활력 물약 (60초)
  - 신속 물약 (120초)
  - 상급 치유 물약 (300초)
  - 화염 폭탄, 얼음 폭탄 등
- ✅ 제작 시간 (craftTime) 설정
- ✅ 판매 가격 (sellPrice) 경제 설계
- ✅ 발견 보너스 (discoveryBonus: gold, exp, gems)
- ✅ 전설 등급 (isLegendary) 플래그

**파일**: `lib/core/models/recipe.dart`, `assets/data/recipes.json`

#### 고양이 시스템 (Cat System)
- ✅ 고양이 데이터 모델 (Cat, CatSkill, TrustLevel, CatInteraction)
- ✅ 10개 레벨 시스템
- ✅ 신뢰도 (Trust) 포인트 시스템
- ✅ 스킬 시스템 (패시브/액티브)
  - Lv1: 재료 수집 가속 +10%
  - Lv2: 제작 시간 단축 -5%
  - Lv3: 판매가 증가 +5%
  - Lv5: 제작 대기열 확장 +1
  - Lv7: 행운 효과 (대성공 확률 증가)
  - Lv10: 최종 스킬
- ✅ 상호작용 시스템 (pet, play, feed 등)
- ✅ 일일 한도 (dailyLimit) 및 쿨다운 (cooldown)

**파일**: `lib/core/models/cat.dart`, `assets/data/cat_data.json`

#### 게임 상태 (Game State)
- ✅ Hive 기반 영구 저장
- ✅ 플레이어 진행도 (gold, gems, workshopLevel, reputation, playerExp)
- ✅ 인벤토리 (inventory: Map<String, int>)
- ✅ 발견한 레시피 (discoveredRecipes: List<String>)
- ✅ 고양이 상태 (catState: trust, level, interactions)
- ✅ 제작 대기열 (craftingQueue)
- ✅ 활성 주문 (activeOrders)
- ✅ 일일 상호작용 (dailyInteractions)
- ✅ 튜토리얼 완료 (tutorialCompleted)
- ✅ 마지막 로그인 시간 (lastLoginTime)
- ✅ 오프라인 시간 계산 (getOfflineHours)

**파일**: `lib/core/models/game_state.dart`, `lib/core/models/game_state.g.dart`

#### NPC 시스템 (NPC System)
- ✅ NPC 데이터 모델
- ✅ 주문 템플릿 (OrderTemplate)
- ✅ 레벨별 잠금 해제

**파일**: `lib/core/models/npc.dart`, `assets/data/npcs.json`

---

### 2. 코어 시스템 (95%)

#### 제작 시스템 (Crafting System)
- ✅ 기본 제작 매니저 (`CraftingGameManager`)
  - 레시피 검증
  - 재료 소비
  - 제작 대기열 관리 (최대 3-5개)
  - 제작 시간 계산
  - 완료된 아이템 수집
  - 제작 취소 및 재료 환불
  - 즉시 완료 (프리미엄 기능)
- ✅ **신규 추가: 연금술 제작 매니저** (`AlchemyCraftingManager`)
  - **대성공/일반/실패 시스템**
    - 대성공 (Critical): 10% 기본 확률 → 150% 출력
    - 일반 (Normal): 75% 기본 확률 → 100% 출력
    - 실패 (Failure): 15% 기본 확률 → 50% 출력 (최소 1개)
  - **행운 시스템 (Luck Modifier)**
    - 고양이 스킬로 행운 보너스
    - 행운 1포인트당 대성공 +5%, 실패 -5%
    - 최소 실패 확률 5% 보장
  - 품질 결과 표시 (CraftQuality enum)
  - 최종 출력량 계산 (finalOutputAmount)
- ✅ 오프라인 제작 처리
- ✅ 제작 시간 수정자 (고양이 스킬)

**파일**:
- `lib/core/managers/crafting_game_manager.dart`
- `lib/core/managers/alchemy_crafting_manager.dart` (신규)

#### 방치 생산 시스템 (Idle Production System)
- ✅ 기본 방치 매니저 (`IdleManager`)
- ✅ 재료별 시간당 생산량
- ✅ 주기적 자동 생산 (5초 간격)
- ✅ 최대 저장 용량 제한

**파일**: `game/lib/game/logic/idle_manager.dart`

#### 인벤토리 시스템 (Inventory System)
- ✅ 아이템 추가/제거
- ✅ 아이템 수량 조회
- ✅ 인벤토리 매니저 (`InventoryGameManager`)
- ✅ 스트림 기반 반응형 UI 업데이트

**파일**: `lib/core/managers/inventory_game_manager.dart`

#### 경제 시스템 (Economy System)
- ✅ 골드 (Gold) - 소프트 커런시
- ✅ 보석 (Gems) - 하드 커런시
- ✅ 골드 추가/소비 검증
- ✅ 판매 가격 계산
- ✅ 주문 보상 시스템

**파일**: `lib/providers/game_providers.dart`

#### 영구 저장 (Persistence System)
- ✅ Hive 기반 로컬 저장
- ✅ GameState 어댑터 (`game_state.g.dart`)
- ✅ 자동 저장
- ✅ 저장/로드/리셋 기능
- ✅ 오프라인 진행 계산

**파일**:
- `lib/core/models/game_state.dart`
- `lib/core/models/game_state.g.dart`
- `game/lib/game/logic/persistence_manager.dart`

#### 데이터 소스 & 레포지토리 (Data Layer)
- ✅ JSON 기반 게임 데이터 로딩
- ✅ 캐시 시스템
- ✅ 재료/레시피/고양이/NPC 조회
- ✅ Tier별, 카테고리별 필터링
- ✅ 레벨별 잠금 해제 조회

**파일**:
- `lib/data/sources/game_data_source.dart`
- `lib/data/repositories/game_repository.dart`

---

### 3. UI/UX (80%)

#### 씬 시스템 (Scene System)
- ✅ Flame 기반 씬 관리 (`CatAlchemyGame`)
- ✅ 15개 씬 구현
  1. ✅ Splash Scene - 스플래시 화면
  2. ✅ Home Scene - 메인 홈 화면
  3. ✅ Crafting Scene - 제작 화면
  4. ✅ Gathering Scene - 재료 수집 화면
  5. ✅ Shop Scene - 상점 화면
  6. ✅ Orders Scene - 주문 화면
  7. ✅ Cat Scene - 고양이 상호작용 화면
  8. ✅ Inventory Scene - 인벤토리 화면
  9. ✅ Recipes Scene - 레시피 도감 화면
  10. ✅ Upgrade Scene - 업그레이드 화면
  11. ✅ Achievements Scene - 업적 화면
  12. ✅ Settings Scene - 설정 화면
  13. ✅ Tutorial Scene - 튜토리얼 화면
  14. ✅ Collection Scene - 수집 화면
  15. ✅ Leaderboard Scene - 리더보드 화면
  16. ✅ Events Scene - 이벤트 화면
- ✅ 씬 네비게이션 시스템

**파일**: `lib/game/cat_alchemy_game.dart`, `lib/game/scenes/*.dart`

#### UI 컴포넌트 (UI Components)
- ✅ GameButton - 커스텀 버튼
- ✅ DialogBox - 대화 상자 (Alert, Confirm, Custom)
- ✅ ProgressBar - 진행 바 (Linear, Circular)
- ✅ ResourceDisplay - 리소스 표시 (Gold, Gems)
- ✅ InventorySlot - 인벤토리 슬롯

**파일**: `lib/game/components/*.dart`

#### 워크샵 게임 씬 (Workshop Game Scene)
- ✅ 공방 배경 렌더링
- ✅ 가마솥 오브젝트
- ✅ 증기 VFX 애니메이션 (스프라이트 시트 2x4)
- ✅ 고양이 캐릭터 렌더링
- ✅ 아이템 배치

**파일**: `lib/game/workshop_game.dart`

#### 상태 관리 (State Management)
- ✅ Riverpod Provider 시스템
- ✅ GameStateNotifier - 게임 상태 관리
- ✅ 자동 저장 기능
- ✅ 스트림 기반 반응형 UI

**파일**: `lib/providers/game_providers.dart`

---

## 🔄 진행 중 기능 (In Progress)

### 레시피 발견 시스템 (Recipe Discovery System) - 70%
- ✅ 레시피 발견 플래그
- ✅ 발견 보너스 (gold, exp, gems)
- ⏳ NPC 대화 기반 힌트 시스템 (미구현)
- ⏳ 조합 실험 UI (부분 구현)

### 공방 인테리어 시스템 (Workshop Decoration System) - 30%
- ✅ 기본 워크샵 씬 렌더링
- ⏳ 가구 배치 시스템 (미구현)
- ⏳ 풍수 보너스 시스템 (미구현)
- ⏳ 데코 아이템 데이터 (미구현)

---

## ⏳ 대기 중 기능 (Pending Features)

### 에셋 (0%)
- ⏳ 이미지 에셋 (24개)
  - 고양이 스프라이트
  - 배경 이미지
  - UI 아이콘
  - 재료 아이콘
  - VFX 스프라이트
- ⏳ 사운드 에셋 (10개)
  - UI 효과음
  - 제작 효과음
  - 환경음
  - BGM

**참고**: `ASSET_GENERATION_PROMPTS.md` 파일에 모든 에셋 생성 프롬프트 준비 완료

### 추가 콘텐츠 (0%)
- ⏳ 추가 레시피 (현재 10개 → 목표 30개)
- ⏳ 추가 재료 (현재 16개 → 목표 25개)
- ⏳ 추가 NPC 및 주문
- ⏳ 추가 고양이 스킨/외형
- ⏳ 시즌 이벤트 시스템

### 테스트 (10%)
- ✅ 기본 테스트 파일 구조
- ⏳ 유닛 테스트
- ⏳ 위젯 테스트
- ⏳ 통합 테스트

---

## 📁 핵심 파일 구조

```
mg-game-0002/
├─ game/
│  ├─ lib/
│  │  ├─ main.dart                           # 앱 진입점
│  │  ├─ core/
│  │  │  ├─ models/                          # 데이터 모델 (100%)
│  │  │  │  ├─ game_state.dart              # ✅ 게임 상태
│  │  │  │  ├─ material.dart                # ✅ 재료
│  │  │  │  ├─ recipe.dart                  # ✅ 레시피
│  │  │  │  ├─ cat.dart                     # ✅ 고양이
│  │  │  │  └─ npc.dart                     # ✅ NPC
│  │  │  └─ managers/                        # 게임 매니저 (95%)
│  │  │     ├─ crafting_game_manager.dart   # ✅ 제작 매니저
│  │  │     ├─ alchemy_crafting_manager.dart # ✅ 연금술 제작 (신규)
│  │  │     ├─ idle_production_manager.dart # ✅ 방치 생산
│  │  │     └─ inventory_game_manager.dart  # ✅ 인벤토리
│  │  ├─ providers/
│  │  │  └─ game_providers.dart             # ✅ Riverpod 프로바이더
│  │  ├─ data/
│  │  │  ├─ sources/game_data_source.dart   # ✅ 데이터 소스
│  │  │  └─ repositories/game_repository.dart # ✅ 레포지토리
│  │  └─ game/
│  │     ├─ cat_alchemy_game.dart           # ✅ 메인 게임 클래스
│  │     ├─ workshop_game.dart              # ✅ 워크샵 씬
│  │     ├─ scenes/                          # ✅ 15개 씬 (80%)
│  │     └─ components/                      # ✅ UI 컴포넌트
│  └─ assets/
│     ├─ data/                               # ✅ JSON 게임 데이터
│     │  ├─ materials.json                  # ✅ 16개 재료
│     │  ├─ recipes.json                    # ✅ 10+ 레시피
│     │  ├─ cat_data.json                   # ✅ 고양이 데이터
│     │  └─ npcs.json                       # ✅ NPC 데이터
│     ├─ images/                             # ⏳ 이미지 에셋 (0%)
│     └─ audio/                              # ⏳ 사운드 에셋 (0%)
├─ docs/
│  ├─ design/
│  │  └─ gdd_game_0002.json                 # ✅ GDD
│  └─ fun_design.md                         # ✅ 재미 디자인 문서
├─ ASSET_GENERATION_PROMPTS.md              # ✅ 에셋 생성 가이드 (신규)
├─ IMPLEMENTATION_STATUS.md                 # ✅ 이 문서 (신규)
└─ README.md                                # ✅ 프로젝트 README
```

---

## 🎯 다음 단계 (Next Steps)

### 우선순위 1: 에셋 생성
1. `ASSET_GENERATION_PROMPTS.md`의 프롬프트를 사용하여 이미지 에셋 생성
2. 사운드 에셋 생성
3. 에셋을 `assets/images/` 및 `assets/audio/`에 배치
4. `pubspec.yaml`에 에셋 등록

### 우선순위 2: 콘텐츠 확장
1. 레시피 20개 더 추가 (총 30개)
2. 재료 9개 더 추가 (총 25개)
3. NPC 5개 추가
4. 주문 템플릿 10개 추가

### 우선순위 3: 미완성 시스템 구현
1. NPC 대화 기반 레시피 힌트 시스템
2. 공방 인테리어 배치 시스템
3. 풍수 보너스 시스템

### 우선순위 4: 테스트 & 밸런싱
1. 유닛 테스트 작성
2. 경제 밸런싱
3. 난이도 곡선 조정

---

## 🆕 최근 추가 기능 (2025-12-18)

### 연금술 제작 시스템 (`AlchemyCraftingManager`)
- **대성공/일반/실패 메커니즘**
  - 확률 기반 품질 계산
  - 행운 시스템으로 확률 조정
  - 출력량 변동 (50% ~ 150%)

- **품질 등급**
  ```dart
  enum CraftQuality {
    failure,   // 50% output, 15% base chance
    normal,    // 100% output, 75% base chance
    critical,  // 150% output, 10% base chance
  }
  ```

- **행운 시스템**
  ```dart
  // 행운 1포인트당:
  - 대성공 확률 +5%
  - 실패 확률 -5% (최소 5% 보장)

  // 예시: 행운 2일 때
  - Critical: 10% → 20%
  - Normal: 75% → 70%
  - Failure: 15% → 10%
  ```

- **통합 지점**
  - 고양이 스킬 시스템 (Lv7: 행운 효과)
  - 공방 인테리어 보너스 (예정)
  - 특수 이벤트 버프 (예정)

### 에셋 생성 가이드
- 24개 이미지 에셋 프롬프트
- 10개 사운드 에셋 프롬프트
- AI 생성 도구 가이드
- 대체 리소스 사이트 목록

---

## 🐛 알려진 이슈 (Known Issues)

### 빌드 이슈
- ❌ Android SDK Build Tools 35.0.0 손상 문제
  - 로컬 환경 문제, 코드와 무관
  - Flutter analyze는 정상 통과 (에러 0개)

### 기능 이슈
- ⚠️ 워크샵 씬 VFX 스프라이트 시트 로딩 미검증
  - 에셋 파일 부재로 테스트 불가
  - 코드 로직은 구현 완료

---

## 📊 기술 스택

- **Framework**: Flutter 3.x + Flame Engine
- **Language**: Dart
- **State Management**: Riverpod 2.6.1
- **Persistence**: Hive (NoSQL local storage)
- **DI**: GetIt (예정, 일부 파일에서 참조)
- **Build Tool**: Flutter CLI, Gradle

---

## 🎮 플레이 가능 상태

### 현재 상태
- ✅ 컴파일 가능 (에러 0개, 경고만 존재)
- ✅ 데이터 로딩 가능 (JSON → 모델)
- ✅ 씬 네비게이션 가능
- ⏳ 비주얼 경험 미완성 (에셋 부재)
- ⏳ 사운드 경험 미완성 (에셋 부재)

### 에셋 추가 후 플레이 가능 시나리오
1. 공방에 진입
2. 고양이와 상호작용하여 신뢰도 증가
3. 방치 시스템으로 재료 수집
4. 레시피 선택 및 제작
5. 제작 완료 시 품질 확인 (대성공/일반/실패)
6. 주문 완료로 골드 획득
7. 골드로 공방 업그레이드
8. 고양이 레벨업으로 스킬 해금
9. 신규 재료 및 레시피 잠금 해제
10. 반복...

---

## 📝 참고 문서

- [GDD](docs/design/gdd_game_0002.json) - 게임 디자인 문서
- [재미 디자인](docs/fun_design.md) - 재미 축 및 디자인 레버
- [에셋 생성 가이드](ASSET_GENERATION_PROMPTS.md) - AI 생성 프롬프트
- [README](README.md) - 프로젝트 개요

---

## ✅ 체크리스트 요약

- [x] 데이터 모델 구조 설계
- [x] JSON 게임 데이터 정의
- [x] 코어 시스템 구현 (제작, 방치, 인벤토리)
- [x] 대성공/실패 제작 시스템 추가
- [x] 15개 UI 씬 구현
- [x] 영구 저장 시스템 (Hive)
- [x] 고양이 신뢰도/레벨 시스템
- [x] 에셋 생성 가이드 작성
- [ ] 이미지 에셋 24개 생성
- [ ] 사운드 에셋 10개 생성
- [ ] 레시피 발견 힌트 시스템
- [ ] 공방 인테리어 배치
- [ ] 테스트 코드 작성
- [ ] 경제 밸런싱

**전체 진행률: 85% / 플레이 가능 상태: 에셋 추가 시 95%**

---

> **Note**: 이 문서는 개발 진행 상황에 따라 지속적으로 업데이트됩니다.
