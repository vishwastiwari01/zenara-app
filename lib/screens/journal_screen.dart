import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/colors.dart';
import '../widgets/glass_card.dart';
import '../models/journal_entry.dart';
import 'doodle_screen.dart';

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

  // Voice recording
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  bool _isPlayingVoice = false;
  String? _voiceRecordingPath;
  int _recordingDuration = 0;
  Timer? _recordingTimer;

  // Image & Doodle
  final ImagePicker _imagePicker = ImagePicker();
  File? _pickedImage;
  File? _doodleImage;

  // List / Checklist
  final List<Map<String, dynamic>> _checklistItems = [];
  final TextEditingController _checklistController = TextEditingController();

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

  @override
  void dispose() {
    _textController.dispose();
    _checklistController.dispose();
    _recordingTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
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
    ];
    setState(() { _entries = defaults; });
    _saveEntriesToPrefs(defaults);
  }

  Future<void> _saveEntriesToPrefs(List<JournalEntry> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('zenara_journal_entries', json.encode(list.map((e) => e.toJson()).toList()));
  }

  String _getTodayLong() {
    final now = DateTime.now();
    final months = ['January','February','March','April','May','June','July','August','September','October','November','December'];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  // Voice logic
  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) return;
    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/zenara_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';
      await _recorder.start(const RecordConfig(encoder: AudioEncoder.aacLc), path: path);
      setState(() {
        _isRecording = true;
        _recordingDuration = 0;
        _voiceRecordingPath = path;
      });
      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _recordingDuration++);
      });
    } catch (e) { debugPrint("Error: $e"); }
  }

  Future<void> _stopRecording() async {
    _recordingTimer?.cancel();
    try {
      final path = await _recorder.stop();
      setState(() {
        _isRecording = false;
        if (path != null) _voiceRecordingPath = path;
      });
    } catch (e) {
      setState(() => _isRecording = false);
    }
  }

  Future<void> _playVoiceRecording() async {
    if (_voiceRecordingPath == null) return;
    if (_isPlayingVoice) {
      await _audioPlayer.stop();
      setState(() => _isPlayingVoice = false);
      return;
    }
    try {
      await _audioPlayer.play(DeviceFileSource(_voiceRecordingPath!));
      setState(() => _isPlayingVoice = true);
      _audioPlayer.onPlayerComplete.listen((_) {
        if (mounted) setState(() => _isPlayingVoice = false);
      });
    } catch (e) { debugPrint("Error: $e"); }
  }

  // Image logic
  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        setState(() {
          _pickedImage = File(image.path);
        });
      }
    } catch (e) { debugPrint("Error picking image: $e"); }
  }

  Future<void> _openDoodleScreen() async {
    final File? result = await Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const DoodleScreen()),
    );
    if (result != null) {
      setState(() {
        _doodleImage = result;
      });
    }
  }

  void _saveEntry() {
    if (_textController.text.trim().isEmpty && _voiceRecordingPath == null && _pickedImage == null && _doodleImage == null && _checklistItems.isEmpty) return;

    final entry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: "${DateTime.now().month}/${DateTime.now().day}/${DateTime.now().year}",
      text: _textController.text.trim(),
      tagColorHex: "#6C5CE7",
      voicePath: _voiceRecordingPath,
      imagePath: _pickedImage?.path ?? _doodleImage?.path,
      checklist: _checklistItems.isNotEmpty ? _checklistItems : null,
      doodleBytes: null, // we now save doodles as regular image paths
    );

    setState(() {
      _entries.insert(0, entry);
      _saved = true;
      _textController.clear();
      _voiceRecordingPath = null;
      _pickedImage = null;
      _doodleImage = null;
      _checklistItems.clear();
      _activeInputType = 'text';
    });

    _saveEntriesToPrefs(_entries);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _saved = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
                _buildEditorArea().animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.1, curve: Curves.easeOutQuart),
                const SizedBox(height: 32),
                _buildPastEntriesHeader().animate().fadeIn(delay: 200.ms),
              ]),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return _buildPastEntryCard(_entries[index])
                      .animate().fadeIn(delay: Duration(milliseconds: 300 + (index * 100))).slideY(begin: 0.1);
                },
                childCount: _entries.length,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final isDark = AppColors.isDark(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MY JOURNAL',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.purpleLight,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _getTodayLong(),
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 28,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text(context),
                  ),
                ),
              ],
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _promptIdx = (_promptIdx + 1) % _prompts.length;
                });
              },
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.purple.withOpacity(0.15) : AppColors.purple.withOpacity(0.08),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.refresh, color: AppColors.purpleLight, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _prompts[_promptIdx],
          style: GoogleFonts.playfairDisplay(
            fontSize: 20,
            fontStyle: FontStyle.italic,
            color: AppColors.mutedText(context),
          ),
        ).animate(key: ValueKey(_promptIdx)).fadeIn(duration: 300.ms).slideX(begin: 0.1),
      ],
    );
  }

  Widget _buildEditorArea() {
    final isDark = AppColors.isDark(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GlassCard(
          glow: true,
          padding: const EdgeInsets.all(0),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.bgCard.withOpacity(0.4) : Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                // Toolbar
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : AppColors.borderLight)),
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    child: Row(
                      children: [
                        _buildToolIcon(Icons.text_fields, 'text'),
                        const SizedBox(width: 8),
                        _buildToolIcon(Icons.mic_none, 'voice'),
                        const SizedBox(width: 8),
                        _buildToolIcon(Icons.image_outlined, 'image'),
                        const SizedBox(width: 8),
                        _buildToolIcon(Icons.checklist, 'list'),
                        const SizedBox(width: 8),
                        _buildToolIcon(Icons.brush, 'doodle'),
                      ],
                    ),
                  ),
                ),
                // Input Area
                Container(
                  constraints: const BoxConstraints(minHeight: 220),
                  padding: const EdgeInsets.all(24),
                  child: _buildInputContent(),
                ),
                const SizedBox(height: 48), // Padding for floating action button
              ],
            ),
          ),
        ),
        
        // Floating Save Button
        Positioned(
          bottom: -24,
          right: 24,
          child: GestureDetector(
            onTap: _saved ? null : _saveEntry,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _saved ? [AppColors.teal, AppColors.teal] : [AppColors.purple, AppColors.purpleLight],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (_saved ? AppColors.teal : AppColors.purple).withOpacity(0.4),
                    blurRadius: 16,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _saved ? Icons.check : Icons.save_alt,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _saved ? 'Saved' : 'Save Entry',
                    style: GoogleFonts.inter(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ).animate().slideY(begin: 1.0, duration: 600.ms, curve: Curves.easeOutBack),
        ),
      ],
    );
  }

  Widget _buildToolIcon(IconData icon, String type) {
    final isActive = _activeInputType == type;
    return GestureDetector(
      onTap: () {
        if (type == 'doodle') {
          _openDoodleScreen();
        } else {
          setState(() => _activeInputType = type);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isActive ? AppColors.purple.withOpacity(0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppColors.purple.withOpacity(0.5) : Colors.transparent,
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: isActive ? AppColors.purpleLight : AppColors.mutedText(context),
        ),
      ),
    );
  }

  Widget _buildInputContent() {
    final isDark = AppColors.isDark(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_doodleImage != null)
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(_doodleImage!, width: double.infinity, fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => setState(() => _doodleImage = null),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(color: isDark ? Colors.black54 : Colors.black38, shape: BoxShape.circle),
                    child: const Icon(Icons.close, color: Colors.white, size: 16),
                  ),
                ),
              ),
            ],
          ),
        
        _buildActiveInputWidget(),
      ],
    );
  }

  Widget _buildActiveInputWidget() {
    final isDark = AppColors.isDark(context);
    switch (_activeInputType) {
      case 'text':
        return TextField(
          controller: _textController,
          maxLines: null,
          style: GoogleFonts.inter(color: AppColors.text(context), height: 1.6, fontSize: 16),
          decoration: InputDecoration(
            hintText: "Start writing here...",
            hintStyle: GoogleFonts.inter(color: AppColors.mutedText(context).withOpacity(0.5)),
            border: InputBorder.none,
          ),
        );
      case 'voice':
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _toggleRecording,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording ? AppColors.coral.withOpacity(0.2) : AppColors.purple.withOpacity(0.1),
                    border: Border.all(
                      color: _isRecording
                          ? AppColors.coral
                          : isDark
                              ? AppColors.purple.withOpacity(0.3)
                              : AppColors.purple.withOpacity(0.4),
                      width: 2,
                    ),
                    boxShadow: _isRecording ? [BoxShadow(color: AppColors.coral.withOpacity(0.3), blurRadius: 20)] : [],
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: _isRecording ? AppColors.coral : AppColors.purpleLight,
                    size: 32,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              if (_isRecording)
                Text(
                  '00:${_recordingDuration.toString().padLeft(2, '0')}',
                  style: GoogleFonts.inter(color: AppColors.coral, fontSize: 18, fontWeight: FontWeight.bold),
                ).animate(onPlay: (controller) => controller.repeat(reverse: true)).fadeIn(duration: 1.seconds),
              if (!_isRecording && _voiceRecordingPath != null)
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: Icon(_isPlayingVoice ? Icons.pause_circle_filled : Icons.play_circle_fill),
                      color: AppColors.teal,
                      iconSize: 40,
                      onPressed: _playVoiceRecording,
                    ),
                    Text("Recording saved", style: GoogleFonts.inter(color: AppColors.teal)),
                  ],
                ),
            ],
          ),
        );
      case 'image':
        return Center(
          child: _pickedImage != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(_pickedImage!, height: 200, fit: BoxFit.cover),
                )
              : GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white.withOpacity(0.02) : AppColors.bgElevatedLight,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : AppColors.borderLight, style: BorderStyle.solid),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined, color: AppColors.mutedText(context), size: 40),
                        const SizedBox(height: 8),
                        Text("Tap to upload photo", style: GoogleFonts.inter(color: AppColors.mutedText(context))),
                      ],
                    ),
                  ),
                ),
        );
      case 'list':
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _checklistController,
                    style: GoogleFonts.inter(color: AppColors.text(context)),
                    decoration: InputDecoration(
                      hintText: "Add a new item...",
                      hintStyle: GoogleFonts.inter(color: AppColors.mutedText(context)),
                      border: InputBorder.none,
                    ),
                    onSubmitted: (val) {
                      if (val.isNotEmpty) {
                        setState(() {
                          _checklistItems.add({'text': val, 'done': false});
                          _checklistController.clear();
                        });
                      }
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle, color: AppColors.purpleLight),
                  onPressed: () {
                    if (_checklistController.text.isNotEmpty) {
                      setState(() {
                        _checklistItems.add({'text': _checklistController.text, 'done': false});
                        _checklistController.clear();
                      });
                    }
                  },
                )
              ],
            ),
            Divider(color: isDark ? Colors.white10 : AppColors.borderLight),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _checklistItems.length,
              itemBuilder: (context, i) {
                return CheckboxListTile(
                  title: Text(
                    _checklistItems[i]['text'],
                    style: GoogleFonts.inter(
                      color: AppColors.text(context),
                      decoration: _checklistItems[i]['done'] ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  value: _checklistItems[i]['done'],
                  activeColor: AppColors.teal,
                  onChanged: (val) {
                    setState(() => _checklistItems[i]['done'] = val);
                  },
                );
              },
            ),
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPastEntriesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'PAST ENTRIES',
          style: GoogleFonts.inter(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppColors.mutedText(context),
            letterSpacing: 1.5,
          ),
        ),
        Icon(Icons.filter_list, color: AppColors.mutedText(context), size: 18),
      ],
    );
  }

  Widget _buildPastEntryCard(JournalEntry entry) {
    final Color tagColor = AppColors.teal;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: tagColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  entry.date,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.mutedText(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (entry.text != null && entry.text!.isNotEmpty)
              Text(
                entry.text!,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  height: 1.6,
                  color: AppColors.text(context),
                ),
              ),
            if (entry.voicePath != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.purpleLight.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.mic, color: AppColors.purpleLight, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Text("Voice Note", style: GoogleFonts.inter(color: AppColors.purpleLight, fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              ),
            if (entry.imagePath != null)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.file(File(entry.imagePath!), width: double.infinity, fit: BoxFit.cover),
                ),
              ),
            if (entry.checklist != null && entry.checklist!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: entry.checklist!.map((c) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        children: [
                          Icon(
                            c['done'] ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: c['done'] ? AppColors.teal : AppColors.mutedText(context),
                            size: 16,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            c['text'],
                            style: GoogleFonts.inter(
                              fontSize: 14,
                              color: c['done'] ? AppColors.mutedText(context) : AppColors.text(context),
                              decoration: c['done'] ? TextDecoration.lineThrough : null,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
