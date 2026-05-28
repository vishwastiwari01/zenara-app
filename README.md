<div align="center">
  <img src="assets/logo.png" alt="Zenara Logo" width="150"/>
  
  # Zenara
  ### Your Premium Emotional Wellness & AI Companion
  
  [Features](#features) • [Installation](#installation) • [Tech Stack](#tech-stack) • [Compliance](#compliance)
</div>

---

## ✦ Overview
**Zenara** is a production-ready, beautifully crafted emotional wellness application built in Flutter. It seamlessly merges daily mood tracking, guided clinical coping mechanisms, and a futuristic emotional AI companion (**Nova**) into one unified, secure, and premium experience.

Inspired by industry leaders like Calm and Reflectly, Zenara utilizes soft glassmorphism, dynamic animations, and calming pastel gradients to create a safe digital space for emotional reflection and growth.

---

## ✨ Features

- 🧠 **Nova (AI Emotional Companion)**
  - A living, breathing animated Orb that reacts to your emotional states.
  - Powered by Anthropic's Claude (via OpenRouter API) for intelligent, compassionate cognitive reframing.
  - Context-aware background animations and glassmorphic chat UI.
- 📔 **My Journal & Mood Tracker**
  - Advanced rich text editor for daily reflections.
  - Interactive, stable **Doodle Canvas** to express emotions visually (with Undo/Redo & Save capabilities).
  - Daily mood and energy level check-ins.
- 📊 **Therapist Portal (Insights)**
  - Deep analytics into emotional trends and triggers.
  - AI-generated weekly summaries and clinical session note integrations.
- 🌿 **Safe Space (Library)**
  - Categorized coping tools (Box Breathing, Grounding techniques, etc.).
  - Built-in ambient soundscapes with volume controls.
- 🌓 **Dynamic Theming**
  - Fully responsive Light and Dark modes.
  - Theme-aware `GlassCard` architecture that automatically adjusts shadows, blurs, and borders based on the environment.

---

## 🛠 Tech Stack
- **Framework**: Flutter (Dart)
- **State Management**: `ValueNotifier` & `StatefulWidgets`
- **Local Storage**: `shared_preferences`
- **Animations**: `flutter_animate`, CustomPainters, AnimationControllers
- **Charts**: `fl_chart`
- **Network**: `http` (for OpenRouter LLM integration)

---

## 🚀 Installation & Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/vishwastiwari01/zenara-app.git
   cd zenara-app
   ```

2. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

3. **Configure API Keys:**
   - The app uses OpenRouter (Claude 3.5 Sonnet) for the Nova AI Companion.
   - You can enter your API Key directly within the **Settings Screen** of the app.
   - *If no API key is provided, Nova will fallback to a local mock offline companion mode.*

4. **Run the App:**
   ```bash
   flutter run
   ```

5. **Build APK (Release):**
   ```bash
   flutter build apk --release
   ```

---

## 🛡 Privacy & Clinical Compliance
- **Data Protection**: Designed with India DPDP Act 2023 compliance in mind. Users have absolute control over their data, with a 1-tap "Erase Everything" function in Settings.
- **Clinical Boundaries**: Built with safety constraints. The AI companion is programmed to detect crisis terminology (e.g., self-harm indicators) and will safely suspend the session while surfacing emergency hotlines.
- **Framework Backing**: Designed incorporating criteria from the Mobile App Rating Scale (MARS) focusing on evidence-based psychoeducation and cognitive reframing.

---

<div align="center">
  <i>Crafted with care to make mental wellness accessible, beautiful, and secure.</i>
</div>
