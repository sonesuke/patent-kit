# Prior Art / Execution Report: <Patent ID>

## 1. Selected Strategy

(Adaptive Decision: FTO vs Invalidation)

- **Strategy**:
- **Rationale**: (Why was this strategy chosen based on search results?)

## 2. Search Strategy

(Based on Infringement Risk Analysis)

| Target Feature/Element | Keywords (JP/EN) | Classification |
| :--- | :--- | :--- |
| ... | ... | ... |

## 3. Search Queries

```bash
# Query:
google-patent-cli search --query "..." --before "..."
```

## 4. Execution Log

Record the results of the search queries defined in the Plan.

- [ ] Run Query 1
  - **Hit Count**: ...
  - **Top Results**: ...

## 5. Prior Art List

Select the most relevant documents.

| Doc Number | Title | Pub Date | Relevance (X/Y/A) | Note |
| :--- | :--- | :--- | :--- | :--- |
| D1 | ... | ... | ... | ... |

### 5.2 Non-Patent Literature (NPL)
| NPL ID | Title | Authors | Pub Date | Relevance | Note |
| :--- | :--- | :--- | :--- | :--- | :--- |
| NPL1 | ... | ... | ... | ... | ... |

## 6. Comparison (Claim Chart)

Compare the Spec (Elements) with the Primary Reference (D1).

| Element | D1 Disclosure | Match? | Difference |
| :--- | :--- | :--- | :--- |
| A | ... | Yes/No | ... |
| B | ... | Yes/No | ... |

### 6.2 Non-Patent Literature Analysis (if applicable)
| Element | NPL Disclosure | Match? | Note |
| :--- | :--- | :--- | :--- |
| A | ... | Yes/No | ... |

## 7. Published Application Amendment Risk (If Applicable)

**Note**: Skip this section if all references are granted patents.

For published patent applications (not yet granted), assess the risk of claim amendments based on embodiments:

| Doc Number | Application Status | Embodiment Scope | Amendment Risk | Assessment |
| :--- | :--- | :--- | :--- | :--- |
| D1 | Published/Pending | (Describe broader features in embodiments) | High/Medium/Low | (Could claims be amended to cover broader scope?) |

**Reasoning**:
- Constitution VI states: "Consider the Detailed Description and embodiments as potential scope for future amendments."
- Evaluate whether embodiments disclose features that could be added to claims during examination.
- High risk: Embodiments clearly describe broader features that would strengthen infringement case.
- Low risk: Embodiments are consistent with current claims or narrower.

## 8. Conclusion

- **Novelty/Invalidity**: (Pass/Fail)
- **Reasoning**: ...

---

## 9. Quality Gates

- [ ] All top results reviewed.
- [ ] All non-patent literature top results reviewed.
- [ ] Grade A NPL candidates analyzed in detail.
- [ ] Claim chart completed for the closest prior art.
- [ ] Final report documents BOTH patent and non-patent literature findings (Constitution III).
- [ ] Conclusion is supported by the comparison.
