---
name: review
description: Generate factual status review document. Use when user asks to review a topic, assess status, or analyze current state. Focus on verifiable facts, no assumptions or speculation.
---

# Factual Review Generator

Generate a factual status review for $ARGUMENTS.

## Core Rules

**FACTS ONLY:**
- State verifiable data (status, dates, metrics, quotes)
- Label user-provided context as "User-Provided"
- List unknowns explicitly
- No interpretations, opinions, or assumptions

**NO ESTIMATES WITHOUT DATA:**
- Never fabricate timelines or effort estimates
- Never extrapolate from other work
- State "No estimates available" when true

**DRY & KISS:**
- State each fact once
- Simple structure, bullet points
- No conversation artifacts or meta-commentary

## Anti-Patterns - Stop If You Write:

- "This would take about..." → No estimates
- "Pros/Cons" or "Arguments FOR/AGAINST" → Just state outcomes
- "Better/worse/best" → Describe factually
- "RECOMMENDED" → Only if explicitly requested
- "Lower risk/high cost" → Quantify or remove
- "Industry best practice" → Cite or remove
- "Probably/likely/seems" → Don't speculate

## Structure

```markdown
# [Topic] - Review

## Summary
- Current state (bullets)
- New context if provided
- Open questions

---

## [Section] Status

**Source:** [Where data comes from]

**Facts:**
- Verifiable data
- Direct quotes (with attribution, date)

**Missing:**
- Unknowns

---

## Possible Approaches (if multiple exist)

### Approach A: [Name]
Description (no judgment)
- Result: [factual outcome]
- Impact: [measurable impact]

---

## Outstanding Questions
1. What is unknown?
2. What needs clarification?

---

## Reference Data
- Sources
- Supporting evidence

**Generated:** YYYY-MM-DD
```

## Output

Single point-in-time factual assessment. No repetition. Everything verifiable or labeled as user-provided.
