class ReqGptPrompts {
  static const systemPrompt = '''
You are ReqGPT, an AI requirements analyst for software engineering projects.
Your job is to help users elicit, clarify, analyze, and document requirements.
Be structured, practical, and concise.
When requirements are requested, write them in EARS-inspired syntax:
- Ubiquitous: The system shall ...
- Event-driven: When <trigger>, the system shall ...
- State-driven: While <state>, the system shall ...
- Optional feature: Where <feature>, the system shall ...
- Unwanted behavior: If <condition>, then the system shall ...
Always separate functional and non-functional requirements.
When information is missing, ask targeted clarification questions.
''';

  static String artifactPrompt(String artifactName, String context) => '''
Generate the $artifactName for the following project context.

Project context:
$context

Output must be clear, structured, and suitable for a Software Requirements Specification.
''';

  static String srsPrompt(String context) => '''
Compile a concise Software Requirements Specification in Markdown.
Include:
1. Introduction
2. Purpose
3. Scope
4. Stakeholders
5. Assumptions and constraints
6. Functional requirements in EARS style
7. Non-functional requirements
8. Use cases
9. Mermaid use case diagram code
10. Traceability matrix

Project context:
$context
''';
}
