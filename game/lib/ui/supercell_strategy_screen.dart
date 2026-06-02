/// Supercell Strategy Integration Screen for Cat Alchemy
///
/// Displays comprehensive Supercell validation results and live ops planning.
library;

import 'package:flutter/material.dart';
import '../supercell/prototype_validator.dart';
import '../supercell/playable_fun_validator.dart';
import '../events/cat_alchemy_live_ops_manager.dart';
import '../meta/cat_alchemy_depth_systems.dart';

/// Main Supercell strategy screen
class SupercellStrategyScreen extends StatefulWidget {
  const SupercellStrategyScreen({super.key});

  @override
  State<SupercellStrategyScreen> createState() => _SupercellStrategyScreenState();
}

class _SupercellStrategyScreenState extends State<SupercellStrategyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Validation results
  late KillDecisionResult _prototypeResult;
  late PlayableFunResult _playableFunResult;
  late DepthAnalysisResult _depthResult;
  late String _liveOpsReport;

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _runValidation();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _runValidation() async {
    // Run all Supercell validations
    final prototypeValidator = CatAlchemyPrototypeValidator();
    final playableFunValidator = CatAlchemyPlayableFunValidator();
    final depthAnalyzer = CatAlchemyDepthAnalyzer();
    final liveOpsManager = CatAlchemyLiveOpsManager();

    _prototypeResult = prototypeValidator.makeKillDecision();
    _playableFunResult = playableFunValidator.validate();
    _depthResult = depthAnalyzer.analyzeDepth();
    _liveOpsReport = liveOpsManager.generateReport();

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supercell Strategy Validation'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Prototype', icon: Icon(Icons.science)),
            Tab(text: 'Playable Fun', icon: Icon(Icons.videogame_asset)),
            Tab(text: 'Depth', icon: Icon(Icons.trending_up)),
            Tab(text: 'Live Ops', icon: Icon(Icons.event)),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildPrototypeTab(),
                _buildPlayableFunTab(),
                _buildDepthTab(),
                _buildLiveOpsTab(),
              ],
            ),
    );
  }

  Widget _buildPrototypeTab() {
    final isKilled = _prototypeResult.shouldKill;
    final isApproved = _prototypeResult.shouldProceed;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Decision Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isKilled
                  ? Colors.red.shade100
                  : isApproved
                      ? Colors.green.shade100
                      : Colors.orange.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(
                  isKilled ? Icons.cancel : Icons.check_circle,
                  size: 48,
                  color: isKilled ? Colors.red : Colors.green,
                ),
                const SizedBox(height: 8),
                Text(
                  _prototypeResult.decision.displayName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  'Overall Score: ${_prototypeResult.scores.overall.toStringAsFixed(1)}/5.0',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(_prototypeResult.reason),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Detailed Scores
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Prototype Scores',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  _buildScoreBar('Concept Strength', _prototypeResult.scores.conceptStrength, 2.0),
                  _buildScoreBar('Core Loop Clarity', _prototypeResult.scores.coreLoopClarity, 2.0),
                  _buildScoreBar('Mechanics Viability', _prototypeResult.scores.mechanicsViability, 1.0),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Full Report
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                CatAlchemyPrototypeValidator().generateReport(),
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayableFunTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Result
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _playableFunResult.overallPass
                  ? Colors.green.shade100
                  : Colors.red.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(
                  _playableFunResult.overallPass ? Icons.check_circle : Icons.cancel,
                  size: 48,
                  color: _playableFunResult.overallPass ? Colors.green : Colors.red,
                ),
                const SizedBox(height: 8),
                Text(
                  _playableFunResult.overallPass ? '✅ READY FOR DEVELOPMENT' : '❌ NEEDS IMPROVEMENT',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('Fun Score: ${_playableFunResult.funScore.toStringAsFixed(1)}/5.0'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Detailed Report
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _playableFunResult.report,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDepthTab() {
    final isDeepEnough = _depthResult.isDeepEnough;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall Result
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDeepEnough
                  ? Colors.green.shade100
                  : Colors.orange.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              children: [
                Icon(
                  isDeepEnough ? Icons.check_circle : Icons.warning,
                  size: 48,
                  color: isDeepEnough ? Colors.green : Colors.orange,
                ),
                const SizedBox(height: 8),
                Text(
                  isDeepEnough ? '✅ DEEP ENOUGH' : '⚠️ NEEDS MORE DEPTH',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('${_depthResult.skillFloor} → ${_depthResult.skillCeiling}'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Detailed Report
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _depthResult.report,
                style: const TextStyle(fontFamily: 'monospace'),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Meta-Game Systems
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Meta-Game Systems',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _depthResult.availableSystems.map((system) {
                      return Chip(
                        label: Text(system.name),
                        avatar: const Icon(Icons.star, size: 16),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveOpsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            _liveOpsReport,
            style: const TextStyle(fontFamily: 'monospace'),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreBar(String label, double value, double max) {
    final percentage = (value / max).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text('${value.toStringAsFixed(1)}/$max'),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage,
          backgroundColor: Colors.grey.shade300,
          valueColor: AlwaysStoppedAnimation<Color>(
            percentage >= 0.7 ? Colors.green : percentage >= 0.5 ? Colors.orange : Colors.red,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
