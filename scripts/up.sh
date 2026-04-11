#!/bin/bash
set -e

docker run -d \
  --name patent-kit \
  -v "$(pwd):/workspaces/patent-kit" \
  -v "${HOME}/.config/gh:/home/user/.config/gh" \
  -e Z_AI_API_KEY="${Z_AI_API_KEY}" \
  -e CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1 \
  patent-kit:latest \
  sleep infinity
