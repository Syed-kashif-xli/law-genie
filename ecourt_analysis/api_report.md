# e-Courts Mobile App API Analysis Report

The e-Courts Services India mobile app (v3.0+) is a Cordova-based application that communicates with a centralized PHP-based backend. All communication is encrypted using AES-128-CBC.

## 1. Network Configuration
- **Base URL**: `https://app.ecourts.gov.in/ecourt_mobile_DC/`
- **Main Endpoints**:
  - `appReleaseWebService.php`: Version check and JWT token initialization.
  - `stateWebService.php`: Fetches list of states.
  - `districtWebService.php`: Fetches districts for a state.
  - `courtEstWebService.php`: Fetches court complexes.
  - `listOfCasesWebService.php`: General case search.
  - `caseHistoryWebService.php`: Detailed case history by CNR or Case Number.
  - `filingCaseHistory.php`: Filing status details.

## 2. Security & Encryption
The app uses **AES-128-CBC** for both request parameters and response data.

### Encryption Details:
- **Key (Hex)**: `4D6251655468576D5A7134743677397A` (String: `MbQeThWmZq4t6w9z`)
- **Initialization Vector (IV)**:
  - Formed by `globalIv` + `randomIv`.
  - `globalIv` is chosen from a fixed array of 6 strings.
  - `randomIv` is 16 random characters.
- **Request Format**:
  - Parameters are JSON-stringified, encrypted, and prefixed with `randomIv` and the `globalIndex` (0-5).
- **Headers**:
  - Requires a `Bearer` token in the `Authorization` header.
  - The token itself is also encrypted before being sent.

## 3. Data Structures
### Case Status Search (by CNR)
- **Endpoint**: `listOfCasesWebService.php`
- **Parameters**:
  - `cino`: The CNR number.
  - `version_number`: App version (e.g., `3.0`).
  - `language_flag`: `english` or other.
  - `bilingual_flag`: `0` or `1`.

## 4. Proof of Concept (Manual Implementation)
One can implement this in Flutter or Python by replicating the `encryptData` and `decodeResponse` functions from `main.js`.

---
*Analysis performed by Antigravity AI.*
