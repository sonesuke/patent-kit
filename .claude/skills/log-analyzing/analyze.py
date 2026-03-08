#!/usr/bin/env python3
"""
Performance Analyzer for skill-bench test logs.

Extracts timeline information from skill-bench log files to identify
bottlenecks and optimization opportunities.
"""

import json
import sys
from pathlib import Path
from typing import List, Tuple


def analyze_log(log_file: str) -> Tuple[List[Tuple[float, str, str]], float]:
    """
    Analyze a skill-bench log file and extract timeline entries.

    Args:
        log_file: Path to the skill-bench log file

    Returns:
        Tuple of (entries, total_time) where:
        - entries: List of (elapsed_time, role, content) tuples
        - total_time: Total execution time in seconds
    """
    entries = []
    tool_uses = {}  # tool_use_id -> (elapsed, name, input_data)

    with open(log_file, 'r') as f:
        first_ts = None

        for line in f:
            try:
                entry = json.loads(line)

                # Get timestamp
                if 'timestamp' not in entry:
                    continue

                if first_ts is None:
                    first_ts = entry['timestamp']

                elapsed = entry['timestamp'] - first_ts

                # Only process message entries
                if 'message' not in entry:
                    continue

                msg = entry['message']
                role = msg.get('role', '')
                content_list = msg.get('content', [])

                for item in content_list:
                    if not isinstance(item, dict):
                        continue

                    item_type = item.get('type', '')

                    # Text content
                    if item_type == 'text':
                        text = item.get('text', '').replace('\n', ' ').strip()
                        if text and not text.startswith('<thinking>'):
                            # Truncate long text
                            text = text[:70]
                            entries.append((elapsed, role, text))

                    # Tool use
                    elif item_type == 'tool_use':
                        tool_id = item.get('id', '')
                        name = item.get('name', '')
                        input_data = item.get('input', {})

                        # Store for later pairing with result
                        tool_uses[tool_id] = (elapsed, name, input_data)

                    # Tool result
                    elif item_type == 'tool_result':
                        tool_use_id = item.get('tool_use_id', '')
                        is_error = item.get('is_error', False)
                        result_content = item.get('content', '')

                        # Get the corresponding tool use
                        if tool_use_id in tool_uses:
                            tool_elapsed, name, input_data = tool_uses[tool_use_id]

                            # Create tool summary with result
                            tool_summary = summarize_tool_with_result(
                                name, input_data, result_content, is_error
                            )
                            entries.append((tool_elapsed, 'TOOL', tool_summary))

                            # Remove from pending
                            del tool_uses[tool_use_id]

            except json.JSONDecodeError:
                continue
            except Exception as e:
                print(f"Error processing line: {e}", file=sys.stderr)

    # Add any unpaired tool uses (no result yet)
    for tool_id, (elapsed, name, input_data) in tool_uses.items():
        tool_summary = summarize_tool_with_result(name, input_data, '', False)
        entries.append((elapsed, 'TOOL', tool_summary))

    # Sort by elapsed time
    entries.sort(key=lambda x: x[0])

    # Calculate total time
    total_time = entries[-1][0] if entries else 0.0

    return entries, total_time


def summarize_tool(name: str, input_data: dict) -> str:
    """Summarize a tool use with its input parameters."""
    if not name:
        return ''

    # Extract relevant input parameters
    summary_parts = [name]

    if 'file_path' in input_data:
        file_path = input_data['file_path']
        # Extract just the filename or key part
        if 'references/instructions/' in file_path:
            file_name = file_path.split('references/instructions/')[1]
        elif 'cases/' in file_path:
            file_name = file_path.split('cases/')[1]
        else:
            file_name = file_path.split('/')[-1]
        summary_parts.append(f"file={file_name}")

    elif 'pattern' in input_data:
        summary_parts.append(f"pattern={input_data['pattern']}")

    elif 'command' in input_data:
        cmd = input_data['command']
        # Truncate long commands
        if cmd.startswith('sqlite3'):
            cmd = 'sqlite3 ...'
        elif cmd.startswith('head'):
            cmd = 'head ...'
        elif cmd.startswith('find'):
            cmd = 'find ...'
        elif len(cmd) > 40:
            cmd = cmd[:40] + '...'
        summary_parts.append(f"cmd={cmd}")

    return ' | '.join(summary_parts)


def summarize_tool_with_result(name: str, input_data: dict, result: str, is_error: bool) -> str:
    """Summarize a tool use with its input parameters and result."""
    if not name:
        return ''

    # Extract relevant input parameters
    summary_parts = [name]

    if 'file_path' in input_data:
        file_path = input_data['file_path']
        # Extract just the filename or key part
        if 'references/instructions/' in file_path:
            file_name = file_path.split('references/instructions/')[1]
        elif 'cases/' in file_path:
            file_name = file_path.split('cases/')[1]
        else:
            file_name = file_path.split('/')[-1]
        summary_parts.append(f"file={file_name}")

    elif 'pattern' in input_data:
        summary_parts.append(f"pattern={input_data['pattern']}")

    elif 'command' in input_data:
        cmd = input_data['command']
        # Truncate long commands
        if cmd.startswith('sqlite3'):
            # Extract key info from sqlite3 commands
            if '.tables' in cmd:
                cmd = 'sqlite3 .tables'
            elif 'SELECT COUNT' in cmd:
                cmd = 'sqlite3 SELECT COUNT'
            elif '.import' in cmd:
                cmd = 'sqlite3 .import'
            elif 'CREATE TABLE' in cmd:
                cmd = 'sqlite3 CREATE TABLE'
            elif 'INSERT INTO' in cmd:
                cmd = 'sqlite3 INSERT'
            elif cmd.startswith('head'):
                cmd = 'head ...'
            elif cmd.startswith('find'):
                cmd = 'find ...'
            elif len(cmd) > 50:
                cmd = cmd[:50] + '...'
        summary_parts.append(f"cmd={cmd}")

    elif 'skill' in input_data:
        summary_parts.append(f"skill={input_data['skill']}")

    # Add result status
    if is_error:
        summary_parts.append("❌ ERROR")
    elif result:
        # Try to extract useful info from result
        if isinstance(result, str):
            result = result.strip()
            if result and len(result) < 100:
                # For short results, show a preview
                preview = result.replace('\n', ' ')[:50]
                summary_parts.append(f"✅ {preview}")
            else:
                summary_parts.append("✅")
        else:
            summary_parts.append("✅")
    else:
        summary_parts.append("⏳")

    return ' | '.join(summary_parts)


def format_timeline(entries: List[Tuple[float, str, str]]) -> str:
    """Format entries as a timeline."""
    lines = []
    lines.append("=" * 100)

    for elapsed, role, content in entries:
        # Format with fixed width columns
        time_str = f"T+{elapsed:7.2f}s"
        role_str = f"{role:10s}"

        # Truncate long content
        if len(content) > 70:
            content = content[:67] + "..."

        line = f"{time_str} | {role_str} | {content}"
        lines.append(line)

    lines.append("=" * 100)
    return '\n'.join(lines)


def identify_bottlenecks(entries: List[Tuple[float, str, str]]) -> List[str]:
    """Identify potential bottlenecks in the execution timeline."""
    bottlenecks = []

    # Look for patterns
    glob_ops = []
    long_gaps = []
    slow_reads = []
    failed_ops = []

    prev_time = 0

    for elapsed, role, content in entries:
        # Check for glob/find operations
        if role == 'TOOL' and ('Glob' in content or 'find' in content):
            glob_ops.append((elapsed, content))

        # Check for slow Read operations (> 2 seconds)
        if role == 'TOOL' and 'Read' in content:
            # Check if this read took a long time (compare with next operation)
            slow_reads.append((elapsed, content))

        # Check for failed operations
        if role == 'TOOL' and '❌ ERROR' in content:
            failed_ops.append((elapsed, content))

        # Check for time gaps > 5 seconds
        if elapsed - prev_time > 5.0:
            long_gaps.append((prev_time, elapsed, elapsed - prev_time))

        prev_time = elapsed

    # Generate bottleneck report
    if failed_ops:
        bottlenecks.append(f"❌ Found {len(failed_ops)} failed operations")
        for t, content in failed_ops[:3]:
            bottlenecks.append(f"    T+{t:.2f}s: {content}")

    if glob_ops:
        bottlenecks.append(f"⚠️  Found {len(glob_ops)} file search operations (Glob/find)")
        for t, content in glob_ops[:3]:
            bottlenecks.append(f"    T+{t:.2f}s: {content}")

    if long_gaps:
        bottlenecks.append(f"⚠️  Found {len(long_gaps)} gaps > 5 seconds (possible AI thinking time)")
        for start, end, duration in long_gaps[:3]:
            bottlenecks.append(f"    T+{start:.2f}s to T+{end:.2f}s: {duration:.2f}s")

    if not bottlenecks:
        bottlenecks.append("✅ No obvious bottlenecks identified")

    return bottlenecks


def main():
    if len(sys.argv) < 2:
        print("Usage: python analyze.py <log_file>")
        sys.exit(1)

    log_file = sys.argv[1]

    if not Path(log_file).exists():
        print(f"Error: Log file not found: {log_file}")
        sys.exit(1)

    print(f"Analyzing: {log_file}")
    print()

    entries, total_time = analyze_log(log_file)

    print(f"Total execution time: {total_time:.2f}s")
    print()

    print("Timeline:")
    print(format_timeline(entries))
    print()

    print("Bottlenecks:")
    for bottleneck in identify_bottlenecks(entries):
        print(bottleneck)


if __name__ == '__main__':
    main()
