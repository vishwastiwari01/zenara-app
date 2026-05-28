import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../theme/colors.dart';
import '../widgets/lotus_logo.dart';
import '../models/journal_entry.dart';

class JournalScreen extends StatefulWidget {
  const JournalScreen({Key? key}) : super(key: key);

  @override
  State<JournalScreen> createState() => _JournalScreenState();
}

class _JournalScreenState extends State<JournalScreen> {
  final TextEditingController _textController = TextEditingController();
  List<JournalEntry> _entries = [];
  bool _saved = false;
  String _activeInputType = 'text';

  final List<String> _prompts = [
    '"What made you smile today?"',
    '"What are you finding hard right now?"',
    '"What do you need most in this moment?"',
    '"Name one thing you\'re grateful for."',
    '"What would you tell your past self?"',
  ];
  int _promptIdx = 0;

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final String? entriesJson = prefs.getString('zenara_journal_entries');
    if (entriesJson != null) {
      try {
        final List<dynamic> decoded = json.decode(entriesJson);
        setState(() {
          _entries = decoded.map((item) => JournalEntry.fromJson(item)).toList();
        });
      } catch (e) {
        _loadDefaultEntries();
      }
    } else {
      _loadDefaultEntries();
    }
  }

  void _loadDefaultEntries() {
    final defaults = [
      JournalEntry(id: "1", date: "May 25, 2026", text: "Feeling more grounded today. The breathing exercise really helped with the presentation anxiety...", tagColorHex: "#4ECDC4"),
      JournalEntry(id: "2", date: "May 24, 2026", text: "Hard day. Couldn't focus at all. Nova helped me break down the tasks into smaller pieces...", tagColorHex: "#7C9ABF"),
      JournalEntry(id: "3", date: "May 23, 2026", text: "Really good session with Dr. Hayes today. We talked about boundary setting and I feel...", tagColorHex: "#F7E08A"),
    ];
    setState(() { _entries = defaults; });
    _saveEntriesToPrefs(defaults);
  }

  Future<void> _saveEntriesToPrefs(List<JournalEntry> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('zenara_journal_entries', json.encode(list.map((e) => e.toJson()).toList()));
  }

  final messenger = ScaffoldMessengerState();

  Future<void> _handleSave() async {
    final text = _textController.text.trim();
    final sm = ScaffoldMessenger.of(context);
    if (text.isEmpty) {
      sm.showSnackBar(SnackBar(
        content: Text('Please write something before saving.', style: GoogleFonts.dmSans()),
        backgroundColor: AppColors.coral,
      ));
      return;
    }

    final newEntry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _formatCurrentDate(),
      text: text,
      tagColorHex: '#7C6FF7',
    );

    final updated = [newEntry, ..._entries];
    setState(() {
      _entries = updated;
      _textController.clear();
      _saved = true;
    });
    await _saveEntriesToPrefs(updated);

    sm.showSnackBar(SnackBar(
      content: Text('Entry saved ✓', style: GoogleFonts.dmSans()),
      backgroundColor: AppColors.teal,
      duration: const Duration(seconds: 2),
    ));

    Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  String _formatCurrentDate() {
    final now = DateTime.now();
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  String _getTodayLong() {
    final now = DateTime.now();
    final months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Journal',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.bgGlass,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(Icons.search, color: Colors.white, size: 18),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // My Journal Banner
            _buildMyJournalBanner(),
            const SizedBox(height: 16),

            // Today Input
            _buildTodaySection(),
            const SizedBox(height: 20),

            // Past Entries
            if (_entries.isNotEmpty) ...[
              Text(
                'PAST ENTRIES',
                style: GoogleFonts.dmSans(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.muted,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _entries.length,
                itemBuilder: (context, index) => _buildEntryCard(_entries[index]),
              ),
            ],
            const SizedBox(height: 28),
          ],
        ),
      ),
    );
  }

  Widget _buildMyJournalBanner() {
    return Container(
      height: 112,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3D2C8D), Color(0xFF1E1060), Color(0xFF121030)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.purple.withValues(alpha: 0.35)),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          )
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'MY JOURNAL',
                style: GoogleFonts.dmSans(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppColors.teal,
                  letterSpacing: 1.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${_entries.length} entries',
                style: GoogleFonts.playfairDisplay(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
                ),
                child: const Center(child: LotusLogo(size: 34)),
              ),
              Positioned(
                top: -6,
                right: -4,
                child: const Icon(Icons.star, size: 12, color: AppColors.gold),
              ),
              Positioned(
                bottom: -2,
                left: -8,
                child: const Icon(Icons.star, size: 9, color: AppColors.purpleLight),
              ),
              Positioned(
                top: 8,
                left: -14,
                child: Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.tealLight,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySection() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bgGlass,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Today header
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Today',
                  style: GoogleFonts.dmSans(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _getTodayLong(),
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Rotating prompt
          GestureDetector(
            onTap: () => setState(() => _promptIdx = (_promptIdx + 1) % _prompts.length),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 14),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bgElevated,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _prompts[_promptIdx],
                      style: GoogleFonts.dmSans(
                        fontSize: 13.5,
                        color: AppColors.muted,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.refresh_rounded, color: AppColors.muted, size: 18),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Text area
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: TextField(
              controller: _textController,
              maxLines: 6,
              minLines: 5,
              style: GoogleFonts.dmSans(
                color: Colors.white,
                fontSize: 14,
                height: 1.6,
              ),
              decoration: InputDecoration(
                hintText: 'How are you feeling right now?',
                hintStyle: GoogleFonts.dmSans(
                  color: AppColors.muted.withValues(alpha: 0.6),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Divider
          Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),

          // Toolbar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                _buildToolbarBtn(Icons.edit_note_outlined, 'text', AppColors.purple),
                const SizedBox(width: 8),
                _buildToolbarBtn(Icons.mic_none_outlined, 'voice', AppColors.teal),
                const SizedBox(width: 8),
                _buildToolbarBtn(Icons.image_outlined, 'image', AppColors.peach),
                const SizedBox(width: 8),
                _buildToolbarBtn(Icons.brush_outlined, 'doodle', AppColors.pink),
                const SizedBox(width: 8),
                _buildToolbarBtn(Icons.format_list_bulleted, 'list', AppColors.purpleLight),
                const Spacer(),
                // Save button
                GestureDetector(
                  onTap: _handleSave,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.purple, AppColors.purpleDark],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.purple.withValues(alpha: 0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        )
                      ],
                    ),
                    child: Text(
                      _saved ? 'Saved ✓' : 'Save',
                      style: GoogleFonts.dmSans(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbarBtn(IconData icon, String type, Color color) {
    final isActive = _activeInputType == type;
    return GestureDetector(
      onTap: () => setState(() => _activeInputType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isActive ? color.withValues(alpha: 0.18) : AppColors.bgElevated,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(
            color: isActive ? color.withValues(alpha: 0.5) : AppColors.border,
          ),
        ),
        child: Icon(icon, color: isActive ? color : AppColors.muted, size: 18),
      ),
    );
  }

  Widget _buildEntryCard(JournalEntry entry) {
    final bulletColor = Color(int.parse(entry.tagColorHex.replaceFirst('#', '0xFF')));
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.bgGlass,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: bulletColor,
              boxShadow: [
                BoxShadow(
                  color: bulletColor.withValues(alpha: 0.5),
                  blurRadius: 6,
                )
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.date,
                  style: GoogleFonts.dmSans(fontSize: 11, color: AppColors.muted),
                ),
                const SizedBox(height: 5),
                Text(
                  entry.text,
                  style: GoogleFonts.dmSans(
                    fontSize: 13.5,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
