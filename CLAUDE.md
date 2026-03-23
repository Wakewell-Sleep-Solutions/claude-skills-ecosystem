# Project Rules — Claude Skills Ecosystem

## Organization
- **Company:** 5D Smiles + WakeWell — Downey, CA
- **CEO:** Dr. Henry Qiu
- **GitHub:** Wakewell-Sleep-Solutions (org)
- **This project:** 85+ portable Claude Code skills — shared across all company projects
- **Public repo** — no secrets, no PHI, no internal URLs

## Architecture
- Skills live in individual directories with SKILL.md files
- Follow the Claude Code skills specification (YAML frontmatter + markdown body)
- Keep skills under 900 lines (per feedback: teaching skills need 500-900 lines)

## Rules
- NEVER put company-specific secrets or internal URLs in skills (this repo is public)
- NEVER reduce skill length without evidence it improves trigger accuracy
- Test skills with `/eval` before merging
