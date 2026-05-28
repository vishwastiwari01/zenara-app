import React, { useState, useEffect } from "react";
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
import { COLORS, FONTS } from "../components/Theme";
import { GearIcon, InsightsIcon, WarningIcon } from "../components/Icons";

export default function SettingsScreen({ onRevokeConsent }) {
  const [apiKey, setApiKey] = useState("");
  const [keySaved, setKeySaved] = useState(false);

  useEffect(() => {
    async function loadKey() {
      try {
        const stored = await AsyncStorage.getItem("zenara_anthropic_api_key");
        if (stored) setApiKey(stored);
      } catch (e) {
        console.log("Error loading API Key");
      }
    }
    loadKey();
  }, []);

  const handleSaveKey = async () => {
    try {
      await AsyncStorage.setItem("zenara_anthropic_api_key", apiKey);
      setKeySaved(true);
      setTimeout(() => setKeySaved(false), 2000);
    } catch (e) {
      Alert.alert("Error", "Failed to save key");
    }
  };

  const handleDeleteAllData = () => {
    Alert.alert(
      "Confirm Deletion",
      "DPDP ACT COMPLIANCE: This will permanently erase all your journal entries, settings, keys, and tracking logs from this device. This action is irreversible.",
      [
        { text: "Cancel", style: "cancel" },
        {
          text: "Erase Everything",
          style: "destructive",
          onPress: async () => {
            try {
              await AsyncStorage.clear();
              setApiKey("");
              Alert.alert("Data Erased", "All your data has been successfully removed.", [
                { text: "OK", onPress: onRevokeConsent },
              ]);
            } catch (e) {
              Alert.alert("Error", "Failed to erase data");
            }
          },
        },
      ]
    );
  };

  return (
    <SafeAreaView style={styles.container}>
      <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
        {/* Header */}
        <View style={styles.header}>
          <Text style={styles.title}>Settings</Text>
          <Text style={styles.subtitle}>Privacy & Configurations</Text>
        </View>

        {/* API Key configuration */}
        <View style={styles.card}>
          <View style={styles.headerRow}>
            <GearIcon color={COLORS.purpleLight} size={18} />
            <Text style={styles.cardTitle}>Anthropic API Key</Text>
          </View>
          <Text style={styles.cardDesc}>
            Enter your Claude API key to enable real-time emotional companion conversations. Left blank, Nova runs in local offline mode.
          </Text>
          <TextInput
            value={apiKey}
            onChangeText={setApiKey}
            placeholder="sk-ant-..."
            placeholderTextColor={COLORS.muted}
            secureTextEntry
            style={styles.textInput}
          />
          <TouchableOpacity style={styles.button} onPress={handleSaveKey}>
            <Text style={styles.buttonText}>{keySaved ? "✓ Key Saved!" : "Save API Key"}</Text>
          </TouchableOpacity>
        </View>

        {/* DPDP Compliance Card */}
        <View style={styles.card}>
          <View style={styles.headerRow}>
            <InsightsIcon color={COLORS.tealLight} size={18} />
            <Text style={styles.cardTitle}>DPDP Act (India) Compliance</Text>
          </View>
          <Text style={styles.cardDesc}>
            In compliance with the Digital Personal Data Protection (DPDP) Act, 2023, you have full control over your digital footprint.
          </Text>

          <TouchableOpacity style={styles.borderButton} onPress={onRevokeConsent}>
            <Text style={styles.borderButtonText}>Revoke Therapist Consent</Text>
          </TouchableOpacity>

          <View style={styles.divider} />

          <View style={styles.dangerWarningHeader}>
            <WarningIcon color="#f06c8a" size={14} />
            <Text style={styles.warningText}>
              Warning: The protocol below deletes all databases and local caches instantly.
            </Text>
          </View>
          <TouchableOpacity style={styles.dangerButton} onPress={handleDeleteAllData}>
            <Text style={styles.dangerButtonText}>One-Click Data Deletion</Text>
          </TouchableOpacity>
        </View>

        {/* Persistent Clinical Disclaimer */}
        <View style={styles.disclaimerCard}>
          <View style={styles.disclaimerHeader}>
            <WarningIcon color={COLORS.muted} size={14} />
            <Text style={styles.disclaimerTitle}>Persistent Medical Disclaimer</Text>
          </View>
          <Text style={styles.disclaimerText}>
            Zenara is a clinical wellness platform designed to support daily self-management and therapist communication. It does NOT diagnose or treat mental health conditions. AI companion features are conversational tools and not a replacement for psychiatric therapy. If you are experiencing crisis, self-harm thoughts, or emergency, please contact national crisis lifelines immediately.
          </Text>
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
  card: {
    backgroundColor: "rgba(19, 16, 43, 0.7)",
    borderRadius: 18,
    borderWidth: 1,
    borderColor: COLORS.border,
    padding: 16,
    marginBottom: 16,
  },
  headerRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
    marginBottom: 8,
  },
  cardTitle: {
    color: COLORS.white,
    fontSize: 15,
    fontWeight: "600",
    fontFamily: FONTS.sans,
  },
  cardDesc: {
    color: COLORS.muted,
    fontSize: 12,
    lineHeight: 16,
    fontFamily: FONTS.sans,
    marginBottom: 14,
  },
  textInput: {
    backgroundColor: COLORS.bgElevated,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: COLORS.border,
    color: COLORS.white,
    fontSize: 13.5,
    fontFamily: FONTS.sans,
    paddingHorizontal: 12,
    paddingVertical: 10,
    marginBottom: 12,
  },
  button: {
    backgroundColor: COLORS.purple,
    borderRadius: 12,
    paddingVertical: 12,
    alignItems: "center",
  },
  buttonText: {
    color: "white",
    fontSize: 13.5,
    fontWeight: "600",
    fontFamily: FONTS.sans,
  },
  borderButton: {
    borderRadius: 12,
    borderWidth: 1,
    borderColor: COLORS.border,
    paddingVertical: 12,
    alignItems: "center",
  },
  borderButtonText: {
    color: COLORS.purpleLight,
    fontSize: 13.5,
    fontWeight: "600",
    fontFamily: FONTS.sans,
  },
  dangerWarningHeader: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    marginBottom: 10,
  },
  dangerButton: {
    backgroundColor: "rgba(240, 108, 138, 0.08)",
    borderWidth: 1.5,
    borderColor: "#f06c8a",
    borderRadius: 12,
    paddingVertical: 12,
    alignItems: "center",
  },
  dangerButtonText: {
    color: "#f06c8a",
    fontSize: 13.5,
    fontWeight: "700",
    fontFamily: FONTS.sans,
  },
  warningText: {
    color: "#f06c8a",
    fontSize: 11,
    fontFamily: FONTS.sans,
    flex: 1,
  },
  disclaimerCard: {
    backgroundColor: "rgba(255, 255, 255, 0.02)",
    borderRadius: 16,
    borderWidth: 1,
    borderColor: "rgba(255, 255, 255, 0.08)",
    padding: 16,
    marginBottom: 16,
  },
  disclaimerHeader: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    marginBottom: 6,
  },
  disclaimerTitle: {
    color: COLORS.muted,
    fontSize: 12,
    fontWeight: "600",
    fontFamily: FONTS.sans,
  },
  disclaimerText: {
    color: COLORS.muted,
    fontSize: 11,
    lineHeight: 16,
    fontFamily: FONTS.sans,
  },
  divider: {
    height: 1,
    backgroundColor: COLORS.border,
    marginVertical: 16,
  },
});
