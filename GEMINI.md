# Gemini CLI Project Instructions

## Feedback Loop & Knowledge Management Workflow
To ensure that all changes, discoveries, and architectural decisions are preserved and integrated into the project's living documentation, follow this workflow for every significant action taken in this app:

1. **Consult the Vault:** Before making architectural changes, always read the corresponding system design and PRD files in the Obsidian vault (e.g., `Projects/Dawer/System Design and PRD/`).
2. **Update the Gemini Feedback Folder:** After implementing changes, resolving conflicts, or making observations, document them in the `Projects/Dawer/Gemini feedback/` folder within the Obsidian vault.
3. **Artifact Maintenance:** 
   - Add new findings to `01 - Feedback Log.md`.
   - Update `02 - System Architecture Diagram.md` (Mermaid diagram) if the architecture changes.
   - Update `03 - System Design.md` if design principles or technical constraints evolve.
4. **Resolution Rule:** If user instructions conflict with existing design documents, prioritize the latest stakeholder input, resolve the conflict, and document the resolution in the Gemini feedback folder.