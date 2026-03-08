#!/bin/bash
# Generic database setup script
# Usage:
#   setup-db.sh init                    - Initialize database
#   setup-db.sh execute <file.sql>       - Execute SQL file

set -e

COMMAND="${1:-}"
shift || true

case "$COMMAND" in
    init)
        # Check if database already exists
        if [ -f patents.db ]; then
            echo "Database already exists, skipping init"
            exit 0
        fi

        # Find initialize-database.sql
        # Try multiple possible locations since we might be run from different directories
        SQL_FILE=""

        # Check if we're in workspace (has claude-plugin directory)
        if [ -d "./claude-plugin" ]; then
            SQL_FILE="./claude-plugin/skills/investigation-preparing/references/sql/initialize-database.sql"
        fi

        # Fallback to script-relative path
        if [ -z "$SQL_FILE" ] || [ ! -f "$SQL_FILE" ]; then
            SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
            SQL_FILE="$SCRIPT_DIR/../../plugin/skills/investigation-preparing/references/sql/initialize-database.sql"
        fi

        if [ -z "$SQL_FILE" ] || [ ! -f "$SQL_FILE" ]; then
            echo "Error: initialize-database.sql not found"
            exit 1
        fi

        # Initialize database
        sqlite3 patents.db < "$SQL_FILE"
        echo "Database initialized"
        ;;

    execute)
        SQL_FILE="$1"

        if [ -z "$SQL_FILE" ]; then
            echo "Error: SQL file not specified"
            echo "Usage: setup-db.sh execute <file.sql>"
            exit 1
        fi

        if [ ! -f "$SQL_FILE" ]; then
            echo "Error: SQL file not found: $SQL_FILE"
            exit 1
        fi

        # Execute SQL file
        sqlite3 patents.db < "$SQL_FILE"
        echo "SQL file executed: $SQL_FILE"
        ;;

    *)
        echo "Error: Unknown command '$COMMAND'"
        echo "Usage:"
        echo "  setup-db.sh init                    - Initialize database"
        echo "  setup-db.sh execute <file.sql>       - Execute SQL file"
        exit 1
        ;;
esac
