import React, { useState, useEffect, useRef } from "react";
import {
  StyleSheet,
  View,
  Text,
  TextInput,
  TouchableOpacity,
  ScrollView,
  SafeAreaView,
  KeyboardAvoidingView,
  Platform,
  ActivityIndicator,
} from "react-native";
import Svg, { Circle, Path, G, Defs, RadialGradient, Stop } from "react-native-svg";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { COLORS, FONTS } from "../components/Theme";
import { WarningIcon } from "../components/Icons";

const CRISIS_WORDS = ["suicide", "kill myself", "harm myself", "end my life", "want to die", "self harm"];

function SmilingPlanetAvatar({ size = 90 }) {
  return (
    <Svg width={size} height={size} viewBox="0 0 100 100" fill="none">
      <Defs>
        <RadialGradient id="planetGrad" cx="35%" cy="35%" r="65%">
          <Stop offset="0%" stopColor="#a89af7" />
          <Stop offset="50%" stopColor="#4a3fa0" />
          <Stop offset="100%" stopColor="#1a1040" />
        </RadialGradient>
      </Defs>
      {/* Glow shadow ring */}
      <Circle cx="50" cy="50" r="46" stroke="rgba(168, 154, 247, 0.25)" strokeWidth="1.5" />
      {/* Planet body */}
      <Circle cx="50" cy="50" r="42" fill="url(#planetGrad)" stroke="rgba(168, 154, 247, 0.4)" strokeWidth="1" />
      {/* Outer Orbit Ring */}
      <Path
        d="M 12 58 C 22 75, 78 75, 88 58"
        stroke="rgba(168, 154, 247, 0.7)"
        strokeWidth="2.5"
        strokeLinecap="round"
      />
      {/* Face details */}
      <G opacity="0.9">
        {/* Left Eye */}
        <Circle cx="38" cy="46" r="3.5" fill="white" />
        <Circle cx="37" cy="45" r="1" fill="#1a1040" />
        {/* Right Eye */}
        <Circle cx="62" cy="46" r="3.5" fill="white" />
        <Circle cx="61" cy="45" r="1" fill="#1a1040" />
        {/* Rosy Cheeks */}
        <Circle cx="30" cy="53" r="4" fill="rgba(247, 168, 212, 0.4)" />
        <Circle cx="70" cy="53" r="4" fill="rgba(247, 168, 212, 0.4)" />
        {/* Smile */}
        <Path
          d="M 44 54 Q 50 60, 56 54"
          stroke="white"
          strokeWidth="2"
          strokeLinecap="round"
        />
      </G>
      {/* Front Planet Ring half (to overlay planet) */}
      <Path
        d="M 88 58 C 84 50, 70 42, 50 42 C 30 42, 16 50, 12 58"
        stroke="rgba(168, 154, 247, 0.7)"
        strokeWidth="2.5"
        strokeLinecap="round"
      />
    </Svg>
  );
}

export default function NovaScreen() {
  const [messages, setMessages] = useState([
    {
      id: "1",
      from: "nova",
      text: "I noticed you've been feeling overwhelmed this week. I'm here for you. What would you like to do?",
    },
  ]);
  const [input, setInput] = useState("");
  const [loading, setLoading] = useState(false);
  const [apiKey, setApiKey] = useState("");
  const [safetyTriggered, setSafetyTriggered] = useState(false);

  const scrollViewRef = useRef();

  useEffect(() => {
    async function loadKey() {
      try {
        const storedKey = await AsyncStorage.getItem("zenara_anthropic_api_key");
        if (storedKey) setApiKey(storedKey);
      } catch (e) {
        console.log("Failed to load api key");
      }
    }
    loadKey();
  }, []);

  const checkForCrisis = (text) => {
    const lower = text.toLowerCase();
    return CRISIS_WORDS.some((word) => lower.includes(word));
  };

  const getMockResponse = (userInput) => {
    const lower = userInput.toLowerCase();
    if (lower.includes("reflect")) {
      return "Let's take a moment to look back at your day. What was one moment where you felt completely in control, however small?";
    }
    if (lower.includes("reframe")) {
      return "I can help with that. Share a negative thought you've had today, and we'll work together to identify cognitive distortions and reframe it gently.";
    }
    if (lower.includes("breathe") || lower.includes("breathing")) {
      return "Let's do a quick Box Breathing exercise. Inhale for 4 seconds, hold for 4, exhale for 4, hold for 4. Shall we begin?";
    }
    if (lower.includes("hello") || lower.includes("hi")) {
      return "Hello! I'm Nova, your emotional companion. How is your heart feeling today?";
    }
    return "I hear you, and I'm holding space for you. Thank you for sharing that with me. What feelings are surfacing for you right now?";
  };

  const sendMessage = async (textToSend) => {
    const text = textToSend || input;
    if (!text.trim() || loading || safetyTriggered) return;

    // Safety Trigger Check
    if (checkForCrisis(text)) {
      setSafetyTriggered(true);
      const userMsg = { id: Date.now().toString(), from: "user", text };
      const safetyMsg = {
        id: (Date.now() + 1).toString(),
        from: "nova",
        text: "Safety Warning: I have detected indicators of crisis. The AI companion is suspended. Please see the crisis support information above.",
      };
      setMessages((prev) => [...prev, userMsg, safetyMsg]);
      setInput("");
      return;
    }

    const userMsg = { id: Date.now().toString(), from: "user", text };
    setMessages((prev) => [...prev, userMsg]);
    setInput("");
    setLoading(true);

    if (apiKey) {
      try {
        const res = await fetch("https://api.anthropic.com/v1/messages", {
          method: "POST",
          headers: {
            "Content-Type": "application/json",
            "x-api-key": apiKey,
            "anthropic-version": "2023-06-01",
          },
          body: JSON.stringify({
            model: "claude-3-5-sonnet-20241022",
            max_tokens: 200,
            system: `You are Nova, Zenara's compassionate AI mental health companion. You are warm, empathetic, and supportive. You help users reflect on their emotions, reframe negative thoughts, and practice coping strategies. You are NOT a therapist or medical professional — always remind users to speak with their therapist (Dr. Hayes) for clinical support. Keep responses concise (2-3 sentences), warm, and conversational. Use gentle, supportive language. If you detect any self-harm language, immediately provide crisis resources.`,
            messages: [...messages, userMsg].map((m) => ({
              role: m.from === "user" ? "user" : "assistant",
              content: m.text,
            })),
          }),
        });

        const data = await res.json();
        const reply = data.content?.[0]?.text || "I'm here with you. Tell me more.";
        setMessages((prev) => [...prev, { id: Date.now().toString(), from: "nova", text: reply }]);
      } catch (err) {
        setMessages((prev) => [
          ...prev,
          {
            id: Date.now().toString(),
            from: "nova",
            text: "I'm having a little trouble connecting to my servers. Take a breath — I'm still here with you. (Offline companion mode active)",
          },
        ]);
      }
    } else {
      // Mock Offline Mode
      setTimeout(() => {
        const reply = getMockResponse(text);
        setMessages((prev) => [...prev, { id: Date.now().toString(), from: "nova", text: reply }]);
        setLoading(false);
      }, 800);
      return;
    }
    setLoading(false);
  };

  const handleResetCrisis = () => {
    setSafetyTriggered(false);
    setMessages([
      {
        id: Date.now().toString(),
        from: "nova",
        text: "I'm back, Sarah. Let's start fresh. How can I support you right now?",
      },
    ]);
  };

  return (
    <SafeAreaView style={styles.container}>
      <KeyboardAvoidingView
        behavior={Platform.OS === "ios" ? "padding" : "height"}
        style={styles.keyboardView}
      >
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.title}>Nova</Text>
          <Text style={styles.subtitle}>AI Companion</Text>
        </View>

        {/* Safety Banner if triggered */}
        {safetyTriggered && (
          <View style={styles.safetyCard}>
            <View style={styles.safetyHeaderRow}>
              <WarningIcon color="#f06c8a" size={18} />
              <Text style={styles.safetyHeader}>IMMEDIATE SUPPORT AVAILABLE</Text>
            </View>
            <Text style={styles.safetyBody}>
              You are not alone. Please reach out to these confidential resources immediately:
            </Text>
            <Text style={styles.safetyContact}>📞 National Helpline (India): 9152987821</Text>
            <Text style={styles.safetyContact}>📞 Suicide & Crisis Lifeline (US): 988</Text>
            <Text style={styles.safetyContact}>📞 Vandrevala Foundation: 1860 2662 345</Text>
            <TouchableOpacity style={styles.safetyResetBtn} onPress={handleResetCrisis}>
              <Text style={styles.safetyResetBtnText}>Reset Companion</Text>
            </TouchableOpacity>
          </View>
        )}

        {/* Nova Glow Moon Avatar */}
        {!safetyTriggered && messages.length <= 2 && (
          <View style={styles.avatarContainer}>
            <View style={styles.glowOuter}>
              <SmilingPlanetAvatar size={90} />
            </View>
          </View>
        )}

        {/* Message Thread */}
        <ScrollView
          ref={scrollViewRef}
          onContentSizeChange={() => scrollViewRef.current?.scrollToEnd({ animated: true })}
          contentContainerStyle={styles.messageScroll}
          showsVerticalScrollIndicator={false}
        >
          {messages.map((msg) => {
            const isUser = msg.from === "user";
            return (
              <View
                key={msg.id}
                style={[
                  styles.messageBubbleContainer,
                  isUser ? styles.bubbleUserAlign : styles.bubbleNovaAlign,
                ]}
              >
                <View
                  style={[
                    styles.messageBubble,
                    isUser ? styles.bubbleUser : styles.bubbleNova,
                  ]}
                >
                  <Text style={styles.messageText}>{msg.text}</Text>
                </View>
              </View>
            );
          })}

          {loading && (
            <View style={[styles.messageBubbleContainer, styles.bubbleNovaAlign]}>
              <View style={[styles.messageBubble, styles.bubbleNova, styles.loadingBubble]}>
                <ActivityIndicator size="small" color={COLORS.purpleLight} />
              </View>
            </View>
          )}
        </ScrollView>

        {/* Suggestion Chips */}
        {!safetyTriggered && messages.length <= 2 && (
          <View style={styles.suggestionsContainer}>
            {[
              "Reflect on my day",
              "Reframe my thoughts",
              "Breathing exercise",
              "Just talk",
            ].map((chip) => (
              <TouchableOpacity
                key={chip}
                style={styles.suggestionChip}
                onPress={() => sendMessage(chip)}
              >
                <Text style={styles.suggestionText}>→ {chip}</Text>
              </TouchableOpacity>
            ))}
          </View>
        )}

        {/* Input Bar */}
        <View style={styles.inputBar}>
          <TextInput
            value={input}
            onChangeText={setInput}
            onSubmitEditing={() => sendMessage()}
            placeholder={safetyTriggered ? "Companion suspended" : "Type your message..."}
            placeholderTextColor={COLORS.muted}
            editable={!safetyTriggered}
            style={[styles.textInput, safetyTriggered && styles.inputDisabled]}
          />
          <TouchableOpacity
            style={[styles.sendButton, safetyTriggered && styles.sendButtonDisabled]}
            disabled={safetyTriggered}
            onPress={() => sendMessage()}
          >
            <Svg width="16" height="16" viewBox="0 0 24 24" fill="none">
              <Path
                d="M5 12h14M12 5l7 7-7 7"
                stroke="white"
                strokeWidth="2.5"
                strokeLinecap="round"
                strokeLinejoin="round"
              />
            </Svg>
          </TouchableOpacity>
        </View>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.bg,
  },
  keyboardView: {
    flex: 1,
  },
  header: {
    paddingTop: 16,
    paddingBottom: 8,
    alignItems: "center",
    borderBottomWidth: 1,
    borderColor: COLORS.border,
  },
  title: {
    color: COLORS.white,
    fontSize: 20,
    fontWeight: "700",
    fontFamily: FONTS.serif,
  },
  subtitle: {
    color: COLORS.muted,
    fontSize: 12,
    fontFamily: FONTS.sans,
  },
  avatarContainer: {
    alignItems: "center",
    marginTop: 20,
    marginBottom: 10,
  },
  glowOuter: {
    width: 120,
    height: 120,
    borderRadius: 60,
    backgroundColor: "rgba(124, 111, 247, 0.08)",
    alignItems: "center",
    justifyContent: "center",
    shadowColor: COLORS.purple,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.6,
    shadowRadius: 20,
    elevation: 4,
  },
  messageScroll: {
    paddingHorizontal: 20,
    paddingVertical: 16,
  },
  messageBubbleContainer: {
    marginBottom: 12,
    flexDirection: "row",
  },
  bubbleUserAlign: {
    justifyContent: "flex-end",
  },
  bubbleNovaAlign: {
    justifyContent: "flex-start",
  },
  messageBubble: {
    maxWidth: "80%",
    borderRadius: 18,
    paddingHorizontal: 16,
    paddingVertical: 12,
    shadowColor: "black",
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 6,
    elevation: 1,
  },
  bubbleUser: {
    backgroundColor: COLORS.purple,
    borderBottomRightRadius: 4,
  },
  bubbleNova: {
    backgroundColor: "rgba(25, 22, 54, 0.75)",
    borderWidth: 1,
    borderColor: COLORS.border,
    borderBottomLeftRadius: 4,
  },
  loadingBubble: {
    paddingVertical: 8,
    paddingHorizontal: 20,
  },
  messageText: {
    color: COLORS.white,
    fontSize: 13.5,
    lineHeight: 19,
    fontFamily: FONTS.sans,
  },
  suggestionsContainer: {
    paddingHorizontal: 20,
    gap: 8,
    marginBottom: 12,
  },
  suggestionChip: {
    backgroundColor: "rgba(25, 22, 54, 0.6)",
    borderRadius: 14,
    borderWidth: 1,
    borderColor: COLORS.border,
    paddingVertical: 10,
    paddingHorizontal: 16,
  },
  suggestionText: {
    color: COLORS.white,
    fontSize: 13,
    fontFamily: FONTS.sans,
  },
  inputBar: {
    flexDirection: "row",
    backgroundColor: "rgba(25, 22, 54, 0.8)",
    borderRadius: 18,
    borderWidth: 1.5,
    borderColor: "rgba(124, 111, 247, 0.25)",
    marginHorizontal: 20,
    marginBottom: 16,
    paddingHorizontal: 14,
    paddingVertical: 8,
    alignItems: "center",
  },
  textInput: {
    flex: 1,
    color: COLORS.white,
    fontSize: 13.5,
    fontFamily: FONTS.sans,
    paddingVertical: 4,
  },
  inputDisabled: {
    color: COLORS.muted,
  },
  sendButton: {
    width: 34,
    height: 34,
    borderRadius: 10,
    backgroundColor: COLORS.purple,
    alignItems: "center",
    justifyContent: "center",
    marginLeft: 8,
    shadowColor: COLORS.purple,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.4,
    shadowRadius: 5,
    elevation: 3,
  },
  sendButtonDisabled: {
    backgroundColor: "rgba(124, 111, 247, 0.2)",
    shadowOpacity: 0,
    elevation: 0,
  },
  safetyCard: {
    backgroundColor: "rgba(240, 108, 138, 0.08)",
    borderColor: "rgba(240, 108, 138, 0.3)",
    borderWidth: 1,
    borderRadius: 16,
    padding: 16,
    margin: 20,
  },
  safetyHeaderRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
    marginBottom: 8,
  },
  safetyHeader: {
    color: "#f06c8a",
    fontSize: 13,
    fontWeight: "700",
    fontFamily: FONTS.sans,
  },
  safetyBody: {
    color: COLORS.white,
    fontSize: 12,
    lineHeight: 17,
    fontFamily: FONTS.sans,
    marginBottom: 10,
    opacity: 0.9,
  },
  safetyContact: {
    color: COLORS.white,
    fontSize: 12.5,
    fontWeight: "600",
    fontFamily: FONTS.sans,
    marginBottom: 4,
  },
  safetyResetBtn: {
    marginTop: 14,
    backgroundColor: COLORS.bgElevated,
    borderWidth: 1,
    borderColor: COLORS.border,
    borderRadius: 10,
    paddingVertical: 10,
    alignItems: "center",
  },
  safetyResetBtnText: {
    color: COLORS.purpleLight,
    fontSize: 12,
    fontWeight: "600",
  },
});
