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
import '../theme/colors.dart';
import '../widgets/lotus_logo.dart';
import '../widgets/doodle_canvas.dart';
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

  // Voice recording
  final AudioRecorder _recorder = AudioRecorder();
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isRecording = false;
  bool _isPlayingVoice = false;
  String? _voiceRecordingPath;
  int _recordingDuration = 0;
  Timer? _recordingTimer;

  // Image
  final ImagePicker _imagePicker = ImagePicker();
  File? _pickedImage;

  // List / Checklist
  final List<Map<String, dynamic>> _checklistItems = [];
  final TextEditingController _checklistController = TextEditingController();

  // Doodle
  final GlobalKey<DoodleCanvasState> _doodleKey = GlobalKey();

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
      JournalEntry(id: "3", date: "May 23, 2026", text: "Really good session with Dr. Hayes today. We talked about boundary setting and I feel...", tagColorHex: "#F7E08A"),
    ];
    setState(() { _entries = defaults; });
    _saveEntriesToPrefs(defaults);
  }

  Future<void> _saveEntriesToPrefs(List<JournalEntry> list) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('zenara_journal_entries', json.encode(list.map((e) => e.toJson()).toList()));
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

  // ─── Voice Recording ──────────────────────────────────────────────────

  Future<void> _toggleRecording() async {
    if (_isRecording) {
      await _stopRecording();
    } else {
      await _startRecording();
    }
  }

  Future<void> _startRecording() async {
    final status = await Permission.microphone.request();
    if (!status.isGranted) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Microphone permission required', style: GoogleFonts.dmSans()),
            backgroundColor: AppColors.coral,
          ),
        );
      }
      return;
    }

    try {
      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/zenara_voice_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _recorder.start(
        const RecordConfig(encoder: AudioEncoder.aacLc),
        path: path,
      );

      setState(() {
        _isRecording = true;
        _recordingDuration = 0;
        _voiceRecordingPath = path;
      });

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() => _recordingDuration++);
      });
    } catch (e) {
      debugPrint("Error starting recording: $e");
    }
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
      debugPrint("Error stopping recording: $e");
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
    } catch (e) {
      debugPrint("Error playing voice: $e");
    }
  }

  // ─── Image Picker ─────────────────────────────────────────────────────

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );
      if (image != null) {
        setState(() {
          _pickedImage = File(image.path);
        });
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  // ─── Save ─────────────────────────────────────────────────────────────

  Future<void> _handleSave() async {
    String entryText = '';
    String tagColor = '#7C6FF7';
    final sm = ScaffoldMessenger.of(context);

    switch (_activeInputType) {
      case 'text':
        entryText = _textController.text.trim();
        if (entryText.isEmpty) {
          sm.showSnackBar(SnackBar(
            content: Text('Please write something before saving.', style: GoogleFonts.dmSans()),
            backgroundColor: AppColors.coral,
          ));
          return;
        }
        break;
      case 'voice':
        if (_voiceRecordingPath == null) {
          sm.showSnackBar(SnackBar(
            content: Text('Please record a voice note first.', style: GoogleFonts.dmSans()),
            backgroundColor: AppColors.coral,
          ));
          return;
        }
        entryText = '🎙 Voice note recorded (${_recordingDuration}s)';
        tagColor = '#35B0A6';
        break;
      case 'image':
        if (_pickedImage == null && _textController.text.trim().isEmpty) {
          sm.showSnackBar(SnackBar(
            content: Text('Please add an image or caption.', style: GoogleFonts.dmSans()),
            backgroundColor: AppColors.coral,
          ));
          return;
        }
        entryText = _pickedImage != null
            ? '📷 Photo entry${_textController.text.trim().isNotEmpty ? ": ${_textController.text.trim()}" : ""}'
            : _textController.text.trim();
        tagColor = '#F7C59F';
        break;
      case 'doodle':
        final canvasState = _doodleKey.currentState;
        if (canvasState == null || !canvasState.hasContent) {
          sm.showSnackBar(SnackBar(
            content: Text('Please draw something before saving.', style: GoogleFonts.dmSans()),
            backgroundColor: AppColors.coral,
          ));
          return;
        }
        entryText = '🎨 Doodle entry${_textController.text.trim().isNotEmpty ? ": ${_textController.text.trim()}" : ""}';
        tagColor = '#F7A8D4';
        break;
      case 'list':
        final completed = _checklistItems.where((i) => i['done'] == true).length;
        if (_checklistItems.isEmpty) {
          sm.showSnackBar(SnackBar(
            content: Text('Please add some checklist items.', style: GoogleFonts.dmSans()),
            backgroundColor: AppColors.coral,
          ));
          return;
        }
        entryText = '☑ Checklist ($completed/${_checklistItems.length} done): ${_checklistItems.map((i) => "${i['done'] ? '✓' : '○'} ${i['text']}").join(', ')}';
        tagColor = '#A89AF7';
        break;
    }

    final newEntry = JournalEntry(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      date: _formatCurrentDate(),
      text: entryText,
      tagColorHex: tagColor,
    );

    final updated = [newEntry, ..._entries];
    setState(() {
      _entries = updated;
      _textController.clear();
      _saved = true;
      _voiceRecordingPath = null;
      _pickedImage = null;
      _checklistItems.clear();
      _doodleKey.currentState?.clear();
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
                'MY MOON JOURNAL',
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

          // Dynamic content area based on active input type
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: _buildActiveInputArea(),
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

  Widget _buildActiveInputArea() {
    switch (_activeInputType) {
      case 'voice':
        return _buildVoiceInput();
      case 'image':
        return _buildImageInput();
      case 'doodle':
        return _buildDoodleInput();
      case 'list':
        return _buildListInput();
      case 'text':
      default:
        return _buildTextInput();
    }
  }

  // ─── Text Input ───────────────────────────────────────────────────────
  Widget _buildTextInput() {
    return TextField(
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
    );
  }

  // ─── Voice Input ──────────────────────────────────────────────────────
  Widget _buildVoiceInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Recording circle
          GestureDetector(
            onTap: _toggleRecording,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isRecording
                    ? AppColors.coral.withOpacity(0.15)
                    : AppColors.teal.withOpacity(0.1),
                border: Border.all(
                  color: _isRecording ? AppColors.coral : AppColors.teal,
                  width: 2,
                ),
                boxShadow: _isRecording
                    ? [BoxShadow(color: AppColors.coral.withOpacity(0.3), blurRadius: 16)]
                    : null,
              ),
              child: Icon(
                _isRecording ? Icons.stop : Icons.mic,
                color: _isRecording ? AppColors.coral : AppColors.teal,
                size: 32,
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Status text
          Text(
            _isRecording
                ? 'Recording... ${_recordingDuration}s'
                : _voiceRecordingPath != null
                    ? 'Voice note recorded (${_recordingDuration}s)'
                    : 'Tap to start recording',
            style: GoogleFonts.dmSans(
              fontSize: 13,
              color: _isRecording ? AppColors.coral : AppColors.muted,
              fontWeight: _isRecording ? FontWeight.bold : FontWeight.normal,
            ),
          ),

          // Playback button
          if (_voiceRecordingPath != null && !_isRecording) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: _playVoiceRecording,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppColors.teal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.teal.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isPlayingVoice ? Icons.pause : Icons.play_arrow,
                      color: AppColors.teal,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _isPlayingVoice ? 'Pause' : 'Play',
                      style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.teal, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ),
          ],

          // Waveform visualization
          if (_isRecording) ...[
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(20, (i) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 100 + i * 20),
                    margin: const EdgeInsets.symmetric(horizontal: 1.5),
                    width: 3,
                    height: (8 + (i % 5) * 6 + (_recordingDuration % 3) * 4).toDouble(),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withOpacity(0.6 + (i % 3) * 0.15),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  );
                }),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Image Input ──────────────────────────────────────────────────────
  Widget _buildImageInput() {
    return Column(
      children: [
        if (_pickedImage != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.file(
              _pickedImage!,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 8),
          // Remove image
          GestureDetector(
            onTap: () => setState(() => _pickedImage = null),
            child: Text(
              'Remove image',
              style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.coral),
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Pick image buttons
        if (_pickedImage == null)
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickImage(ImageSource.gallery),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      color: AppColors.bgElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.peach.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.photo_library_outlined, color: AppColors.peach, size: 32),
                        const SizedBox(height: 6),
                        Text('Gallery', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.muted)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () => _pickImage(ImageSource.camera),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    decoration: BoxDecoration(
                      color: AppColors.bgElevated,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.peach.withOpacity(0.2)),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.camera_alt_outlined, color: AppColors.peach, size: 32),
                        const SizedBox(height: 6),
                        Text('Camera', style: GoogleFonts.dmSans(fontSize: 12, color: AppColors.muted)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),

        if (_pickedImage != null) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _textController,
            maxLines: 2,
            style: GoogleFonts.dmSans(color: Colors.white, fontSize: 14, height: 1.6),
            decoration: InputDecoration(
              hintText: 'Add a caption...',
              hintStyle: GoogleFonts.dmSans(color: AppColors.muted.withValues(alpha: 0.6), fontSize: 14),
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ],
      ],
    );
  }

  // ─── Doodle Input ─────────────────────────────────────────────────────
  Widget _buildDoodleInput() {
    return Column(
      children: [
        DoodleCanvas(key: _doodleKey),
        const SizedBox(height: 8),
        TextField(
          controller: _textController,
          maxLines: 2,
          style: GoogleFonts.dmSans(color: Colors.white, fontSize: 14, height: 1.6),
          decoration: InputDecoration(
            hintText: 'Add a note about your doodle...',
            hintStyle: GoogleFonts.dmSans(color: AppColors.muted.withValues(alpha: 0.6), fontSize: 14),
            border: InputBorder.none,
            isDense: true,
          ),
        ),
      ],
    );
  }

  // ─── List / Checklist Input ───────────────────────────────────────────
  Widget _buildListInput() {
    return Column(
      children: [
        // Add item row
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _checklistController,
                style: GoogleFonts.dmSans(color: Colors.white, fontSize: 14),
                decoration: InputDecoration(
                  hintText: 'Add item...',
                  hintStyle: GoogleFonts.dmSans(color: AppColors.muted.withValues(alpha: 0.6)),
                  border: InputBorder.none,
                  isDense: true,
                ),
                onSubmitted: (_) => _addChecklistItem(),
              ),
            ),
            GestureDetector(
              onTap: _addChecklistItem,
              child: Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.purpleLight.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.purpleLight.withOpacity(0.3)),
                ),
                child: const Icon(Icons.add, color: AppColors.purpleLight, size: 18),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        // Checklist items
        if (_checklistItems.isNotEmpty)
          ...List.generate(_checklistItems.length, (index) {
            final item = _checklistItems[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        _checklistItems[index]['done'] = !item['done'];
                      });
                    },
                    child: Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        color: item['done'] ? AppColors.purple : Colors.transparent,
                        border: Border.all(
                          color: item['done'] ? AppColors.purple : AppColors.muted,
                          width: 1.5,
                        ),
                      ),
                      child: item['done']
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item['text'],
                      style: GoogleFonts.dmSans(
                        fontSize: 13.5,
                        color: item['done'] ? AppColors.muted : Colors.white,
                        decoration: item['done'] ? TextDecoration.lineThrough : null,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() => _checklistItems.removeAt(index));
                    },
                    child: const Icon(Icons.close, color: AppColors.muted, size: 16),
                  ),
                ],
              ),
            );
          }),

        if (_checklistItems.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(
              'Add items to your checklist above',
              style: GoogleFonts.dmSans(fontSize: 13, color: AppColors.muted),
            ),
          ),
      ],
    );
  }

  void _addChecklistItem() {
    final text = _checklistController.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _checklistItems.add({'text': text, 'done': false});
      _checklistController.clear();
    });
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
