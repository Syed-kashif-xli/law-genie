# Law Genie - App Blueprint

## Overview

Law Genie is a Flutter-based mobile application designed to be an AI-powered legal assistant. It aims to provide users with tools for legal research, document analysis, case management, and secure client communication. The app is built with a futuristic and visually appealing dark theme and integrates with Firebase for backend services.

## Current Features

*   **Onboarding:** A multi-page onboarding flow introduces users to the app's key features.
*   **Authentication:** Users can log in to the application. The project is set up with Firebase Auth.
*   **Home Page:** A central dashboard that provides an overview of AI queries, documents, and tracked cases. It also includes quick actions to navigate to different features.
*   **AI Chat:** A chat interface to interact with an AI for legal advice.
*   **Document Generation:** A feature to create legal documents.
*   **Risk Check:** A tool to assess legal risks.
*   **Case Timeline:** A feature to track and manage legal cases with a timeline view.
*   **Notifications:** The app is configured to send local notifications.

## Style and Design

*   **Theme:** The app uses a custom "futuristic" dark theme.
    *   **Primary Color:** `0xFF6B3E9A` (a deep purple)
    *   **Accent Color:** `Colors.blueAccent`
    *   **Background Color:** `0xFF1A0B2E` (a very dark purple)
*   **Typography:** The `Lexend` font from Google Fonts is used for the text theme.
*   **UI Components:** The UI is built with standard Material Design components, styled to match the futuristic theme. This includes custom styles for `AppBar`, `Card`, `ElevatedButton`, and `InputDecoration`.

## Project Structure

The project is organized into the following main directories:

*   `lib/features`: Contains the UI and business logic for each feature of the application, such as `auth`, `chat`, `home`, etc.
*   `lib/services`: Includes services for interacting with external systems, such as `FirestoreService` and `NotificationService`.
*   `lib/core`: Shared constants and utilities.

## Planned Improvements

### Home Page Refactoring

To improve the performance, maintainability, and scalability of the home page (`lib/features/home/home_page.dart`), the following changes will be implemented:

1.  **Componentize the UI:** The different sections of the home page (Stats, Quick Actions, Upcoming Events, AI Usage, and Legal News) will be broken down into smaller, reusable `StatelessWidget` classes. This will make the code more organized and allow Flutter to optimize rendering by rebuilding only the widgets that have changed.

2.  **Introduce Data Models:** `Case` and `Timeline` data models will be created to represent the application's data structure. This will replace the current hardcoded data, making it easier to manage and preparing the app for integration with a backend service like Firestore.

3.  **Performance Optimization:** `const` constructors will be added to all eligible widgets to prevent unnecessary rebuilds and improve the overall performance of the home page.

4.  **Create a New `feature_card.dart` Widget:** A new `FeatureCard` widget will be created to encapsulate the design and layout of the quick action cards, promoting reusability and simplifying the `home_page.dart` file.
