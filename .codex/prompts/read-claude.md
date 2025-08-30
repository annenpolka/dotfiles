# Reusable Prompt: Read CLAUDE.md and .claude/ First

Use this at the start of any task in this repository.

## Paste‑Ready Prompt

```
Before doing anything in this repository, first read the root "CLAUDE.md" and every file under the ".claude/" directory (including subdirectories). Treat these documents as the highest‑priority governing rules for all decisions, outputs, plans, code changes, tests, and commits. After reading, produce a 3‑bullet summary of the most important constraints and procedures, ask clarifying questions for any ambiguity or conflicts, and proceed only after alignment. Re‑read them if they change. If the documents are missing or inconsistent, pause and confirm with the user before continuing.
```

## Detailed Guidance

- Read Order: `CLAUDE.md` → all files under `.claude/` (including subfolders).
- Priority: Treat these as the top‑priority rules; only an explicit override may supersede them.
- Summarize: Share three concise bullets capturing key rules, prohibitions, and workflow.
- Clarify: Ask questions if anything is unclear, conflicting, or missing before proceeding.
- Apply: Reflect the rules in your plan, test design, implementation, messages, and commits.
- Monitor: Re‑read during the session if those documents are updated.
- Safeguard: If files are absent or inconsistencies are detected, pause work and ask the user.
- Location: Both paths are expected at the repository root.
