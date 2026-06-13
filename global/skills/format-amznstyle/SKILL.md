---
source: claude-workbench
name: format-amznstyle
description: >
  Reviews text for weasel words, vague language, and corporate jargon using
  Amazon's writing principles. Returns flagged issues and a polished version.
  Use when drafting Slack updates, PR descriptions, Jira tickets, or any
  professional communication that needs to be direct and concrete.
---

Review the text for writing quality. Apply Amazon's writing standards: no weasel words, no vague quantifiers, no corporate jargon. Every claim must be specific and concrete.

## Weasel words to flag

**Vague quantifiers without a number:**
significant, significantly, meaningful, many, most, some, better, improved, enhanced, optimized, increased, decreased (when no number follows)

**Form-without-content adjectives:**
structured (describes format, not value: ask "what does it contain?"), complete (as in "complete picture": say what was missing before), stable (without a comparison baseline: say what was failing), automated (when the interesting part is what it does, not that it runs automatically), comprehensive, thorough, detailed (without specifics)

**Corporate jargon:**
leverage, leveraged, synergy, synergies, robust, scalable, world-class, best-in-class, innovative, disruptive, seamless, cutting-edge, utilize, holistic, streamline, empower, enable, align, drive (as in "drive results")

**Empty qualifiers:**
very, quite, rather, somewhat, fairly, pretty (as in "pretty good")

**Filler outcome phrases:**
"complete picture", "single source of truth" (without saying what was fragmented before), "anyone on the team can use" (says nothing: who couldn't use it before?), "gives leadership visibility into" (say what they can now decide), "end-to-end" without specifying the two ends

**Weasel phrases:**
going forward, at the end of the day, circle back, touch base, move the needle, at this point in time, in order to (replace with "to")

**Weak attribution:**
we believe, we feel, we think, it seems, it appears (without data)

**Passive voice that hides the actor:**
"was implemented by", "has been resolved", "is being addressed"

## Output format

**Issues found**
For each flagged item: quote the phrase, explain why it's weak, and suggest a concrete rewrite. If a number would fix it, say so explicitly.

**Polished version**
The full text rewritten with all fixes applied. Keep the same structure and length.
