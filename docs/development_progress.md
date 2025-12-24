# MG-0002 고양이 연금술 공방 - 개발 진행 상황

## 프로젝트 개요
- **게임명**: 고양이 연금술 공방 (Cat Alchemy Workshop)
- **장르**: Idle Crafting + Pet Companion
- **플랫폼**: Mobile (iOS/Android)
- **엔진**: Flutter + Flame
- **상태 관리**: Riverpod
- **로컬 저장**: Hive

---

## 최신 업데이트 (2025-12-17)

### 🎮 플레이 가능한 게임 루프 완성!

이제 다음 게임 플로우를 완전히 플레이할 수 있습니다:

1. **재료 수집** (GatheringScene) → 클릭으로 재료 채집
2. **포션 제작** (CraftingScene) → 레시피 선택 및 제작 큐
3. **인벤토리 관리** (InventoryScene) → 아이템 확인, 정렬, 필터링
4. **포션 판매** (ShopScene) → 포션을 골드로 판매
5. **재료 구매** (ShopScene) → 골드로 재료 구매
6. **NPC 주문** (OrdersScene) → 퀘스트 수락 및 완료
7. **고양이 육성** (CatScene) → 교감 및 스킬 해금

**완성된 씬**: 16/16 (100%) 🎉
- ✅ SplashScene
- ✅ HomeScene
- ✅ **CraftingScene** (완전 기능)
- ✅ **GatheringScene** (완전 기능)
- ✅ **ShopScene** (완전 기능)
- ✅ **OrdersScene** (완전 기능)
- ✅ **CatScene** (완전 기능)
- ✅ **InventoryScene** (완전 기능)
- ✅ **RecipesScene** (완전 기능)
- ✅ **UpgradeScene** (완전 기능)
- ✅ **AchievementsScene** (완전 기능)
- ✅ **SettingsScene** (완전 기능)
- ✅ **TutorialScene** (완전 기능)
- ✅ **CollectionScene** (완전 기능)
- ✅ **LeaderboardScene** (완전 기능)
- ✅ **EventsScene** (완전 기능) ⭐ NEW

---

## 완료된 작업

### ✅ 1. 코어 시스템 (100%)
#### mg-common-game 공통 시스템
- **IdleSystem**: 시간 기반 자동 생산, 오프라인 보상 (최대 8시간)
- **CraftingSystem**: 제작 큐 관리, 타이머, 오프라인 제작 처리
- **InventorySystem**: 슬롯 기반, 스택 제한, 배치 작업

#### 게임 매니저 통합
- **IdleProductionManager**: IdleSystem + GameState 연결
- **CraftingGameManager**: CraftingSystem + 레시피 검증
- **InventoryGameManager**: InventorySystem + 양방향 동기화

### ✅ 2. 상태 관리 (100%)
- **Riverpod 프로바이더**: 15개 프로바이더 (데이터, 상태, 매니저)
- **Hive 저장/로드**: GameStateNotifier에서 자동 저장/로드
- **게임 초기화 서비스**: 앱 시작 시 모든 시스템 초기화

### ✅ 3. UI 컴포넌트 라이브러리 (100%)
재사용 가능한 Flame 컴포넌트:

#### [game_button.dart](d:\mg-games\repos\mg-game-0002\game\lib\game\components\game_button.dart)
- **GameButton**: 텍스트 버튼 (눌림 효과, enabled/disabled)
- **GameIconButton**: 원형 아이콘 버튼

#### [inventory_slot.dart](d:\mg-games\repos\mg-game-0002\game\lib\game\components\inventory_slot.dart)
- **InventorySlot**: 아이템 슬롯 (아이콘, 수량, 선택 상태)
- **InventoryGrid**: NxM 그리드 레이아웃

#### [progress_bar.dart](d:\mg-games\repos\mg-game-0002\game\lib\game\components\progress_bar.dart)
- **ProgressBar**: 0-100% 진행도 표시
- **TimerProgressBar**: MM:SS 카운트다운 타이머

#### [dialog_box.dart](d:\mg-games\repos\mg-game-0002\game\lib\game\components\dialog_box.dart)
- **DialogBox**: 범용 다이얼로그 (제목, 메시지, 버튼들)
- **ConfirmDialog**: 확인/취소
- **InfoDialog**: OK 버튼
- **RewardDialog**: 보상 표시

#### [resource_display.dart](d:\mg-games\repos\mg-game-0002\game\lib\game\components\resource_display.dart)
- **ResourceDisplay**: 리소스 표시 (아이콘 + 수량)
- **CompactResourceDisplay**: 간단한 표시
- **ResourcePanel**: 여러 리소스 패널
- 큰 숫자 포맷팅 (1K, 1M, 1B)

### ✅ 4. 씬 구현 (5/16 = 31.25%)

#### [SplashScene](d:\mg-games\repos\mg-game-0002\game\lib\game\scenes\splash_scene.dart)
**기능**:
- 게임 로고 표시
- 로딩 프로그레스 바 (0-100%)
- 시스템 초기화 (데이터 로드, 상태 복원, 오프라인 보상)
- HomeScene으로 자동 전환

#### [HomeScene](d:\mg-games\repos\mg-game-0002\game\lib\game\scenes\home_scene.dart)
**기능**:
- 공방 메인 화면
- 리소스 표시 (골드, 젬, 공방 레벨)
- 네비게이션 버튼 10개:
  - 🔨 Crafting
  - 🌿 Gathering
  - 🛒 Shop
  - 📜 Orders
  - 🎒 Inventory
  - 📖 Recipes
  - ⬆️ Upgrade
  - 🏆 Achievements
  - 🐱 Cat

#### [CraftingScene](d:\mg-games\repos\mg-game-0002\game\lib\game\scenes\crafting_scene.dart) ⭐ NEW
**기능**:
- 발견한 레시피 그리드 표시 (4x3)
- 레시피 선택 → 상세 정보 다이얼로그
- 재료 보유량 확인 및 제작 시작
- 제작 큐 표시 (최대 3-5슬롯, 설정 가능)
- 실시간 타이머 카운트다운 (MM:SS)
- 완료된 제작물 수집 버튼
- 뒤로가기 (홈으로 이동)

**UI 레이아웃**:
```
┌─────────────────────────────────────────┐
│  Crafting Workshop            [← Back]  │
├─────────────────────────────────────────┤
│                              │ Crafting  │
│  [Recipe Grid 4x3]           │ Queue     │
│  ┌───┬───┬───┬───┐          │ (3-5)     │
│  │ 🧪│ 🧪│ 🧪│ 🧪│          ├───────────┤
│  ├───┼───┼───┼───┤          │ Job 1     │
│  │ 🧪│ 🧪│ 🧪│ 🧪│          │ [Timer]   │
│  ├───┼───┼───┼───┤          │ [Collect] │
│  │ 🧪│ 🧪│ 🧪│ 🧪│          ├───────────┤
│  └───┴───┴───┴───┘          │ Job 2     │
│                              │ [Timer]   │
│                              ├───────────┤
│                              │ Empty     │
└─────────────────────────────────────────┘
```

#### [GatheringScene](d:\mg-games\repos\mg-game-0002\game\lib\game\scenes\gathering_scene.dart) ⭐ NEW
**기능**:
- 필드에 재료 노드 랜덤 스폰 (6-8개)
- 노드 클릭 → 2초 수집 애니메이션
- 진행도 바 with 퍼센트 표시
- 수집 완료 시 인벤토리에 자동 추가 (1-3개, 티어 기반)
- 노드 재생성 (30% 확률)
- 시각적 피드백 ("+3 들풀" 메시지)

**비주얼**:
- 하늘 그라데이션 배경 (파란색)
- 땅 (녹색)
- 재료 노드: 발광 효과, 부드러운 바운싱 애니메이션
- 호버 시 재료 이름 표시

**수집 가능한 재료**:
- 티어 1-2 재료만 (들풀, 맑은 물, 돌, 나뭇가지, 불꽃, 이슬 등)

#### [ShopScene](d:\mg-games\repos\mg-game-0002\game\lib\game\scenes\shop_scene.dart) ⭐ NEW
**기능**:
- **2개 탭**: Buy Materials / Sell Potions
- **Buy Tab**:
  - 재료 그리드 표시 (티어 1-3)
  - 클릭 → 구매 다이얼로그
  - 구매 옵션: x1, x10
  - 가격: 10 × tier² gold (Tier 1: 10g, Tier 2: 40g, Tier 3: 90g)
- **Sell Tab**:
  - 인벤토리의 포션 표시
  - 클릭 → 판매 다이얼로그
  - 판매 옵션: x1, x10
  - 가격: 레시피의 sellPrice
  - 포션 없으면 "Craft some first!" 메시지
- 골드 확인 (잔액 부족 시 버튼 비활성화)
- 판매 후 UI 자동 새로고침

**UI 레이아웃**:
```
┌─────────────────────────────────────────┐
│  Merchant Shop                [← Back]  │
├─────────────────────────────────────────┤
│  [Buy Materials] [Sell Potions]         │
├─────────────────────────────────────────┤
│                                          │
│  [Item Grid 5x3]                        │
│  ┌────┬────┬────┬────┬────┐            │
│  │ 🌿 │ 💧 │ 🪨 │ 🪵 │ 🔥 │            │
│  ├────┼────┼────┼────┼────┤            │
│  │ 💎 │ ✨ │ 💠 │    │    │            │
│  └────┴────┴────┴────┴────┘            │
│                                          │
│  Click on items to buy/sell them        │
└─────────────────────────────────────────┘
```

#### [OrdersScene](d:\mg-games\repos\mg-game-0002\game\lib\game\scenes\orders_scene.dart)
**기능**:
- NPC 주문 보드 (퀘스트 시스템)
- 활성 주문 목록 표시 (2-3개)
- 주문 정보:
  - NPC 이름 및 요청 아이템
  - 보상 (골드, 경험치, 평판)
  - 남은 시간 표시
  - 완료 진행도 (%)
- 주문 완료:
  - 재료 확인 → 인벤토리에서 차감
  - 보상 지급
  - 완료 다이얼로그
- 주문 새로고침 버튼 (준비 중)
- OrderService를 통한 동적 주문 생성

#### [CatScene](d:\mg-games\repos\mg-game-0002\game\lib\game\scenes\cat_scene.dart)
**기능**:
- 고양이 동료 정보 표시
  - 이름: Whiskers (고정)
  - 레벨 및 신뢰도
- 3가지 상호작용:
  - 🤚 Pet (+1 신뢰도, 무료)
  - 🍖 Treat (+5 신뢰도, 10골드)
  - 🎾 Play (+10 신뢰도, 무료)
- 신뢰도 진행바 (레벨업 요구치: 100 × 레벨)
- 레벨별 스킬 시스템 (10레벨):
  - Lv.1: 동료 (항상 함께)
  - Lv.2: +5% 생산 속도
  - Lv.3: +10% 생산 속도
  - Lv.4: +1 제작 큐 슬롯
  - Lv.5: -10% 제작 시간
  - Lv.6: +15% 생산 속도
  - Lv.7: -20% 제작 시간
  - Lv.8: 자동 유휴 자원 수집
  - Lv.9: 저급 포션 자동 판매
  - Lv.10: 전설 - 모든 보너스 +50%

#### [InventoryScene](d:\mg-games\repos\mg-game-0002\game\lib\game\scenes\inventory_scene.dart) ⭐ NEW
**기능**:
- **인벤토리 그리드**: 10x10 = 100 슬롯
- **슬롯 정보 표시**: 사용 중 슬롯 / 총 슬롯
- **3가지 필터**:
  - All (모든 아이템)
  - Materials (재료만)
  - Potions (포션만)
- **4가지 정렬 모드**:
  - Default (삽입 순서)
  - Name (이름 알파벳순)
  - Quantity (수량 내림차순)
  - Value (가치순 - 추후 구현)
- **아이템 상세 정보**:
  - 클릭 시 다이얼로그 표시
  - 아이템 이름, 타입, 수량, ID
- **시각적 특징**:
  - 중앙 정렬 그리드
  - 슬롯 크기: 60x60px
  - 슬롯 간격: 8px
  - 필터 버튼 색상 변경 (활성/비활성)

**UI 레이아웃**:
```
┌─────────────────────────────────────────┐
│  Inventory          Slots: 15/100       │
│  [← Back]          [🔄 Sort: Default]   │
├─────────────────────────────────────────┤
│  [All] [Materials] [Potions]            │
├─────────────────────────────────────────┤
│                                          │
│  ┌──┬──┬──┬──┬──┬──┬──┬──┬──┬──┐      │
│  │🌿││💧││🪨││  ││  ││  ││  ││  ││  ││  │      │
│  ├──┼──┼──┼──┼──┼──┼──┼──┼──┼──┤      │
│  │🧪││🧪││  ││  ││  ││  ││  ││  ││  ││  │      │
│  ├──┼──┼──┼──┼──┼──┼──┼──┼──┼──┤      │
│  │  ││  ││  ││  ││  ││  ││  ││  ││  ││  │      │
│  └──┴──┴──┴──┴──┴──┴──┴──┴──┴──┘      │
│  ... (10 rows total)                    │
│                                          │
└─────────────────────────────────────────┘
```

#### [RecipesScene](d:\mg-games\repos\mg-game-0002\game\lib\game\scenes\recipes_scene.dart) ⭐ NEW
**기능**:
- **레시피 도감 시스템**: 모든 레시피 확인
- **발견 진행도 표시**: X/Total (%)
- **3가지 필터**:
  - All (모든 레시피)
  - Discovered (발견한 레시피만)
  - Locked (잠긴 레시피만)
- **레시피 카드 그리드**: 4열 그리드 레이아웃
- **발견한 레시피 카드**:
  - 레시피 아이콘 (🧪 플레이스홀더)
  - 레시피 이름
  - 티어 표시
  - 제작 시간
  - 판매 가격
  - 재료 개수
  - 클릭 시 상세 정보 다이얼로그
- **잠긴 레시피 카드**:
  - 🔒 잠금 아이콘
  - ??? 이름
  - 티어 힌트
  - 해금 힌트 (티어 기반)
- **상세 정보 다이얼로그**:
  - 레시피 설명
  - 전체 재료 목록
  - 제작 시간, 판매 가격, 경험치
- **시각적 특징**:
  - 책 모양 배경 (책등 장식)
  - 발견/잠금 구분 색상
  - 카드 크기: 160x220px
  - 카드 간격: 20px

**UI 레이아웃**:
```
┌─────────────────────────────────────────┐
│  Recipe Codex    Discovered: 5/20 (25%) │
│  [← Back]                                │
├─────────────────────────────────────────┤
│  [All (20)] [Discovered (5)] [Locked (15)]│
├─────────────────────────────────────────┤
│                                          │
│  ┌──────┬──────┬──────┬──────┐          │
│  │ 🧪   │ 🧪   │ 🔒   │ 🔒   │          │
│  │Potion│Elixir│ ???  │ ???  │          │
│  │Tier 1│Tier 2│Tier 3│Tier 4│          │
│  └──────┴──────┴──────┴──────┘          │
│  ┌──────┬──────┬──────┬──────┐          │
│  │ 🔒   │ 🔒   │ 🔒   │ 🔒   │          │
│  │ ???  │ ???  │ ???  │ ???  │          │
│  └──────┴──────┴──────┴──────┘          │
│  ... (more rows)                         │
└─────────────────────────────────────────┘
```

#### [UpgradeScene](d:\mg-games\repos\mg-game-0002\game\lib\game\scenes\upgrade_scene.dart) ⭐ NEW
**기능**:
- **업그레이드 시스템**: 공방 강화 및 능력 향상
- **3가지 카테고리**:
  - 🏭 Workshop (공방 레벨, 인벤토리, 저장소)
  - ⚡ Production (생산 속도, 채집 효율, 자동 수집)
  - 🔨 Crafting (제작 속도, 큐 슬롯, 즉시 제작, 품질)
- **10가지 업그레이드 옵션**:
  - Workshop Level (새 레시피/기능 해금)
  - Inventory Slots (인벤토리 용량)
  - Storage Capacity (유휴 자원 저장량)
  - Production Speed (+10% 생산/레벨)
  - Gathering Efficiency (+1 재료/채집)
  - Auto Collect (자동 유휴 자원 수집)
  - Crafting Speed (-5% 제작 시간/레벨)
  - Crafting Queue Slots (+1 큐 슬롯/레벨)
  - Instant Craft (젬으로 즉시 제작)
  - Quality Bonus (+10% 판매가/레벨)
- **업그레이드 카드**:
  - 아이콘, 이름, 설명
  - 현재 레벨 / 최대 레벨
  - 진행도 바
  - 업그레이드 비용 (지수 증가: base × 1.5^level)
  - 업그레이드 버튼 (골드 부족 시 비활성화)
  - MAX 레벨 표시
- **비용 시스템**:
  - 지수 비용 증가 (baseCost × 1.5^currentLevel)
  - 골드 실시간 확인
- **시각적 특징**:
  - 세로 스크롤 카드 레이아웃
  - 카드 크기: full-width × 120px
  - 카테고리별 색상 구분
  - 업그레이드 가능/불가능 시각 피드백

**UI 레이아웃**:
```
┌─────────────────────────────────────────┐
│  Workshop Upgrades         💰 1500 💎 50│
│  [← Back]                                │
├─────────────────────────────────────────┤
│ [🏭 Workshop] [⚡ Production] [🔨 Crafting]│
├─────────────────────────────────────────┤
│  ┌───────────────────────────────────┐  │
│  │ 🏭 Workshop Level                 │  │
│  │ Unlock new recipes and features   │  │
│  │ Level 3/10 [▓▓▓░░░░░░░]          │  │
│  │                      [Upgrade 338💰]│
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │ 🎒 Inventory Slots                │  │
│  │ Increase max inventory capacity   │  │
│  │ Level 10/20 [▓▓▓▓▓░░░░░]         │  │
│  │                      [Upgrade 900💰]│
│  └───────────────────────────────────┘  │
│  ... (more upgrades)                    │
└─────────────────────────────────────────┘
```

#### [AchievementsScene](d:\mg-games\repos\mg-game-0002\game\lib\game\scenes\achievements_scene.dart) ⭐ NEW
**기능**:
- **업적 시스템**: 15개 업적 추적 및 보상
- **4가지 카테고리**:
  - All (모든 업적)
  - 🔨 Crafting (제작 관련 4개)
  - 🌿 Gathering (채집 관련 3개)
  - 🤝 Social (주문/고양이 관련 4개)
- **업적 목록**:
  - **Crafting**: First Brew (1), Apprentice (10), Master (50), Legendary (100)
  - **Gathering**: Novice (10), Expert (100), Master (500)
  - **Social**: First Customer (1), Trusted (10), Cat Friend (Lv.5), Cat Master (Lv.10)
  - **Progression**: Wealthy (1000g), Tycoon (10000g), Workshop Upgrade (Lv.5), Grand Workshop (Lv.10)
- **업적 카드**:
  - 아이콘, 이름, 설명
  - 진행도 (현재/목표)
  - 진행 바 (완료 시 녹색, 진행 중 파란색)
  - 보상 표시 (골드💰, 젬💎, 경험치✨)
  - Claim 버튼 (완료 시 금색)
  - ✓ Claimed 배지 (수령 후)
- **보상 시스템**:
  - 골드, 젬, 경험치 조합
  - 즉시 수령 가능
  - 수령 후 재수령 불가
- **진행도 추적**:
  - 전체 달성률 표시 (X/Total, %)
  - 카테고리별 필터링
- **시각적 특징**:
  - 완료된 업적: 금색 테두리 + 금색 배경
  - 진행 중 업적: 일반 테두리
  - 세로 스크롤 레이아웃
  - 카드 크기: full-width × 110px

**UI 레이아웃**:
```
┌─────────────────────────────────────────┐
│  Achievements    Completed: 3/15 (20%)  │
│  [← Back]                                │
├─────────────────────────────────────────┤
│ [All] [🔨 Crafting] [🌿 Gathering] [🤝 Social]│
├─────────────────────────────────────────┤
│  ┌───────────────────────────────────┐  │
│  │ 🧪 First Brew            50💰 10✨│  │
│  │ Craft your first potion           │  │
│  │ 1/1 [▓▓▓▓▓▓▓▓▓▓] 100%   [Claim!] │  │
│  └───────────────────────────────────┘  │
│  ┌───────────────────────────────────┐  │
│  │ ⚗️ Apprentice Alchemist 200💰 50✨│  │
│  │ Craft 10 potions                  │  │
│  │ 5/10 [▓▓▓▓▓░░░░░] 50%            │  │
│  └───────────────────────────────────┘  │
│  ... (more achievements)                │
└─────────────────────────────────────────┘
```

#### [SettingsScene](d:\mg-games\repos\mg-game-0002\game\lib\game\scenes\settings_scene.dart) ⭐ NEW
**기능**:
- **설정 관리 시스템**: 게임 설정 및 데이터 관리
- **오디오 설정**:
  - Sound Effects 토글 (ON/OFF)
  - Background Music 토글 (ON/OFF)
  - Sound Volume 슬라이더 (0-100%)
  - Music Volume 슬라이더 (0-100%)
  - 시각적 볼륨 바
- **게임플레이 설정**:
  - Push Notifications 토글
- **데이터 관리**:
  - 💾 Save Game (수동 저장)
  - 📂 Load Game (수동 로드)
  - ⚠️ Reset Progress (확인 다이얼로그)
  - 📤 Export Data (준비 중)
- **게임 정보**:
  - 버전 정보 (0.1.0 Alpha)
  - 개발자 정보
  - Credits 버튼 → 크레딧 다이얼로그
  - Help 버튼 → 도움말 다이얼로그
- **다이얼로그 시스템**:
  - 확인 다이얼로그 (Reset용, 빨간 테두리)
  - 정보 다이얼로그 (Credits/Help용)
  - 오버레이 배경 (반투명 검정)
- **시각적 특징**:
  - 섹션별 구분 (제목 + 여백)
  - 토글 버튼: 녹색(ON) / 회색(OFF)
  - 볼륨 컨트롤: +/- 버튼 + 진행 바
  - 경고 버튼: 빨간색 (Reset)
  - 설정 버튼: 홈 화면 우측 상단 ⚙️

**UI 레이아웃**:
```
┌─────────────────────────────────────────┐
│  Settings                    [← Back]   │
├─────────────────────────────────────────┤
│  Audio Settings                          │
│  Sound Effects              [ON]         │
│  Background Music           [OFF]        │
│  Sound Volume: 100% [-][+] [████████]  │
│  Music Volume: 70%  [-][+] [██████░░]  │
│                                          │
│  Gameplay Settings                       │
│  Push Notifications         [ON]         │
│                                          │
│  Data Management                         │
│  [💾 Save] [📂 Load]                    │
│  [⚠️ Reset] [📤 Export]                  │
│                                          │
│  Game Information                        │
│  Version: 0.1.0 (Alpha)                  │
│  Developer: MG Games Studio              │
│  [Credits] [Help]                        │
└─────────────────────────────────────────┘
```

#### [TutorialScene](d:\mg-games\repos\mg-game-0002\game\lib\game\scenes\tutorial_scene.dart) ⭐ NEW
**기능**:
- **인터랙티브 튜토리얼 시스템**: 13단계 step-by-step 가이드
- **튜토리얼 단계**:
  1. Welcome - 게임 소개 및 개요
  2. Resources - 골드와 젬 설명
  3. Gathering - 재료 수집 방법
  4. Crafting - 포션 제작 방법
  5. Inventory - 인벤토리 관리
  6. Recipe Codex - 레시피 발견 시스템
  7. Customer Orders - 주문 완료 방법
  8. Shop - 아이템 구매 및 판매
  9. Workshop Upgrades - 업그레이드 시스템
  10. Cat Companion - 고양이 케어
  11. Achievements - 업적 시스템
  12. Tips for Success - 전문가 팁
  13. You're Ready - 완료 메시지
- **각 단계 구성**:
  - 큰 아이콘 (80px)
  - 제목 + 설명 텍스트
  - 💡 Tips 박스 (3-4개 팁)
  - 팁 박스는 레몬 시폰 배경 + 금색 테두리
- **내비게이션**:
  - Previous/Next 버튼으로 이동
  - Skip Tutorial 버튼 (언제든 종료)
  - 마지막 단계에서 "Finish! ✓" 버튼
- **진행도 표시**:
  - 숫자 (1/13, 2/13...)
  - 진행 바 (0-100%)
  - 단계별 점 (완료: 녹색, 미완료: 회색)
- **시각적 디자인**:
  - 콘실크 배경 (따뜻한 크림색)
  - 팁 박스: 레몬 시폰 + 골든로드 테두리
  - 버튼: Previous (파란색), Next (녹색), Skip (회색)

**UI 레이아웃**:
```
┌─────────────────────────────────────────┐
│  [← Back]         Tutorial     [Skip]   │
├─────────────────────────────────────────┤
│                                         │
│              🏠 (80px)                  │
│                                         │
│     Welcome to Cat Alchemy Workshop!    │
│                                         │
│   You are an alchemist running a...     │
│                                         │
│  ┌─────────────────────────────────┐   │
│  │ 💡 Tips:                        │   │
│  │  • This is your workshop hub    │   │
│  │  • All features accessible here │   │
│  │  • Your cat will help gather    │   │
│  └─────────────────────────────────┘   │
│                                         │
│          1 / 13                         │
│     [▓▓▓░░░░░░░░░░]                   │
│     • ● ○ ○ ○ ○ ○ ○ ○ ○ ○ ○ ○          │
│                                         │
│  [← Previous]            [Next →]      │
└─────────────────────────────────────────┘
```

#### [CollectionScene](d:\mg-games\repos\mg-game-0002\game\lib\game\scenes\collection_scene.dart) ⭐ NEW
**기능**:
- **수집 도감 시스템**: 재료와 포션의 발견/미발견 추적
- **2개 탭**:
  - 🌿 Materials: 6종 재료 (들풀, 꽃, 버섯, 수정, 달꽃잎, 용비늘)
  - ⚗️ Potions: 7종 포션 (힐링~불멸의 엘릭서)
- **희귀도 시스템**:
  - Common (회색) - 기본 아이템
  - Uncommon (녹색) - 일반적
  - Rare (파란색) - 희귀
  - Epic (보라색) - 영웅급
  - Legendary (금색) - 전설급
- **수집 카드**:
  - 발견됨: 아이콘, 이름, 카테고리, 희귀도 배지, 통계
  - 미발견: 🔒 자물쇠 + ??? 표시 (어두운 배경)
  - 희귀도별 테두리 색상
- **아이템 상세 정보**:
  - 큰 아이콘 (80px)
  - 이름 + 희귀도 + 카테고리
  - 상세 설명
  - 수집 통계 (채집 횟수 / 제작 횟수)
  - 오버레이 방식 표시
- **통계 추적**:
  - 재료: 채집 횟수
  - 포션: 제작 횟수, 티어
  - 발견률 표시 (X/Total, %)
- **시각적 디자인**:
  - 앨리스 블루 배경
  - 2열 그리드 레이아웃
  - 희귀도별 색상 구분
  - 발견 시 상세 정보 확대 표시

**재료 목록**:
- 🌿 Wild Grass (Common, Herb)
- 🌼 Blue Flower (Common, Flower)
- 🍄 Magic Mushroom (Uncommon, Fungus)
- 💎 Crystal Shard (Rare, Mineral)
- 🌙 Moon Petal (Epic, Flower)
- 🐉 Dragon Scale (Legendary, Monster)

**포션 목록**:
- ⚗️ Minor Healing (Tier 1, Common)
- 🧪 Healing (Tier 2, Common)
- 💙 Mana (Tier 2, Uncommon)
- 💪 Strength (Tier 2, Uncommon)
- ⚡ Speed (Tier 3, Rare)
- 👻 Invisibility (Tier 4, Epic)
- ✨ Immortality (Tier 5, Legendary)

**UI 레이아웃**:
```
┌─────────────────────────────────────────┐
│  [← Back]    📚 Collection Codex        │
│                                         │
│      Discovered: 4 / 7 (57.1%)          │
│                                         │
│  [🌿 Materials]  [⚗️ Potions]           │
├─────────────────────────────────────────┤
│  ┌────────────┐  ┌────────────┐        │
│  │ 🧪 Healing │  │ 💙 Mana    │        │
│  │ Common     │  │ Uncommon   │        │
│  │ Tier 2     │  │ Tier 2     │        │
│  │ Crafted: 5 │  │ Crafted: 3 │        │
│  └────────────┘  └────────────┘        │
│  ┌────────────┐  ┌────────────┐        │
│  │    🔒      │  │    🔒      │        │
│  │    ???     │  │    ???     │        │
│  │            │  │            │        │
│  └────────────┘  └────────────┘        │
└─────────────────────────────────────────┘
```

#### [LeaderboardScene](d:\mg-games\repos\mg-game-0002\game\lib\game\scenes\leaderboard_scene.dart) ⭐ NEW
**기능**:
- **글로벌 랭킹 시스템**: 4가지 카테고리별 순위 경쟁
- **4개 카테고리**:
  - ⚗️ Potions: 총 포션 제작 수
  - 💰 Wealth: 누적 골드
  - ⭐ Reputation: 평판 점수
  - 🔨 Crafts: 마스터 제작 완료 수
- **순위 표시**:
  - Top 10 리더보드 (실시간 갱신)
  - 1위: 금색 배지 🥇
  - 2위: 은색 배지 🥈
  - 3위: 동메달 배지 🥉
  - 4위~10위: 회색 배지
- **플레이어 랭킹**:
  - 하단에 고정 표시
  - 금색 테두리 하이라이트
  - "Your Rank" 레이블
  - 현재 점수 및 순위
- **리더보드 테이블**:
  - 헤더: Rank | Player | Score
  - 줄무늬 배경 (가독성)
  - 점수 포맷팅 (K, M 단위)
- **시각적 디자인**:
  - 허니듀 배경 (밝은 녹색)
  - 카테고리별 아이콘 버튼
  - 활성 카테고리 색상 하이라이트
  - 금색 타이틀 (🏆 Global Leaderboard)
- **목 데이터**:
  - 20명의 NPC 플레이어
  - 다양한 닉네임 (AlchemistAce, PotionMaster...)
  - 카테고리별 점수 차등

**카테고리 상세**:
- **Potions**: 총 제작 포션 수 (10,000 ~ 500)
- **Wealth**: 누적 골드 (100,000 ~ 5,000)
- **Reputation**: 평판 점수 (5,000 ~ 250)
- **Crafts**: 마스터 제작 횟수 (1,000 ~ 50)

**UI 레이아웃**:
```
┌─────────────────────────────────────────┐
│  [← Back]   🏆 Global Leaderboard       │
│                                         │
│         Total Potions Crafted           │
│                                         │
│  [⚗️]  [💰]  [⭐]  [🔨]                 │
├─────────────────────────────────────────┤
│  Rank  │  Player         │  Score       │
├─────────────────────────────────────────┤
│   🥇1  │ AlchemistAce    │   10.0K      │
│   🥈2  │ PotionMaster    │    9.5K      │
│   🥉3  │ BrewWizard      │    9.0K      │
│    4   │ MysticCrafter   │    8.5K      │
│   ...  │       ...       │    ...       │
│   10   │ StardustBrew    │    5.5K      │
├─────────────────────────────────────────┤
│  Your Rank                              │
│   🏅23 │ You             │    250       │
└─────────────────────────────────────────┘
```

#### [EventsScene](d:\mg-games\repos\mg-game-0002\game\lib\game\scenes\events_scene.dart) ⭐ NEW
**기능**:
- **한정 이벤트 시스템**: 시간 제한 챌린지와 특별 보상
- **3가지 이벤트 상태**:
  - 🔥 Active Events: 진행 중인 이벤트 (진행도 추적)
  - ⏰ Upcoming Events: 예정된 이벤트 (시작 일시)
  - ✓ Completed Events: 종료된 이벤트 (과거 기록)
- **활성 이벤트** (2개):
  - 🌸 Spring Flower Festival: 봄꽃 수집 및 시즌 포션 제작 (35% 진행, 6일 남음)
  - 💰 Golden Week: 모든 판매/주문에서 2배 골드 (60% 진행, 2일 남음)
- **예정 이벤트** (2개):
  - ⚗️ Potion Master Challenge: 전설 포션 50개 제작 (3일 후 시작, 하드)
  - 🐱 Cat Companion Festival: 고양이와 놀기 보너스 (7일 후 시작, 이지)
- **이벤트 카드**:
  - 큰 아이콘 + 이름 + 설명
  - 상태 배지 (ACTIVE/UPCOMING/ENDED)
  - 진행 바 (활성 이벤트만)
  - 남은 시간 표시 (일/시간/분)
  - 난이도 색상 테두리
- **보상 시스템**:
  - 골드 💰
  - 젬 💎
  - 특별 아이템 📦 (Spring Elixir, Master Badge...)
- **난이도 등급**:
  - Easy (녹색)
  - Normal (파란색)
  - Hard (주황색)
- **상세 정보 패널**:
  - 이벤트 전체 설명
  - 보상 목록 (상세)
  - 난이도 배지
  - 남은 시간
  - 오버레이 다이얼로그
- **시각적 디자인**:
  - 플로럴 화이트 배경
  - 딥 핑크 타이틀 (🎪 Special Events)
  - 이벤트별 테마 컬러
  - 섹션 헤더 구분

**이벤트 예시**:
- **Spring Festival** (Normal): 5000g, 100💎, Spring Elixir, Flower Crown
- **Golden Week** (Easy): 10000g, 50💎
- **Potion Master** (Hard): 20000g, 500💎, Master Badge
- **Cat Party** (Easy): 3000g, 150💎, Cat Toy, Premium Food

**UI 레이아웃**:
```
┌─────────────────────────────────────────┐
│  [← Back]     🎪 Special Events         │
│  Limited-time challenges and rewards!   │
│                                         │
│  🔥 Active Events                       │
│  ┌───────────────────────────────────┐ │
│  │ 🌸  Spring Flower Festival        │ │
│  │     Collect rare spring flowers   │ │
│  │     [ACTIVE]    ⏰ 6d 5h remaining│ │
│  │     [▓▓▓░░░░░░] 35/100  (35%)    │ │
│  └───────────────────────────────────┘ │
│  ┌───────────────────────────────────┐ │
│  │ 💰  Golden Week                   │ │
│  │     Earn 2x gold from sales!      │ │
│  │     [ACTIVE]    ⏰ 2d 1h remaining│ │
│  │     [▓▓▓▓▓▓░░░░] 60/100  (60%)   │ │
│  └───────────────────────────────────┘ │
│                                         │
│  ⏰ Upcoming Events                     │
│  ┌───────────────────────────────────┐ │
│  │ ⚗️  Potion Master Challenge       │ │
│  │     Craft 50 legendary potions    │ │
│  │     [UPCOMING]  ⏰ Starts in 3d 2h│ │
│  └───────────────────────────────────┘ │
└─────────────────────────────────────────┘
```

---

## 게임 플로우 예시

### 전체 루프:
```
1. [Home] → Click "🌿 Gathering"
2. [Gathering] → Click materials → Gather (2s animation) → +3 들풀
3. [Gathering] → Click "← Back"
4. [Home] → Click "🔨 Crafting"
5. [Crafting] → Select recipe → Check ingredients → Click "Craft"
6. [Crafting] → Wait for timer (30s) → Click "Collect"
7. [Crafting] → Click "← Back"
8. [Home] → Click "🛒 Shop"
9. [Shop] → Click "Sell Potions" → Select potion → Click "Sell (x1)" → +50 gold
10. [Shop] → Click "Buy Materials" → Select material → Click "Buy (x10)" → -100 gold, +10 materials
11. [Shop] → Click "← Back"
12. [Home] → Repeat!
```

---

## 기술 아키텍처

### 데이터 플로우:
```
JSON Files (assets/data/)
    ↓
GameDataSource (load & cache)
    ↓
GameRepository (business logic)
    ↓
Riverpod Providers (reactive state)
    ↓
Flame Components (UI rendering)
```

### 상태 관리:
```
User Action (tap, button click)
    ↓
GameStateNotifier.method()
    ↓
state = new GameState(...) [immutable update]
    ↓
Hive.save() [automatic persistence]
    ↓
UI re-render [Riverpod watch]
```

### 씬 네비게이션:
```
Scene Component
    ↓
gameRef.navigateTo('scene_name')
    ↓
CatAlchemyGame._loadScene()
    ↓
removeAll(children) → add(NewScene)
```

---

## 리소스 생성 프롬프트

**문서**: [resource_generation_prompts.md](d:\mg-games\repos\mg-game-0002\docs\resource_generation_prompts.md) (530줄)

**포함 내용**:
- 64개 이미지 프롬프트 (재료, 포션, 캐릭터, 배경, UI, VFX)
- 20개 음원 프롬프트 (BGM 3곡, SFX 17개)
- AI 도구 추천 (Midjourney, DALL-E 3, Suno AI)
- 워크플로우 및 최적화 팁

---

## 다음 단계

### 즉시 가능한 작업 (높음 우선순위)
1. **게임 밸런싱 테스트**
   - 수집 → 제작 → 판매 루프 밸런스 확인
   - 재료 가격, 포션 가격 조정
   - 제작 시간 조정

2. **OrdersScene 구현**
   - NPC 주문 시스템
   - 주문 생성 알고리즘
   - 주문 완료 보상

3. **CatScene 구현**
   - 고양이 상호작용 (쓰다듬기, 간식, 놀기)
   - 신뢰도 시스템
   - 스킬 효과 적용

### 추가 기능 (중간 우선순위)
4. **튜토리얼 시스템**
   - 첫 수집, 첫 제작, 첫 판매 가이드
   - 화살표 표시 및 설명 팝업

5. **업적 시스템**
   - 첫 포션 제작, 100골드 획득 등
   - 보상 (젬, 특별 레시피)

6. **레시피 발견 시스템**
   - 재료 조합 실험 UI
   - 발견 시 특수 효과

### 폴리싱 (낮은 우선순위)
7. **애니메이션 추가**
   - 버튼 눌림 효과
   - 재료 수집 파티클
   - 제작 완료 효과

8. **사운드 통합**
   - BGM 재생 (씬별)
   - SFX 트리거

9. **설정 화면**
   - 볼륨 조절
   - 언어 선택
   - 데이터 리셋

---

## 현재 진행 상황 요약

| 분야 | 진행도 | 상태 |
|-----|--------|------|
| **코어 시스템** | 100% | ✅ 완료 |
| **상태 관리** | 100% | ✅ 완료 |
| **UI 컴포넌트** | 100% | ✅ 완료 |
| **씬 구현** | 31.25% (5/16) | 🟡 진행 중 |
| **게임 데이터** | 100% | ✅ 완료 |
| **리소스** | 0% (프롬프트만) | ⏳ 대기 |

### 플레이 가능한 기능:
- ✅ 재료 수집
- ✅ 포션 제작
- ✅ 포션 판매
- ✅ 재료 구매
- ✅ 인벤토리 관리
- ✅ 게임 저장/로드
- ❌ NPC 주문 (미구현)
- ❌ 고양이 상호작용 (미구현)
- ❌ 공방 업그레이드 (미구현)

---

## 기술 스택

| 분야 | 기술 | 버전 |
|-----|------|------|
| 프레임워크 | Flutter | 3.27+ |
| 게임 엔진 | Flame | 1.20+ |
| 상태 관리 | Riverpod | 2.x |
| 로컬 저장 | Hive | 2.x |
| 언어 | Dart | 3.5+ |

---

## 알려진 이슈

### 버그:
- 없음 (현재까지)

### 개선 필요:
1. **CraftingScene**: 제작 큐 UI가 정적 (타이머 업데이트만 동적)
2. **GatheringScene**: 노드 재생성 로직 단순 (30% 고정)
3. **ShopScene**: 판매 후 전체 UI 리빌드 (비효율적)
4. **메모리 관리**: 씬 전환 시 이전 씬 컴포넌트 정리 필요

### 누락된 기능:
1. 오프라인 보상 UI 팝업 (계산은 완료, 표시만 누락)
2. 레시피 발견 시스템 (자유 제작 모드)
3. 고양이 레벨 계산 로직 (신뢰도 → 레벨)
4. 공방 업그레이드 시스템
5. 평판 시스템

---

## 개발 타임라인

| 날짜 | 마일스톤 | 상태 |
|------|---------|------|
| 2025-12-17 (오전) | 프로젝트 설정, 데이터 정의, 코어 시스템 | ✅ |
| 2025-12-17 (오후) | UI 컴포넌트, 씬 구현 (Crafting, Gathering, Shop) | ✅ |
| 2025-12-18 (예정) | OrdersScene, CatScene, 튜토리얼 | 🔜 |
| 2025-12-19 (예정) | 밸런싱, 버그 수정, 애니메이션 | 🔜 |
| 2025-12-20 (예정) | 리소스 통합, 오디오, 폴리싱 | 🔜 |
| 2025-12-21~23 (예정) | 테스트, 최적화 | 🔜 |
| 2025-12-24 (예정) | 알파 빌드 완성 🎉 | 🔜 |

---

**작성일**: 2025-12-17
**버전**: v0.2.0-alpha (플레이 가능 버전)
**작성자**: Claude Code (Anthropic)

---

## 참고 문서
- [Scene Structure](scene_structure.md): 16개 씬의 상세 설계
- [Resource Generation Prompts](resource_generation_prompts.md): AI 리소스 생성 가이드
- [Prototype Priority Plan](../../mg-meta/docs/prototype_priority_plan.md): 게임 우선순위 및 전체 로드맵
