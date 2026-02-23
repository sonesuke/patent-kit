# Legal Checker - Examples

This document provides examples of compliant and non-compliant language for patent analysis.

## Example 1: Claim Element Mapping

### Non-Compliant (Legal Conclusions):
```
Element 1: "A system comprising a processor and memory."

Analysis: The reference US1234567 **satisfies** this element because it **clearly discloses** a CPU and RAM. This element is **infringed**.

Conclusion: Claim 1 is **anticipated** by the reference.
```

### Compliant (Technical Descriptions):
```
Element 1: "A system comprising a processor and memory."

Reference Analysis (US1234567):
- The reference discloses a central processing unit (CPU) (Column 3, Lines 15-20)
- The reference discloses random access memory (RAM) (Column 3, Lines 22-25)
- The reference describes the CPU executing instructions stored in RAM (Column 4, Lines 5-10)

Technical Summary:
The reference shows a processor-memory architecture where the CPU executes instructions from RAM. This matches the functional description of Element 1.
```

## Example 2: Missing Element

### Non-Compliant (Legal Conclusions):
```
Element 2: "A wireless communication module."

Analysis: The reference **does not disclose** wireless communication. Therefore, the claim **is not anticipated** and the reference **does not infringe**.
```

### Compliant (Factual Observations):
```
Element 2: "A wireless communication module."

Reference Analysis (US1234567):
- The reference discloses wired Ethernet communication (Column 5, Lines 10-15)
- The reference does not mention wireless communication
- No wireless transceiver or antenna is described

Technical Summary:
The reference is limited to wired communication (Ethernet). Wireless communication components are not disclosed.
```

## Example 3: Equivalence Analysis

### Non-Compliant (Legal Determination):
```
The alternative implementation using optical fibers **is equivalent** to the copper wires in the reference and **would be obvious** to one skilled in the art.
```

### Compliant (Technical Description):
```
Functional Comparison:
- Reference: Copper wires for data transmission (Column 2, Lines 5-10)
- Alternative: Optical fibers for data transmission

Technical Analysis:
Both implementations achieve high-speed data transmission. The optical fiber implementation provides higher bandwidth and lower signal attenuation compared to copper wires.

The optical fiber approach is a commonly used alternative in applications requiring long-distance data transmission.
```

## Example 4: FTO Risk Assessment

### Non-Compliant (Definitive Legal Opinion):
```
**FTO Opinion**: The product **does not infringe** Claim 5 because it uses a different algorithm. There is **no risk** of infringement.
```

### Compliant (Risk Assessment):
```
**Feature Comparison**:
- Claim 5 requires: "[specific algorithm steps A, B, C]"
- Product uses: "[alternative algorithm steps X, Y, Z]"

**Technical Differences**:
- The product's algorithm omits step B and replaces it with step Y
- Step Y achieves a different technical result: [describe result]

**Risk Assessment**:
The product's algorithm differs from Claim 5 in the following aspects:
- Missing step B
- Alternative implementation with step Y

This difference may reduce potential risk, but further review by patent counsel is recommended to confirm.
```

## Example 5: Invalidity Analysis

### Non-Compliant (Legal Conclusions):
```
**Invalidity Analysis**: Claim 7 is **invalid** under 35 U.S.C. § 103 as **obvious** over the combination of References A and B. Any skilled person would **clearly** combine these references.
```

### Compliant (Technical Comparison):
``**Technical Comparison**:

Claim 7 requires:
- Element A: [feature description]
- Element B: [feature description]
- Element C: [feature description]

Reference A discloses:
- Element A: [description]
- Element B: [description]
- Does not disclose Element C

Reference B discloses:
- Element C: [description]

Technical Differences:
- Claim 7 requires the combination of A + B + C
- Reference A teaches A + B
- Reference B teaches C
- Neither reference teaches the combination of all three elements

**Observations**:
- No single reference discloses all three elements
- The references do not suggest or motivate combining A+B from Reference A with C from Reference B
- The combination achieves a unique technical result: [describe result]
```

## Quick Reference: Red Flags

Avoid these phrases:
- "satisfies", "fulfills", "meets" (use "discloses", "shows", "describes")
- "infringes", "violates" (use "overlaps with", "covers similar features")
- "anticipates", "renders obvious" (use "discloses all elements", "teaches away")
- "clearly", "obviously", "undoubtedly" (use specific quotes and facts)
- "is invalid", "is not enforceable" (use "has differences from", "varies from")

Acceptable alternatives:
- "discloses", "shows", "describes", "teaches"
- "covers", "includes", "implements", "performs"
- "found in", "present in", "described in"
- "differs from", "lacks", "does not show"
