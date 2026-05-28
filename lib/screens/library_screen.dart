import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:audioplayers/audioplayers.dart';
import '../theme/colors.dart';

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
    {
      'label': 'Ocean',
      'icon': Icons.waves,
      'url': 'https://www.soundjay.com/nature/sounds/ocean-wave-1.mp3',
    },
    {
      'label': 'Rain',
      'icon': Icons.grain,
      'url': 'https://www.soundjay.com/nature/sounds/rain-07.mp3',
    },
    {
      'label': 'Fire',
      'icon': Icons.local_fire_department,
      'url': 'https://www.soundjay.com/nature/sounds/fire-1.mp3',
    },
    {
      'label': 'Forest',
      'icon': Icons.forest,
      'url': 'https://www.soundjay.com/nature/sounds/river-1.mp3',
    },
  ];

  final List<Map<String, dynamic>> _copingTools = [
    {
      'id': '1',
      'icon': Icons.waves,
      'title': 'Sound Bath',
      'subtitle': 'Calming frequencies',
      'time': '5 min',
      'tag': 'Sleep',
      'color': Color(0xFF4ECDC4)
    },
    {
      'id': '2',
      'icon': Icons.air,
      'title': 'Box Breathing',
      'subtitle': 'Calm your mind and reduce stress',
      'time': '4 min',
      'tag': 'Breathing',
      'color': Color(0xFFA89AF7)
    },
    {
      'id': '3',
      'icon': Icons.forest,
      'title': 'Body Scan',
      'subtitle': 'Reconnect with your body',
      'time': '10 min',
      'tag': 'Grounding',
      'color': Color(0xFFF7C59F)
    },
    {
      'id': '4',
      'icon': Icons.auto_awesome,
      'title': 'Affirmations',
      'subtitle': 'Positive daily reminders',
      'time': '3 min',
      'tag': 'Focus',
      'color': Color(0xFFF7A8D4)
    },
    {
      'id': '5',
      'icon': Icons.pin_drop,
      'title': 'Grounding 5-4-3-2-1',
      'subtitle': 'Anchor yourself in the present',
      'time': '6 min',
      'tag': 'Grounding',
      'color': Color(0xFF4ECDC4)
    },
    {
      'id': '6',
      'icon': Icons.nightlight_outlined,
      'title': 'Sleep Story',
      'subtitle': 'Drift into peaceful rest',
      'time': '20 min',
      'tag': 'Sleep',
      'color': Color(0xFF7C6FF7)
    },
    {
      'id': '7',
      'icon': Icons.spa,
      'title': 'Mindful Breathing',
      'subtitle': 'Slow, intentional breath',
      'time': '7 min',
      'tag': 'Breathing',
      'color': Color(0xFFA89AF7)
    },
    {
      'id': '8',
      'icon': Icons.self_improvement,
      'title': 'Somatic Exercises',
      'subtitle': 'Release stored tension',
      'time': '12 min',
      'tag': 'Focus',
      'color': Color(0xFFF7E08A)
    },
  ];

  @override
  void initState() {
    super.initState();
    _audioPlayer.setReleaseMode(ReleaseMode.loop);
    _audioPlayer.setVolume(_volume);
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.playing) {
        setState(() {
          _audioLoading = false;
        });
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
        print("Failed to stop audio: $e");
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
      print("Error playing audio: $e");
      setState(() {
        _playingSoundLabel = null;
        _audioLoading = false;
      });
    }
  }

  Future<void> _changeVolume(double val) async {
    setState(() {
      _volume = val;
    });
    await _audioPlayer.setVolume(val);
  }

  @override
  Widget build(BuildContext context) {
    // Filter tools
    final filteredTools = _copingTools.where((t) {
      final matchesTab = _activeTab == 'All' || t['tag'] == _activeTab;
      final matchesSearch = t['title'].toString().toLowerCase().contains(_searchQuery.toLowerCase()) ||
          t['subtitle'].toString().toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesTab && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Safe Space',
              style: GoogleFonts.playfairDisplay(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Coping Library',
              style: GoogleFonts.dmSans(
                fontSize: 13,
                color: AppColors.muted,
              ),
            ),
            const SizedBox(height: 16),

            // Search Bar
            _buildSearchBar(),
            const SizedBox(height: 16),

            // Category Tab Scroll
            _buildCategoryTabs(),
            const SizedBox(height: 16),

            // Recommended Card
            if (_searchQuery.isEmpty) _buildRecommendedCard(),
            if (_searchQuery.isEmpty) const SizedBox(height: 20),

            // Soundboard Card
            _buildSoundboard(),
            const SizedBox(height: 20),

            // All Coping Tools Header
            Text(
              'ALL COPING TOOLS',
              style: GoogleFonts.dmSans(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.muted,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 12),

            // Grid List of Tools
            _buildToolsGrid(filteredTools),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgCard.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Row(
        children: [
          const Icon(Icons.search, color: AppColors.muted, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: GoogleFonts.dmSans(color: AppColors.textPrimary, fontSize: 13.5),
              decoration: InputDecoration(
                hintText: 'Search tools...',
                hintStyle: GoogleFonts.dmSans(color: AppColors.muted),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    return SizedBox(
      height: 38,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final tab = _categories[index];
          final isActive = _activeTab == tab;

          return GestureDetector(
            onTap: () => setState(() => _activeTab = tab),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isActive ? AppColors.purple : AppColors.bgCard.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isActive ? AppColors.purple : AppColors.border,
                ),
              ),
              child: Text(
                tab,
                style: GoogleFonts.dmSans(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isActive ? AppColors.textPrimary : AppColors.muted,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecommendedCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF112424), // Premium deep green/teal glow
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.teal.withOpacity(0.22)),
        boxShadow: [
          BoxShadow(
            color: AppColors.teal.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.teal.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.teal.withOpacity(0.25)),
            ),
            child: Text(
              'RECOMMENDED FOR YOU',
              style: GoogleFonts.dmSans(
                fontSize: 9,
                fontWeight: FontWeight.bold,
                color: AppColors.tealLight,
                letterSpacing: 1.0,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Box Breathing',
                      style: GoogleFonts.dmSans(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Calm your mind & reduce stress',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.tealLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '⏱ 4 min',
                      style: GoogleFonts.dmSans(
                        fontSize: 11,
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.teal,
                ),
                child: const Icon(Icons.play_arrow, color: AppColors.textPrimary, size: 20),
              )
            ],
          )
        ],
      ),
    );
  }

  Widget _buildSoundboard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xCC0D2A2A), // deep green/teal background
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.teal.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SENSORY RESET SOUNDBOARD',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.tealLight,
                  letterSpacing: 1.0,
                ),
              ),
              if (_audioLoading)
                const SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.tealLight),
                )
            ],
          ),
          const SizedBox(height: 14),

          // Sound Grid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: _sounds.map((sound) {
              final label = sound['label'] as String;
              final icon = sound['icon'] as IconData;
              final isPlaying = _playingSoundLabel == label;

              return Expanded(
                child: GestureDetector(
                  onTap: () => _handleSoundPress(sound),
                  child: Column(
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: isPlaying ? AppColors.teal.withOpacity(0.25) : AppColors.teal.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isPlaying ? AppColors.teal : AppColors.teal.withOpacity(0.2),
                          ),
                          boxShadow: isPlaying
                              ? [
                                  BoxShadow(
                                    color: AppColors.teal.withOpacity(0.4),
                                    blurRadius: 10,
                                  )
                                ]
                              : null,
                        ),
                        child: Icon(
                          icon,
                          color: isPlaying ? AppColors.textPrimary : AppColors.tealLight,
                          size: 22,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$label ${isPlaying ? "🔊" : ""}',
                        style: GoogleFonts.dmSans(
                          fontSize: 11,
                          fontWeight: isPlaying ? FontWeight.bold : FontWeight.normal,
                          color: isPlaying ? AppColors.textPrimary : AppColors.tealLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),

          // Live Volume Slider (shown when sound is playing)
          if (_playingSoundLabel != null) ...[
            const SizedBox(height: 16),
            const Divider(color: AppColors.textPrimary10),
            Row(
              children: [
                const Icon(Icons.volume_down, color: AppColors.tealLight, size: 16),
                Expanded(
                  child: SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.teal,
                      inactiveTrackColor: AppColors.textPrimary.withOpacity(0.06),
                      trackHeight: 4.0,
                      thumbColor: AppColors.teal,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 5.0),
                      overlayColor: AppColors.teal.withOpacity(0.12),
                    ),
                    child: Slider(
                      value: _volume,
                      min: 0.0,
                      max: 1.0,
                      onChanged: _changeVolume,
                    ),
                  ),
                ),
                const Icon(Icons.volume_up, color: AppColors.tealLight, size: 16),
              ],
            ),
          ]
        ],
      ),
    );
  }

  Widget _buildToolsGrid(List<Map<String, dynamic>> tools) {
    if (tools.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 40.0),
          child: Text(
            'No tools match your query.',
            style: GoogleFonts.dmSans(color: AppColors.muted, fontSize: 13),
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.9,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        final Color color = tool['color'] as Color;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bgCard.withOpacity(0.7),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.textPrimary.withOpacity(0.03)),
                ),
                child: Icon(tool['icon'] as IconData, color: color, size: 20),
              ),
              const SizedBox(height: 10),
              Text(
                tool['title'] as String,
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Expanded(
                child: Text(
                  tool['subtitle'] as String,
                  style: GoogleFonts.dmSans(
                    fontSize: 11,
                    color: AppColors.muted,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    tool['time'] as String,
                    style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.muted),
                  ),
                  Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: color.withOpacity(0.12),
                    ),
                    child: Icon(Icons.play_arrow, color: color, size: 12),
                  )
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
