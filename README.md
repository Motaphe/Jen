# Jen - Mindfulness and Stress Reduction App

A Flutter-based mobile application designed to promote mindfulness and help users reduce stress through guided exercises, journaling, and emotional awareness.

## Project Overview

Jen provides a calming, minimalistic interface focused on mental clarity and simplicity. Built with Flutter and themed using the Catppuccin color palette, the app offers both light and dark themes with a modern aesthetic that enhances the mindfulness experience. The app features comprehensive wellness tracking, audio-guided exercises, and personalized user experiences.

## Core Features

### Wellness Tracking
- **Daily Affirmations**: Rotating motivational quotes with the ability to favorite and save your preferred affirmations
- **Journal**: Private space for thoughts and reflections with persistent storage, date filtering, and rich text editing
- **Mood Tracker**: Log daily emotions with visual feedback, view mood history, and track weekly emotional trends with charts
- **Calendar View**: Unified timeline displaying all activities (journal entries, mood logs, lockdown sessions) with filtering options

### Mindfulness Exercises
- **Breathing Exercises**: Audio-guided breathing sessions with voice cues for inhale/hold/exhale patterns, session tracking, and completion statistics
- **Lockdown Mode**: Enhanced focus feature with app blocking capabilities, timer management, session history, and productivity tracking

### Health & Wellness
- **Water Reminder**: Daily hydration tracking with goal setting (8 glasses), visual progress indicators, and streak tracking

### Personalization
- **Light/Dark Mode**: Complete theme support with Catppuccin Mocha (dark) and Latte (light) color palettes
- **User Personalization**: Custom greeting on home screen with first-time user onboarding
- **Haptic Feedback**: Enhanced tactile responses across all interactive elements

## Tech Stack

- **Framework**: Flutter (Dart)
- **Database**: SQLite for local data persistence
- **Local Storage**: SharedPreferences for user settings
- **Audio**: AudioPlayers for guided meditation and breathing exercises
- **Charts**: FL Chart for mood visualization
- **Typography**: Google Fonts (Nunito, Merriweather)
- **Design Theme**: Catppuccin Mocha & Latte color palettes
- **State Management**: Provider
- **UI/UX**: [Figma Wireframes](https://lid-couch-37881953.figma.site/)

## Development Approach

This project follows a milestone-based development approach managed through GitHub Projects:

- **Milestone 1**: UI implementation, navigation, and static layouts
- **Milestone 2**: Data persistence, state management, and feature integration
- **Extra Features**: Audio-guided exercises, calendar/timeline view, water tracking, theme enhancements, and polish

## Team

- **Suzal Regmi** - Development & Implementation
- **Diana Avila** - Planning, Design & Documentation

## Getting Started

### Prerequisites

```bash
flutter --version  # Flutter 3.0 or higher
```

### Installation

```bash
git clone https://github.com/Motaphe/Jen.git
cd jen
flutter pub get
flutter run
```

## Project Management

Development progress and task tracking are managed through [GitHub Projects](https://github.com/users/Motaphe/projects/2).