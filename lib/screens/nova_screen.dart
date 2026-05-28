import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/colors.dart';
import '../widgets/glass_card.dart';
import '../widgets/nova_orb.dart';

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
  NovaState _novaState = NovaState.idle;

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

  void _updateNovaState(String text, bool isTyping) {
    if (_safetyTriggered) {
      _novaState = NovaState.stressed;
      return;
    }
    
    if (isTyping) {
      _novaState = NovaState.typing;
      return;
    }

    if (_loading) {
      _novaState = NovaState.thinking;
      return;
    }

    final lower = text.toLowerCase();
    if (lower.contains('happy') || lower.contains('good') || lower.contains('great')) {
      _novaState = NovaState.happy;
    } else if (lower.contains('stress') || lower.contains('overwhelmed') || lower.contains('anxious')) {
      _novaState = NovaState.stressed;
    } else if (lower.contains('sleep') || lower.contains('tired')) {
      _novaState = NovaState.sleeping;
    } else {
      _novaState = NovaState.idle;
    }
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
        _novaState = NovaState.stressed;
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
      _updateNovaState(text, false);
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
            _updateNovaState(reply, false);
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
          _novaState = NovaState.idle;
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
        _updateNovaState(reply, false);
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
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutQuart,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Background Gradient Mesh
          Positioned.fill(
            child: AnimatedContainer(
              duration: 2.seconds,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    if (_novaState == NovaState.stressed)
                      AppColors.coral.withOpacity(0.05)
                    else if (_novaState == NovaState.happy)
                      AppColors.pink.withOpacity(0.05)
                    else if (_novaState == NovaState.sleeping)
                      AppColors.purpleDark.withOpacity(0.1)
                    else
                      AppColors.purple.withOpacity(isDark ? 0.05 : 0.02),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Central Nova Avatar
          Positioned(
            top: MediaQuery.of(context).size.height * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: NovaOrb(state: _novaState, size: 160),
            ),
          ),

          // Foreground Chat
          Column(
            children: [
              // Header
              SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      Text(
                        'Nova',
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                          color: AppColors.text(context),
                        ),
                      ).animate().fadeIn(duration: 400.ms),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: const BoxDecoration(
                                color: AppColors.purpleLight,
                                shape: BoxShape.circle,
                              ),
                            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                             .fadeIn(duration: 1.seconds),
                            const SizedBox(width: 8),
                            Text(
                              'Online',
                              style: GoogleFonts.inter(
                                fontSize: 12,
                                color: AppColors.purpleLight,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Chat Thread
              Expanded(
                child: ShaderMask(
                  shaderCallback: (Rect bounds) {
                    return const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.white, Colors.white, Colors.white],
                      stops: [0.0, 0.1, 0.9, 1.0],
                    ).createShader(bounds);
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).size.height * 0.35, // Push messages down initially
                      left: 16,
                      right: 16,
                      bottom: 24,
                    ),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final msg = _messages[index];
                      final isUser = msg['from'] == 'user';
                      return _buildChatBubble(msg['text']!, isUser)
                          .animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuart);
                    },
                  ),
                ),
              ),
              
              // Typing Indicator & Input Area
              ClipRRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.bgCard.withOpacity(0.8) : Colors.white.withOpacity(0.8),
                      border: Border(top: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : AppColors.borderLight)),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Column(
                        children: [
                          if (_loading)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0, left: 16),
                              child: Row(
                                children: [
                                  Text(
                                    "Nova is thinking...",
                                    style: GoogleFonts.inter(
                                      color: AppColors.purpleLight, 
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                                   .fade(begin: 0.5, end: 1.0, duration: 1.seconds),
                                ],
                              ),
                            ),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withOpacity(0.05) : AppColors.bgElevatedLight,
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(color: isDark ? Colors.white.withOpacity(0.1) : AppColors.borderLight),
                                  ),
                                  child: TextField(
                                    controller: _inputController,
                                    style: GoogleFonts.inter(color: AppColors.text(context)),
                                    onChanged: (text) {
                                      if (text.isNotEmpty && _novaState == NovaState.idle) {
                                        setState(() => _novaState = NovaState.typing);
                                      } else if (text.isEmpty && _novaState == NovaState.typing) {
                                        setState(() => _novaState = NovaState.idle);
                                      }
                                    },
                                    decoration: InputDecoration(
                                      hintText: "Share what's on your mind...",
                                      hintStyle: GoogleFonts.inter(color: AppColors.mutedText(context)),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                    onSubmitted: (_) => _sendMessage(),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              GestureDetector(
                                onTap: () => _sendMessage(),
                                child: Container(
                                  width: 52,
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: AppColors.purple,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.purple.withOpacity(0.3),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                                ).animate().scale(delay: 200.ms, duration: 300.ms, curve: Curves.easeOutBack),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChatBubble(String text, bool isUser) {
    final isDark = AppColors.isDark(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
              decoration: BoxDecoration(
                color: isUser 
                    ? AppColors.purple 
                    : (isDark ? AppColors.bgGlass : Colors.white),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(24),
                  topRight: const Radius.circular(24),
                  bottomLeft: Radius.circular(isUser ? 24 : 8),
                  bottomRight: Radius.circular(isUser ? 8 : 24),
                ),
                border: Border.all(
                  color: isUser 
                      ? Colors.transparent 
                      : (isDark ? Colors.white.withOpacity(0.1) : AppColors.borderLight),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 20,
                    spreadRadius: 0,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: Text(
                text,
                style: GoogleFonts.inter(
                  color: isUser ? Colors.white : AppColors.text(context),
                  fontSize: 16,
                  height: 1.6,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
