import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/colors.dart';
import '../widgets/glass_card.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({Key? key}) : super(key: key);

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();

  String _activeTab = 'All';
  String _searchQuery = '';
  String? _playingSoundLabel;
  bool _audioLoading = false;
  double _volume = 0.8;

  final List<String> _categories = ["All", "Breathing", "Grounding", "Sleep", "Focus"];

  final List<Map<String, dynamic>> _sounds = [
    {'label': 'Ocean', 'icon': Icons.waves, 'url': 'https://www.soundjay.com/nature/sounds/ocean-wave-1.mp3'},
    {'label': 'Rain', 'icon': Icons.grain, 'url': 'https://www.soundjay.com/nature/sounds/rain-07.mp3'},
    {'label': 'Fire', 'icon': Icons.local_fire_department, 'url': 'https://www.soundjay.com/nature/sounds/fire-1.mp3'},
    {'label': 'Forest', 'icon': Icons.forest, 'url': 'https://www.soundjay.com/nature/sounds/river-1.mp3'},
  ];

  final List<Map<String, dynamic>> _copingTools = [
    {'id': '1', 'icon': Icons.waves, 'title': 'Sound Bath', 'subtitle': 'Calming frequencies', 'time': '5 min', 'tag': 'Sleep', 'color': AppColors.teal},
    {'id': '2', 'icon': Icons.air, 'title': 'Box Breathing', 'subtitle': 'Calm your mind and reduce stress', 'time': '4 min', 'tag': 'Breathing', 'color': AppColors.purpleLight},
    {'id': '3', 'icon': Icons.forest, 'title': 'Body Scan', 'subtitle': 'Reconnect with your body', 'time': '10 min', 'tag': 'Grounding', 'color': AppColors.peach},
    {'id': '4', 'icon': Icons.auto_awesome, 'title': 'Affirmations', 'subtitle': 'Positive daily reminders', 'time': '3 min', 'tag': 'Focus', 'color': AppColors.coral},
    {'id': '5', 'icon': Icons.pin_drop, 'title': 'Grounding 5-4-3-2-1', 'subtitle': 'Anchor yourself in the present', 'time': '6 min', 'tag': 'Grounding', 'color': AppColors.teal},
    {'id': '6', 'icon': Icons.nightlight_outlined, 'title': 'Sleep Story', 'subtitle': 'Drift into peaceful rest', 'time': '20 min', 'tag': 'Sleep', 'color': AppColors.purpleDark},
  ];

  Future<void> _changeVolume(double val) async {
    setState(() {
      _volume = val;
    });
    await _audioPlayer.setVolume(val);
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _audioPlayer.setVolume(_volume);
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        if (mounted) setState(() => _audioLoading = false);
      }
    });
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _handleSoundPress(Map<String, dynamic> soundItem) async {
    final label = soundItem['label'] as String;
    final url = soundItem['url'] as String;

    if (_audioLoading) return;

    if (_playingSoundLabel == label) {
      setState(() => _audioLoading = true);
      try {
        await _audioPlayer.stop();
        setState(() {
          _playingSoundLabel = null;
          _audioLoading = false;
        });
      } catch (e) {
        setState(() => _audioLoading = false);
      }
      return;
    }

    setState(() {
      _audioLoading = true;
      _playingSoundLabel = label;
    });

    try {
      await _audioPlayer.stop();
      await _audioPlayer.setVolume(_volume);
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.play(UrlSource(url));
    } catch (e) {
      setState(() {
        _playingSoundLabel = null;
        _audioLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredTools = _copingTools.where((t) {
      final matchesTab = _activeTab == 'All' || t['tag'] == _activeTab;
      final matchesSearch = t['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t['subtitle'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesTab && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildHeader().animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
                const SizedBox(height: 24),
                _buildSearchBar().animate().fadeIn(delay: 100.ms, duration: 400.ms),
                const SizedBox(height: 24),
                _buildCategoryTabs().animate().fadeIn(delay: 200.ms, duration: 400.ms).slideX(begin: 0.1),
                const SizedBox(height: 24),
                if (_searchQuery.isEmpty)
                  _buildRecommendedCard().animate().fadeIn(delay: 300.ms, duration: 400.ms).scale(begin: const Offset(0.9, 0.9)),
                if (_searchQuery.isEmpty) const SizedBox(height: 24),
                _buildSoundboard().animate().fadeIn(delay: 400.ms, duration: 400.ms).slideY(begin: 0.2),
                const SizedBox(height: 24),
                Text(
                  'ALL COPING TOOLS',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.mutedText(context),
                    letterSpacing: 1.5,
                  ),
                ).animate().fadeIn(delay: 500.ms),
                const SizedBox(height: 16),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.85,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildToolCard(filteredTools[index])
                      .animate().fadeIn(delay: Duration(milliseconds: 300 + (index * 100))).slideY(begin: 0.1);
                },
                childCount: filteredTools.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Safe Space',
          style: GoogleFonts.playfairDisplay(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: AppColors.text(context),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Coping Library',
          style: GoogleFonts.inter(
            fontSize: 14,
            color: AppColors.mutedText(context),
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    final isDark = AppColors.isDark(context);
    return Container(
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : AppColors.borderLight),
        boxShadow: isDark
            ? []
            : [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 8)],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: TextField(
        controller: _searchController,
        style: GoogleFonts.inter(color: AppColors.text(context), fontSize: 15),
        onChanged: (val) {
          setState(() {
            _searchQuery = val;
          });
        },
        decoration: InputDecoration(
          icon: Icon(Icons.search, color: AppColors.mutedText(context)),
          hintText: 'Search tools, exercises...',
          hintStyle: GoogleFonts.inter(color: AppColors.mutedText(context).withOpacity(0.6)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final isDark = AppColors.isDark(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: _categories.map((cat) {
          final isActive = _activeTab == cat;
          return GestureDetector(
            onTap: () {
              setState(() {
                _activeTab = cat;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isActive ? AppColors.purple : (isDark ? Colors.white.withOpacity(0.05) : Colors.white),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? Colors.transparent : (isDark ? Colors.white.withOpacity(0.1) : AppColors.borderLight),
                ),
                boxShadow: isActive ? [BoxShadow(color: AppColors.purple.withOpacity(0.3), blurRadius: 12)] : [],
              ),
              child: Text(
                cat,
                style: GoogleFonts.inter(
                  color: isActive ? Colors.white : AppColors.mutedText(context),
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildRecommendedCard() {
    final isDark = AppColors.isDark(context);
    return GlassCard(
      glow: true,
      padding: const EdgeInsets.all(0),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [AppColors.purple.withOpacity(0.6), AppColors.purpleDark.withOpacity(0.6)]
                : [AppColors.purple.withOpacity(0.8), AppColors.purpleDark.withOpacity(0.8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text('RECOMMENDED', style: GoogleFonts.inter(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Box Breathing',
                    style: GoogleFonts.playfairDisplay(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '4 minutes • Reduce anxiety instantly',
                    style: GoogleFonts.inter(fontSize: 12, color: Colors.white.withOpacity(0.8)),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)]),
                    child: const Icon(Icons.play_arrow_rounded, color: AppColors.purple, size: 24),
                  ),
                ],
              ),
            ),
            Icon(Icons.air, color: Colors.white.withOpacity(0.3), size: 100),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundboard() {
    final isDark = AppColors.isDark(context);
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AMBIENT SOUNDS',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.mutedText(context),
                  letterSpacing: 1.5,
                ),
              ),
              if (_playingSoundLabel != null && _audioLoading)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.purpleLight),
                )
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _sounds.map((sound) {
              final isPlaying = _playingSoundLabel == sound['label'];
              return GestureDetector(
                onTap: () => _handleSoundPress(sound),
                child: Column(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: isPlaying
                            ? AppColors.teal.withOpacity(0.2)
                            : (isDark ? Colors.white.withOpacity(0.05) : AppColors.bgElevatedLight),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isPlaying
                              ? AppColors.teal
                              : (isDark ? Colors.white.withOpacity(0.1) : AppColors.borderLight),
                          width: isPlaying ? 2 : 1,
                        ),
                        boxShadow: isPlaying ? [BoxShadow(color: AppColors.teal.withOpacity(0.3), blurRadius: 12)] : [],
                      ),
                      child: Icon(
                        sound['icon'] as IconData,
                        color: isPlaying ? AppColors.teal : AppColors.mutedText(context),
                        size: 24,
                      ),
                    ).animate(target: isPlaying ? 1 : 0).shimmer(duration: 1.seconds, color: Colors.white54),
                    const SizedBox(height: 8),
                    Text(
                      sound['label'] as String,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: isPlaying ? AppColors.text(context) : AppColors.mutedText(context),
                        fontWeight: isPlaying ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
          if (_playingSoundLabel != null) ...[
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.volume_down_rounded, color: AppColors.mutedText(context), size: 20),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.teal,
                      inactiveTrackColor: isDark ? Colors.white.withOpacity(0.1) : AppColors.borderLight,
                      thumbColor: Colors.white,
                      trackHeight: 4,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    ),
                    child: Slider(
                      value: _volume,
                      min: 0.0,
                      max: 1.0,
                      onChanged: _changeVolume,
                    ),
                  ),
                ),
                Icon(Icons.volume_up_rounded, color: AppColors.mutedText(context), size: 20),
              ],
            ).animate().fadeIn(duration: 400.ms),
          ]
        ],
      ),
    );
  }

  Widget _buildToolCard(Map<String, dynamic> tool) {
    final Color color = tool['color'] as Color;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withOpacity(0.3)),
                ),
                child: Icon(tool['icon'] as IconData, color: color, size: 20),
              ),
              Text(
                tool['time'] as String,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.mutedText(context),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            tool['title'] as String,
            style: GoogleFonts.inter(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.text(context),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tool['subtitle'] as String,
            style: GoogleFonts.inter(
              fontSize: 11,
              color: AppColors.mutedText(context),
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
