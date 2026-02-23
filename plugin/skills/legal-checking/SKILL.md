---
name: legal-checking
description: "Use to review patent analysis for legal compliance violations. Detects prohibited terms (infringe, satisfy, anticipate, obvious, equivalent, invalid) and suggests compliant alternatives. Trigger: review, legal compliance, violation, check"
metadata:
  author: sonesuke
  version: 1.0.0
---

# Legal Checker - Patent Compliance Reviewer

Version: 1.0.0

## Purpose

Reviews patent analysis documents for legal compliance violations and suggests corrective actions. This skill identifies prohibited legal assertions and descriptive language that crosses into the practice of law.

## How It Works

1. **Input**: Accepts a file path to a patent analysis document
2. **Review**: Analyzes the content for prohibited legal language
3. **Output**: Provides a compliance report with:
   - List of prohibited terms found
   - Location of each violation
   - Suggested compliant alternatives
   - Corrected version (optional)

**Important**: This skill does NOT modify files. It only provides analysis and suggestions.

## Usage

```
/path/to/patent-analysis.md
```

The skill will:
1. Read the specified file
2. Review for legal compliance violations
3. Output a compliance report with findings and suggestions

## What It Checks

### Prohibited Legal Assertions

- "Does not satisfy"
- "Does not infringe"
- "Is a core technology"
- "Is invalid"
- "Anticipates"
- "Renders obvious"
- "Is equivalent"
- Definitive legal conclusions

### Recommended Descriptive Language

- "Discloses", "shows", "describes", "teaches"
- "Covers", "includes", "implements", "performs"
- "Found in", "present in", "described in"
- "Differs from", "lacks", "does not show"

## References

- `references/instructions.md` - Detailed legal compliance rules
- `references/examples.md` - Compliant vs non-compliant examples
