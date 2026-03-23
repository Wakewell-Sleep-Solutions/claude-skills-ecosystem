#!/bin/bash
# Weekly CLAUDE.md Rule Consolidation Reminder
# Runs every Monday at 9am via launchd
# Sends macOS notification + Slack DM via Aria

# 1. Count rules added this week via @.claude (git log)
cd ~/Documents/Claude
NEW_RULES=$(git log --since="7 days ago" --all --oneline --grep="add rule from PR" 2>/dev/null | wc -l | tr -d ' ')

# 2. Count total lines in project CLAUDE.md
TOTAL_LINES=$(wc -l < CLAUDE.md 2>/dev/null | tr -d ' ')

# 3. macOS notification
osascript -e "display notification \"$NEW_RULES new rules this week. Project CLAUDE.md is $TOTAL_LINES lines. Review and promote universal rules to global.\" with title \"📋 Weekly Rule Review\" subtitle \"CLAUDE.md Consolidation\""

# 4. Slack DM via Aria webhook (uses existing Aria infrastructure)
# Only send if there are new rules to review
if [ "$NEW_RULES" -gt 0 ] 2>/dev/null; then
  curl -s -X POST "https://slack.com/api/chat.postMessage" \
    -H "Authorization: Bearer ${SLACK_BOT_TOKEN:-skip}" \
    -H "Content-Type: application/json" \
    -d "{
      \"channel\": \"${CEO_SLACK_USER_ID:-U07DZC2EG95}\",
      \"text\": \"📋 *Weekly Rule Review*\n\n$NEW_RULES new rules added via \`@.claude\` this week.\nProject CLAUDE.md is $TOTAL_LINES lines.\n\nReview: \`git log --since='7 days ago' --grep='add rule from PR' --oneline\`\n\nPromote universal rules → \`~/.claude/CLAUDE.md\`\nDelete project-specific duplicates.\nKeep project file under 80 lines.\"
    }" 2>/dev/null
fi

echo "[$(date)] Rule review reminder sent. New rules: $NEW_RULES, Total lines: $TOTAL_LINES"
