# AI Transparency Log

## Project: Jen - Mindfulness & Mental Wellness App

This document tracks our team's use of AI tools during the development of Jen, a Flutter-based mobile application for mindfulness, meditation, and mental health tracking.

---

## Entry 1: Diagnosing and Fixing Flutter Analyze Errors

**Date:** October 26, 2024
**AI Tool Used:** Claude (Anthropic)

### What Was Asked/Generated

We used Claude multiple times to diagnose and fix errors from `flutter analyze`. This was one example:

**Issue:** Deprecation warning for `Color.withOpacity()` method
- Affected files: Multiple screen files including [breathing_screen.dart](jen/lib/screens/breathing_screen.dart:414-420)
- Flutter suggested using the new `Color.withValues()` API instead

We asked Claude to explain the deprecation and show us how to fix it.

### How It Was Applied

Claude explained that `withOpacity()` was replaced with `withValues(alpha: value)` where alpha takes values from 0.0 to 1.0.

We updated all instances throughout the codebase:
```dart
// Before
AppColors.teal.withOpacity(0.6)

// After
AppColors.teal.withValues(alpha: 0.6)
```

### Reflection: What Was Learned

- How to interpret Flutter deprecation warnings and migrate to new APIs
- The importance of running `flutter analyze` regularly to catch issues early

---

## Entry 2: Rapid Feature Development with AI-Assisted Autocomplete

**Date:** October 26, 2024
**AI Tool Used:** Claude Code (Anthropic) & Cursor

### What Was Asked/Generated

We used AI-powered code completion throughout development to:
- Suggest idiomatic Flutter patterns for StatefulWidgets and animations
- Complete boilerplate code for database operations
- Suggest widget hierarchies and layouts

**Example Use Cases:**
1. AnimationController setup with proper disposal patterns in [breathing_screen.dart](jen/lib/screens/breathing_screen.dart)
2. Database CRUD operations with async/await patterns
3. Consistent navigation callback patterns across screens

### How It Was Applied

We maintained control of architecture while using AI to speed up repetitive coding tasks and ensure consistent patterns. We reviewed every suggestion before accepting it.

### Reflection: What Was Learned

- How to use AI as a productivity tool without losing understanding of the code
- Recognition of common Flutter patterns and when to apply them

---

## Entry 3: Project Requirements Validation

**Date:** October 26, 2024
**AI Tool Used:** Claude (Anthropic)

### What Was Asked/Generated

We provided Claude with:
1. The original project requirements and rubric
2. Our complete codebase structure
3. List of implemented features

We asked Claude to analyze our implementation against the requirements and identify what was complete, incomplete, or missing.

### How It Was Applied

Claude's analysis helped us verify we met core requirements like multi-screen navigation, data persistence, and state management. We used this to prioritize remaining work and ensure we weren't missing any rubric criteria.

### Reflection: What Was Learned

- How to systematically compare implementation against requirements
- The value of requirements traceability in software projects

---

## Entry 4: Learning Industry Standards and Best Practices

**Date:** October 26, 2024
**AI Tool Used:** Claude (Anthropic)

### What Was Asked/Generated

For features not extensively covered in class, we used AI as a tutor to understand industry standards.

**Audio Integration Example:**
- **Asked:** "What's the best way to implement audio playback for guided meditation in Flutter?"
- **Learned about:** The `audioplayers` package, asset management, proper audio lifecycle management

**Implementation in [breathing_screen.dart](jen/lib/screens/breathing_screen.dart:1-508):**
```dart
final AudioPlayer _audioPlayer = AudioPlayer();

Future<void> _playAudioCue(String assetPath) async {
  await _audioPlayer.stop();
  await _audioPlayer.play(AssetSource(assetPath));
}

@override
void dispose() {
  _audioPlayer.dispose();
  super.dispose();
}
```

**Other Topics:**
- State Management: Why we chose Provider over alternatives
- SQLite schema design and relationships
- Coordinating animations with audio cues
- Material 3 theming and dark mode

### How It Was Applied

We asked AI to explain concepts and trade-offs, reviewed recommended packages and documentation, then implemented features ourselves using the knowledge gained.

### Reflection: What Was Learned

- How to evaluate third-party packages effectively
- Resource management patterns in Flutter (preventing memory leaks)
- Async programming patterns and error handling
- The Flutter asset pipeline and pubspec.yaml configuration

---

## Summary

We used AI tools responsibly as assistants for debugging, accelerating development, validating requirements, and learning topics beyond class scope. We maintained ownership of all architectural decisions and feature design.

**Key Stats:**
- 8+ core features implemented
- ~3000+ lines of original code across 20+ Dart files
- All architecture decisions made by the team
