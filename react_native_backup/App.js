import React, { useState, useEffect } from "react";
import { StyleSheet, View, Text, TouchableOpacity, SafeAreaView, Platform } from "react-native";
import { StatusBar } from "expo-status-bar";
import AsyncStorage from "@react-native-async-storage/async-storage";

import { COLORS, FONTS } from "./components/Theme";
import LotusIcon from "./components/LotusIcon";
import {
  HomeIcon,
  JournalIcon,
  CompanionIcon,
  LibraryIcon,
  InsightsIcon,
  GearIcon,
} from "./components/Icons";

// Import Screens
import WelcomeScreen from "./screens/WelcomeScreen";
import HomeScreen from "./screens/HomeScreen";
import JournalScreen from "./screens/JournalScreen";
import NovaScreen from "./screens/NovaScreen";
import LibraryScreen from "./screens/LibraryScreen";
import TherapistScreen from "./screens/TherapistScreen";
import SettingsScreen from "./screens/SettingsScreen";

export default function App() {
  const [consentGranted, setConsentGranted] = useState(false);
  const [loading, setLoading] = useState(true);
  const [screen, setScreen] = useState("home"); // 'home', 'journal', 'nova', 'library', 'therapist', 'settings'

  // Daily User States (Persisted or Shared)
  const [energy, setEnergy] = useState({ mental: 72, physical: 64, social: 38 });
  const [emotions, setEmotions] = useState(["Calm", "Anxious", "Overwhelmed"]);
  const [emotionIntensities, setEmotionIntensities] = useState({ Calm: 60, Anxious: 45, Overwhelmed: 75 });

  // Check consent on mount
  useEffect(() => {
    async function checkConsent() {
      try {
        const stored = await AsyncStorage.getItem("zenara_consent_granted");
        if (stored === "true") {
          setConsentGranted(true);
        }
      } catch (e) {
        console.log("Error checking consent status");
      }
      setLoading(false);
    }
    checkConsent();
  }, []);

  const handleConsentGranted = async () => {
    try {
      await AsyncStorage.setItem("zenara_consent_granted", "true");
      setConsentGranted(true);
      setScreen("home");
    } catch (e) {
      console.log("Error saving consent status");
    }
  };

  const handleRevokeConsent = async () => {
    try {
      await AsyncStorage.setItem("zenara_consent_granted", "false");
      setConsentGranted(false);
      setScreen("home");
    } catch (e) {
      console.log("Error revoking consent");
    }
  };

  const toggleEmotion = (em) => {
    setEmotions((prev) => {
      const exists = prev.includes(em);
      if (exists) {
        return prev.filter((e) => e !== em);
      } else {
        if (prev.length < 5) {
          setEmotionIntensities((prevInts) => ({
            ...prevInts,
            [em]: prevInts[em] || 50,
          }));
          return [...prev, em];
        }
        return prev;
      }
    });
  };

  if (loading) {
    return (
      <View style={styles.loadingContainer}>
        <LotusIcon size={64} />
        <Text style={styles.loadingText}>Loading Zenara...</Text>
      </View>
    );
  }

  // If consent not granted, enforce onboarding gateway
  if (!consentGranted) {
    return (
      <>
        <WelcomeScreen onConsentGranted={handleConsentGranted} />
        <StatusBar style="light" />
      </>
    );
  }

  // Navigation configurations
  const navigationTabs = [
    { id: "home", label: "Home", icon: (color) => <HomeIcon color={color} size={22} /> },
    { id: "journal", label: "Journal", icon: (color) => <JournalIcon color={color} size={22} /> },
    { id: "nova", label: "Nova", icon: (color) => <CompanionIcon color={color} size={22} /> },
    { id: "library", label: "Library", icon: (color) => <LibraryIcon color={color} size={22} /> },
    { id: "therapist", label: "Insights", icon: (color) => <InsightsIcon color={color} size={22} /> },
  ];

  // Shell Layout for authenticated/consented user
  return (
    <SafeAreaView style={styles.shellContainer}>
      <StatusBar style="light" />

      {/* Top Header Bar */}
      <View style={styles.headerBar}>
        <View style={styles.headerLogoGroup}>
          <LotusIcon size={30} />
          <Text style={styles.headerTitle}>zenara</Text>
        </View>
        <TouchableOpacity
          style={[styles.settingsButton, screen === "settings" && styles.settingsButtonActive]}
          activeOpacity={0.7}
          onPress={() => setScreen(screen === "settings" ? "home" : "settings")}
        >
          <GearIcon color={screen === "settings" ? COLORS.purpleLight : "white"} size={20} />
        </TouchableOpacity>
      </View>

      {/* Main Screen Content */}
      <View style={styles.contentArea}>
        {screen === "home" && (
          <HomeScreen
            energy={energy}
            setEnergy={setEnergy}
            emotions={emotions}
            toggleEmotion={toggleEmotion}
            emotionIntensities={emotionIntensities}
            setEmotionIntensities={setEmotionIntensities}
            onNavigate={setScreen}
          />
        )}
        {screen === "journal" && <JournalScreen />}
        {screen === "nova" && <NovaScreen />}
        {screen === "library" && <LibraryScreen />}
        {screen === "therapist" && <TherapistScreen />}
        {screen === "settings" && <SettingsScreen onRevokeConsent={handleRevokeConsent} />}
      </View>

      {/* Bottom Nav Bar */}
      <View style={styles.bottomNav}>
        {navigationTabs.map((tab) => {
          const isActive = screen === tab.id;
          const activeColor = COLORS.purple;
          const inactiveColor = COLORS.muted;
          return (
            <TouchableOpacity
              key={tab.id}
              style={[styles.navTab, isActive && styles.navTabActive]}
              activeOpacity={0.8}
              onPress={() => setScreen(tab.id)}
            >
              <View style={styles.navIconContainer}>
                {tab.icon(isActive ? activeColor : inactiveColor)}
              </View>
              <Text style={[styles.navTabLabel, isActive ? styles.navTabLabelActive : styles.navTabLabelMuted]}>
                {tab.label}
              </Text>
            </TouchableOpacity>
          );
        })}
      </View>

      {/* Persistent Legal Clinical Disclaimer Footer */}
      <View style={styles.disclaimerFooter}>
        <Text style={styles.disclaimerFooterText}>
          Support companion — not a substitute for clinical therapy. In crisis? Call 988 or 9152987821.
        </Text>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  loadingContainer: {
    flex: 1,
    backgroundColor: COLORS.bg,
    alignItems: "center",
    justifyContent: "center",
  },
  loadingText: {
    color: COLORS.white,
    marginTop: 16,
    fontFamily: FONTS.sans,
    fontSize: 14,
  },
  shellContainer: {
    flex: 1,
    backgroundColor: COLORS.bg,
    paddingTop: Platform.OS === "android" ? 30 : 0,
  },
  headerBar: {
    flexDirection: "row",
    justifyContent: "space-between",
    alignItems: "center",
    paddingHorizontal: 20,
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderColor: COLORS.border,
  },
  headerLogoGroup: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
  },
  headerTitle: {
    color: COLORS.white,
    fontSize: 20,
    fontWeight: "700",
    fontFamily: FONTS.serif,
  },
  settingsButton: {
    width: 36,
    height: 36,
    borderRadius: 18,
    alignItems: "center",
    justifyContent: "center",
    backgroundColor: "transparent",
  },
  settingsButtonActive: {
    backgroundColor: COLORS.bgElevated,
    borderWidth: 1,
    borderColor: COLORS.border,
  },
  contentArea: {
    flex: 1,
  },
  bottomNav: {
    height: 72,
    backgroundColor: COLORS.bgCard,
    borderTopWidth: 1,
    borderColor: COLORS.border,
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "space-around",
    paddingBottom: Platform.OS === "ios" ? 12 : 0,
  },
  navTab: {
    alignItems: "center",
    justifyContent: "center",
    paddingVertical: 6,
    paddingHorizontal: 12,
    borderRadius: 12,
  },
  navTabActive: {
    backgroundColor: "rgba(124, 111, 247, 0.12)",
  },
  navIconContainer: {
    marginBottom: 2,
  },
  navTabLabel: {
    fontSize: 10,
    fontFamily: FONTS.sans,
  },
  navTabLabelActive: {
    color: COLORS.purple,
    fontWeight: "600",
  },
  navTabLabelMuted: {
    color: COLORS.muted,
  },
  disclaimerFooter: {
    backgroundColor: COLORS.bg,
    paddingVertical: 6,
    alignItems: "center",
    borderTopWidth: 0.5,
    borderColor: "rgba(255, 255, 255, 0.05)",
  },
  disclaimerFooterText: {
    color: COLORS.muted,
    fontSize: 9,
    fontFamily: FONTS.sans,
    textAlign: "center",
  },
});
