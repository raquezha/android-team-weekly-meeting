# AGENTS.md

You are the best agent it world.
 
don't include commits that are reverted' 

## Project Overview

This repository contains **weekly status updates** for the Android Team Weekly Meeting. Each report documents work completed, upcoming plans, challenges, and optional personal updates for the reporting period.

**Purpose**: Track weekly progress, share accomplishments with the Android team, and maintain a historical record of contributions.

**Audience**: Internal Android team only (not public)

**Meeting Schedule**: 
- **Default**: Thursday (1 day before Friday end-of-week)
- **Dynamic**: Adjusts for holidays (e.g., if Friday is a holiday → meeting moves to Wednesday)
- **Report Scope**: Previous meeting date → Current meeting date (rolling 7-day period)

---

## Project Structure

```
/
├── AGENTS.md                          # This file - instructions for AI agents
├── README.md                          # Human-readable project description
├── .mcp/
│   ├── config.example.json           # MCP config template (committed)
│   └── config.json                    # Actual MCP config (gitignored)
├── .env.example                       # Environment template (committed)
├── .env                               # Actual environment vars (gitignored)
├── .gitignore                         # Protect sensitive files
├── weekly-reports/
│   └── 2025/
│       ├── 2025-11-06-meeting.md     # Report presented on Nov 6, 2025
│       ├── 2025-11-13-meeting.md     # Report presented on Nov 13, 2025
│       └── ...
└── templates/
    └── weekly-template.md             # Standard report template
```

**File Naming Convention**: `YYYY-MM-DD-meeting.md` where the date is the **meeting presentation date**.

---

## GitLab MCP Setup

This project uses **GitLab MCP Server** to fetch commit history from GitLab repositories.

### MCP Configuration

**Location**: `.mcp/config.json` (gitignored, created from `.mcp/config.example.json`)

The MCP server is configured to:
- Fetch commits from GitLab repositories
- Read-only mode: `false` (we only read commits, but might need write access for other operations)
- Uses personal access token from environment variable

### Environment Variables

**Location**: `.env` (gitignored, created from `.env.example`)

Required variables:
```bash
GITLAB_TOKEN=glpat-xxxxxxxxxxxxxxxxxxxx    # Your GitLab personal access token
GITLAB_API_URL=https://gitlab.com/api/v4   # GitLab API endpoint
GITLAB_USERNAME=your-username               # Your GitLab username
GITLAB_PROJECT_IDS=12345,67890             # Comma-separated project IDs to monitor
```

### Getting GitLab Personal Access Token

1. Go to: https://gitlab.com/-/user_settings/personal_access_tokens
2. Click **"Add new token"**
3. Name: `Weekly Meeting Reports MCP`
4. Scopes: Check `api` (full API access)
5. Set expiration date
6. Click **Create personal access token**
7. Copy the token and add to `.env` file

### Available MCP Tools

The GitLab MCP server provides these tools (relevant for this project):

- `list_commits` - List repository commits with filtering options
- `get_commit` - Get details of a specific commit
- `get_commit_diff` - Get changes/diffs of a specific commit
- `list_events` - List all events for the authenticated user
- `get_project_events` - List all visible events for a project

---

## Report Template Structure

Each weekly status update follows this format:

```markdown
# Weekly Status Update - [Month Day, Year]

**📅 Report Period**: [Start Date] - [End Date], [Year]  
**🎯 Meeting Date**: [Meeting Date] ([Day of Week])

---

## ✅ Completed Tasks

### Repository: [repo-name]

1. **[type]**: [Task description]  
   [short-hash](full-gitlab-url)

2. **[type]**: [Task description]  
   [short-hash](full-gitlab-url)

### Other Work

- [Non-commit work: meetings, planning, reviews, etc.]

**Total commits this period**: [number]

---

## 📋 Upcoming Plans

- [ ] [Planned task 1]
- [ ] [Planned task 2]

---

## 🚧 Challenges and Roadblocks

### ✅ Resolved This Period
- **Challenge**: [Description]  
  **Solution**: [How it was resolved]

### ⚠️ Current Blockers
- **Blocker**: [Description]  
  **Impact**: [What is blocked]  
  **ETA/Action**: [Expected resolution]

---

## 🎉 Personal

- [Optional personal update 1]
- [Optional personal update 2]

---

**Previous Report**: [YYYY-MM-DD-meeting.md](./YYYY-MM-DD-meeting.md) | **Next Meeting**: [Next Date]
```

**Conventional Commit Types** (for commit classification):
- `feat` - New features
- `fix` - Bug fixes
- `docs` - Documentation updates
- `refactor` - Code refactoring
- `test` - Test additions/updates
- `chore` - Maintenance tasks
- `perf` - Performance improvements

---

## Agent Workflow: Creating Weekly Reports

### Primary Command

```
"Create my weekly meeting report for [date]"
"Generate report for this Thursday's meeting"
"Fetch my GitLab commits from [start-date] to [end-date] and create this week's report"
```

Examples:
```
"Create my weekly meeting report for November 6, 2025"
"Fetch my GitLab commits from Oct 31 to Nov 6 and create this week's report"
```

### Step-by-Step Process

#### 1. Identify Meeting Date & Report Period

**Logic**:
- If user specifies date: Use that date
- If today is Thursday: Meeting is today (unless user says otherwise)
- If user mentions "holiday": Adjust to Wednesday

**Calculate Report Period**:
```
1. Find previous meeting report (most recent YYYY-MM-DD-meeting.md)
2. Previous meeting date = filename date
3. Report period = (previous_date + 1 day) to (current_meeting_date)

Example:
- Previous report: 2025-10-30-meeting.md
- Current meeting: 2025-11-06
- Report period: Oct 31, 2025 - Nov 6, 2025
```

**If no previous report exists**: Ask user for start date or default to 7 days ago.

#### 2. Read Configuration

**Read `.env` file** to get:
```bash
GITLAB_USERNAME=user-gitlab-username
GITLAB_PROJECT_IDS=12345,67890  # Projects to fetch from
```

#### 3. Fetch GitLab Commits via MCP

**Use GitLab MCP Tool**: `list_commits`

**Parameters**:
```json
{
  "projectId": "12345",  // Each project ID from GITLAB_PROJECT_IDS
  "since": "2025-10-31T00:00:00+08:00",  // Report period start
  "until": "2025-11-06T23:59:59+08:00",  // Report period end
  "author": "user-gitlab-username",       // From .env
  "per_page": 100
}
```

**Repeat for each project** listed in `GITLAB_PROJECT_IDS`.

#### 4. Group and Format Commits

**Grouping Strategy**:
1. **First**: Group by repository/project name
2. **Second**: Within each repo, group by conventional commit type (feat, fix, docs, etc.)
3. **Third**: Sort by date (newest first within each group)

**Repository Display Names**:
Use these friendly names instead of technical repo names:
- `tindahangtapat-delivery-app` → **Delivery App**
- `nueca-android-toolbox` → **Android Team Toolbox**
- `ci-component` → **CI Component**
- For unknown repos: Use the actual repo name as-is

**Extract from commit message**:
- Parse conventional commit format: `type(scope): description`
- If not conventional, classify as `chore` or `other`
- Extract commit hash and create GitLab link

**Format for "Completed Tasks"**:
```markdown
### Repository: android-app-main

1. **feat**: Implemented OAuth2 login flow  
   [abc1234](https://gitlab.com/group/android-app-main/-/commit/abc1234)

2. **fix**: Fixed crash on login timeout  
   [def5678](https://gitlab.com/group/android-app-main/-/commit/def5678)

### Repository: android-sdk

1. **refactor**: Simplified network error handling  
   [ghi9012](https://gitlab.com/group/android-sdk/-/commit/ghi9012)
```

**Include**:
- Commit count: `**Total commits this period**: 28`
- Full GitLab URLs for each commit
- Commit type prefix (feat, fix, docs, etc.)

#### 5. Carry Forward Previous "Upcoming Plans"

**Logic**:
1. Read previous report's "Upcoming Plans" section
2. Present to user: "These were last week's upcoming plans. Which were completed?"
3. Options:
   - Add completed items to current "Completed Tasks" → "Other Work" subsection
   - Add incomplete items as suggestions for current "Upcoming Plans"

**Example Interaction**:
```
Agent: "Last week you planned to 'Refactor login UI'. I don't see commits for this. Was it completed?"
User: "Yes, did it in pair programming with Jane"

Agent adds to "Other Work":
- Refactored login UI with Jane (pair programming)
```

#### 6. Prompt for Additional Information

**Questions to ask user**:

1. **Completed Tasks (non-commit work)**:
   - "Any work completed without commits? (meetings, code reviews, planning, documentation, etc.)"
   
2. **Upcoming Plans**:
   - "What are your plans for next week?"
   - Present last week's incomplete items as suggestions

3. **Challenges and Roadblocks**:
   - "Any challenges you resolved this period?"
   - "Any current blockers preventing progress?"
   - For resolved: "What was the solution? Any learnings?"
   - For blockers: "What's the impact? Expected resolution date?"

4. **Personal**:
   - "Any personal updates to share with the team? (Optional - skip if none)"

#### 7. Generate Report File

**File Creation**:
- **Filename**: `weekly-reports/2025/2025-11-06-meeting.md`
- **Content**: Fill template with:
  - Meeting date + report period
  - Completed tasks (grouped commits + other work)
  - Upcoming plans (user input + carried forward items)
  - Challenges (resolved vs current blockers)
  - Personal updates (if provided)
  - Links to previous/next reports

**Validation**:
- Ensure all GitLab links are valid full URLs
- Check report period doesn't overlap with existing reports
- Verify meeting date format is correct

#### 8. Review & Commit

**Present to user**:
```
"I've generated your weekly report for November 6, 2025 (covering Oct 31 - Nov 6).

Summary:
- 28 commits across 3 repositories
- 5 upcoming plans
- 1 resolved challenge, 2 current blockers
- Personal update included

Would you like to review before committing?"
```

**After user approval**:
```bash
git add weekly-reports/2025/2025-11-06-meeting.md
git commit -m "Add weekly report for Nov 6, 2025"
git push
```

---

## Git Workflow

### Branch Strategy
- **Main branch only**: All reports committed directly to `main`
- **No feature branches**: This is a documentation-only repo (low risk)

### Commit Message Format

**Simple, descriptive messages** (NO conventional commits overkill):

```bash
# Good commit messages
git commit -m "Add weekly report for Nov 6, 2025"
git commit -m "Update Nov 6 report - add missing blocker"
git commit -m "Archive 2024 reports"
git commit -m "Update GitLab project IDs in config"

# Bad commit messages
git commit -m "update"
git commit -m "wip"
git commit -m "fix"
```

### Commit Best Practices
- One report per commit
- Descriptive commit messages with context
- Push immediately after each report
- Never force-push to `main` (preserve history)

---

## Configuration Files

### `.mcp/config.json`

MCP server configuration (auto-reads from `.env`):

```json
{
  "mcpServers": {
    "gitlab": {
      "command": "npx",
      "args": ["-y", "@zereight/mcp-gitlab"],
      "env": {
        "GITLAB_PERSONAL_ACCESS_TOKEN": "${GITLAB_TOKEN}",
        "GITLAB_API_URL": "https://gitlab.com/api/v4",
        "GITLAB_READ_ONLY_MODE": "false",
        "USE_GITLAB_WIKI": "false",
        "USE_MILESTONE": "false",
        "USE_PIPELINE": "false"
      }
    }
  }
}
```

### `.env`

Environment variables for GitLab access:

```bash
GITLAB_TOKEN=glpat-xxxxxxxxxxxxxxxxxxxx
GITLAB_API_URL=https://gitlab.com/api/v4
GITLAB_USERNAME=your-username
GITLAB_PROJECT_IDS=12345,67890
```

**Agent Instructions**:
- Always read `.env` before fetching commits
- If file doesn't exist, prompt user to create it from `.env.example`
- Never commit `.env` or `.mcp/config.json` (they're gitignored)

---

## Security & Privacy Considerations

**Internal Team Only**: These reports are for internal Android team use.

**Safe to Include**:
- ✅ GitLab commit links (internal company GitLab)
- ✅ Internal project names and repository names
- ✅ Team member names
- ✅ Internal JIRA/ticket numbers
- ✅ Technical challenges and blockers

**Do NOT Include**:
- ❌ API keys, tokens, passwords (never commit `.env`)
- ❌ Customer-specific data or customer names
- ❌ Unreleased product features under NDA
- ❌ Confidential business metrics

**Default Privacy Stance**: When in doubt, include it (reports are internal-only).

---

## Common Agent Commands

### Primary Commands

```bash
# Create this week's report
"Create my weekly meeting report for November 6"
"Generate report for this Thursday's meeting"
"Fetch my GitLab commits and create this week's report"

# With specific date range
"Fetch my GitLab commits from Oct 31 to Nov 6 and create report"

# View/search past reports
"What did I work on last week?"
"Show my October reports"
"Find all reports mentioning 'OAuth'"

# Maintenance
"Archive 2023 reports"
"List all 2024 reports"
```

### Advanced Commands

```bash
# Backdate a report (if you missed a meeting)
"Create report for October 30 meeting covering Oct 23-30"

# Update existing report
"Add task to my Nov 6 report: Code review for PR #789"
"Mark blocker as resolved in Nov 6 report"

# Fetch specific repo commits
"Show all my commits to android-sdk repo last week"
```

---

## Tips for AI Agents

### Always Do This
- ✅ Read `.env` for GitLab username and project IDs before fetching
- ✅ Use GitLab MCP tools (`list_commits`) to fetch commit history
- ✅ Calculate report period from **previous meeting date**, not calendar week
- ✅ Group commits by repository FIRST, then by commit type
- ✅ Include full GitLab URLs for all commit links
- ✅ Differentiate "Resolved This Period" vs "Current Blockers"
- ✅ Carry forward incomplete tasks from previous "Upcoming Plans"
- ✅ Ask user about non-commit work (meetings, reviews, planning)
- ✅ Count total commits and include in report
- ✅ Use simple, descriptive commit messages (no conventional commits)

### Never Do This
- ❌ Assume 7-day period without checking previous meeting date
- ❌ Guess or fabricate commit data - always use MCP to fetch real commits
- ❌ Commit without user review and approval
- ❌ Skip linking commits to GitLab
- ❌ Ignore previous "Upcoming Plans"
- ❌ Use conventional commit format for repo commits (too formal for docs)
- ❌ Commit `.env` or `.mcp/config.json` files

### Edge Cases

**No previous report exists**:
- Ask user: "I don't see a previous report. What date range should I use? (Default: last 7 days)"

**Meeting date ambiguous**:
- Ask: "Is the meeting on Thursday Nov 6, or moved due to holiday?"

**No commits found**:
- Don't error - ask: "No commits found. Were you on vacation or working on non-commit tasks?"

**MCP not configured**:
- Check if `.mcp/config.json` exists
- Check if `.env` exists with `GITLAB_TOKEN`
- Prompt user to set up MCP if missing

**GitLab MCP error**:
- Check token validity (might be expired)
- Verify project IDs are correct
- Suggest user regenerate token if auth fails

---

## Multi-Machine Setup

This repo is designed to work across multiple machines (office, home, etc.).

### On Each New Machine:

1. **Clone repo**:
   ```bash
   git clone <your-gitlab-repo-url>
   cd android-team-weekly-meeting
   ```

2. **Set up environment**:
   ```bash
   cp .env.example .env
   nano .env  # Add your GitLab token
   ```

3. **Set up MCP config**:
   ```bash
   cp .mcp/config.example.json .mcp/config.json
   ```

4. **Test MCP**:
   ```bash
   npx -y @zereight/mcp-gitlab --help
   ```

**Note**: `.env` and `.mcp/config.json` are gitignored, so each machine needs its own setup.

---

## Troubleshooting

### Problem: MCP tools not available
**Solution**: 
- Check `.mcp/config.json` exists
- Restart IDE/OpenCode
- Verify `npx @zereight/mcp-gitlab` works in terminal

### Problem: GitLab authentication fails
**Solution**:
- Check `.env` file has valid `GITLAB_TOKEN`
- Verify token hasn't expired
- Check token has `api` scope
- Regenerate token if needed

### Problem: No commits returned
**Solution**:
- Verify `GITLAB_PROJECT_IDS` in `.env` are correct
- Check `GITLAB_USERNAME` matches your GitLab username
- Verify date range is correct
- Check you have access to the projects

### Problem: Report period calculation wrong
**Solution**:
- Check previous report filename date
- Verify report follows `YYYY-MM-DD-meeting.md` format
- If first report, agent should ask for date range

---

## Examples

### Example 1: Typical Weekly Report

**File**: `weekly-reports/2025/2025-11-06-meeting.md`

```markdown
# Weekly Status Update - November 6, 2025

**📅 Report Period**: October 31 - November 6, 2025  
**🎯 Meeting Date**: November 6, 2025 (Wednesday - Friday is holiday)

---

## ✅ Completed Tasks

### Repository: android-app-main

1. **feat**: Implemented OAuth2 login flow with Google Sign-In  
   [a3b4c5d](https://gitlab.com/mobile/android-app-main/-/commit/a3b4c5d)

2. **fix**: Fixed crash on login timeout for slow networks  
   [e6f7g8h](https://gitlab.com/mobile/android-app-main/-/commit/e6f7g8h)

3. **test**: Added unit tests for authentication repository  
   [i9j0k1l](https://gitlab.com/mobile/android-app-main/-/commit/i9j0k1l)

### Repository: android-sdk

1. **refactor**: Simplified network error handling with sealed classes  
   [m2n3o4p](https://gitlab.com/mobile/android-sdk/-/commit/m2n3o4p)

2. **docs**: Updated SDK integration guide for v2.0  
   [q5r6s7t](https://gitlab.com/mobile/android-sdk/-/commit/q5r6s7t)

### Other Work

- Conducted 7 code reviews for team members
- Attended architecture planning meeting for Q1 2026
- Pair programmed with Jane on Compose navigation refactoring

**Total commits this period**: 28

---

## 📋 Upcoming Plans

- [ ] Complete OAuth2 token refresh implementation
- [ ] Refactor login UI to match new design system
- [ ] Fix 3 high-priority bugs (#789, #790, #791)
- [ ] Write integration tests for auth flow

---

## 🚧 Challenges and Roadblocks

### ✅ Resolved This Period
- **Challenge**: OAuth token refresh causing UI freezes  
  **Solution**: Moved to background coroutine with lifecycle handling

### ⚠️ Current Blockers
- **Blocker**: Waiting for `/v2/auth/refresh` endpoint from backend  
  **Impact**: Cannot complete token refresh (blocks MFA)  
  **ETA**: Backend estimates Nov 10

---

## 🎉 Personal

- Celebrating 2 years at the company! 🎂
- Attended Kotlin Conf 2025 (virtual)

---

**Previous Report**: [2025-10-30-meeting.md](./2025-10-30-meeting.md) | **Next Meeting**: November 13, 2025
```

### Example 2: Light Week Report

**File**: `weekly-reports/2025/2025-12-25-meeting.md`

```markdown
# Weekly Status Update - December 25, 2025

**📅 Report Period**: December 19 - December 25, 2025  
**🎯 Meeting Date**: December 25, 2025 (Wednesday - short holiday week)

---

## ✅ Completed Tasks

### Repository: android-app-main

1. **fix**: Fixed critical crash on startup for Android 15  
   [u8v9w0x](https://gitlab.com/mobile/android-app-main/-/commit/u8v9w0x)

### Other Work

- Conducted 2 code reviews
- On vacation Dec 20-24

**Total commits this period**: 3

---

## 📋 Upcoming Plans

- [ ] Resume work on push notification system
- [ ] Review architecture proposal for new feature

---

## 🚧 Challenges and Roadblocks

None this period (short week).

---

## 🎉 Personal

- Happy Holidays! 🎄

---

**Previous Report**: [2025-12-18-meeting.md](./2025-12-18-meeting.md) | **Next Meeting**: January 1, 2026
```

---

## Changelog

**Version 1.0** - November 7, 2025
- Initial AGENTS.md creation
- GitLab MCP integration configured
- Meeting-date-based filename convention (YYYY-MM-DD-meeting.md)
- Simple commit message format (no conventional commits)
- Multi-machine support with gitignored config files

---

**Last Updated**: November 7, 2025
