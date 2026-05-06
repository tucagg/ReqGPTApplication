# ReqGPT Flutter

ReqGPT is a Flutter mobile prototype for AI-augmented requirements elicitation and analysis. It helps a user start from a project idea, ask clarifying questions, and generate structured software requirements artifacts.

## Core Features

- Chat-style requirements elicitation
- GPT API integration through OpenAI Chat Completions
- Requirements generation in EARS style
- Functional and non-functional requirement separation
- Use case scenario and Mermaid diagram text generation
- Traceability matrix draft generation
- SRS markdown compilation
- Local in-memory prototype state

## Requirement Analysis Summary

### Problem
Requirements elicitation depends heavily on communication with domain experts. When domain expertise is limited or inconsistent, requirements become ambiguous, incomplete, and hard to validate.

### Proposed Solution
ReqGPT acts as an AI-assisted analyst. It asks structured clarification questions, refines scope, and generates standardized requirements artifacts.

### Target Users
- Software analysts
- Students learning requirements engineering
- Product owners
- Early-stage startup teams

### Main Modules

1. **Project Intake**
   - User enters initial idea or problem statement.
   - AI identifies domain, stakeholders, goals, assumptions, and missing details.

2. **Iterative Elicitation Chat**
   - AI asks clarification questions.
   - User answers progressively.
   - App stores the evolving context.

3. **Requirements Generator**
   - Generates functional requirements.
   - Generates non-functional requirements.
   - Uses EARS-inspired sentence patterns.

4. **Use Case Generator**
   - Produces actors, goals, preconditions, main flow, alternative flow, and postconditions.
   - Produces Mermaid UML text.

5. **Traceability Matrix**
   - Maps user needs to generated requirements and artifacts.

6. **SRS Compiler**
   - Compiles overview, scope, requirements, use cases, assumptions, constraints, and traceability into markdown.

## Tech Stack

- Flutter
- Dart
- Provider
- OpenAI API via `http`
- `flutter_dotenv` for API key loading

## Setup

```bash
flutter pub get
cp .env.example .env
```

Edit `.env`:

```env
OPENAI_API_KEY=sk-your-api-key-here
OPENAI_MODEL=gpt-4o-mini
```

Run:

```bash
flutter run
```

## Important Security Note

This prototype calls OpenAI directly from the mobile app for demo purposes. For production, route API calls through your own backend so API keys are never shipped inside the mobile app.

## Suggested 10-Week Development Plan

| Week | Work |
|---|---|
| 1 | Finalize requirements, user stories, scope |
| 2 | Flutter project setup and UI wireframes |
| 3 | Chat screen and session state |
| 4 | GPT API integration |
| 5 | EARS requirements generator |
| 6 | Use case and Mermaid generator |
| 7 | Traceability matrix and SRS compiler |
| 8 | Export/share SRS markdown |
| 9 | Testing, prompt refinement, UX improvements |
| 10 | Final demo, documentation, presentation |

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

## Production Improvements

- Backend proxy for GPT API
- Firebase/Supabase authentication
- Persistent database
- PDF/DOCX export
- Mermaid preview renderer
- Mockup image generation through backend
- Role-based project collaboration
