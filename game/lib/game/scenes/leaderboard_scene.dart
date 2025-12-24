import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/game_providers.dart';
import '../components/game_button.dart';
import '../cat_alchemy_game.dart';

/// Leaderboard scene - global rankings and competition
class LeaderboardScene extends Component with HasGameRef {
  final WidgetRef ref;

  // UI state
  String _currentCategory = 'potions'; // 'potions', 'wealth', 'reputation', 'crafts'

  // UI Components
  late GameButton _backButton;
  late GameButton _potionsCategoryButton;
  late GameButton _wealthCategoryButton;
  late GameButton _reputationCategoryButton;
  late GameButton _craftsCategoryButton;

  // Leaderboard data
  final List<LeaderboardEntry> _currentLeaderboard = [];
  LeaderboardEntry? _playerEntry;

  LeaderboardScene(this.ref);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _generateMockLeaderboard();
    await _setupUI();
  }

  /// Generate mock leaderboard data
  void _generateMockLeaderboard() {
    final gameState = ref.read(gameStateProvider);

    // Mock player names
    final names = [
      'AlchemistAce', 'PotionMaster', 'BrewWizard', 'MysticCrafter',
      'ElixirKing', 'HerbLord', 'CauldronQueen', 'MagicMixer',
      'WitchDoctor', 'SorcererSupreme', 'EnchantedBrew', 'DragonAlchemist',
      'PhoenixPotion', 'CrystalCraft', 'MoonlightMixer', 'StardustBrew',
      'ThunderPotion', 'FrostAlchemist', 'FireCrafter', 'EarthMixer'
    ];

    // Generate leaderboard based on category
    _currentLeaderboard.clear();

    switch (_currentCategory) {
      case 'potions':
        _generatePotionsLeaderboard(names);
        break;
      case 'wealth':
        _generateWealthLeaderboard(names);
        break;
      case 'reputation':
        _generateReputationLeaderboard(names);
        break;
      case 'crafts':
        _generateCraftsLeaderboard(names);
        break;
    }

    // Add player entry
    _addPlayerEntry(gameState);
  }

  /// Generate potions leaderboard
  void _generatePotionsLeaderboard(List<String> names) {
    for (int i = 0; i < 20; i++) {
      final score = 10000 - (i * 500) + (i % 3 * 100); // Varying scores
      _currentLeaderboard.add(LeaderboardEntry(
        rank: i + 1,
        playerName: names[i % names.length],
        score: score,
        icon: '⚗️',
        isPlayer: false,
      ));
    }
  }

  /// Generate wealth leaderboard
  void _generateWealthLeaderboard(List<String> names) {
    for (int i = 0; i < 20; i++) {
      final score = 100000 - (i * 5000) + (i % 5 * 500);
      _currentLeaderboard.add(LeaderboardEntry(
        rank: i + 1,
        playerName: names[i % names.length],
        score: score,
        icon: '💰',
        isPlayer: false,
      ));
    }
  }

  /// Generate reputation leaderboard
  void _generateReputationLeaderboard(List<String> names) {
    for (int i = 0; i < 20; i++) {
      final score = 5000 - (i * 250) + (i % 4 * 50);
      _currentLeaderboard.add(LeaderboardEntry(
        rank: i + 1,
        playerName: names[i % names.length],
        score: score,
        icon: '⭐',
        isPlayer: false,
      ));
    }
  }

  /// Generate crafts leaderboard
  void _generateCraftsLeaderboard(List<String> names) {
    for (int i = 0; i < 20; i++) {
      final score = 1000 - (i * 50) + (i % 3 * 10);
      _currentLeaderboard.add(LeaderboardEntry(
        rank: i + 1,
        playerName: names[i % names.length],
        score: score,
        icon: '🔨',
        isPlayer: false,
      ));
    }
  }

  /// Add player entry to leaderboard
  void _addPlayerEntry(dynamic gameState) {
    int playerScore = 0;
    String icon = '⚗️';

    switch (_currentCategory) {
      case 'potions':
        playerScore = 250; // Mock: total potions crafted
        icon = '⚗️';
        break;
      case 'wealth':
        playerScore = gameState.gold;
        icon = '💰';
        break;
      case 'reputation':
        playerScore = 150; // Mock: reputation points
        icon = '⭐';
        break;
      case 'crafts':
        playerScore = 45; // Mock: total crafts
        icon = '🔨';
        break;
    }

    // Find player rank
    int playerRank = _currentLeaderboard.length + 1;
    for (int i = 0; i < _currentLeaderboard.length; i++) {
      if (playerScore > _currentLeaderboard[i].score) {
        playerRank = i + 1;
        break;
      }
    }

    _playerEntry = LeaderboardEntry(
      rank: playerRank,
      playerName: 'You',
      score: playerScore,
      icon: icon,
      isPlayer: true,
    );
  }

  /// Setup UI components
  Future<void> _setupUI() async {
    final size = gameRef.size;

    // Back button
    _backButton = GameButton(
      text: '← Back',
      onPressed: _navigateBack,
      position: Vector2(20, 20),
      size: Vector2(120, 50),
      fontSize: 18,
      backgroundColor: const Color(0xFF808080),
    );
    add(_backButton);

    // Category buttons
    final centerX = size.x / 2;
    final buttonY = 90.0;
    final buttonWidth = (size.x - 100) / 4;
    final buttonSpacing = 10.0;

    _potionsCategoryButton = GameButton(
      text: '⚗️',
      onPressed: () => _switchCategory('potions'),
      position: Vector2(30, buttonY),
      size: Vector2(buttonWidth, 50),
      fontSize: 24,
      backgroundColor: const Color(0xFF9370DB), // Purple
    );
    add(_potionsCategoryButton);

    _wealthCategoryButton = GameButton(
      text: '💰',
      onPressed: () => _switchCategory('wealth'),
      position: Vector2(30 + buttonWidth + buttonSpacing, buttonY),
      size: Vector2(buttonWidth, 50),
      fontSize: 24,
      backgroundColor: const Color(0xFFFFD700), // Gold
    );
    add(_wealthCategoryButton);

    _reputationCategoryButton = GameButton(
      text: '⭐',
      onPressed: () => _switchCategory('reputation'),
      position: Vector2(30 + (buttonWidth + buttonSpacing) * 2, buttonY),
      size: Vector2(buttonWidth, 50),
      fontSize: 24,
      backgroundColor: const Color(0xFF4169E1), // Blue
    );
    add(_reputationCategoryButton);

    _craftsCategoryButton = GameButton(
      text: '🔨',
      onPressed: () => _switchCategory('crafts'),
      position: Vector2(30 + (buttonWidth + buttonSpacing) * 3, buttonY),
      size: Vector2(buttonWidth, 50),
      fontSize: 24,
      backgroundColor: const Color(0xFF228B22), // Green
    );
    add(_craftsCategoryButton);
  }

  /// Switch category
  void _switchCategory(String category) {
    _currentCategory = category;
    _generateMockLeaderboard();
  }

  /// Navigate back to home
  void _navigateBack() {
    if (gameRef is CatAlchemyGame) {
      (gameRef as CatAlchemyGame).navigateTo('home');
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final size = gameRef.size;

    // Background
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.x, size.y),
      Paint()..color = const Color(0xFFF0FFF0), // Honeydew
    );

    // Title
    _drawTitle(canvas);

    // Category description
    _drawCategoryDescription(canvas);

    // Update category button appearance
    _updateCategoryButtons();

    // Draw leaderboard
    _drawLeaderboard(canvas);

    // Draw player entry at bottom
    _drawPlayerEntry(canvas);
  }

  /// Draw title
  void _drawTitle(Canvas canvas) {
    final size = gameRef.size;
    final centerX = size.x / 2;

    final titlePainter = TextPainter(
      text: const TextSpan(
        text: '🏆 Global Leaderboard',
        style: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFFD700), // Gold
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    titlePainter.layout();
    titlePainter.paint(
      canvas,
      Offset(centerX - titlePainter.width / 2, 30),
    );
  }

  /// Draw category description
  void _drawCategoryDescription(Canvas canvas) {
    final size = gameRef.size;
    final centerX = size.x / 2;

    String description = '';
    switch (_currentCategory) {
      case 'potions':
        description = 'Total Potions Crafted';
        break;
      case 'wealth':
        description = 'Total Gold Accumulated';
        break;
      case 'reputation':
        description = 'Reputation Points';
        break;
      case 'crafts':
        description = 'Master Crafts Completed';
        break;
    }

    final descPainter = TextPainter(
      text: TextSpan(
        text: description,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF4B0082), // Indigo
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    descPainter.layout();
    descPainter.paint(
      canvas,
      Offset(centerX - descPainter.width / 2, 160),
    );
  }

  /// Update category button appearance
  void _updateCategoryButtons() {
    // Reset all to gray
    _potionsCategoryButton.backgroundColor = const Color(0xFF808080);
    _wealthCategoryButton.backgroundColor = const Color(0xFF808080);
    _reputationCategoryButton.backgroundColor = const Color(0xFF808080);
    _craftsCategoryButton.backgroundColor = const Color(0xFF808080);

    // Highlight active category
    switch (_currentCategory) {
      case 'potions':
        _potionsCategoryButton.backgroundColor = const Color(0xFF9370DB);
        break;
      case 'wealth':
        _wealthCategoryButton.backgroundColor = const Color(0xFFFFD700);
        break;
      case 'reputation':
        _reputationCategoryButton.backgroundColor = const Color(0xFF4169E1);
        break;
      case 'crafts':
        _craftsCategoryButton.backgroundColor = const Color(0xFF228B22);
        break;
    }
  }

  /// Draw leaderboard
  void _drawLeaderboard(Canvas canvas) {
    final size = gameRef.size;
    final startY = 200.0;
    final rowHeight = 50.0;
    final maxRows = 10; // Show top 10

    // Header
    _drawLeaderboardHeader(canvas, startY);

    // Entries
    for (int i = 0; i < maxRows && i < _currentLeaderboard.length; i++) {
      final entry = _currentLeaderboard[i];
      final y = startY + 40 + (i * rowHeight);
      _drawLeaderboardRow(canvas, entry, y, i % 2 == 0);
    }
  }

  /// Draw leaderboard header
  void _drawLeaderboardHeader(Canvas canvas, double y) {
    final size = gameRef.size;

    // Header background
    canvas.drawRect(
      Rect.fromLTWH(30, y, size.x - 60, 35),
      Paint()..color = const Color(0xFF2F4F4F), // Dark slate gray
    );

    // Rank
    _drawHeaderText(canvas, 'Rank', 50, y + 10);
    // Name
    _drawHeaderText(canvas, 'Player', 140, y + 10);
    // Score
    _drawHeaderText(canvas, 'Score', size.x - 120, y + 10);
  }

  /// Draw header text
  void _drawHeaderText(Canvas canvas, String text, double x, double y) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFFFFFF), // White
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(x, y));
  }

  /// Draw leaderboard row
  void _drawLeaderboardRow(Canvas canvas, LeaderboardEntry entry, double y, bool isEven) {
    final size = gameRef.size;

    // Row background
    final bgColor = isEven
        ? const Color(0xFFF5F5F5) // White smoke
        : const Color(0xFFFFFFFF); // White

    canvas.drawRect(
      Rect.fromLTWH(30, y, size.x - 60, 48),
      Paint()..color = bgColor,
    );

    // Rank badge
    _drawRankBadge(canvas, entry.rank, 40, y + 10);

    // Player name
    final namePainter = TextPainter(
      text: TextSpan(
        text: entry.playerName,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    namePainter.layout();
    namePainter.paint(canvas, Offset(140, y + 15));

    // Score
    final scorePainter = TextPainter(
      text: TextSpan(
        text: _formatNumber(entry.score),
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Color(0xFF228B22), // Forest green
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    scorePainter.layout();
    scorePainter.paint(canvas, Offset(size.x - 140, y + 15));
  }

  /// Draw rank badge
  void _drawRankBadge(Canvas canvas, int rank, double x, double y) {
    Color badgeColor;
    if (rank == 1) {
      badgeColor = const Color(0xFFFFD700); // Gold
    } else if (rank == 2) {
      badgeColor = const Color(0xFFC0C0C0); // Silver
    } else if (rank == 3) {
      badgeColor = const Color(0xFFCD7F32); // Bronze
    } else {
      badgeColor = const Color(0xFF808080); // Gray
    }

    // Badge circle
    canvas.drawCircle(
      Offset(x + 15, y + 14),
      18,
      Paint()..color = badgeColor,
    );

    // Rank number
    final rankPainter = TextPainter(
      text: TextSpan(
        text: rank.toString(),
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFFFFFFFF), // White
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );
    rankPainter.layout();
    rankPainter.paint(
      canvas,
      Offset(
        x + 15 - rankPainter.width / 2,
        y + 14 - rankPainter.height / 2,
      ),
    );
  }

  /// Draw player entry at bottom
  void _drawPlayerEntry(Canvas canvas) {
    if (_playerEntry == null) return;

    final size = gameRef.size;
    final y = size.y - 100;

    // Background with highlight
    canvas.drawRect(
      Rect.fromLTWH(20, y - 10, size.x - 40, 80),
      Paint()..color = const Color(0xFFFFE4B5), // Moccasin
    );

    // Border
    canvas.drawRect(
      Rect.fromLTWH(20, y - 10, size.x - 40, 80),
      Paint()
        ..style = PaintingStyle.stroke
        ..color = const Color(0xFFFFD700) // Gold
        ..strokeWidth = 3,
    );

    // "Your Rank" label
    final labelPainter = TextPainter(
      text: const TextSpan(
        text: 'Your Rank',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Color(0xFF8B4513), // Saddle brown
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    labelPainter.layout();
    labelPainter.paint(canvas, Offset(40, y));

    // Rank badge
    _drawRankBadge(canvas, _playerEntry!.rank, 40, y + 25);

    // Player name
    final namePainter = TextPainter(
      text: TextSpan(
        text: _playerEntry!.playerName,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    namePainter.layout();
    namePainter.paint(canvas, Offset(140, y + 30));

    // Score
    final scorePainter = TextPainter(
      text: TextSpan(
        text: _formatNumber(_playerEntry!.score),
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF228B22), // Forest green
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    scorePainter.layout();
    scorePainter.paint(canvas, Offset(size.x - 140, y + 30));
  }

  /// Format number with K, M suffixes
  String _formatNumber(int number) {
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(1)}M';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(1)}K';
    } else {
      return number.toString();
    }
  }
}

/// Leaderboard entry model
class LeaderboardEntry {
  final int rank;
  final String playerName;
  final int score;
  final String icon;
  final bool isPlayer;

  LeaderboardEntry({
    required this.rank,
    required this.playerName,
    required this.score,
    required this.icon,
    required this.isPlayer,
  });
}
