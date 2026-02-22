#!/bin/bash
INPUT_DIR="${1:-1-targeting/csv}"
OUTPUT_FILE="${2:-1-targeting/target.jsonl}"

if [ ! -d "$INPUT_DIR" ]; then
    echo "Directory not found: $INPUT_DIR. Please create it and place CSV files there."
    exit 0
fi

mkdir -p "$(dirname "$OUTPUT_FILE")"

# Use Node.js to safely parse CSV and output JSONL
node -e "
const fs = require('fs');
const path = require('path');

const inputDir = process.argv[1];
const outputFile = process.argv[2];

let uniquePatents = {};
let fileCount = 0;

const files = fs.readdirSync(inputDir).filter(f => f.endsWith('.csv'));

function parseCSV(csvText) {
    const lines = [];
    let currentLine = [];
    let currentCell = '';
    let inQuotes = false;
    
    for (let i = 0; i < csvText.length; i++) {
        const char = csvText[i];
        const nextChar = csvText[i+1];
        
        if (inQuotes) {
            if (char === '\\\"' && nextChar === '\\\"') {
                currentCell += '\\\"';
                i++;
            } else if (char === '\\\"') {
                inQuotes = false;
            } else {
                currentCell += char;
            }
        } else {
            if (char === '\\\"') {
                inQuotes = true;
            } else if (char === ',') {
                currentLine.push(currentCell);
                currentCell = '';
            } else if (char === '\\n' || char === '\\r') {
                if (char === '\\r' && nextChar === '\\n') i++;
                currentLine.push(currentCell);
                lines.push(currentLine);
                currentLine = [];
                currentCell = '';
            } else {
                currentCell += char;
            }
        }
    }
    if (currentCell !== '' || currentLine.length > 0) {
        currentLine.push(currentCell);
        lines.push(currentLine);
    }
    return lines;
}

for (const file of files) {
    const filePath = path.join(inputDir, file);
    console.log('Processing ' + file);
    fileCount++;
    
    const content = fs.readFileSync(filePath, 'utf8');
    const textLines = content.split(/\r?\n/);
    
    let csvStartIndex = 0;
    for (let i = 0; i < textLines.length; i++) {
        const line = textLines[i].trim();
        if (line && !line.startsWith('search URL:')) {
            csvStartIndex = i;
            break;
        }
    }
    
    const csvContent = textLines.slice(csvStartIndex).join('\n');
    const parsed = parseCSV(csvContent);
    if (parsed.length < 2) continue;
    
    const headers = parsed[0];
    
    for (let i = 1; i < parsed.length; i++) {
        const row = parsed[i];
        if (row.length === 0 || (row.length === 1 && !row[0])) continue;
        
        const obj = {};
        for (let j = 0; j < headers.length; j++) {
            obj[headers[j]] = row[j] || '';
        }
        
        if (obj['id']) {
            uniquePatents[obj['id']] = obj;
        }
    }
}

if (fileCount === 0) {
    console.log('No CSV files found in ' + inputDir);
    process.exit(0);
}

const outData = [];
for (const key in uniquePatents) {
    const record = uniquePatents[key];
    const filteredRecord = {};
    
    for (const k in record) {
        if (k && !k.includes('link') && k !== 'inventor/author') {
            filteredRecord[k] = record[k];
        }
    }
    
    if (filteredRecord['id']) {
        filteredRecord['id'] = filteredRecord['id'].replace(/-/g, '');
    }
    outData.push(JSON.stringify(filteredRecord));
}

fs.writeFileSync(outputFile, outData.join('\\n') + '\\n', 'utf8');
console.log('Merged ' + Object.keys(uniquePatents).length + ' unique patents from ' + fileCount + ' files into ' + outputFile);
" "$INPUT_DIR" "$OUTPUT_FILE"
