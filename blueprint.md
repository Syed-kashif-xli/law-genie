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

### 4. Fully Functional Navigation
- Implemented a complete navigation system using named routes.
- The app's quick actions and drawer menu are now fully functional.
- Added three new pages: `GenerateDocPage`, `RiskCheckPage`, and `CaseTimelinePage`.