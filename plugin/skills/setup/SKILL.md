---
name: setup
description: "特許分析に必要なディレクトリ構造（0-specifications など）を初期セットアップする。ユーザーが「プロジェクトの初期化をして」「フォルダを作って」と求めた場合に使用。"
metadata:
  author: sonesuke
  version: 1.0.0
---

# Patent Kit Setup

Your task is to prepare the working directory for a new patent analysis project.

## Instructions

Run the following commands to create the necessary directories.
These directories are ignored by git (via `.gitignore`) or tracked via `.gitkeep`, and are required to store outputs during the analysis process.

### Step 1: Create Directories

Execute the appropriate command based on the user's Operating System:

- **For Linux / Mac (Bash/Zsh)**:

  ```bash
  mkdir -p 0-specifications \
           1-targeting/csv \
           1-targeting/json \
           2-screening/json \
           3-investigations
  ```

- **For Windows (PowerShell)**:
  ```powershell
  New-Item -ItemType Directory -Force -Path "0-specifications", "1-targeting\csv", "1-targeting\json", "2-screening\json", "3-investigations"
  ```

### Step 2: Confirmation

Verify that the directories have been created successfully.
Once created, inform the user that the workspace is ready and they can proceed to Phase 0 (Concept Interview) or Phase 1 (Targeting).

# Examples

Example 1: プロジェクトの初期化
User says: "新しい調査のためにフォルダをセットアップして"
Actions:

1. OSの環境（Mac/Windows）を判別
2. mkdir（またはNew-Item）を使用して必須ディレクトリを一括作成
   Result: 0-specifications などの必須フォルダ構造が準備される

# Troubleshooting

Error: "Permission denied / Directory already exists"
Cause: すでにフォルダが存在するか、アクセス権限がない
Solution: -p フラグまたは -Force オプションが使われているため通常は失敗しません。環境の書き込み権限を確認してください
