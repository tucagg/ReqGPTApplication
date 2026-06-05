# ReqGPT

AI-powered requirements engineering tool. Describe your project idea and get requirements, use cases, traceability matrix, and SRS document generated automatically.

🌐 **Live Demo:** [tucagg.github.io/ReqGPTApplication](https://tucagg.github.io/ReqGPTApplication/)

---

## Getting Started

ReqGPT runs entirely in your browser. No account or installation needed.

### 1. Get an OpenAI API Key
Go to [platform.openai.com/api-keys](https://platform.openai.com/api-keys) and create a new API key.

### 2. Enter Your Key in the App
Open the app → go to **Settings** → paste your API key (`sk-...`) → click **Save**.

Your key is stored only in your browser's local storage and is never sent anywhere other than OpenAI's API.

### 3. Start a Project
Go to the **Chat** tab, describe your project idea, and let ReqGPT guide you through the requirements elicitation process.

---

## Features

- **Chat-based elicitation** — AI asks clarifying questions to refine your project scope
- **Requirements generation** — Functional and non-functional requirements in EARS style
- **Use case generation** — Actors, flows, and Mermaid UML diagrams
- **Traceability matrix** — Maps user needs to requirements and artifacts
- **SRS compiler** — Full Software Requirements Specification in Markdown
- **Session history** — Multiple projects stored locally in your browser
- **Dark / light theme**

---

## Tech Stack

- Flutter Web
- Dart
- Provider
- OpenAI API (`gpt-4o-mini` by default)
- GitHub Actions + GitHub Pages for deployment

---

## Local Development

```bash
git clone https://github.com/tucagg/ReqGPTApplication.git
cd ReqGPTApplication
flutter pub get
flutter run -d chrome
```

No `.env` file needed — API key is entered through the Settings screen.

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

- Your API key is stored only in your browser's local storage.
- No data is sent to any server other than OpenAI's API.
- No analytics, no tracking.
