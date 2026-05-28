import React, { useState } from "react";
import { StyleSheet, View, Text, TouchableOpacity, ScrollView, SafeAreaView } from "react-native";
import { COLORS, FONTS } from "../components/Theme";
import LotusIcon from "../components/LotusIcon";
import {
  BrainIcon,
  JournalIcon,
  CompanionIcon,
  LibraryIcon,
  InsightsIcon,
  CheckIcon,
  WarningIcon,
  ChevronRightIcon,
  SparkleIcon,
} from "../components/Icons";

export default function WelcomeScreen({ onConsentGranted }) {
  const [step, setStep] = useState(1);
  const [consentTherapist, setConsentTherapist] = useState(false);
  const [consentDisclaimer, setConsentDisclaimer] = useState(false);

  const features = [
    {
      icon: <BrainIcon color={COLORS.purpleLight} size={22} />,
      title: "Daily Check-Ins",
      desc: "Understand your emotions through tracking physical, mental and social energy.",
    },
    {
      icon: <JournalIcon color={COLORS.tealLight} size={22} />,
      title: "Personalized Journal",
      desc: "Express yourself freely via text, guided prompts and quick reflections.",
    },
    {
      icon: <CompanionIcon color={COLORS.pink} size={22} />,
      title: "AI Companion",
      desc: "Empathetic chat support with Nova, your companion for cognitive reframing.",
    },
    {
      icon: <LibraryIcon color={COLORS.peach} size={22} />,
      title: "Coping Library",
      desc: "Access sensory reset soundboards and grounding techniques on demand.",
    },
    {
      icon: <InsightsIcon color={COLORS.gold} size={22} />,
      title: "Therapist Insights",
      desc: "Bridging the gap by feeding structured trends to your clinical sessions.",
    },
  ];

  if (step === 1) {
    return (
      <SafeAreaView style={styles.container}>
        <ScrollView contentContainerStyle={styles.scrollContent} showsVerticalScrollIndicator={false}>
          <View style={styles.logoContainer}>
            <View style={styles.logoCircle}>
              <LotusIcon size={58} />
            </View>
            <Text style={styles.logoText}>zenara</Text>
            <View style={styles.taglineRow}>
              <SparkleIcon size={12} color={COLORS.purpleLight} />
              <Text style={styles.tagline}>Your mind. Your space. Your growth.</Text>
            </View>
          </View>

          <View style={styles.featuresList}>
            {features.map((f, i) => (
              <View key={i} style={styles.featureItem}>
                <View style={styles.featureIconContainer}>{f.icon}</View>
                <View style={styles.featureTextContainer}>
                  <Text style={styles.featureTitle}>{f.title}</Text>
                  <Text style={styles.featureDesc}>{f.desc}</Text>
                </View>
              </View>
            ))}
          </View>

          <View style={styles.footer}>
            <Text style={styles.footerNote}>Mindful. Intelligent. Personal. This is Zenara. ✦</Text>
            <TouchableOpacity style={styles.button} activeOpacity={0.85} onPress={() => setStep(2)}>
              <Text style={styles.buttonText}>Get Started</Text>
              <ChevronRightIcon color="white" size={14} />
            </TouchableOpacity>
          </View>
        </ScrollView>
      </SafeAreaView>
    );
  }

  return (
    <SafeAreaView style={styles.container}>
      <View style={styles.scrollContent}>
        <View style={styles.logoContainer}>
          <View style={styles.logoCircleMini}>
            <LotusIcon size={32} />
          </View>
          <Text style={styles.logoTextMini}>Consent & Gateways</Text>
          <Text style={styles.tagline}>Zenara is a clinical tool. Please review below.</Text>
        </View>

        <View style={styles.consentCard}>
          <View style={styles.consentHeaderRow}>
            <InsightsIcon color={COLORS.purpleLight} size={18} />
            <Text style={styles.consentCardHeader}>Data Protection & Consent</Text>
          </View>
          <Text style={styles.consentText}>
            Zenara complies with India's Digital Personal Data Protection (DPDP) Act, 2023. We encrypt all your journals, logs, and chats using AES-256.
          </Text>

          <TouchableOpacity
            style={styles.checkboxContainer}
            activeOpacity={0.8}
            onPress={() => setConsentTherapist(!consentTherapist)}
          >
            <View style={[styles.checkbox, consentTherapist && styles.checkboxChecked]}>
              {consentTherapist && <CheckIcon size={12} />}
            </View>
            <Text style={styles.checkboxLabel}>
              I consent to sharing my daily mood trends and journal summaries with my licensed therapist (Dr. Hayes).
            </Text>
          </TouchableOpacity>

          <TouchableOpacity
            style={styles.checkboxContainer}
            activeOpacity={0.8}
            onPress={() => setConsentDisclaimer(!consentDisclaimer)}
          >
            <View style={[styles.checkbox, consentDisclaimer && styles.checkboxChecked]}>
              {consentDisclaimer && <CheckIcon size={12} />}
            </View>
            <Text style={styles.checkboxLabel}>
              I understand that the AI companion (Nova) is a supportive tool and NOT a licensed medical professional.
            </Text>
          </TouchableOpacity>
        </View>

        <View style={styles.disclaimerContainer}>
          <View style={styles.disclaimerHeader}>
            <WarningIcon color="#f06c8a" size={16} />
            <Text style={styles.disclaimerTitle}>PERSISTENT CLINICAL DISCLAIMER</Text>
          </View>
          <Text style={styles.disclaimerText}>
            In case of crisis, emergency, or self-harm thoughts, please close the app and call local emergency services immediately.
          </Text>
        </View>

        <View style={styles.footer}>
          <TouchableOpacity
            style={[styles.button, (!consentTherapist || !consentDisclaimer) && styles.buttonDisabled]}
            disabled={!consentTherapist || !consentDisclaimer}
            activeOpacity={0.85}
            onPress={onConsentGranted}
          >
            <Text style={styles.buttonText}>Accept & Enter App</Text>
            <CheckIcon color="white" size={14} />
          </TouchableOpacity>
          <TouchableOpacity style={styles.backButton} activeOpacity={0.7} onPress={() => setStep(1)}>
            <Text style={styles.backButtonText}>Back</Text>
          </TouchableOpacity>
        </View>
      </View>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.bg,
  },
  scrollContent: {
    padding: 24,
    flexGrow: 1,
    justifyContent: "space-between",
  },
  logoContainer: {
    alignItems: "center",
    marginTop: 10,
    marginBottom: 20,
  },
  logoCircle: {
    width: 90,
    height: 90,
    borderRadius: 45,
    backgroundColor: "rgba(124, 111, 247, 0.08)",
    borderWidth: 1.5,
    borderColor: "rgba(124, 111, 247, 0.2)",
    alignItems: "center",
    justifyContent: "center",
    shadowColor: COLORS.purple,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.4,
    shadowRadius: 15,
    elevation: 6,
  },
  logoCircleMini: {
    width: 50,
    height: 50,
    borderRadius: 25,
    backgroundColor: "rgba(124, 111, 247, 0.08)",
    borderWidth: 1,
    borderColor: "rgba(124, 111, 247, 0.15)",
    alignItems: "center",
    justifyContent: "center",
    marginBottom: 8,
  },
  logoText: {
    color: COLORS.white,
    fontSize: 34,
    fontWeight: "700",
    fontFamily: FONTS.serif,
    marginTop: 10,
    letterSpacing: 0.5,
  },
  logoTextMini: {
    color: COLORS.white,
    fontSize: 22,
    fontWeight: "600",
    fontFamily: FONTS.serif,
  },
  taglineRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    marginTop: 8,
  },
  tagline: {
    color: COLORS.muted,
    fontSize: 13,
    fontFamily: FONTS.sans,
  },
  featuresList: {
    marginVertical: 8,
    backgroundColor: "rgba(25, 22, 54, 0.3)",
    borderRadius: 20,
    padding: 16,
    borderWidth: 1,
    borderColor: COLORS.border,
  },
  featureItem: {
    flexDirection: "row",
    marginBottom: 18,
    alignItems: "center",
  },
  featureIconContainer: {
    width: 42,
    height: 42,
    borderRadius: 12,
    backgroundColor: "rgba(255, 255, 255, 0.03)",
    borderWidth: 1,
    borderColor: COLORS.border,
    alignItems: "center",
    justifyContent: "center",
    marginRight: 14,
  },
  featureTextContainer: {
    flex: 1,
  },
  featureTitle: {
    color: COLORS.white,
    fontSize: 14,
    fontWeight: "600",
    fontFamily: FONTS.sans,
  },
  featureDesc: {
    color: COLORS.muted,
    fontSize: 11.5,
    marginTop: 2,
    lineHeight: 15,
    fontFamily: FONTS.sans,
  },
  consentCard: {
    backgroundColor: "rgba(25, 22, 54, 0.7)",
    borderRadius: 20,
    borderWidth: 1.5,
    borderColor: "rgba(124, 111, 247, 0.22)",
    padding: 18,
    marginVertical: 10,
    shadowColor: COLORS.purple,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.15,
    shadowRadius: 15,
    elevation: 3,
  },
  consentHeaderRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 8,
    marginBottom: 10,
  },
  consentCardHeader: {
    color: COLORS.white,
    fontSize: 15,
    fontWeight: "600",
    fontFamily: FONTS.sans,
  },
  consentText: {
    color: COLORS.muted,
    fontSize: 12,
    lineHeight: 16,
    marginBottom: 18,
    fontFamily: FONTS.sans,
  },
  checkboxContainer: {
    flexDirection: "row",
    alignItems: "flex-start",
    marginBottom: 16,
  },
  checkbox: {
    width: 20,
    height: 20,
    borderRadius: 6,
    borderWidth: 1.5,
    borderColor: COLORS.muted,
    alignItems: "center",
    justifyContent: "center",
    marginRight: 12,
    marginTop: 2,
    backgroundColor: "rgba(255, 255, 255, 0.02)",
  },
  checkboxChecked: {
    backgroundColor: COLORS.purple,
    borderColor: COLORS.purple,
    shadowColor: COLORS.purple,
    shadowOffset: { width: 0, height: 0 },
    shadowOpacity: 0.5,
    shadowRadius: 4,
  },
  checkboxLabel: {
    color: COLORS.white,
    fontSize: 12,
    flex: 1,
    lineHeight: 16,
    fontFamily: FONTS.sans,
  },
  disclaimerContainer: {
    backgroundColor: "rgba(240, 108, 138, 0.06)",
    borderWidth: 1,
    borderColor: "rgba(240, 108, 138, 0.18)",
    borderRadius: 16,
    padding: 14,
    marginVertical: 10,
  },
  disclaimerHeader: {
    flexDirection: "row",
    alignItems: "center",
    gap: 6,
    marginBottom: 6,
  },
  disclaimerTitle: {
    color: "#f06c8a",
    fontSize: 10,
    fontWeight: "700",
    fontFamily: FONTS.sans,
    letterSpacing: 1,
  },
  disclaimerText: {
    color: "#f06c8a",
    fontSize: 11,
    lineHeight: 15,
    fontFamily: FONTS.sans,
    opacity: 0.9,
  },
  footer: {
    marginTop: 10,
    alignItems: "center",
    width: "100%",
  },
  footerNote: {
    color: COLORS.muted,
    fontSize: 11,
    marginBottom: 14,
    fontFamily: FONTS.sans,
  },
  button: {
    backgroundColor: COLORS.purple,
    borderRadius: 14,
    paddingVertical: 14,
    width: "100%",
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 6,
    shadowColor: COLORS.purple,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.4,
    shadowRadius: 12,
    elevation: 5,
  },
  buttonDisabled: {
    backgroundColor: "rgba(124, 111, 247, 0.2)",
    shadowOpacity: 0,
    elevation: 0,
  },
  buttonText: {
    color: "white",
    fontSize: 14.5,
    fontWeight: "600",
    fontFamily: FONTS.sans,
  },
  backButton: {
    marginTop: 12,
    paddingVertical: 8,
  },
  backButtonText: {
    color: COLORS.muted,
    fontSize: 13,
    fontFamily: FONTS.sans,
  },
});
