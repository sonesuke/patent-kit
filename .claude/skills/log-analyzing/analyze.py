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
    agent_tool_ids = set()  # Track Agent tool IDs
    agent_active = False  # Track if any agent is currently active
    agent_start_time = 0.0  # Track when agent started

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

                        # Track Agent tool launches
                        if name == 'Agent':
                            agent_tool_ids.add(tool_id)
                            agent_active = True
                            agent_start_time = elapsed

                        # Store for later pairing with result
                        tool_uses[tool_id] = (elapsed, name, input_data)

                    # Tool result
                    elif item_type == 'tool_result':
                        tool_use_id = item.get('tool_use_id', '')
                        is_error = item.get('is_error', False)
                        result_content = item.get('content', '')

                        # Check if this is an Agent tool completing
                        if tool_use_id in agent_tool_ids:
                            agent_active = False
                            agent_tool_ids.remove(tool_use_id)

                        # Get the corresponding tool use
                        if tool_use_id in tool_uses:
                            tool_elapsed, name, input_data = tool_uses[tool_use_id]

                            # Determine role: if agent was active when this tool was used, mark as SUBAGENT
                            tool_role = 'TOOL'
                            if agent_active and tool_elapsed > agent_start_time and tool_use_id not in agent_tool_ids:
                                # This tool was used while an agent was active (and it's not the agent launch itself)
                                tool_role = 'SUBAGENT'

                            # Create tool summary with result
                            tool_summary = summarize_tool_with_result(
                                name, input_data, result_content, is_error
                            )
                            entries.append((tool_elapsed, tool_role, tool_summary))

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

    # Special handling for Agent tool
    if name == 'Agent':
        return format_agent_tool(input_data, result, is_error)

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


def format_agent_tool(input_data: dict, result: str, is_error: bool) -> str:
    """Format Agent tool use with subagent information."""
    summary_parts = ['🤖 Agent']

    # Extract subagent info
    subagent_type = input_data.get('subagent_type', 'unknown')
    subagent_name = input_data.get('name', 'unnamed')
    description = input_data.get('description', '')
    prompt = input_data.get('prompt', '')

    summary_parts.append(f"type={subagent_type}")
    summary_parts.append(f"name={subagent_name}")

    if description and len(description) < 30:
        summary_parts.append(f"desc={description}")
    elif description:
        summary_parts.append(f"desc={description[:27]}...")

    # Show prompt preview (first task)
    if prompt:
        lines = prompt.strip().split('\n')
        for line in lines[:3]:  # Show first 3 lines
            line = line.strip()
            if line and not line.startswith('#'):
                # Extract key info
                if line.startswith(('1.', '2.', '3.', '4.', '-', '*')):
                    summary_parts.append(f"task={line[:50]}")
                    break

    # Add result status
    if is_error:
        summary_parts.append("❌ ERROR")
    elif result:
        # Try to extract useful summary from agent result
        if isinstance(result, str) and len(result) > 100:
            # Extract key patterns from agent result
            if 'Patent ID and title' in result:
                summary_parts.append("✅ Analysis complete")
            elif '## Summary' in result or 'Summary:' in result:
                # Extract summary line
                for line in result.split('\n'):
                    if 'summary' in line.lower() and len(line) < 100:
                        summary_parts.append(f"✅ {line.strip()[:50]}")
                        break
                else:
                    summary_parts.append("✅ Result received")
            else:
                # Show first line of result
                first_line = result.split('\n')[0].strip()
                if first_line and len(first_line) < 80:
                    summary_parts.append(f"✅ {first_line}")
                else:
                    summary_parts.append("✅ Result received")
        elif isinstance(result, str):
            result = result.strip()
            if result and len(result) < 100:
                summary_parts.append(f"✅ {result}")
            else:
                summary_parts.append("✅")
        else:
            summary_parts.append("✅")
    else:
        summary_parts.append("⏳ Running...")

    return ' | '.join(summary_parts)


def format_timeline(entries: List[Tuple[float, str, str]]) -> str:
    """Format entries as a timeline."""
    lines = []
    lines.append("=" * 100)

    for elapsed, role, content in entries:
        # Format with fixed width columns
        time_str = f"T+{elapsed:7.2f}s"
        role_str = f"{role:12s}"  # Increased width for SUBAGENT

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
    agent_ops = []
    subagent_ops = []

    prev_time = 0

    for elapsed, role, content in entries:
        # Check for Agent operations (parallel processing)
        if role == 'TOOL' and '🤖 Agent' in content:
            agent_ops.append((elapsed, content))

        # Check for Subagent operations
        if role == 'SUBAGENT':
            subagent_ops.append((elapsed, content))

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
    if subagent_ops:
        bottlenecks.append(f"🤖 Subagent Activity: {len(subagent_ops)} operations")
        # Group subagent operations by type
        op_types = {}
        for _, content in subagent_ops:
            op_name = content.split('|')[0].strip()
            op_types[op_name] = op_types.get(op_name, 0) + 1
        for op_type, count in sorted(op_types.items(), key=lambda x: -x[1]):
            bottlenecks.append(f"    {op_type}: {count} operation(s)")

    if agent_ops:
        bottlenecks.append(f"🤖 Found {len(agent_ops)} Agent tool uses (parallel processing)")
        # Check if multiple agents were launched in quick succession (< 1 second)
        if len(agent_ops) > 1:
            quick_launches = []
            for i in range(len(agent_ops) - 1):
                time_diff = agent_ops[i + 1][0] - agent_ops[i][0]
                if time_diff < 1.0:
                    quick_launches.append((agent_ops[i][0], agent_ops[i + 1][0], time_diff))
            if quick_launches:
                bottlenecks.append(f"    ✅ {len(quick_launches)} agents launched for parallel processing")
                for t1, t2, diff in quick_launches:
                    bottlenecks.append(f"       T+{t1:.2f}s and T+{t2:.2f}s (Δ{diff:.3f}s)")
        # Show first few agent launches
        for t, content in agent_ops[:2]:
            bottlenecks.append(f"    T+{t:.2f}s: {content[:80]}...")

    if failed_ops:
        bottlenecks.append(f"❌ Found {len(failed_ops)} failed operations")
        for t, content in failed_ops[:3]:
            bottlenecks.append(f"    T+{t:.2f}s: {content}")

    if glob_ops:
        bottlenecks.append(f"⚠️  Found {len(glob_ops)} file search operations (Glob/find)")
        for t, content in glob_ops[:3]:
            bottlenecks.append(f"    T+{t:.2f}s: {content}")

    if long_gaps:
        bottlenecks.append(f"⚠️  Found {len(long_gaps)} gaps > 5 seconds (possible AI thinking or subagent execution)")
        for start, end, duration in long_gaps[:5]:
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

    # Count Agent and Subagent operations
    agent_count = sum(1 for _, role, content in entries if role == 'TOOL' and '🤖 Agent' in content)
    subagent_count = sum(1 for _, role, _ in entries if role == 'SUBAGENT')

    if agent_count > 0:
        print(f"🤖 Parallel Processing: {agent_count} subagent(s) launched")
        print(f"📊 Subagent Activity: {subagent_count} operations executed by subagents")
        print()

    print("Timeline:")
    print(format_timeline(entries))
    print()

    print("Bottlenecks:")
    for bottleneck in identify_bottlenecks(entries):
        print(bottleneck)


if __name__ == '__main__':
    main()
