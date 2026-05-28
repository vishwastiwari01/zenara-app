import React, { useState } from "react";
import { StyleSheet, View, Text, ScrollView, TouchableOpacity, SafeAreaView } from "react-native";
import { COLORS, FONTS } from "../components/Theme";
import LotusIcon from "../components/LotusIcon";
import {
  BrainIcon,
  HeartIcon,
  PeopleIcon,
  JournalIcon,
  CompanionIcon,
  LibraryIcon,
  SparkleIcon,
  PlusIcon,
} from "../components/Icons";

const EMOTIONS = [
  { label: "Calm", color: "#4ecdc4" },
  { label: "Anxious", color: "#a89af7" },
  { label: "Tired", color: "#7c9abf" },
  { label: "Hopeful", color: "#f7c59f" },
  { label: "Overwhelmed", color: "#f7a8d4" },
  { label: "Happy", color: "#f7e08a" },
  { label: "Sad", color: "#7c6ff7" },
  { label: "Grateful", color: "#4ecdc4" },
];

function EnergySlider({ label, icon, value, onChange, color }) {
  const [trackWidth, setTrackWidth] = useState(0);

  const handleTouch = (event) => {
    if (!trackWidth) return;
    const x = event.nativeEvent.locationX;
    const pct = Math.round(Math.max(0, Math.min(100, (x / trackWidth) * 100)));
    onChange(pct);
  };

  return (
    <View style={styles.sliderContainer}>
      <View style={styles.sliderHeader}>
        <View style={styles.sliderLabelGroup}>
          <View style={[styles.sliderIconBox, { backgroundColor: `${color}15` }]}>
            {icon || <View style={{ width: 6, height: 6, borderRadius: 3, backgroundColor: color }} />}
          </View>
          <Text style={styles.sliderLabel}>{label}</Text>
        </View>
        <Text style={[styles.sliderValue, { color }]}>{value}%</Text>
      </View>
      <View
        style={styles.touchArea}
        onLayout={(e) => setTrackWidth(e.nativeEvent.layout.width)}
        onTouchStart={handleTouch}
        onTouchMove={handleTouch}
      >
        <View style={styles.sliderTrack}>
          <View style={[styles.sliderFill, { width: `${value}%`, backgroundColor: color }]} />
          <View
            style={[
              styles.sliderThumb,
              {
                left: `${value}%`,
                backgroundColor: color,
                borderColor: "white",
                shadowColor: color,
              },
            ]}
          />
        </View>
      </View>
    </View>
  );
}

function EmotionBubble({ emotion, selected, intensity = 50, onClick }) {
  const size = selected ? 54 + intensity * 0.45 : 66;
  return (
    <TouchableOpacity
      activeOpacity={0.85}
      onPress={onClick}
      style={[
        styles.bubble,
        {
          width: size,
          height: size,
          borderRadius: size / 2,
          backgroundColor: selected ? `${emotion.color}18` : "rgba(255,255,255,0.03)",
          borderColor: selected ? emotion.color : "rgba(124,111,247,0.15)",
          shadowColor: emotion.color,
          shadowRadius: selected ? 10 : 0,
          shadowOpacity: selected ? 0.35 : 0,
          transform: [{ scale: selected ? 1.05 : 1 }],
        },
      ]}
    >
      <Text
        style={[
          styles.bubbleText,
          {
            fontSize: selected ? Math.max(9.5, size * 0.2) : 11,
            color: selected ? emotion.color : COLORS.muted,
            fontWeight: selected ? "600" : "400",
          },
        ]}
      >
        {emotion.label}
      </Text>
      {selected && (
        <Text style={[styles.bubblePercentage, { color: emotion.color }]}>
          {intensity}%
        </Text>
      )}
    </TouchableOpacity>
  );
}

export default function HomeScreen({
  energy,
  setEnergy,
  emotions,
  toggleEmotion,
  emotionIntensities,
  setEmotionIntensities,
  onNavigate,
}) {
  const hour = new Date().getHours();
  const greeting = hour < 12 ? "Good morning" : hour < 17 ? "Good afternoon" : "Good evening";

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.subGreeting}>
            {greeting}, Sarah
          </Text>
          <Text style={styles.greetingTitle}>How are you feeling today?</Text>
        </View>

        {/* Daily Insight Card */}
        <View style={[styles.card, styles.gradientCard]}>
          <View style={styles.sparkleContainer}>
            <SparkleIcon size={20} color={COLORS.purpleLight} />
          </View>
          <View style={styles.insightTextContainer}>
            <Text style={styles.insightHeader}>Daily Insight</Text>
            <Text style={styles.insightText}>
              Your anxiety is lower than usual this week. Great job checking in!
            </Text>
          </View>
        </View>

        {/* Energy Levels Card */}
        <View style={styles.card}>
          <Text style={styles.cardSectionTitle}>Energy Levels</Text>
          <EnergySlider
            label="Mental"
            icon={<BrainIcon color={COLORS.purple} size={15} />}
            value={energy.mental}
            onChange={(v) => setEnergy((e) => ({ ...e, mental: v }))}
            color={COLORS.purple}
          />
          <EnergySlider
            label="Physical"
            icon={<HeartIcon color={COLORS.teal} size={15} />}
            value={energy.physical}
            onChange={(v) => setEnergy((e) => ({ ...e, physical: v }))}
            color={COLORS.teal}
          />
          <EnergySlider
            label="Social"
            icon={<PeopleIcon color="#f06c8a" size={15} />}
            value={energy.social}
            onChange={(v) => setEnergy((e) => ({ ...e, social: v }))}
            color="#f06c8a"
          />
        </View>

        {/* Mood Meter Card */}
        <View style={styles.card}>
          <Text style={styles.cardSectionTitle}>Mood Meter</Text>
          <Text style={styles.cardSubtitle}>Select up to 5 emotions</Text>
          <View style={styles.bubblesContainer}>
            {EMOTIONS.map((em) => (
              <EmotionBubble
                key={em.label}
                emotion={em}
                selected={emotions.includes(em.label)}
                intensity={emotionIntensities[em.label]}
                onClick={() => toggleEmotion(em.label)}
              />
            ))}
            
            {/* Custom styled "+ Add Emotion" pill */}
            <TouchableOpacity style={styles.addEmotionBtn} activeOpacity={0.7}>
              <PlusIcon color={COLORS.muted} size={12} />
              <Text style={styles.addEmotionText}>Add Emotion</Text>
            </TouchableOpacity>
          </View>

          {emotions.length > 0 && (
            <View style={styles.calibrationContainer}>
              <View style={styles.calibrationDivider} />
              <Text style={styles.calibrationHeader}>Calibrate Intensities</Text>
              {emotions.map((emName) => {
                const emObj = EMOTIONS.find((e) => e.label === emName) || { color: COLORS.purple };
                const val = emotionIntensities[emName] || 50;
                return (
                  <EnergySlider
                    key={emName}
                    label={emName}
                    icon={null}
                    value={val}
                    onChange={(v) => {
                      setEmotionIntensities((prev) => ({
                        ...prev,
                        [emName]: v,
                      }));
                    }}
                    color={emObj.color}
                  />
                );
              })}
            </View>
          )}
        </View>

        {/* Quick Actions */}
        <Text style={styles.sectionTitle}>Quick Actions</Text>
        <View style={styles.actionsGrid}>
          {[
            {
              icon: <JournalIcon color={COLORS.purple} size={18} />,
              label: "Start Journal",
              screen: "journal",
              bg: "rgba(124, 111, 247, 0.06)",
            },
            {
              icon: <CompanionIcon color="#a89af7" size={18} />,
              label: "Talk to Nova",
              screen: "nova",
              bg: "rgba(168, 154, 247, 0.06)",
            },
            {
              icon: <LibraryIcon color={COLORS.teal} size={18} />,
              label: "Sound Bath",
              screen: "library",
              bg: "rgba(78, 205, 196, 0.06)",
            },
            {
              icon: <LotusIcon size={18} />,
              label: "Breathe",
              screen: "library",
              bg: "rgba(247, 197, 159, 0.06)",
            },
          ].map(({ icon, label, screen, bg }) => (
            <TouchableOpacity
              key={label}
              style={[styles.actionButton, { backgroundColor: bg }]}
              activeOpacity={0.7}
              onPress={() => onNavigate(screen)}
            >
              <View style={styles.actionIconBox}>{icon}</View>
              <Text style={styles.actionLabel}>{label}</Text>
            </TouchableOpacity>
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
    paddingBottom: 16,
  },
  subGreeting: {
    color: COLORS.muted,
    fontSize: 13,
    fontFamily: FONTS.sans,
  },
  greetingTitle: {
    color: COLORS.white,
    fontSize: 22,
    fontWeight: "600",
    fontFamily: FONTS.serif,
    marginTop: 4,
  },
  card: {
    backgroundColor: "rgba(19, 16, 43, 0.7)",
    borderRadius: 18,
    borderWidth: 1,
    borderColor: COLORS.border,
    padding: 16,
    marginBottom: 16,
    shadowColor: "black",
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.2,
    shadowRadius: 10,
    elevation: 3,
  },
  gradientCard: {
    flexDirection: "row",
    backgroundColor: "rgba(30, 26, 64, 0.6)",
    borderColor: "rgba(124, 111, 247, 0.25)",
    alignItems: "flex-start",
  },
  sparkleContainer: {
    width: 32,
    height: 32,
    borderRadius: 8,
    backgroundColor: "rgba(124, 111, 247, 0.15)",
    alignItems: "center",
    justifyContent: "center",
    marginRight: 12,
  },
  insightTextContainer: {
    flex: 1,
  },
  insightHeader: {
    color: COLORS.purpleLight,
    fontSize: 10,
    fontWeight: "600",
    letterSpacing: 1,
    textTransform: "uppercase",
    fontFamily: FONTS.sans,
    marginBottom: 2,
  },
  insightText: {
    color: COLORS.white,
    fontSize: 13.5,
    lineHeight: 18,
    fontFamily: FONTS.sans,
  },
  cardSectionTitle: {
    color: COLORS.muted,
    fontSize: 11,
    fontWeight: "600",
    letterSpacing: 1,
    textTransform: "uppercase",
    fontFamily: FONTS.sans,
    marginBottom: 12,
  },
  cardSubtitle: {
    color: COLORS.muted,
    fontSize: 12,
    fontFamily: FONTS.sans,
    marginTop: -8,
    marginBottom: 14,
  },
  sliderContainer: {
    marginBottom: 14,
  },
  sliderHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 6,
  },
  sliderLabelGroup: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
  },
  sliderIconBox: {
    width: 24,
    height: 24,
    borderRadius: 6,
    alignItems: "center",
    justifyContent: "center",
  },
  sliderLabel: {
    color: COLORS.muted,
    fontSize: 12,
    fontFamily: FONTS.sans,
  },
  sliderValue: {
    fontSize: 12,
    fontWeight: "700",
    fontFamily: FONTS.sans,
  },
  touchArea: {
    height: 24,
    justifyContent: "center",
  },
  sliderTrack: {
    height: 6,
    borderRadius: 3,
    backgroundColor: "rgba(255,255,255,0.06)",
    position: "relative",
  },
  sliderFill: {
    height: "100%",
    borderRadius: 3,
  },
  sliderThumb: {
    position: "absolute",
    top: -4,
    marginLeft: -7,
    width: 14,
    height: 14,
    borderRadius: 7,
    borderWidth: 2,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.8,
    shadowRadius: 5,
    elevation: 3,
  },
  bubblesContainer: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 8,
    justifyContent: "flex-start",
    alignItems: "center",
  },
  bubble: {
    alignItems: "center",
    justifyContent: "center",
    borderWidth: 1,
    shadowOffset: { width: 0, height: 0 },
    shadowRadius: 6,
    elevation: 2,
  },
  bubbleText: {
    fontFamily: FONTS.sans,
  },
  addEmotionBtn: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    height: 38,
    paddingHorizontal: 12,
    borderRadius: 19,
    borderWidth: 1,
    borderStyle: "dashed",
    borderColor: "rgba(124, 111, 247, 0.4)",
    backgroundColor: "rgba(124, 111, 247, 0.02)",
  },
  addEmotionText: {
    color: COLORS.muted,
    fontSize: 11.5,
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
  actionsGrid: {
    flexDirection: "row",
    flexWrap: "wrap",
    gap: 10,
    marginBottom: 10,
  },
  actionButton: {
    flex: 1,
    minWidth: "45%",
    borderRadius: 14,
    padding: 12,
    borderWidth: 1,
    borderColor: COLORS.border,
    flexDirection: "row",
    alignItems: "center",
  },
  actionIconBox: {
    marginRight: 10,
  },
  actionLabel: {
    color: COLORS.white,
    fontSize: 13,
    fontWeight: "600",
    fontFamily: FONTS.sans,
  },
  bubblePercentage: {
    fontSize: 9,
    fontFamily: FONTS.sans,
    opacity: 0.8,
    marginTop: 2,
  },
  calibrationContainer: {
    marginTop: 16,
  },
  calibrationDivider: {
    height: 1,
    backgroundColor: "rgba(255, 255, 255, 0.05)",
    marginBottom: 12,
  },
  calibrationHeader: {
    color: COLORS.muted,
    fontSize: 10,
    fontWeight: "600",
    letterSpacing: 1,
    textTransform: "uppercase",
    fontFamily: FONTS.sans,
    marginBottom: 12,
  },
});
