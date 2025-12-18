# Android Team Weekly Meeting Reports

This repository contains weekly status updates for the Android Team Weekly Meeting. Each report documents work completed, upcoming plans, challenges, and optional personal updates.

## 📋 Meeting Schedule

- **Default**: Thursday (1 day before Friday end-of-week)
- **Dynamic**: Adjusts for holidays (e.g., if Friday is holiday → meeting moves to Wednesday)
- **Report Scope**: Previous meeting date → Current meeting date

## 🚀 Quick Start (New Machine Setup)

### 1. Clone Repository
```bash
git clone <your-gitlab-repo-url>
cd android-team-weekly-meeting
```

### 2. Set Up GitLab MCP Server

#### Get Your GitLab Personal Access Token
1. Go to: https://gitlab.com/-/user_settings/personal_access_tokens
2. Click **"Add new token"**
3. Name: `Weekly Meeting Reports MCP`
4. Scopes: Check `api` (full API access)
5. Expiration: Set to your preference
6. Click **Create personal access token**
7. **Copy the token** (you won't see it again!)

#### Configure Environment
```bash
# Copy environment template
cp .env.example .env

# Edit .env and add your GitLab token
nano .env
```

Update `.env` with:
```bash
GITLAB_TOKEN=glpat-your-actual-token-here
GITLAB_API_URL=https://gitlab.com/api/v4
GITLAB_USERNAME=your-gitlab-username
GITLAB_PROJECT_IDS=12345678,87654321  # Your project IDs
```

#### Set Up MCP Configuration (OpenCode)
```bash
# Copy MCP config template
cp .mcp/config.example.json .mcp/config.json
```

The MCP server is now ready! OpenCode will automatically detect `.mcp/config.json`.

### 3. Test Installation

```bash
# Test if MCP server works
npx -y @zereight/mcp-gitlab --help
```

If successful, you'll see the GitLab MCP help information.

## 📝 Creating Weekly Reports

### Using AI Agent (Recommended)

Ask your AI agent (OpenCode, Cursor, etc.):

```
"Fetch my GitLab commits from [start-date] to [end-date] and create this week's meeting report"
```

Example:
```
"Fetch my GitLab commits from Oct 31 to Nov 6 and create this week's meeting report"
```

The agent will:
1. Use bash script or GitLab MCP to fetch your commits
2. Group them by repository and type
3. Generate report using the template
4. Save to `weekly-reports/2025/YYYY-MM-DD-meeting.md`

### Using Bash Script (Manual)

You can also manually fetch commits and create reports:

```bash
# Fetch commits for a date range
./scripts/fetch-commits.sh "2025-11-01" "2025-11-28"

# View commits grouped by project
jq 'group_by(.project_name) | map({project: .[0].project_name, count: length, commits: map(.title)})' \
  scripts/output/commits-2025-11-01-to-2025-11-28.json
```

The script:
- Reads credentials from `.env` file
- Fetches commits from all projects in `GITLAB_PROJECT_IDS`
- Filters by `GITLAB_USERNAME` and date range
- Outputs to `scripts/output/commits-YYYY-MM-DD-to-YYYY-MM-DD.json`
- Automatically handles API URL formatting (adds `/api/v4` if missing)

### Manual Creation

1. Copy the template:
   ```bash
   cp templates/weekly-template.md weekly-reports/2025/2025-11-06-meeting.md
   ```

2. Fill in your work manually

3. Commit the report:
   ```bash
   git add weekly-reports/2025/2025-11-06-meeting.md
   git commit -m "Add weekly report for Nov 6, 2025"
   git push
   ```

## 📂 Repository Structure

```
/
├── .mcp/
│   ├── config.example.json       # MCP config template (committed)
│   └── config.json                # Your MCP config (gitignored)
├── scripts/
│   ├── fetch-commits.sh           # Bash script to fetch GitLab commits
│   └── output/                    # JSON output from fetch script
├── .env.example                   # Environment variables template
├── .gitignore                     # Git ignore rules
├── AGENTS.md                      # Instructions for AI agents
├── README.md                      # This file (for humans)
├── weekly-reports/
│   └── 2025/
│       ├── 2025-11-06-meeting.md
│       └── 2025-11-13-meeting.md
└── templates/
    └── weekly-template.md         # Report template
```

## 🔒 Security Notes

- **Never commit** `.mcp/config.json` or `.env` (they contain your GitLab token)
- These files are in `.gitignore` to prevent accidental commits
- Each machine you work on needs its own `.env` setup

## 🆘 Troubleshooting

### MCP Server Not Found
```bash
# Install MCP server globally (optional)
npm install -g @zereight/mcp-gitlab
```

### Token Issues
- Make sure your token has `api` scope
- Check token hasn't expired
- Verify `.env` file has correct token

### OpenCode Not Detecting MCP
- Ensure `.mcp/config.json` exists (copy from `.mcp/config.example.json`)
- Restart OpenCode/your IDE
- Check OpenCode MCP settings

## 📖 More Information

For detailed AI agent instructions, see [AGENTS.md](./AGENTS.md).
