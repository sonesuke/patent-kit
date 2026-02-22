param (
    [string]$InputPath = "1-targeting/csv",
    [string]$OutputPath = "1-targeting/target.jsonl"
)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$MergePy = Join-Path $ScriptDir "..\merge.py"

python3 $MergePy $InputPath $OutputPath
