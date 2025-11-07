# Law Genie - AI-Powered Legal Assistant

**Overview:**

Law Genie is a Flutter application designed to be a comprehensive legal assistant. It leverages AI to provide legal insights, document generation, case management, and up-to-date legal news. The app is built with a focus on a modern, intuitive user experience, with a dark, futuristic theme.

**Key Features:**

*   **AI Chat:** A core feature of the app, the AI Chat allows users to ask legal questions and receive detailed answers from a Gemini-powered AI. The chat interface is designed to be intuitive and user-friendly, with support for markdown rendering of AI responses.
*   **Document Generation:** Users can generate legal documents based on templates and user-provided information. The app can generate documents like Non-Disclosure Agreements (NDAs).
*   **Case Timeline:** A tool for managing and visualizing the key events of a legal case. Users can add, edit, and track the status of different milestones in their case.
*   **Legal News:** The app fetches and displays the latest legal news from various sources, keeping users informed about current events in the legal world.
*   **Onboarding:** A smooth and visually appealing onboarding experience to introduce new users to the app's features.

**Design and Theming:**

*   **Theme:** The app uses a dark, futuristic theme with a color palette based on deep purple, accented with a vibrant teal. The typography is based on the Lexend and Poppins font families from Google Fonts.
*   **UI Components:** The app uses custom-styled widgets to create a consistent and modern look and feel. This includes custom-themed buttons, text fields, cards, and bottom navigation.
*   **Layout:** The app is designed to be responsive and work well on both mobile and web platforms.

**Technical Details:**

*   **State Management:** The app uses the `provider` package for state management, with `ChangeNotifier` to manage the state of different features.
*   **Navigation:** The app uses a combination of named routes and `onGenerateRoute` for navigation, with a `MainLayout` widget that includes a bottom navigation bar for easy access to the main features.
*   **Persistence:** The app uses `hive` for local storage of chat history.
*   **AI Integration:** The app uses the `google_generative_ai` package to interact with the Gemini AI model.
*   **Dependencies:** The app uses a number of open-source packages, including:
    *   `flutter_markdown` for rendering markdown in the chat.
    *   `url_launcher` for opening links in the browser.
    *   `intl` for date formatting.
    *   `iconsax` for modern icons.
    *   `timeline_tile` for creating the case timeline.
    *   `http` for making network requests to the news API.

**Fixes and Improvements in this session:**

*   Fixed a `deprecated_member_use` warning related to the `Share` class.
*   Fixed a `missing_required_param` warning in the `AIChatPage`.
*   Fixed several `use_build_context_synchronously` warnings by checking if the widget is still mounted before using the `BuildContext`.
*   Fixed `unnecessary_import` warnings by removing unused imports.
*   Fixed `deprecated_member_use` warnings related to `withOpacity` by replacing it with `withAlpha`.
*   Fixed an `invalid_assignment` warning by adding a missing type annotation.
*   Fixed an `unreachable_switch_case` warning by removing the `default` case from a switch statement on an enum.
