import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

void main() {
  runApp(const MyApp());
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}

// ─── App ──────────────────────────────────────────────────────────────────────

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => MyAppState(),
      child: MaterialApp(
        title: 'Baby Name Finder',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A56A0),
          ),
          navigationRailTheme: const NavigationRailThemeData(
            indicatorColor: Color(0xFF1A56A0),
            selectedIconTheme: IconThemeData(color: Colors.white),
            selectedLabelTextStyle: TextStyle(
              color: Color(0xFF1A56A0),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

// ─── State ────────────────────────────────────────────────────────────────────

class MyAppState extends ChangeNotifier {
  String current = "{Name: Ljósbjört, Description: björt sem ljós., Gender: F}";
  List<String> saved = [];
  List<String> _pool = [];

  MyAppState() {
    _loadJson().then((data) {
      // Store everything as strings so pool.remove(current) works correctly
      _pool = data.map((e) => e.toString()).toList();
      _pickRandom();
    });
  }

  Future<List<dynamic>> _loadJson() async {
    final raw = await rootBundle.loadString('assets/names_json.json');
    return (json.decode(raw) as Map)['names'] as List;
  }

  void _pickRandom() {
    if (_pool.isEmpty) return;
    current = _pool[Random().nextInt(_pool.length)];
    notifyListeners();
  }

  void skipName() => _pickRandom();

  void saveName() {
    saved.add(current);
    _pool.remove(current);
    _pickRandom();
  }

  void removeSaved(String name) {
    saved.remove(name);
    notifyListeners();
  }
}

// ─── Home ─────────────────────────────────────────────────────────────────────

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF4A5FA8), Color(0xFF7B8FD4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Baby Name',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'FINDER',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Color(0xFFCDD6F4),
                letterSpacing: 4,
              ),
            ),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 12),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: const Color(0xFF4A5FA8),
                unselectedLabelColor: Colors.white,
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
                tabs: [
                  const Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.explore, size: 18),
                        SizedBox(width: 6),
                        Text('Discover'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.favorite, size: 18),
                        const SizedBox(width: 6),
                        Text(appState.saved.isEmpty
                            ? 'Saved'
                            : 'Saved (${appState.saved.length})'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [GeneratorPage(), FavoritesPage()],
      ),
    );
  }
}

// ─── Generator Page ───────────────────────────────────────────────────────────

class GeneratorPage extends StatelessWidget {
  const GeneratorPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Discover Baby Names',
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the card to see its meaning',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withOpacity(0.55),
              ),
            ),
            const SizedBox(height: 48),
            NameCard(pair: appState.current),
            const SizedBox(height: 48),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: appState.skipName,
                  icon: const Icon(Icons.close_rounded),
                  label: const Text('Skip'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(width: 20),
                FilledButton.icon(
                  onPressed: appState.saveName,
                  icon: const Icon(Icons.favorite_rounded),
                  label: const Text('Save'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 14),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (appState.saved.isNotEmpty)
              Text(
                '${appState.saved.length} name${appState.saved.length == 1 ? '' : 's'} saved',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Favourites Page ──────────────────────────────────────────────────────────

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final saved = appState.saved;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.favorite_rounded,
                      color: theme.colorScheme.primary, size: 28),
                  const SizedBox(width: 10),
                  Text(
                    'Saved Names',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      '${saved.length}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                saved.isEmpty
                    ? 'Names you save will appear here.'
                    : 'Tap any card to see its meaning  •  Tap × to remove',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.55),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        if (saved.isEmpty)
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.favorite_border_rounded,
                    size: 72,
                    color: theme.colorScheme.onSurface.withOpacity(0.15),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No names saved yet',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.35),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Head to Discover to find names you love',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.25),
                    ),
                  ),
                ],
              ),
            ),
          )
        else
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 32),
              child: Wrap(
                spacing: 14,
                runSpacing: 14,
                // ValueKey ensures each card keeps its own flip state
                // independently, even when the list changes
                children: saved
                    .map((item) => NameCard(
                          key: ValueKey(item),
                          pair: item,
                          onRemove: () => appState.removeSaved(item),
                        ))
                    .toList(),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Name Card ────────────────────────────────────────────────────────────────

class NameCard extends StatefulWidget {
  final String pair;
  final VoidCallback? onRemove;

  const NameCard({Key? key, required this.pair, this.onRemove}) : super(key: key);

  @override
  State<NameCard> createState() => _NameCardState();
}

class _NameCardState extends State<NameCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFlipped = false;
  bool _showBack = false;

  static const double _cardWidth = 420;
  static const double _cardHeight = 260;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 450),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _animation.addListener(() {
      final half = _animation.value >= 0.5;
      if (half != _showBack) setState(() => _showBack = half);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    _isFlipped ? _controller.reverse() : _controller.forward();
    _isFlipped = !_isFlipped;
  }

  @override
  Widget build(BuildContext context) {
    String name, description, gender;
    try {
      final split = widget.pair.split(': ');
      name = split[1].split(',')[0].trim();
      description = split[2].split(', Gender')[0].trim();
      if (description.isNotEmpty) {
        description = description[0].toUpperCase() + description.substring(1);
      }
      gender = split[3][0];
    } catch (_) {
      name = widget.pair;
      description = '';
      gender = 'M';
    }

    final isMale = gender == 'M';
    final cardColor =
        isMale ? const Color(0xFF5EA4E9) : const Color(0xFFF4A8E5);
    final textColor = isMale ? Colors.white : const Color(0xFF5C2060);

    return GestureDetector(
      onTap: _flip,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          final angle = _animation.value * pi;
          // After 90°, counter-rotate the content so it reads correctly
          final contentAngle = _showBack ? pi : 0.0;
          return Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0012)
              ..rotateY(angle),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..rotateY(contentAngle),
              child: Container(
                width: _cardWidth,
                height: _cardHeight,
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: cardColor.withOpacity(0.45),
                      blurRadius: 18,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Stack(
                    children: [
                      _showBack
                          ? _buildBack(description, name, textColor)
                          : _buildFront(name, isMale, textColor),
                      if (widget.onRemove != null)
                        Positioned(
                          top: 8,
                          right: 8,
                          child: GestureDetector(
                            onTap: widget.onRemove,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                size: 16,
                                color: textColor.withOpacity(0.8),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFront(String name, bool isMale, Color textColor) {
    return SizedBox(
      width: _cardWidth,
      height: _cardHeight,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              name,
              style: TextStyle(
                fontSize: 44,
                fontWeight: FontWeight.bold,
                color: textColor,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app_outlined,
                    size: 13, color: textColor.withOpacity(0.5)),
                const SizedBox(width: 5),
                Text(
                  'Tap to see meaning',
                  style: TextStyle(
                    fontSize: 12,
                    color: textColor.withOpacity(0.5),
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBack(String description, String name, Color textColor) {
    return SizedBox(
      width: _cardWidth,
      height: _cardHeight,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              description.isEmpty ? 'No description available.' : description,
              style: TextStyle(
                fontSize: 18,
                color: textColor,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            Text(
              '— $name',
              style: TextStyle(
                fontSize: 14,
                color: textColor.withOpacity(0.6),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.touch_app_outlined,
                    size: 11, color: textColor.withOpacity(0.45)),
                const SizedBox(width: 4),
                Text(
                  'Tap to flip back',
                  style: TextStyle(
                    fontSize: 10,
                    color: textColor.withOpacity(0.45),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
