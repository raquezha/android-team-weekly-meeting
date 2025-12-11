---
description: Send weekly report to Telegram
---

Send the weekly report to Telegram.

## Steps

1. Find the latest report in `weekly-reports/2025/` (most recent by filename date)
2. Read `.env` to get `REPORT_AUTHOR` and Telegram credentials
3. Read the commits JSON from `scripts/output/` to get commit links
4. Convert the report to Telegram format:
   - Use `*text*` for bold headers
   - Use `_text_` for italic (footer)
   - Use bullet points (•)
   - Include emojis: ✅ Completed, 📋 Upcoming, 🚧 Blockers, 💬 Personal
   - Add clickable commit links: `([short_id](commit_url))`
   - Skip "Personal" section if empty or not present
5. **IMPORTANT**: Show the formatted message to user and ASK FOR CONFIRMATION before sending
6. Only after user confirms, run: `./scripts/notify-telegram.sh "message"`
7. Report success or failure to user

## Telegram Message Format

```
*[Author Name]* ([Date Range])

*Completed* ✅
• Task description ([abc1234](https://gitlab.example.com/...))
• Another task ([def5678](https://gitlab.example.com/...))

*Upcoming* 📋
• Upcoming task 1
• Upcoming task 2

*Blockers* 🚧
• Blocker description

*Personal* 💬
• Personal update

_sent via opencode_
```

## Commit Links

For completed items that came from commits:
- Read the commits JSON to get `short_id` and `web_url`
- Format: `• Task description ([short_id](web_url))`
- Group related commits and use the main commit's link
- Non-commit items (like "Code reviews") don't need links

## Notes

- Personal section is optional - only include if content exists
- Keep bullets brief (3-7 words each)
- The script reads Telegram credentials from `.env`
- The script disables link previews automatically
- If $ARGUMENTS is provided, use that as the report file path instead of finding the latest
- **Always include the footer**: `_sent via opencode_`
