import React, { useState } from "react";
import {
  StyleSheet,
  View,
  Text,
  ScrollView,
  TouchableOpacity,
  SafeAreaView,
} from "react-native";
import Svg, { Path, Defs, LinearGradient, Stop, Text as SvgText } from "react-native-svg";
import { COLORS, FONTS } from "../components/Theme";
import LotusIcon from "../components/LotusIcon";
import { SparkleIcon, InsightsIcon } from "../components/Icons";

export default function TherapistScreen() {
  const [activeTab, setActiveTab] = useState("Overview");

  const stats = [
    { label: "Anxiety", value: "↓ 18%", color: COLORS.teal },
    { label: "Sleep Quality", value: "↑ 12%", color: COLORS.purple },
    { label: "Energy", value: "↑ 8%", color: COLORS.gold },
  ];

  const themes = [
    { label: "Work Stress", pct: 32, color: COLORS.purple },
    { label: "Self Worth", pct: 24, color: COLORS.teal },
    { label: "Burnout", pct: 18, color: COLORS.pink },
    { label: "Relationships", pct: 14, color: COLORS.gold },
    { label: "Other", pct: 12, color: COLORS.muted },
  ];

  const daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"];
  const sparklineDays = ["T", "W", "T", "F", "S", "S", "M"];
  const activityHeights = [60, 30, 70, 50, 40, 60, 50]; // Out of 70

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        {/* Header */}
        <View style={styles.header}>
          <View style={styles.headerTitleRow}>
            <View style={styles.iconContainer}>
              <InsightsIcon color={COLORS.purpleLight} size={16} />
            </View>
            <Text style={styles.portalTag}>Therapist Portal</Text>
          </View>
          <Text style={styles.patientName}>Sarah Johnson</Text>
          <Text style={styles.lastSession}>Last session: May 24, 2026</Text>
        </View>

        {/* Dashboard Nav Tabs */}
        <View style={styles.tabsContainer}>
          {["Overview", "Mood", "Themes", "Sessions"].map((tab) => {
            const isActive = activeTab === tab;
            return (
              <TouchableOpacity
                key={tab}
                onPress={() => setActiveTab(tab)}
                style={[styles.tabButton, isActive && styles.tabButtonActive]}
              >
                <Text style={[styles.tabText, isActive && styles.tabTextActive]}>
                  {tab}
                </Text>
              </TouchableOpacity>
            );
          })}
        </View>

        {/* Stats Row */}
        <View style={styles.statsRow}>
          {stats.map((item) => (
            <View key={item.label} style={styles.statCard}>
              <Text style={[styles.statValue, { color: item.color }]}>{item.value}</Text>
              <Text style={styles.statLabel}>{item.label}</Text>
            </View>
          ))}
        </View>

        {/* Mood Trend Sparkline */}
        <View style={styles.card}>
          <View style={styles.cardHeader}>
            <Text style={styles.cardTitle}>Mood Trend</Text>
            <Text style={styles.cardSubtitle}>Last 7 days</Text>
          </View>
          <View style={styles.sparklineContainer}>
            <Svg width="100%" height="80" viewBox="0 0 280 80">
              <Defs>
                <LinearGradient id="mg" x1="0" y1="0" x2="0" y2="1">
                  <Stop offset="0%" stopColor={COLORS.purple} stopOpacity={0.4} />
                  <Stop offset="100%" stopColor={COLORS.purple} stopOpacity="0" />
                </LinearGradient>
              </Defs>
              <Path
                d="M 10 55 C 40 50, 60 45, 90 38 C 120 31, 140 42, 170 32 C 200 22, 230 28, 270 15 L 270 70 L 10 70 Z"
                fill="url(#mg)"
              />
              <Path
                d="M 10 55 C 40 50, 60 45, 90 38 C 120 31, 140 42, 170 32 C 200 22, 230 28, 270 15"
                fill="none"
                stroke={COLORS.purple}
                strokeWidth="2.5"
                strokeLinecap="round"
              />
              {sparklineDays.map((d, i) => (
                <SvgText
                  key={i}
                  x={15 + i * 40}
                  y="76"
                  fill={COLORS.muted}
                  fontSize="9"
                  textAnchor="middle"
                  fontFamily={FONTS.sans}
                >
                  {d}
                </SvgText>
              ))}
            </Svg>
          </View>
        </View>

        {/* Journal Activity Bar Chart */}
        <View style={styles.card}>
          <View style={styles.cardHeader}>
            <Text style={styles.cardTitle}>Journal Activity</Text>
            <Text style={styles.cardSubtitle}>This week</Text>
          </View>
          <View style={styles.barChartContainer}>
            {activityHeights.map((h, i) => (
              <View key={i} style={styles.barColumn}>
                <View style={styles.barTrack}>
                  <View
                    style={[
                      styles.barFill,
                      {
                        height: `${(h / 70) * 100}%`,
                        opacity: i === 6 ? 1 : 0.5,
                      },
                    ]}
                  />
                </View>
                <Text style={styles.barLabel}>{daysOfWeek[i]}</Text>
              </View>
            ))}
          </View>
        </View>

        {/* Top Themes */}
        <View style={styles.card}>
          <Text style={styles.cardTitle}>Top Themes</Text>
          <View style={styles.themesList}>
            {themes.map((theme) => (
              <View key={theme.label} style={styles.themeItem}>
                <View style={styles.themeHeader}>
                  <Text style={styles.themeLabel}>{theme.label}</Text>
                  <Text style={[styles.themeValue, { color: theme.color }]}>{theme.pct}%</Text>
                </View>
                <View style={styles.themeProgressTrack}>
                  <View
                    style={[
                      styles.themeProgressFill,
                      { width: `${theme.pct}%`, backgroundColor: theme.color },
                    ]}
                  />
                </View>
              </View>
            ))}
          </View>
        </View>

        {/* AI Weekly Summary Card */}
        <View style={[styles.card, styles.aiCard]}>
          <View style={styles.aiCardHeader}>
            <Text style={styles.aiCardTitle}>AI Weekly Summary</Text>
            <View style={styles.aiBadge}>
              <SparkleIcon size={10} color={COLORS.purpleLight} />
              <Text style={styles.aiBadgeText}>AI Generated</Text>
            </View>
          </View>
          <Text style={styles.aiSummaryText}>
            Sarah shows improved emotional regulation this week with reduced anxiety levels and
            increased moments of calm. Journals indicate ongoing work stress and self-worth challenges.
            Continue exploring boundaries and self-compassion in upcoming sessions.
          </Text>
          <TouchableOpacity style={styles.reportButton}>
            <Text style={styles.reportButtonText}>View Full Report</Text>
          </TouchableOpacity>
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
  headerTitleRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    marginBottom: 4,
  },
  iconContainer: {
    width: 24,
    height: 24,
    borderRadius: 6,
    backgroundColor: "rgba(124, 111, 247, 0.08)",
    alignItems: "center",
    justifyContent: "center",
    borderWidth: 1,
    borderColor: COLORS.border,
  },
  portalTag: {
    color: COLORS.muted,
    fontSize: 10,
    fontWeight: "600",
    letterSpacing: 1,
    textTransform: "uppercase",
    fontFamily: FONTS.sans,
  },
  patientName: {
    color: COLORS.white,
    fontSize: 22,
    fontWeight: "600",
    fontFamily: FONTS.serif,
  },
  lastSession: {
    color: COLORS.muted,
    fontSize: 12,
    fontFamily: FONTS.sans,
    marginTop: 2,
  },
  tabsContainer: {
    flexDirection: "row",
    backgroundColor: "rgba(25, 22, 54, 0.6)",
    borderRadius: 14,
    padding: 4,
    borderWidth: 1,
    borderColor: COLORS.border,
    marginBottom: 20,
  },
  tabButton: {
    flex: 1,
    textAlign: "center",
    paddingVertical: 8,
    borderRadius: 10,
    alignItems: "center",
    justifyContent: "center",
  },
  tabButtonActive: {
    backgroundColor: COLORS.purple,
  },
  tabText: {
    color: COLORS.muted,
    fontSize: 11,
    fontFamily: FONTS.sans,
  },
  tabTextActive: {
    color: "white",
    fontWeight: "600",
  },
  statsRow: {
    flexDirection: "row",
    gap: 10,
    marginBottom: 16,
  },
  statCard: {
    flex: 1,
    backgroundColor: "rgba(19, 16, 43, 0.7)",
    borderRadius: 16,
    borderWidth: 1,
    borderColor: COLORS.border,
    paddingVertical: 12,
    paddingHorizontal: 8,
    alignItems: "center",
  },
  statValue: {
    fontSize: 16,
    fontWeight: "700",
    fontFamily: FONTS.sans,
    marginBottom: 4,
  },
  statLabel: {
    color: COLORS.muted,
    fontSize: 10,
    fontFamily: FONTS.sans,
    textAlign: "center",
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
  cardTitle: {
    color: COLORS.white,
    fontSize: 13,
    fontWeight: "600",
    fontFamily: FONTS.sans,
  },
  cardSubtitle: {
    color: COLORS.muted,
    fontSize: 11,
    fontFamily: FONTS.sans,
  },
  sparklineContainer: {
    height: 80,
    justifyContent: "center",
  },
  barChartContainer: {
    flexDirection: "row",
    alignItems: "flex-end",
    gap: 12,
    height: 70,
    paddingHorizontal: 10,
  },
  barColumn: {
    flex: 1,
    alignItems: "center",
  },
  barTrack: {
    height: 50,
    width: "100%",
    backgroundColor: "rgba(255,255,255,0.03)",
    borderRadius: 4,
    justifyContent: "flex-end",
    overflow: "hidden",
  },
  barFill: {
    width: "100%",
    backgroundColor: COLORS.purple,
    borderRadius: 4,
  },
  barLabel: {
    color: COLORS.muted,
    fontSize: 9,
    fontFamily: FONTS.sans,
    marginTop: 6,
  },
  themesList: {
    marginTop: 10,
  },
  themeItem: {
    marginBottom: 12,
  },
  themeHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    marginBottom: 4,
  },
  themeLabel: {
    color: COLORS.muted,
    fontSize: 12,
    fontFamily: FONTS.sans,
  },
  themeValue: {
    fontSize: 12,
    fontWeight: "600",
    fontFamily: FONTS.sans,
  },
  themeProgressTrack: {
    height: 5,
    borderRadius: 3,
    backgroundColor: "rgba(255,255,255,0.06)",
  },
  themeProgressFill: {
    height: "100%",
    borderRadius: 3,
  },
  aiCard: {
    backgroundColor: "rgba(28, 16, 64, 0.7)",
    borderColor: "rgba(124, 111, 247, 0.3)",
  },
  aiCardHeader: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    marginBottom: 10,
  },
  aiCardTitle: {
    color: COLORS.white,
    fontSize: 13,
    fontWeight: "600",
    fontFamily: FONTS.sans,
  },
  aiBadge: {
    borderWidth: 1,
    borderColor: COLORS.purple,
    paddingHorizontal: 8,
    paddingVertical: 2,
    borderRadius: 8,
    flexDirection: "row",
    alignItems: "center",
    gap: 4,
  },
  aiBadgeText: {
    color: COLORS.purpleLight,
    fontSize: 9,
    fontFamily: FONTS.sans,
  },
  aiSummaryText: {
    color: COLORS.muted,
    fontSize: 12,
    lineHeight: 18,
    fontFamily: FONTS.sans,
    marginBottom: 14,
  },
  reportButton: {
    backgroundColor: "rgba(124, 111, 247, 0.15)",
    borderWidth: 1,
    borderColor: COLORS.purple,
    borderRadius: 12,
    paddingVertical: 10,
    alignItems: "center",
  },
  reportButtonText: {
    color: COLORS.purpleLight,
    fontSize: 12,
    fontWeight: "600",
    fontFamily: FONTS.sans,
  },
});
