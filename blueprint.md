# Law Genie - App Blueprint

## Overview

Law Genie is an AI-powered legal assistant designed to make legal services more accessible and affordable. It provides users with tools to get instant legal advice, generate legal documents, assess risks, and track cases.

## Design & Style

- **Theme:** A modern and sophisticated "liquid glass" (Glassmorphism) aesthetic.
- **Color Palette:** A vibrant palette built on deep purples and complemented by a range of dynamic, translucent colors for UI elements. This creates a fluid and visually engaging experience.
- **Typography:** Google Fonts (Oswald for headings, Roboto and Open Sans for body text) are used for a clean and readable experience.
- **Iconography:** `iconsax` and `font_awesome_flutter` packages are used for modern and clean icons.
- **Layout:** UI components like cards and buttons will have a frosted glass look with blurred backgrounds, gradients, and soft borders to create a sense of depth and fluidity.

## Implemented Features

### 1. Onboarding Experience
- A multi-step onboarding process with a "liquid glass" UI.

### 2. User Authentication
- A sleek, modern login page that appears after onboarding.

### 3. Dashboard Home Page
- A dashboard-style home page with a `GridView` of feature cards.
- Reusable `FeatureCard` widget.

## Current Plan: Apply "Liquid Glass" UI to Home Page

To create a cohesive and modern user experience, the "liquid glass" design will be applied to the home page.

### Steps:
1.  **Update Feature Cards:** The `FeatureCard` widget will be redesigned to have a frosted glass background, a semi-transparent border, and a subtle gradient.
2.  **Dynamic Asset Colors:** The icons and backgrounds on the feature cards will use a more vibrant and varied color scheme to feel more dynamic and align with the "liquid glass" theme.
3.  **Refactor `home_page.dart`:** The home page will be updated to orchestrate the new `FeatureCard` design and color scheme.
