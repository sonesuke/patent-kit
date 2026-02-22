#!/usr/bin/env python3
import os
import sys
import csv
import json

def merge_csvs(input_dir, output_file):
    if not os.path.exists(input_dir):
        print(f"Directory not found: {input_dir}. Please create it and place CSV files there.")
        return

    unique_patents = {}
    file_count = 0

    for filename in os.listdir(input_dir):
        if not filename.endswith('.csv'):
            continue
            
        filepath = os.path.join(input_dir, filename)
        print(f"Processing {filepath}")
        file_count += 1
        
        # Read the file and skip the "search URL:" preamble
        with open(filepath, 'r', encoding='utf-8') as f:
            lines = f.readlines()
            
        csv_start_index = 0
        for i, line in enumerate(lines):
            if line.strip() and not line.strip().startswith('search URL:'):
                csv_start_index = i
                break
                
        if csv_start_index >= len(lines):
            continue
            
        reader = csv.DictReader(lines[csv_start_index:])
        for row in reader:
            if 'id' in row and row['id']:
                unique_patents[row['id']] = row

    if file_count == 0:
        print(f"No CSV files found in {input_dir}")
        return

    # Create output directory if it doesn't exist
    os.makedirs(os.path.dirname(output_file), exist_ok=True)
    
    with open(output_file, 'w', encoding='utf-8') as f:
        for record in unique_patents.values():
            filtered_record = {}
            for k, v in record.items():
                if k and 'link' not in k and k != 'inventor/author':
                    filtered_record[k] = v
            
            # Remove hyphens from id
            if 'id' in filtered_record:
                filtered_record['id'] = filtered_record['id'].replace('-', '')
                
            f.write(json.dumps(filtered_record, ensure_ascii=False) + '\n')

    print(f"Merged {len(unique_patents)} unique patents from {file_count} files into {output_file}")

if __name__ == '__main__':
    input_dir = '1-targeting/csv'
    output_file = '1-targeting/target.jsonl'
    
    if len(sys.argv) > 1:
        input_dir = sys.argv[1]
    if len(sys.argv) > 2:
        output_file = sys.argv[2]
        
    merge_csvs(input_dir, output_file)
