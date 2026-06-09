# ReqGPT

AI-powered requirements engineering tool. Describe your project idea and get requirements, use cases, traceability matrix, and SRS document generated automatically.

Available on **Web**, **Android**, **iOS**, **macOS**, **Linux**, and **Windows**.

🌐 **Live Demo:** [tucagg.github.io/ReqGPTApplication](https://tucagg.github.io/ReqGPTApplication/)

---

## Getting Started

### Web
Open the live demo — no installation needed.

### Mobile & Desktop
Clone the repo and run on your target platform:

```bash
git clone https://github.com/tucagg/ReqGPTApplication.git
cd ReqGPTApplication
flutter pub get
flutter run                        # connected device / emulator
flutter run -d macos               # macOS
flutter run -d linux               # Linux
flutter run -d windows             # Windows
flutter run -d chrome              # Web (browser)
```

### API Key Setup
On first launch, open the **Settings** tab, paste your OpenAI API key (`sk-...`), and tap **Save**.

Your key is stored only on your device and is never sent anywhere other than OpenAI's API.

> Don't have a key? Get one at [platform.openai.com/api-keys](https://platform.openai.com/api-keys).

---

## Features

- **Chat-based elicitation** — AI asks clarifying questions to refine your project scope
- **Requirements generation** — Functional and non-functional requirements in EARS style
- **Use case generation** — Actors, flows, and Mermaid UML diagrams
- **Traceability matrix** — Maps user needs to requirements and artifacts
- **SRS compiler** — Full Software Requirements Specification in Markdown
- **Session history** — Multiple projects stored locally on your device
- **Dark / light / system theme**
- **Cross-platform** — Web, Android, iOS, macOS, Linux, Windows

---

## Tech Stack

- Flutter (Dart)
- Provider
- OpenAI API (`gpt-4o-mini` by default)
- GitHub Actions + GitHub Pages for web deployment

---

## Folder Structure

```text
lib/
  main.dart
  models/
  screens/
  services/
  utils/
  widgets/
```

---

## Privacy

- Your API key is stored only on your device (local storage / shared preferences).
- No data is sent to any server other than OpenAI's API.
- No analytics, no tracking.
