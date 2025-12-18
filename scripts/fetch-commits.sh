#!/bin/bash

# fetch-commits.sh
# Fetches GitLab commits for a given date range using the GitLab API
# Usage: ./scripts/fetch-commits.sh "2025-11-01" "2025-11-28"

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if .env file exists
if [ ! -f ".env" ]; then
    echo -e "${RED}Error: .env file not found!${NC}"
    echo "Please copy .env.example to .env and configure it with your GitLab credentials."
    exit 1
fi

# Load environment variables from .env
export $(grep -v '^#' .env | xargs)

# Validate required environment variables
if [ -z "$GITLAB_TOKEN" ] || [ -z "$GITLAB_API_URL" ] || [ -z "$GITLAB_USERNAME" ] || [ -z "$GITLAB_PROJECT_IDS" ]; then
    echo -e "${RED}Error: Missing required environment variables in .env${NC}"
    echo "Required variables: GITLAB_TOKEN, GITLAB_API_URL, GITLAB_USERNAME, GITLAB_PROJECT_IDS"
    exit 1
fi

# Ensure GITLAB_API_URL ends with /api/v4
if [[ ! "$GITLAB_API_URL" == */api/v4 ]]; then
    GITLAB_API_URL="${GITLAB_API_URL}/api/v4"
fi

# Parse command line arguments
START_DATE=${1:-$(date -v-7d +%Y-%m-%d)}
END_DATE=${2:-$(date +%Y-%m-%d)}

echo -e "${GREEN}Fetching GitLab commits...${NC}"
echo "Date range: $START_DATE to $END_DATE"
echo "Username: $GITLAB_USERNAME"
echo "Projects: $GITLAB_PROJECT_IDS"
echo ""

# Convert dates to ISO 8601 format with timezone
START_ISO="${START_DATE}T00:00:00+08:00"
END_ISO="${END_DATE}T23:59:59+08:00"

# Create output directory
OUTPUT_DIR="scripts/output"
mkdir -p "$OUTPUT_DIR"

# Output file
OUTPUT_FILE="$OUTPUT_DIR/commits-${START_DATE}-to-${END_DATE}.json"

# Temporary array to store all commits
ALL_COMMITS="[]"

# Split project IDs by comma and iterate
IFS=',' read -ra PROJECT_IDS <<< "$GITLAB_PROJECT_IDS"
for PROJECT_ID in "${PROJECT_IDS[@]}"; do
    PROJECT_ID=$(echo "$PROJECT_ID" | xargs) # Trim whitespace
    
    echo -e "${YELLOW}Fetching commits from project ID: $PROJECT_ID${NC}"
    
    # Fetch commits from GitLab API
    RESPONSE=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
        "${GITLAB_API_URL}/projects/${PROJECT_ID}/repository/commits?since=${START_ISO}&until=${END_ISO}&author=${GITLAB_USERNAME}&per_page=100")
    
    # Check if response is valid JSON
    if echo "$RESPONSE" | jq empty 2>/dev/null; then
        COMMIT_COUNT=$(echo "$RESPONSE" | jq 'length')
        echo "  Found $COMMIT_COUNT commits"
        
        if [ "$COMMIT_COUNT" -gt 0 ]; then
            # Get project details
            PROJECT_INFO=$(curl -s --header "PRIVATE-TOKEN: $GITLAB_TOKEN" \
                "${GITLAB_API_URL}/projects/${PROJECT_ID}")
            
            PROJECT_NAME=$(echo "$PROJECT_INFO" | jq -r '.name')
            PROJECT_PATH=$(echo "$PROJECT_INFO" | jq -r '.path_with_namespace')
            
            # Add project info to each commit
            COMMITS_WITH_PROJECT=$(echo "$RESPONSE" | jq --arg name "$PROJECT_NAME" --arg path "$PROJECT_PATH" --arg id "$PROJECT_ID" \
                'map(. + {project_name: $name, project_path: $path, project_id: $id})')
            
            # Merge with all commits
            ALL_COMMITS=$(echo "$ALL_COMMITS" | jq --argjson new "$COMMITS_WITH_PROJECT" '. + $new')
        fi
    else
        echo -e "${RED}  Error fetching commits: $RESPONSE${NC}"
    fi
done

# Write final JSON to file
echo "$ALL_COMMITS" > "$OUTPUT_FILE"

TOTAL_COMMITS=$(jq 'length' "$OUTPUT_FILE")

echo ""
echo -e "${GREEN}✓ Done! Fetched $TOTAL_COMMITS commits total${NC}"
echo "Output saved to: $OUTPUT_FILE"
echo ""
echo "To view commits grouped by project:"
echo "  jq 'group_by(.project_name) | map({project: .[0].project_name, count: length, commits: map(.title)})' $OUTPUT_FILE"
