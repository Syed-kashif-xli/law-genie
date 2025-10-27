# Law Genie - App Blueprint

## Overview

Law Genie is an AI-powered legal assistant designed to make legal services more accessible and affordable. It provides users with tools to get instant legal advice, generate legal documents, assess risks, and track cases.

## Design & Style

- **Theme:** Modern, clean, and professional with a "glassmorphism" aesthetic.
- **Color Palette:** A primary palette of deep purple and a secondary palette of white and grey, creating a vibrant and energetic look and feel.
- **Typography:** Google Fonts (Oswald for headings, Roboto and Open Sans for body text) are used for a clean and readable experience.
- **Iconography:** `iconsax` and `font_awesome_flutter` packages are used for modern and clean icons.
- **Layout:** Card-based layouts with clean spacing, gradients, and subtle shadows to create depth and a premium feel.

## Implemented Features

### 1. Onboarding Experience
- A multi-step onboarding process to introduce users to the app's features.
- A visually engaging UI with a gradient background and smooth page indicators.
- Refined visual design with a frosted glass effect for icon backgrounds.

### 2. User Authentication
- A sleek, modern login page that appears after onboarding.
- Supports both email and phone number login.
- Includes options for social login (Google & Apple).

### 3. Dashboard Home Page
- A dashboard-style home page with a `GridView` of feature cards.
- Reusable `FeatureCard` widget.

## Current Plan: Refine Onboarding UI

Based on user feedback, the UI of the onboarding screen will be enhanced.

### Steps:
1.  **Apply Glassmorphism:** The container for the icon on the onboarding screens will be changed from a simple circle to a rounded square with a blurred background (frosted glass effect).
2.  **Add Border:** A semi-transparent white border will be added to the container to give it a defined, line-like appearance.
3.  **Update `onboarding_screen.dart`:** The `lib/features/onboarding/onboarding_screen.dart` file will be modified to implement this new design.
