import React, { useState, useEffect, useRef } from "react";
import {
  StyleSheet,
  View,
  Text,
  TextInput,
  TouchableOpacity,
  ScrollView,
  SafeAreaView,
  Alert,
} from "react-native";
import AsyncStorage from "@react-native-async-storage/async-storage";
import { AudioModule, useAudioRecorder, useAudioPlayer, useAudioPlayerStatus, RecordingPresets } from "expo-audio";
import Svg, { Path } from "react-native-svg";
import { COLORS, FONTS } from "../components/Theme";
import {
  TextCanvasIcon,
  MicIcon,
  ImageIcon,
  PencilIcon,
  ListIcon,
  SearchIcon,
  RefreshIcon,
  SparkleIcon,
  CheckIcon,
} from "../components/Icons";
import LotusIcon from "../components/LotusIcon";

const DEFAULT_ENTRIES = [
  { id: "1", date: "May 25, 2026", preview: "Feeling more grounded today. The breathing exercise really helped with the presentation anxiety...", tagColor: "#4ecdc4" },
  { id: "2", date: "May 24, 2026", preview: "Hard day. Couldn't focus at all. Nova helped me break down the tasks into smaller pieces...", tagColor: "#7c9abf" },
  { id: "3", date: "May 23, 2026", preview: "Really good session with Dr. Hayes today. We talked about boundary setting and I feel...", tagColor: "#f7e08a" },
];

function DoodleCanvas({ onSave, onCancel }) {
  const [paths, setPaths] = useState([]);
  const [currentPath, setCurrentPath] = useState("");
  const [canvasLayout, setCanvasLayout] = useState({ width: 0, height: 0 });

  const handleTouchStart = (e) => {
    const { locationX, locationY } = e.nativeEvent;
    const startPoint = `M ${locationX.toFixed(1)} ${locationY.toFixed(1)}`;
    setCurrentPath(startPoint);
  };

  const handleTouchMove = (e) => {
    const { locationX, locationY } = e.nativeEvent;
    if (
      locationX < 0 ||
      locationY < 0 ||
      locationX > canvasLayout.width ||
      locationY > canvasLayout.height
    ) {
      return;
    }
    if (currentPath) {
      setCurrentPath((prev) => `${prev} L ${locationX.toFixed(1)} ${locationY.toFixed(1)}`);
    }
  };

  const handleTouchEnd = () => {
    if (currentPath) {
      setPaths((prev) => [...prev, currentPath]);
      setCurrentPath("");
    }
  };

  const handleClear = () => {
    setPaths([]);
    setCurrentPath("");
  };

  return (
    <View style={styles.doodleContainer}>
      <View style={styles.doodleHeader}>
        <Text style={styles.doodleTitle}>Draw Your Feeling</Text>
        <TouchableOpacity onPress={handleClear}>
          <Text style={styles.doodleClearText}>Clear Canvas</Text>
        </TouchableOpacity>
      </View>
      <View
        style={styles.doodleCanvas}
        onLayout={(e) => {
          setCanvasLayout({
            width: e.nativeEvent.layout.width,
            height: e.nativeEvent.layout.height,
          });
        }}
        onTouchStart={handleTouchStart}
        onTouchMove={handleTouchMove}
        onTouchEnd={handleTouchEnd}
      >
        <Svg style={StyleSheet.absoluteFill}>
          {paths.map((p, idx) => (
            <Path
              key={idx}
              d={p}
              stroke={COLORS.teal}
              strokeWidth={3}
              fill="none"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          ))}
          {currentPath ? (
            <Path
              d={currentPath}
              stroke={COLORS.teal}
              strokeWidth={3}
              fill="none"
              strokeLinecap="round"
              strokeLinejoin="round"
            />
          ) : null}
        </Svg>
        {paths.length === 0 && !currentPath && (
          <View style={styles.doodlePlaceholderContainer} pointerEvents="none">
            <Text style={styles.doodlePlaceholderText}>Express yourself with doodles here... 🎨</Text>
          </View>
        )}
      </View>
      <View style={styles.doodleFooterButtons}>
        <TouchableOpacity style={styles.doodleCancelBtn} onPress={onCancel}>
          <Text style={styles.doodleCancelBtnText}>Cancel</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.doodleSaveBtn, paths.length === 0 && styles.doodleSaveBtnDisabled]}
          disabled={paths.length === 0}
          onPress={() => onSave(paths.length)}
        >
          <Text style={styles.doodleSaveBtnText}>Attach Doodle</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

function VoiceRecorder({ onSave, onCancel }) {
  const recorder = useAudioRecorder(RecordingPresets.HIGH_QUALITY);
  const [recordSecs, setRecordSecs] = useState(0);
  const [status, setStatus] = useState("idle"); // 'idle', 'recording', 'stopped'
  const [recordingUri, setRecordingUri] = useState(null);

  const player = useAudioPlayer();
  const playerStatus = useAudioPlayerStatus(player);
  const isPlaying = playerStatus?.isPlaying ?? false;
  
  const timerRef = useRef(null);

  useEffect(() => {
    return () => {
      if (timerRef.current) clearInterval(timerRef.current);
    };
  }, []);

  const startRecording = async () => {
    try {
      const permission = await AudioModule.requestRecordingPermissionsAsync();
      if (permission.status !== "granted") {
        Alert.alert("Permission Denied", "Microphone access is required to record voice notes.");
        return;
      }
      
      await recorder.record();
      setStatus("recording");
      setRecordSecs(0);
      setRecordingUri(null);
      timerRef.current = setInterval(() => {
        setRecordSecs((prev) => prev + 1);
      }, 1000);
    } catch (err) {
      console.error("Failed to start recording", err);
      Alert.alert("Error", "Could not start audio recording.");
    }
  };

  const stopRecording = async () => {
    if (!recorder.isRecording) return;
    setStatus("stopped");
    if (timerRef.current) {
      clearInterval(timerRef.current);
      timerRef.current = null;
    }
    try {
      await recorder.stop();
      setRecordingUri(recorder.uri);
    } catch (err) {
      console.error("Failed to stop recording", err);
    }
  };

  const playRecordedAudio = async () => {
    if (!recordingUri) return;
    if (isPlaying) {
      player.pause();
      return;
    }
    try {
      if (player.source?.uri !== recordingUri) {
        player.replace({ uri: recordingUri });
      }
      if (playerStatus?.currentTime >= playerStatus?.duration) {
        player.seekTo(0);
      }
      player.play();
    } catch (err) {
      console.error("Failed to play recording", err);
    }
  };

  const formatTime = (secs) => {
    const mins = Math.floor(secs / 60);
    const remainingSecs = secs % 60;
    return `${mins}:${remainingSecs < 10 ? "0" : ""}${remainingSecs}`;
  };

  return (
    <View style={styles.recorderContainer}>
      <Text style={styles.recorderTitle}>Voice Reflection</Text>
      <View style={styles.recorderWaveContainer}>
        {status === "recording" ? (
          <View style={styles.recordingIndicator}>
            <View style={[styles.redDot, { opacity: recordSecs % 2 === 0 ? 1 : 0.3 }]} />
            <Text style={styles.recordingText}>Recording...</Text>
          </View>
        ) : recordingUri ? (
          <TouchableOpacity style={styles.playRecordedBtn} onPress={playRecordedAudio}>
            <Text style={styles.playRecordedBtnText}>{isPlaying ? "⏸ Pause Note" : "▶ Play Note"}</Text>
          </TouchableOpacity>
        ) : (
          <Text style={styles.recorderPlaceholder}>Tap Record to start voice note</Text>
        )}
      </View>
      <Text style={styles.recorderDuration}>{formatTime(recordSecs)}</Text>
      <View style={styles.recorderControlRow}>
        {status === "recording" ? (
          <TouchableOpacity style={styles.stopRecordBtn} onPress={stopRecording}>
            <Text style={styles.stopRecordBtnText}>Stop</Text>
          </TouchableOpacity>
        ) : (
          <TouchableOpacity style={styles.startRecordBtn} onPress={startRecording}>
            <Text style={styles.startRecordBtnText}>Record</Text>
          </TouchableOpacity>
        )}
      </View>
      <View style={styles.recorderFooterButtons}>
        <TouchableOpacity style={styles.recorderCancelBtn} onPress={onCancel}>
          <Text style={styles.recorderCancelBtnText}>Cancel</Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.recorderSaveBtn, !recordingUri && styles.recorderSaveBtnDisabled]}
          disabled={!recordingUri}
          onPress={() => onSave(recordingUri, recordSecs)}
        >
          <Text style={styles.recorderSaveBtnText}>Attach Voice Note</Text>
        </TouchableOpacity>
      </View>
    </View>
  );
}

export default function JournalScreen() {
  const [entryText, setEntryText] = useState("");
  const [entries, setEntries] = useState([]);
  const [saved, setSaved] = useState(false);
  const [activeInputType, setActiveInputType] = useState("text"); // 'text', 'voice', 'doodle'

  const prompts = [
    "What made you smile today?",
    "What are you finding hard right now?",
    "What do you need most in this moment?",
    "Name one thing you're grateful for.",
  ];
  const [promptIdx, setPromptIdx] = useState(0);

  // Load journal entries
  useEffect(() => {
    async function loadEntries() {
      try {
        const stored = await AsyncStorage.getItem("zenara_journal_entries");
        if (stored) {
          setEntries(JSON.parse(stored));
        } else {
          setEntries(DEFAULT_ENTRIES);
          await AsyncStorage.setItem("zenara_journal_entries", JSON.stringify(DEFAULT_ENTRIES));
        }
      } catch (e) {
        setEntries(DEFAULT_ENTRIES);
      }
    }
    loadEntries();
  }, []);

  const handleSave = async () => {
    if (!entryText.trim()) {
      Alert.alert("Empty Journal", "Please write something before saving.");
      return;
    }

    const newEntry = {
      id: Date.now().toString(),
      date: new Date().toLocaleDateString("en-US", { month: "short", day: "numeric", year: "numeric" }),
      preview: entryText.trim(),
      tagColor: COLORS.purple,
    };

    const updated = [newEntry, ...entries];
    setEntries(updated);
    setEntryText("");
    setSaved(true);

    try {
      await AsyncStorage.setItem("zenara_journal_entries", JSON.stringify(updated));
    } catch (e) {
      console.log("Failed to save entries to storage");
    }

    setTimeout(() => setSaved(false), 2000);
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.title}>Journal</Text>
          <TouchableOpacity style={styles.searchButton}>
            <SearchIcon color="white" size={16} />
          </TouchableOpacity>
        </View>

        {/* My Moon Journal Banner */}
        <View style={styles.banner}>
          <View style={styles.bannerTextContainer}>
            <Text style={styles.bannerTag}>My Moon Journal</Text>
            <Text style={styles.bannerCount}>{entries.length} entries</Text>
          </View>
          <View style={styles.bannerVectorContainer}>
            {/* Custom Glowing Lotus and sparkle vector instead of emoji moon */}
            <View style={styles.moonBg}>
              <LotusIcon size={42} />
            </View>
            <View style={styles.star1}><SparkleIcon size={12} color={COLORS.gold} /></View>
            <View style={styles.star2}><SparkleIcon size={8} color={COLORS.purpleLight} /></View>
          </View>
        </View>

        {/* Today's Entry Box */}
        <View style={styles.card}>
          <View style={styles.cardHeader}>
            <Text style={styles.cardToday}>Today</Text>
            <Text style={styles.cardDate}>
              {new Date().toLocaleDateString("en-US", {
                month: "short",
                day: "numeric",
                year: "numeric",
              })}
            </Text>
          </View>

          {/* Guided Prompt */}
          <View style={styles.promptContainer}>
            <Text style={styles.promptText}>"{prompts[promptIdx]}"</Text>
            <TouchableOpacity onPress={() => setPromptIdx((i) => (i + 1) % prompts.length)}>
              <RefreshIcon color={COLORS.purpleLight} size={15} />
            </TouchableOpacity>
          </View>

          {/* Input Canvas */}
          {activeInputType === "text" && (
            <TextInput
              value={entryText}
              onChangeText={setEntryText}
              placeholder="How are you feeling right now?"
              placeholderTextColor={COLORS.muted}
              multiline
              style={styles.textInput}
            />
          )}

          {activeInputType === "voice" && (
            <VoiceRecorder
              onCancel={() => setActiveInputType("text")}
              onSave={(uri, secs) => {
                setEntryText((prev) => (prev ? prev + ` [Voice note: ${secs}s]` : `[Voice note: ${secs}s]`));
                setActiveInputType("text");
              }}
            />
          )}

          {activeInputType === "doodle" && (
            <DoodleCanvas
              onCancel={() => setActiveInputType("text")}
              onSave={(strokes) => {
                setEntryText((prev) => (prev ? prev + ` [Doodle attached: ${strokes} stroke(s)]` : `[Doodle attached: ${strokes} stroke(s)]`));
                setActiveInputType("text");
              }}
            />
          )}

          {/* Tool bar */}
          <View style={styles.toolbar}>
            {[
              { icon: <TextCanvasIcon color="white" size={16} />, type: "text" },
              { icon: <MicIcon color="white" size={16} />, type: "voice" },
              { icon: <ImageIcon color="white" size={16} />, type: "text" },
              { icon: <PencilIcon color="white" size={16} />, type: "doodle" },
              { icon: <ListIcon color="white" size={16} />, type: "text" },
            ].map((item, i) => (
              <TouchableOpacity
                key={i}
                style={[
                  styles.toolbarButton,
                  activeInputType === item.type && item.type !== "text" && styles.toolbarButtonActive,
                ]}
                onPress={() => {
                  if (item.type === "voice" || item.type === "doodle") {
                    setActiveInputType(item.type);
                  } else {
                    setActiveInputType("text");
                  }
                }}
              >
                {item.icon}
              </TouchableOpacity>
            ))}
          </View>

          {/* Save Button */}
          <TouchableOpacity
            style={[styles.saveButton, saved && styles.saveButtonSaved]}
            onPress={handleSave}
            activeOpacity={0.8}
          >
            <Text style={styles.saveButtonText}>{saved ? "✓ Saved!" : "Save Entry"}</Text>
          </TouchableOpacity>
        </View>

        {/* Past Entries */}
        <Text style={styles.sectionTitle}>Past Entries</Text>
        {entries.map((item) => (
          <View key={item.id} style={[styles.card, styles.pastEntryCard]}>
            <View style={[styles.bulletIndicator, { backgroundColor: item.tagColor || COLORS.purple }]} />
            <View style={styles.pastEntryContent}>
              <Text style={styles.pastEntryDate}>{item.date}</Text>
              <Text style={styles.pastEntryPreview} numberOfLines={2}>
                {item.preview}
              </Text>
            </View>
          </View>
        ))}
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.bg,
  },
  scrollContent: {
    paddingHorizontal: 20,
    paddingBottom: 24,
  },
  header: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    paddingTop: 16,
    paddingBottom: 16,
  },
  title: {
    color: COLORS.white,
    fontSize: 22,
    fontWeight: "600",
    fontFamily: FONTS.serif,
  },
  searchButton: {
    width: 36,
    height: 36,
    borderRadius: 10,
    backgroundColor: COLORS.bgElevated,
    borderWidth: 1,
    borderColor: COLORS.border,
    alignItems: "center",
    justifyContent: "center",
  },
  banner: {
    borderRadius: 18,
    overflow: "hidden",
    height: 110,
    backgroundColor: "rgba(28, 16, 64, 0.7)",
    borderWidth: 1,
    borderColor: "rgba(124, 111, 247, 0.25)",
    position: "relative",
    flexDirection: "row",
    alignItems: "center",
    paddingHorizontal: 20,
    marginBottom: 16,
  },
  bannerTextContainer: {
    flex: 1,
  },
  bannerTag: {
    color: COLORS.purpleLight,
    fontSize: 11,
    fontWeight: "600",
    letterSpacing: 1,
    textTransform: "uppercase",
    fontFamily: FONTS.sans,
    marginBottom: 4,
  },
  bannerCount: {
    color: COLORS.white,
    fontSize: 18,
    fontFamily: FONTS.serif,
  },
  bannerVectorContainer: {
    width: 70,
    height: 70,
    position: "relative",
    justifyContent: "center",
    alignItems: "center",
  },
  moonBg: {
    width: 58,
    height: 58,
    borderRadius: 29,
    backgroundColor: "rgba(124, 111, 247, 0.12)",
    alignItems: "center",
    justifyContent: "center",
    borderWidth: 1,
    borderColor: "rgba(124, 111, 247, 0.2)",
  },
  star1: {
    position: "absolute",
    top: 4,
    right: 2,
  },
  star2: {
    position: "absolute",
    bottom: 6,
    left: 2,
  },
  card: {
    backgroundColor: "rgba(19, 16, 43, 0.7)",
    borderRadius: 18,
    borderWidth: 1,
    borderColor: COLORS.border,
    padding: 16,
    marginBottom: 16,
  },
  cardHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 12,
  },
  cardToday: {
    color: COLORS.white,
    fontSize: 14,
    fontWeight: "600",
    fontFamily: FONTS.sans,
  },
  cardDate: {
    color: COLORS.muted,
    fontSize: 11,
    fontFamily: FONTS.sans,
  },
  promptContainer: {
    backgroundColor: COLORS.bgElevated,
    borderRadius: 12,
    paddingHorizontal: 14,
    paddingVertical: 10,
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 12,
    borderWidth: 1,
    borderColor: "rgba(124, 111, 247, 0.1)",
  },
  promptText: {
    color: COLORS.purpleLight,
    fontSize: 13,
    fontStyle: "italic",
    fontFamily: FONTS.sans,
    flex: 1,
  },
  textInput: {
    color: COLORS.white,
    fontSize: 14,
    lineHeight: 22,
    minHeight: 110,
    fontFamily: FONTS.sans,
    textAlignVertical: "top",
    paddingTop: 4,
    paddingBottom: 8,
  },
  toolbar: {
    flexDirection: "row",
    gap: 12,
    marginTop: 8,
    marginBottom: 12,
  },
  toolbarButton: {
    width: 34,
    height: 34,
    borderRadius: 10,
    backgroundColor: COLORS.bgElevated,
    alignItems: "center",
    justifyContent: "center",
    borderWidth: 1,
    borderColor: COLORS.border,
  },
  toolbarButtonActive: {
    backgroundColor: COLORS.purpleDark,
    borderColor: COLORS.purple,
    borderWidth: 1,
  },
  saveButton: {
    backgroundColor: COLORS.purple,
    borderRadius: 14,
    paddingVertical: 12,
    alignItems: "center",
  },
  saveButtonSaved: {
    backgroundColor: COLORS.teal,
  },
  saveButtonText: {
    color: "white",
    fontSize: 14,
    fontWeight: "600",
    fontFamily: FONTS.sans,
  },
  sectionTitle: {
    color: COLORS.muted,
    fontSize: 11,
    fontWeight: "600",
    letterSpacing: 1,
    textTransform: "uppercase",
    fontFamily: FONTS.sans,
    marginVertical: 12,
  },
  pastEntryCard: {
    flexDirection: "row",
    alignItems: "center",
    marginBottom: 10,
    paddingVertical: 14,
  },
  bulletIndicator: {
    width: 10,
    height: 10,
    borderRadius: 5,
    marginRight: 14,
    marginLeft: 4,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.8,
    shadowRadius: 3,
  },
  pastEntryContent: {
    flex: 1,
  },
  pastEntryDate: {
    color: COLORS.muted,
    fontSize: 11,
    fontFamily: FONTS.sans,
    marginBottom: 4,
  },
  pastEntryPreview: {
    color: COLORS.white,
    fontSize: 13,
    lineHeight: 18,
    fontFamily: FONTS.sans,
  },
  mockInterfaceContainer: {
    alignItems: "center",
    justifyContent: "center",
    minHeight: 130,
    paddingVertical: 10,
  },
  mockWaveContainer: {
    width: 50,
    height: 50,
    borderRadius: 25,
    backgroundColor: "rgba(124, 111, 247, 0.08)",
    alignItems: "center",
    justifyContent: "center",
    borderWidth: 1,
    borderColor: COLORS.border,
    marginBottom: 8,
  },
  mockInterfaceTitle: {
    color: COLORS.white,
    fontSize: 14,
    fontWeight: "600",
    fontFamily: FONTS.sans,
  },
  mockInterfaceSubtitle: {
    color: COLORS.muted,
    fontSize: 12,
    marginTop: 2,
    marginBottom: 12,
    fontFamily: FONTS.sans,
  },
  mockInterfaceButton: {
    backgroundColor: COLORS.bgElevated,
    borderRadius: 8,
    paddingHorizontal: 16,
    paddingVertical: 8,
    borderWidth: 1,
    borderColor: COLORS.border,
  },
  mockInterfaceButtonText: {
    color: COLORS.purpleLight,
    fontSize: 12,
    fontWeight: "600",
    fontFamily: FONTS.sans,
  },
  mockDoodleCanvas: {
    width: "100%",
    height: 80,
    backgroundColor: COLORS.bgElevated,
    borderRadius: 8,
    borderWidth: 1,
    borderStyle: "dashed",
    borderColor: COLORS.border,
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 12,
  },
  mockDoodleCanvas: {
    width: "100%",
    height: 80,
    backgroundColor: COLORS.bgElevated,
    borderRadius: 8,
    borderWidth: 1,
    borderStyle: "dashed",
    borderColor: COLORS.border,
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 12,
  },
  mockDoodleCanvasText: {
    color: COLORS.muted,
    fontSize: 12,
    fontFamily: FONTS.sans,
  },

  // Doodle Canvas Styles
  doodleContainer: {
    padding: 10,
    alignItems: "center",
  },
  doodleHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    width: "100%",
    marginBottom: 8,
  },
  doodleTitle: {
    color: COLORS.white,
    fontSize: 14,
    fontWeight: "600",
    fontFamily: FONTS.sans,
  },
  doodleClearText: {
    color: COLORS.purpleLight,
    fontSize: 12,
    fontFamily: FONTS.sans,
  },
  doodleCanvas: {
    width: "100%",
    height: 160,
    backgroundColor: COLORS.bgElevated,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: COLORS.border,
    position: "relative",
    overflow: "hidden",
  },
  doodlePlaceholderContainer: {
    ...StyleSheet.absoluteFillObject,
    alignItems: "center",
    justifyContent: "center",
  },
  doodlePlaceholderText: {
    color: COLORS.muted,
    fontSize: 12,
    fontFamily: FONTS.sans,
    textAlign: "center",
  },
  doodleFooterButtons: {
    flexDirection: "row",
    justifyContent: "space-between",
    width: "100%",
    marginTop: 14,
    gap: 12,
  },
  doodleCancelBtn: {
    flex: 1,
    paddingVertical: 10,
    borderRadius: 10,
    backgroundColor: "transparent",
    borderWidth: 1,
    borderColor: COLORS.border,
    alignItems: "center",
  },
  doodleCancelBtnText: {
    color: COLORS.muted,
    fontSize: 12,
    fontWeight: "600",
    fontFamily: FONTS.sans,
  },
  doodleSaveBtn: {
    flex: 1,
    paddingVertical: 10,
    borderRadius: 10,
    backgroundColor: COLORS.teal,
    alignItems: "center",
  },
  doodleSaveBtnDisabled: {
    backgroundColor: "rgba(78, 205, 196, 0.2)",
  },
  doodleSaveBtnText: {
    color: "white",
    fontSize: 12,
    fontWeight: "600",
    fontFamily: FONTS.sans,
  },

  // Voice Recorder Styles
  recorderContainer: {
    padding: 10,
    alignItems: "center",
  },
  recorderTitle: {
    color: COLORS.white,
    fontSize: 14,
    fontWeight: "600",
    fontFamily: FONTS.sans,
    marginBottom: 8,
  },
  recorderWaveContainer: {
    width: "100%",
    height: 60,
    backgroundColor: COLORS.bgElevated,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: COLORS.border,
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 6,
  },
  recorderPlaceholder: {
    color: COLORS.muted,
    fontSize: 12,
    fontFamily: FONTS.sans,
  },
  recordingIndicator: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
  },
  redDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: "#f06c8a",
  },
  recordingText: {
    color: "#f06c8a",
    fontSize: 12.5,
    fontWeight: "600",
    fontFamily: FONTS.sans,
  },
  playRecordedBtn: {
    backgroundColor: "rgba(124, 111, 247, 0.12)",
    borderWidth: 1,
    borderColor: COLORS.border,
    borderRadius: 8,
    paddingHorizontal: 16,
    paddingVertical: 8,
  },
  playRecordedBtnText: {
    color: COLORS.purpleLight,
    fontSize: 12,
    fontWeight: "600",
    fontFamily: FONTS.sans,
  },
  recorderDuration: {
    color: COLORS.white,
    fontSize: 18,
    fontWeight: "700",
    fontFamily: FONTS.sans,
    marginBottom: 10,
  },
  recorderControlRow: {
    flexDirection: "row",
    justifyContent: "center",
    marginBottom: 14,
  },
  startRecordBtn: {
    width: 52,
    height: 52,
    borderRadius: 26,
    backgroundColor: COLORS.purple,
    alignItems: "center",
    justifyContent: "center",
    shadowColor: COLORS.purple,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.4,
    shadowRadius: 6,
    elevation: 3,
  },
  startRecordBtnText: {
    color: "white",
    fontSize: 12,
    fontWeight: "700",
    fontFamily: FONTS.sans,
  },
  stopRecordBtn: {
    width: 52,
    height: 52,
    borderRadius: 26,
    backgroundColor: "#f06c8a",
    alignItems: "center",
    justifyContent: "center",
    shadowColor: "#f06c8a",
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.4,
    shadowRadius: 6,
    elevation: 3,
  },
  stopRecordBtnText: {
    color: "white",
    fontSize: 12,
    fontWeight: "700",
    fontFamily: FONTS.sans,
  },
  recorderFooterButtons: {
    flexDirection: "row",
    justifyContent: "space-between",
    width: "100%",
    gap: 12,
  },
  recorderCancelBtn: {
    flex: 1,
    paddingVertical: 10,
    borderRadius: 10,
    backgroundColor: "transparent",
    borderWidth: 1,
    borderColor: COLORS.border,
    alignItems: "center",
  },
  recorderCancelBtnText: {
    color: COLORS.muted,
    fontSize: 12,
    fontWeight: "600",
    fontFamily: FONTS.sans,
  },
  recorderSaveBtn: {
    flex: 1,
    paddingVertical: 10,
    borderRadius: 10,
    backgroundColor: COLORS.purple,
    alignItems: "center",
  },
  recorderSaveBtnDisabled: {
    backgroundColor: "rgba(124, 111, 247, 0.2)",
  },
  recorderSaveBtnText: {
    color: "white",
    fontSize: 12,
    fontWeight: "600",
    fontFamily: FONTS.sans,
  },
});
