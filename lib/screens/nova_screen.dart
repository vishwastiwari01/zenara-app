import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../theme/colors.dart';

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
    "suicide",
    "kill myself",
    "harm myself",
    "end my life",
    "want to die",
    "self harm",
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
          'text': "Safety Warning: I have detected indicators of crisis. The AI companion is suspended. Please see the crisis support information above.",
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
        final systemPrompt = "You are Nova, Zenara's compassionate AI mental health companion. You are warm, empathetic, and supportive. You help users reflect on their emotions, reframe negative thoughts, and practice coping strategies. You are NOT a therapist or medical professional — always remind users to speak with their therapist (Dr. Hayes) for clinical support. Keep responses concise (2-3 sentences), warm, and conversational. Use gentle, supportive language. If you detect any self-harm language, immediately provide crisis resources.";
        
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
      // Mock offline mode
      await Future.delayed(const Duration(milliseconds: 800));
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
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleResetCrisis() {
    setState(() {
      _safetyTriggered = false;
      _messages = [
        {
          'id': DateTime.now().millisecondsSinceEpoch.toString(),
          'from': 'nova',
          'text': "I'm back, Sarah. Let's start fresh. How can I support you right now?",
        }
      ];
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
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              children: [
                Text(
                  'Nova',
                  style: GoogleFonts.playfairDisplay(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'AI Companion',
                  style: GoogleFonts.dmSans(
                    fontSize: 12,
                    color: AppColors.muted,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: Column(
              children: [
                // Safety Banner
                if (_safetyTriggered) _buildSafetyBanner(),

                // Nova Glow Planet Avatar (shown when chat starts)
                if (!_safetyTriggered && _messages.length <= 2) _buildPlanetAvatar(),

                // Chat Thread
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: _messages.length + (_loading ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _messages.length) {
                        return _buildLoadingBubble();
                      }

                      final msg = _messages[index];
                      final isUser = msg['from'] == 'user';

                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            gradient: isUser
                                ? const LinearGradient(
                                    colors: [AppColors.purple, AppColors.purpleDark],
                                  )
                                : null,
                            color: isUser ? null : AppColors.bgCard.withOpacity(0.75),
                            borderRadius: BorderRadius.only(
                              topLeft: const Radius.circular(18),
                              topRight: const Radius.circular(18),
                              bottomLeft: Radius.circular(isUser ? 18 : 4),
                              bottomRight: Radius.circular(isUser ? 4 : 18),
                            ),
                            border: isUser ? null : Border.all(color: AppColors.border),
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.8,
                          ),
                          child: Text(
                            msg['text']!,
                            style: GoogleFonts.dmSans(
                              fontSize: 13.5,
                              color: Colors.white,
                              height: 1.45,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Suggestion Chips (shown when chat is in initial state)
                if (!_safetyTriggered && _messages.length <= 2) _buildSuggestions(),

                // Input Bar
                _buildInputBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSafetyBanner() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0x14F06C8A), // Color(0xFFF06C8A) with 0.08 opacity
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0x4DF06C8A), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: Color(0xFFF06C8A), size: 18),
              const SizedBox(width: 8),
              Text(
                'IMMEDIATE SUPPORT AVAILABLE',
                style: GoogleFonts.dmSans(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFF06C8A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'You are not alone. Please reach out to these confidential resources immediately:',
            style: GoogleFonts.dmSans(
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 10),
          Text('📞 National Helpline (India): 9152987821',
              style: GoogleFonts.dmSans(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text('📞 Suicide & Crisis Lifeline (US): 988',
              style: GoogleFonts.dmSans(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 4),
          Text('📞 Vandrevala Foundation: 1860 2662 345',
              style: GoogleFonts.dmSans(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white)),
          const SizedBox(height: 14),
          ElevatedButton(
            onPressed: _handleResetCrisis,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.bgElevated,
              elevation: 0,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Text(
              'Reset Companion',
              style: GoogleFonts.dmSans(color: AppColors.purpleLight, fontSize: 12, fontWeight: FontWeight.bold),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildPlanetAvatar() {
    return Container(
      margin: const EdgeInsets.only(top: 20, bottom: 10),
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.purple.withOpacity(0.08),
        boxShadow: [
          BoxShadow(
            color: AppColors.purple.withOpacity(0.4),
            blurRadius: 20,
          ),
        ],
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Planet body with gradient
            Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const RadialGradient(
                  colors: [Color(0xFFA89AF7), Color(0xFF4A3FA0), Color(0xFF1A1040)],
                  center: Alignment(-0.3, -0.3),
                  radius: 0.65,
                ),
                border: Border.all(color: const Color(0x66A89AF7), width: 1),
              ),
            ),
            // Orbit Ring (tilted ellipse)
            Transform.rotate(
              angle: 0.25,
              child: Container(
                width: 96,
                height: 36,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(48),
                  border: Border.all(color: const Color(0xB3A89AF7), width: 2.5),
                ),
              ),
            ),
            // Inner Face Details
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    ),
                    const SizedBox(width: 18),
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                // Smile shape (semi-circle)
                Container(
                  width: 12,
                  height: 6,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(6),
                      bottomRight: Radius.circular(6),
                    ),
                    border: Border(
                      bottom: BorderSide(color: Colors.white, width: 2),
                      left: BorderSide(color: Colors.white, width: 2),
                      right: BorderSide(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingBubble() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.bgCard.withOpacity(0.75),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(18),
            topRight: Radius.circular(18),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(18),
          ),
          border: Border.all(color: AppColors.border),
        ),
        child: const SizedBox(
          width: 24,
          height: 16,
          child: Center(
            child: SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.purpleLight,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    final chips = [
      "Reflect on my day",
      "Reframe my thoughts",
      "Breathing exercise",
      "Just talk",
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: chips.map((text) {
          return GestureDetector(
            onTap: () => _sendMessage(text),
            child: Container(
              margin: const EdgeInsets.only(bottom: 8),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.bgCard.withOpacity(0.6),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(
                '→ $text',
                style: GoogleFonts.dmSans(color: Colors.white, fontSize: 13),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      margin: const EdgeInsets.only(left: 20, right: 20, bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.bgCard.withOpacity(0.8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.purple.withOpacity(0.25), width: 1.5),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _inputController,
              enabled: !_safetyTriggered,
              style: GoogleFonts.dmSans(color: Colors.white, fontSize: 13.5),
              decoration: InputDecoration(
                hintText: _safetyTriggered ? 'Companion suspended' : 'Type your message...',
                hintStyle: GoogleFonts.dmSans(color: AppColors.muted),
                border: InputBorder.none,
                isDense: true,
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (val) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: _safetyTriggered ? null : () => _sendMessage(),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: _safetyTriggered ? AppColors.purple.withOpacity(0.2) : AppColors.purple,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.arrow_forward, color: Colors.white, size: 16),
            ),
          )
        ],
      ),
    );
  }
}
