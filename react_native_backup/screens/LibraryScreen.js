import React, { useState, useEffect } from "react";
import {
  StyleSheet,
  View,
  Text,
  TextInput,
  TouchableOpacity,
  ScrollView,
  SafeAreaView,
  ActivityIndicator,
} from "react-native";
import { useAudioPlayer, useAudioPlayerStatus } from "expo-audio";
import { COLORS, FONTS } from "../components/Theme";
import {
  OceanIcon,
  RainIcon,
  FireIcon,
  ForestIcon,
  SearchIcon,
  SparkleIcon,
  CompanionIcon,
} from "../components/Icons";

const CATEGORIES = ["All", "Breathing", "Grounding", "Sleep", "Focus"];

const SOUNDS = [
  { label: "Ocean", icon: (color) => <OceanIcon color={color} size={24} />, url: "https://www.soundjay.com/nature/sounds/ocean-wave-1.mp3" },
  { label: "Rain", icon: (color) => <RainIcon color={color} size={24} />, url: "https://www.soundjay.com/nature/sounds/rain-07.mp3" },
  { label: "Fire", icon: (color) => <FireIcon color={color} size={24} />, url: "https://www.soundjay.com/nature/sounds/fire-1.mp3" },
  { label: "Forest", icon: (color) => <ForestIcon color={color} size={24} />, url: "https://www.soundjay.com/nature/sounds/river-1.mp3" },
];

export default function LibraryScreen() {
  const [activeTab, setActiveTab] = useState("All");
  const [search, setSearch] = useState("");
  const player = useAudioPlayer();
  const playerStatus = useAudioPlayerStatus(player);
  const [playingSound, setPlayingSound] = useState(null); // label of currently playing sound
  const [audioLoading, setAudioLoading] = useState(false);

  const COPING_TOOLS = [
    { id: "1", icon: <OceanIcon color="#4ecdc4" size={20} />, title: "Sound Bath", subtitle: "Calming frequencies", time: "5 min", tag: "Sleep", color: "#4ecdc4" },
    { id: "2", icon: <RainIcon color="#a89af7" size={20} />, title: "Box Breathing", subtitle: "Calm your mind and reduce stress", time: "4 min", tag: "Breathing", color: "#a89af7" },
    { id: "3", icon: <ForestIcon color="#f7c59f" size={20} />, title: "Body Scan", subtitle: "Reconnect with your body", time: "10 min", tag: "Grounding", color: "#f7c59f" },
    { id: "4", icon: <SparkleIcon color="#f7a8d4" size={20} />, title: "Affirmations", subtitle: "Positive daily reminders", time: "3 min", tag: "Focus", color: "#f7a8d4" },
    { id: "5", icon: <OceanIcon color="#4ecdc4" size={20} />, title: "Grounding 5-4-3-2-1", subtitle: "Anchor yourself in the present", time: "6 min", tag: "Grounding", color: "#4ecdc4" },
    { id: "6", icon: <CompanionIcon color="#7c6ff7" size={20} />, title: "Sleep Story", subtitle: "Drift into peaceful rest", time: "20 min", tag: "Sleep", color: "#7c6ff7" },
    { id: "7", icon: <RainIcon color="#a89af7" size={20} />, title: "Mindful Breathing", subtitle: "Slow, intentional breath", time: "7 min", tag: "Breathing", color: "#a89af7" },
    { id: "8", icon: <FireIcon color="#f7e08a" size={20} />, title: "Somatic Exercises", subtitle: "Release stored tension", time: "12 min", tag: "Focus", color: "#f7e08a" },
  ];

  const handleSoundPress = async (soundItem) => {
    if (audioLoading) return;

    // Toggle off if currently playing
    if (playingSound === soundItem.label && playerStatus?.isPlaying) {
      setAudioLoading(true);
      try {
        player.pause();
        setPlayingSound(null);
      } catch (e) {
        console.log("Failed to stop audio", e);
      }
      setAudioLoading(false);
      return;
    }

    // Load new sound
    setAudioLoading(true);
    try {
      player.replace({ uri: soundItem.url });
      player.loop = true;
      player.volume = 0.8;
      player.play();
      setPlayingSound(soundItem.label);
    } catch (e) {
      console.log("Error playing audio", e);
    }
    setAudioLoading(false);
  };

  const filteredTools = COPING_TOOLS.filter((t) => {
    const matchesTab = activeTab === "All" || t.tag === activeTab;
    const matchesSearch = t.title.toLowerCase().includes(search.toLowerCase()) ||
                          t.subtitle.toLowerCase().includes(search.toLowerCase());
    return matchesTab && matchesSearch;
  });

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.title}>Safe Space</Text>
          <Text style={styles.subtitle}>Coping Library</Text>
        </View>

        {/* Search */}
        <View style={styles.searchBar}>
          <View style={styles.searchIconBox}>
            <SearchIcon color={COLORS.muted} size={15} />
          </View>
          <TextInput
            value={search}
            onChangeText={setSearch}
            placeholder="Search tools..."
            placeholderTextColor={COLORS.muted}
            style={styles.searchInput}
          />
        </View>

        {/* Category Tabs */}
        <ScrollView
          horizontal
          showsHorizontalScrollIndicator={false}
          style={styles.tabsContainer}
          contentContainerStyle={styles.tabsContent}
        >
          {CATEGORIES.map((tab) => (
            <TouchableOpacity
              key={tab}
              onPress={() => setActiveTab(tab)}
              style={[
                styles.tabButton,
                activeTab === tab && styles.tabButtonActive,
              ]}
            >
              <Text
                style={[
                  styles.tabText,
                  activeTab === tab && styles.tabTextActive,
                ]}
              >
                {tab}
              </Text>
            </TouchableOpacity>
          ))}
        </ScrollView>

        {/* Recommended Card */}
        {search === "" && (
          <View style={styles.recommendedCard}>
            <View style={styles.recommendedBadge}>
              <Text style={styles.recommendedBadgeText}>RECOMMENDED FOR YOU</Text>
            </View>
            <View style={styles.recommendedBody}>
              <View style={styles.recommendedText}>
                <Text style={styles.recommendedTitle}>Box Breathing</Text>
                <Text style={styles.recommendedSubtitle}>Calm your mind & reduce stress</Text>
                <Text style={styles.recommendedTime}>⏱️ 4 min</Text>
              </View>
              <TouchableOpacity style={styles.playButtonCircular}>
                <Text style={styles.playButtonIcon}>▶</Text>
              </TouchableOpacity>
            </View>
          </View>
        )}

        {/* Soundboard Card */}
        <View style={[styles.card, styles.soundboardCard]}>
          <View style={styles.soundboardHeader}>
            <Text style={styles.soundboardTitle}>Sensory Reset Soundboard</Text>
            {audioLoading && <ActivityIndicator size="small" color={COLORS.tealLight} />}
          </View>
          <View style={styles.soundboardGrid}>
            {SOUNDS.map((item) => {
              const isPlaying = playingSound === item.label && playerStatus?.isPlaying;
              const activeColor = "white";
              const inactiveColor = COLORS.tealLight;
              return (
                <TouchableOpacity
                  key={item.label}
                  style={styles.soundButton}
                  activeOpacity={0.8}
                  onPress={() => handleSoundPress(item)}
                >
                  <View
                    style={[
                      styles.soundIconContainer,
                      isPlaying && styles.soundIconContainerActive,
                    ]}
                  >
                    {item.icon(isPlaying ? activeColor : inactiveColor)}
                  </View>
                  <Text
                    style={[
                      styles.soundLabel,
                      isPlaying && styles.soundLabelActive,
                    ]}
                  >
                    {item.label} {isPlaying && "🔊"}
                  </Text>
                </TouchableOpacity>
              );
            })}
          </View>
        </View>

        {/* Grid List of Tools */}
        <Text style={styles.sectionTitle}>All Coping Tools</Text>
        <View style={styles.toolsGrid}>
          {filteredTools.map((tool) => (
            <View key={tool.id} style={styles.toolCard}>
              <View style={[styles.toolIconBg, { backgroundColor: `${tool.color}12` }]}>
                {tool.icon}
              </View>
              <Text style={styles.toolTitle} numberOfLines={1}>
                {tool.title}
              </Text>
              <Text style={styles.toolSubtitle} numberOfLines={2}>
                {tool.subtitle}
              </Text>
              <View style={styles.toolFooter}>
                <Text style={styles.toolTime}>{tool.time}</Text>
                <TouchableOpacity
                  style={[styles.toolPlayBtn, { backgroundColor: `${tool.color}20` }]}
                >
                  <Text style={[styles.toolPlayIcon, { color: tool.color }]}>▶</Text>
                </TouchableOpacity>
              </View>
            </View>
          ))}
        </View>
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
    paddingTop: 16,
    paddingBottom: 12,
  },
  title: {
    color: COLORS.white,
    fontSize: 22,
    fontWeight: "600",
    fontFamily: FONTS.serif,
  },
  subtitle: {
    color: COLORS.muted,
    fontSize: 13,
    fontFamily: FONTS.sans,
    marginTop: 2,
  },
  searchBar: {
    flexDirection: "row",
    backgroundColor: "rgba(25, 22, 54, 0.6)",
    borderRadius: 14,
    borderWidth: 1,
    borderColor: COLORS.border,
    paddingHorizontal: 12,
    paddingVertical: 10,
    alignItems: "center",
    marginBottom: 16,
  },
  searchIconBox: {
    marginRight: 8,
  },
  searchInput: {
    flex: 1,
    color: COLORS.white,
    fontSize: 13,
    fontFamily: FONTS.sans,
    paddingVertical: 0,
  },
  tabsContainer: {
    marginBottom: 16,
  },
  tabsContent: {
    gap: 8,
    paddingBottom: 4,
  },
  tabButton: {
    paddingHorizontal: 14,
    paddingVertical: 7,
    borderRadius: 20,
    backgroundColor: "rgba(25, 22, 54, 0.6)",
    borderWidth: 1,
    borderColor: COLORS.border,
  },
  tabButtonActive: {
    backgroundColor: COLORS.purple,
    borderColor: COLORS.purple,
  },
  tabText: {
    color: COLORS.muted,
    fontSize: 12,
    fontWeight: "500",
    fontFamily: FONTS.sans,
  },
  tabTextActive: {
    color: "white",
  },
  recommendedCard: {
    backgroundColor: "#112424", // Premium deep green/teal glow
    borderRadius: 18,
    borderWidth: 1,
    borderColor: "rgba(78, 205, 196, 0.22)",
    padding: 16,
    marginBottom: 20,
    shadowColor: COLORS.teal,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.15,
    shadowRadius: 10,
    elevation: 3,
  },
  recommendedBadge: {
    backgroundColor: "rgba(78, 205, 196, 0.1)",
    borderWidth: 1,
    borderColor: "rgba(78, 205, 196, 0.25)",
    paddingHorizontal: 8,
    paddingVertical: 4,
    borderRadius: 6,
    alignSelf: "flex-start",
    marginBottom: 10,
  },
  recommendedBadgeText: {
    color: COLORS.tealLight,
    fontSize: 9,
    fontWeight: "600",
    letterSpacing: 1,
  },
  recommendedBody: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
  },
  recommendedText: {
    flex: 1,
  },
  recommendedTitle: {
    color: COLORS.white,
    fontSize: 15,
    fontWeight: "600",
    fontFamily: FONTS.sans,
  },
  recommendedSubtitle: {
    color: COLORS.tealLight,
    fontSize: 12,
    marginTop: 2,
    fontFamily: FONTS.sans,
  },
  recommendedTime: {
    color: COLORS.muted,
    fontSize: 11,
    marginTop: 6,
    fontFamily: FONTS.sans,
  },
  playButtonCircular: {
    width: 44,
    height: 44,
    borderRadius: 22,
    backgroundColor: COLORS.teal,
    alignItems: "center",
    justifyContent: "center",
  },
  playButtonIcon: {
    color: "white",
    fontSize: 16,
    marginLeft: 2,
  },
  card: {
    backgroundColor: "rgba(19, 16, 43, 0.7)",
    borderRadius: 18,
    borderWidth: 1,
    borderColor: COLORS.border,
    padding: 16,
    marginBottom: 16,
  },
  soundboardCard: {
    backgroundColor: "rgba(13, 42, 42, 0.75)",
    borderColor: "rgba(78, 205, 196, 0.2)",
  },
  soundboardHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 14,
  },
  soundboardTitle: {
    color: COLORS.tealLight,
    fontSize: 11,
    fontWeight: "600",
    letterSpacing: 1,
    textTransform: "uppercase",
    fontFamily: FONTS.sans,
  },
  soundboardGrid: {
    flexDirection: "row",
    justifyContent: "space-between",
  },
  soundButton: {
    alignItems: "center",
    flex: 1,
  },
  soundIconContainer: {
    width: 52,
    height: 52,
    borderRadius: 14,
    backgroundColor: "rgba(78, 205, 196, 0.08)",
    borderWidth: 1,
    borderColor: "rgba(78, 205, 196, 0.2)",
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 6,
  },
  soundIconContainerActive: {
    backgroundColor: "rgba(78, 205, 196, 0.25)",
    borderColor: COLORS.teal,
    shadowColor: COLORS.teal,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.6,
    shadowRadius: 10,
    elevation: 3,
  },
  soundLabel: {
    color: COLORS.tealLight,
    fontSize: 11,
    fontFamily: FONTS.sans,
  },
  soundLabelActive: {
    color: COLORS.white,
    fontWeight: "600",
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
  toolsGrid: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 12,
  },
  toolCard: {
    backgroundColor: "rgba(19, 16, 43, 0.7)",
    borderRadius: 16,
    borderWidth: 1,
    borderColor: COLORS.border,
    padding: 12,
    width: "47%",
    minWidth: 140,
    flexGrow: 1,
  },
  toolIconBg: {
    width: 36,
    height: 36,
    borderRadius: 10,
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 10,
    borderWidth: 1,
    borderColor: "rgba(255, 255, 255, 0.03)",
  },
  toolTitle: {
    color: COLORS.white,
    fontSize: 13,
    fontWeight: "600",
    fontFamily: FONTS.sans,
    marginBottom: 2,
  },
  toolSubtitle: {
    color: COLORS.muted,
    fontSize: 11,
    fontFamily: FONTS.sans,
    lineHeight: 14,
    marginBottom: 10,
    height: 28,
  },
  toolFooter: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
  },
  toolTime: {
    color: COLORS.muted,
    fontSize: 11,
    fontFamily: FONTS.sans,
  },
  toolPlayBtn: {
    width: 26,
    height: 26,
    borderRadius: 13,
    alignItems: "center",
    justifyContent: "center",
  },
  toolPlayIcon: {
    fontSize: 10,
    marginLeft: 1,
  },
});
