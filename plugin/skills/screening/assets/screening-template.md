# Screening Report

## Progress

- **Completion Rate**: [PERCENT]% ([SCREENED]/[TOTAL])
- **Remaining**: [REMAINING] patents
- **Relevant Patents**: [RELEVANT_COUNT]

## Detail by Judgment

| Judgment           | Count    | Percentage |
| ------------------ | -------- | ---------- |
| Relevant           | [NUMBER] | [PERCENT]% |
| Irrelevant         | [NUMBER] | [PERCENT]% |
| Expired            | [NUMBER] | [PERCENT]% |
| **Total Screened** | [NUMBER] | 100.0%     |
| Not Processed      | [NUMBER] | -          |

## Top 10 Relevant Patents

| Patent ID | Title   | Assignee   | Priority Date | Reason   |
| --------- | ------- | ---------- | ------------- | -------- |
| [ID]      | [TITLE] | [ASSIGNEE] | [DATE]        | [REASON] |

---

## Quality Gates

- [ ] All records in `target.jsonl` have been processed.
- [ ] Each judgment is one of: `relevant`, `irrelevant`, `expired`.
- [ ] Screened count matches (Relevant + Irrelevant + Expired).
- [ ] Summary statistics are accurate.
- [ ] Used strictly standard sections (Progress, Detail by Judgment, Top 10 Relevant Patents).
- [ ] No extra sections added.
- [ ] **NO Legal Assertions**:
  - [ ] Avoid terms: "Does not satisfy", "Does not infringe", "Is a core technology" or cite court cases.
