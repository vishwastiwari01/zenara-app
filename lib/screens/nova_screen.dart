import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/colors.dart';
import '../widgets/glass_card.dart';

class NovaScreen extends StatefulWidget {
  const NovaScreen({Key? key}) : super(key: key);

  @override
  State<NovaScreen> createState() => _NovaScreenState();
}

class _NovaScreenState extends State<NovaScreen> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  List<Map<String, String>> _messages = [
    {
      'id': '1',
      'from': 'nova',
      'text': "I noticed you've been feeling overwhelmed this week. I'm here for you. What would you like to do?",
    }
  ];

  bool _loading = false;
  String _apiKey = '';
  bool _safetyTriggered = false;

  final List<String> _crisisWords = [
    "suicide", "kill myself", "harm myself", "end my life", "want to die", "self harm",
  ];

  @override
  void initState() {
    super.initState();
    _loadApiKey();
  }

  Future<void> _loadApiKey() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _apiKey = prefs.getString('zenara_openrouter_api_key') ?? '';
    });
  }

  bool _checkForCrisis(String text) {
    final lower = text.toLowerCase();
    return _crisisWords.any((word) => lower.contains(word));
  }

  String _getMockResponse(String userInput) {
    final lower = userInput.toLowerCase();
    if (lower.contains("reflect")) {
      return "Let's take a moment to look back at your day. What was one moment where you felt completely in control, however small?";
    }
    if (lower.contains("reframe")) {
      return "I can help with that. Share a negative thought you've had today, and we'll work together to identify cognitive distortions and reframe it gently.";
    }
    if (lower.contains("breathe") || lower.contains("breathing")) {
      return "Let's do a quick Box Breathing exercise. Inhale for 4 seconds, hold for 4, exhale for 4, hold for 4. Shall we begin?";
    }
    if (lower.contains("hello") || lower.contains("hi") || lower.contains("hey")) {
      return "Hello! I'm Nova, your emotional companion. How is your heart feeling today?";
    }
    return "I hear you, and I'm holding space for you. Thank you for sharing that with me. What feelings are surfacing for you right now?";
  }

  Future<void> _sendMessage([String? textToSend]) async {
    final text = textToSend ?? _inputController.text;
    if (text.trim().isEmpty || _loading || _safetyTriggered) return;

    if (_checkForCrisis(text)) {
      setState(() {
        _safetyTriggered = true;
        _messages.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'from': 'user',
          'text': text,
        });
        _messages.add({
          'id': (DateTime.now().millisecondsSinceEpoch + 1).toString(),
          'from': 'nova',
          'text': "Safety Warning: I have detected indicators of crisis. The AI companion is suspended. Please call 988 immediately.",
        });
        _inputController.clear();
      });
      _scrollToEnd();
      return;
    }

    setState(() {
      _messages.add({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'from': 'user',
        'text': text,
      });
      if (textToSend == null) {
        _inputController.clear();
      }
      _loading = true;
    });
    _scrollToEnd();

    if (_apiKey.isNotEmpty) {
      try {
        final systemPrompt = "You are Nova, Zenara's compassionate AI mental health companion.";
        final response = await http.post(
          Uri.parse('https://openrouter.ai/api/v1/chat/completions'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $_apiKey',
          },
          body: json.encode({
            'model': 'anthropic/claude-3.5-sonnet',
            'messages': [
              {'role': 'system', 'content': systemPrompt},
              ..._messages.where((m) => m['from'] != 'nova' || !m['text']!.startsWith("Safety Warning")).map((m) => {
                'role': m['from'] == 'user' ? 'user' : 'assistant',
                'content': m['text'],
              }).toList(),
            ],
          }),
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          String reply = "I'm here with you. Tell me more.";
          if (data['choices'] != null && data['choices'].isNotEmpty) {
            reply = data['choices'][0]['message']['content'] ?? reply;
          }
          setState(() {
            _messages.add({
              'id': DateTime.now().millisecondsSinceEpoch.toString(),
              'from': 'nova',
              'text': reply,
            });
          });
        } else {
          throw Exception("API Error");
        }
      } catch (e) {
        setState(() {
          _messages.add({
            'id': DateTime.now().millisecondsSinceEpoch.toString(),
            'from': 'nova',
            'text': "I'm having a little trouble connecting to my servers. Take a breath — I'm still here with you. (Offline companion mode active)",
          });
        });
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 1200));
      final reply = _getMockResponse(text);
      setState(() {
        _messages.add({
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'from': 'nova',
          'text': reply,
        });
      });
    }

    setState(() {
      _loading = false;
    });
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutQuart,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.only(top: 12, bottom: 12),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.isDark(context) ? Colors.white.withOpacity(0.05) : AppColors.borderLight)),
            ),
            child: Column(
              children: [
                Text(
                  'Nova',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: AppColors.text(context),
                  ),
                ).animate().fadeIn(duration: 400.ms),
                const SizedBox(height: 2),
                Text(
                  'AI Companion',
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    color: AppColors.purpleLight,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.2,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms),
              ],
            ),
          ),

          Expanded(
            child: Stack(
              children: [
                // Floating Particles/Glow in background
                if (!_safetyTriggered && _messages.length <= 2)
                  Center(
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.purple.withOpacity(AppColors.isDark(context) ? 0.2 : 0.08),
                            blurRadius: 100,
                            spreadRadius: 20,
                          ),
                        ],
                      ),
                    ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                     .scaleXY(begin: 1.0, end: 1.2, duration: 4.seconds, curve: Curves.easeInOut)
                     .fade(begin: 0.5, end: 1.0, duration: 2.seconds),
                  ),

                // Chat Thread
                Column(
                  children: [
                    if (_safetyTriggered)
                      Container(
                        margin: const EdgeInsets.all(16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.coral.withOpacity(0.1),
                          border: Border.all(color: AppColors.coral.withOpacity(0.5)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          "Safety mechanisms engaged. Please seek immediate support.",
                          style: GoogleFonts.inter(color: AppColors.coral, fontWeight: FontWeight.bold),
                        ),
                      ).animate().shake(duration: 400.ms),

                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isUser = msg['from'] == 'user';
                          return _buildChatBubble(msg['text']!, isUser)
                              .animate().fadeIn(duration: 300.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuart);
                        },
                      ),
                    ),
                    
                    if (_loading)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.purple.withOpacity(0.2),
                              ),
                              child: const Icon(Icons.graphic_eq, color: AppColors.purpleLight, size: 16),
                            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                             .scaleXY(end: 1.1, duration: 600.ms)
                             .shimmer(color: Colors.white, duration: 1.seconds),
                            const SizedBox(width: 12),
                            Text("Nova is thinking...", style: GoogleFonts.inter(color: AppColors.mutedText(context), fontSize: 13)),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Input Area
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.isDark(context) ? AppColors.bgCard.withOpacity(0.6) : Colors.white,
              border: Border(top: BorderSide(color: AppColors.isDark(context) ? Colors.white.withOpacity(0.05) : AppColors.borderLight)),
            ),
            child: SafeArea(
              top: false,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: AppColors.isDark(context) ? Colors.white.withOpacity(0.05) : AppColors.bgElevatedLight,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: AppColors.isDark(context) ? Colors.white.withOpacity(0.1) : AppColors.borderLight),
                      ),
                      child: TextField(
                        controller: _inputController,
                        style: GoogleFonts.inter(color: AppColors.text(context)),
                        decoration: InputDecoration(
                          hintText: "Share your thoughts...",
                          hintStyle: GoogleFonts.inter(color: AppColors.mutedText(context)),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _sendMessage(),
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppColors.purple, AppColors.purpleLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.purple.withOpacity(0.3),
                            blurRadius: 12,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                    ).animate().scale(delay: 200.ms, duration: 300.ms, curve: Curves.easeOutBack),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [AppColors.teal.withOpacity(0.8), AppColors.purple.withOpacity(0.8)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: isUser ? AppColors.purple : (AppColors.isDark(context) ? AppColors.bgGlass : const Color(0xFFF1F0FF)),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                border: Border.all(
                  color: isUser ? Colors.transparent : (AppColors.isDark(context) ? Colors.white.withOpacity(0.1) : AppColors.borderLight),
                ),
              ),
              child: Text(
                text,
                style: GoogleFonts.inter(
                  color: isUser ? Colors.white : AppColors.text(context),
                  fontSize: 15,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 12),
        ],
      ),
    );
  }
}
