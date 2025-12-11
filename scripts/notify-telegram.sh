#!/bin/bash
#
# notify-telegram.sh - Send a message to Telegram
#
# Usage:
#   ./scripts/notify-telegram.sh "Your message here"
#   echo "Your message" | ./scripts/notify-telegram.sh
#
# Requires .env file with:
#   TELEGRAM_BOT_TOKEN
#   TELEGRAM_CHAT_ID
#   TELEGRAM_TOPIC_ID (optional)
#

set -e

# Get script directory and project root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

# Load environment variables from .env
ENV_FILE="$PROJECT_ROOT/.env"
if [[ ! -f "$ENV_FILE" ]]; then
    echo "Error: .env file not found at $ENV_FILE" >&2
    exit 1
fi

# Source .env file (handle quotes and exports)
set -a
source "$ENV_FILE"
set +a

# Validate required environment variables
if [[ -z "$TELEGRAM_BOT_TOKEN" ]]; then
    echo "Error: TELEGRAM_BOT_TOKEN not set in .env" >&2
    exit 1
fi

if [[ -z "$TELEGRAM_CHAT_ID" ]]; then
    echo "Error: TELEGRAM_CHAT_ID not set in .env" >&2
    exit 1
fi

# Get message from argument or stdin
if [[ -n "$1" ]]; then
    MESSAGE="$1"
elif [[ ! -t 0 ]]; then
    MESSAGE=$(cat)
else
    echo "Error: No message provided" >&2
    echo "Usage: $0 \"message\" OR echo \"message\" | $0" >&2
    exit 1
fi

if [[ -z "$MESSAGE" ]]; then
    echo "Error: Message is empty" >&2
    exit 1
fi

# Build Telegram API URL
API_URL="https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage"

# Build request payload
PAYLOAD=$(jq -n \
    --arg chat_id "$TELEGRAM_CHAT_ID" \
    --arg text "$MESSAGE" \
    --arg parse_mode "Markdown" \
    '{
        chat_id: $chat_id,
        text: $text,
        parse_mode: $parse_mode,
        disable_web_page_preview: true
    }')

# Add message_thread_id if TELEGRAM_TOPIC_ID is set and not empty/zero
if [[ -n "$TELEGRAM_TOPIC_ID" && "$TELEGRAM_TOPIC_ID" != "0" ]]; then
    PAYLOAD=$(echo "$PAYLOAD" | jq --arg thread_id "$TELEGRAM_TOPIC_ID" '. + {message_thread_id: ($thread_id | tonumber)}')
fi

# Send the message
RESPONSE=$(curl -s -X POST "$API_URL" \
    -H "Content-Type: application/json" \
    -d "$PAYLOAD")

# Check if successful
OK=$(echo "$RESPONSE" | jq -r '.ok')

if [[ "$OK" == "true" ]]; then
    echo "Message sent successfully!"
    exit 0
else
    ERROR_DESC=$(echo "$RESPONSE" | jq -r '.description // "Unknown error"')
    echo "Error sending message: $ERROR_DESC" >&2
    exit 1
fi
