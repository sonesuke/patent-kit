#!/usr/bin/env python3
"""
parse-toml.py - Parse TOML test case files

Usage:
    parse-toml.py <toml_file> <field>

Fields:
    test_prompt  - Extract test_prompt value
    timeout      - Extract timeout value (default: 300)
    setup_count  - Count number of [setup] entries
    setup_path N - Get path from Nth setup entry (0-indexed)
    setup_content N - Get content from Nth setup entry
    checks_count - Count number of [[checks]] entries
    check_name N - Get name from Nth check entry
    check_command N - Get command from Nth check entry
"""

import sys
import re

def parse_toml_file(file_path):
    """Parse TOML file into structured data."""
    with open(file_path, 'r') as f:
        content = f.read()

    result = {
        'test_prompt': None,
        'timeout': 300,
        'setup': [],
        'checks': []
    }

    # Extract test_prompt
    prompt_match = re.search(r'test_prompt\s*=\s*["\']{3}(.+?)["\']{3}', content, re.DOTALL)
    if prompt_match:
        result['test_prompt'] = prompt_match.group(1)

    # Extract timeout
    timeout_match = re.search(r'timeout\s*=\s*(\d+)', content)
    if timeout_match:
        result['timeout'] = int(timeout_match.group(1))

    # Extract setup entries
    setup_pattern = r'\[\[setup\]\]\s*\npath\s*=\s*["\']([^"\']+)["\']\s*\ncontent\s*=\s*["\']{3}(.+?)["\']{3}'
    for match in re.finditer(setup_pattern, content, re.DOTALL):
        result['setup'].append({
            'path': match.group(1),
            'content': match.group(2)
        })

    # Extract check entries
    check_pattern = r'\[\[checks\]\]\s*\nname\s*=\s*["\']([^"\']+)["\']\s*\ntype\s*=\s*["\']([^"\']+)["\']\s*\ncommand\s*=\s*["\']([^"\']+)["\']'
    for match in re.finditer(check_pattern, content):
        result['checks'].append({
            'name': match.group(1),
            'type': match.group(2),
            'command': match.group(3)
        })

    return result

def main():
    if len(sys.argv) < 3:
        sys.exit(1)

    file_path = sys.argv[1]
    field = sys.argv[2]

    try:
        data = parse_toml_file(file_path)

        if field == 'test_prompt':
            if data['test_prompt']:
                print(data['test_prompt'], end='')
            else:
                sys.exit(1)

        elif field == 'timeout':
            print(data['timeout'])

        elif field == 'setup_count':
            print(len(data['setup']))

        elif field == 'setup_path':
            idx = int(sys.argv[3]) if len(sys.argv) > 3 else 0
            if 0 <= idx < len(data['setup']):
                print(data['setup'][idx]['path'])
            else:
                sys.exit(1)

        elif field == 'setup_content':
            idx = int(sys.argv[3]) if len(sys.argv) > 3 else 0
            if 0 <= idx < len(data['setup']):
                print(data['setup'][idx]['content'], end='')
            else:
                sys.exit(1)

        elif field == 'checks_count':
            print(len(data['checks']))

        elif field == 'check_name':
            idx = int(sys.argv[3]) if len(sys.argv) > 3 else 0
            if 0 <= idx < len(data['checks']):
                print(data['checks'][idx]['name'])
            else:
                sys.exit(1)

        elif field == 'check_command':
            idx = int(sys.argv[3]) if len(sys.argv) > 3 else 0
            if 0 <= idx < len(data['checks']):
                print(data['checks'][idx]['command'])
            else:
                sys.exit(1)

        else:
            sys.exit(1)

    except Exception as e:
        sys.exit(1)

if __name__ == '__main__':
    main()
