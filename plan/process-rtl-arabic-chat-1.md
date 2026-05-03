---
goal: Implement right-to-left (RTL) language handling for Arabic in chat interactions.
version: 1.0
date_created: 2026-05-03
owner: RTL Policy Designer
status: 'Planned'
tags: [rtl, arabic, chat, ui-ux]
---

# Introduction

![Status: Planned](https://img.shields.io/badge/status-Planned-blue)

This plan defines the architectural and behavioral standards for enforcing Right-to-Left (RTL) language handling for Arabic within chat interfaces. It ensures that all Arabic text is correctly aligned, formatted, and rendered, providing a seamless experience for Arabic-speaking users while handling mixed-language (BiDi) edge cases gracefully.

## 1. Requirements & Constraints

- **REQ-001**: All Arabic text must use `direction: rtl`.
- **REQ-002**: Text containers for Arabic must be right-aligned (`text-align: right`).
- **REQ-003**: Punctuation marks (periods, question marks, exclamation points) must appear at the correct (left) end of the RTL line.
- **REQ-004**: Chat bubbles and message status indicators must mirror their positions for RTL messages.
- **CON-001**: English text or code snippets within an Arabic block must maintain their LTR directionality (Bidirectional support).
- **CON-002**: No external translation tools; focus strictly on formatting and rendering directionality.

## 2. Implementation Steps

### Implementation Phase 1: Directionality & Alignment Standards

- GOAL-001: Enforce global RTL directionality for Arabic content.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-001 | Implement logic to detect Arabic script in messages and apply the `rtl` class/style. | | |
| TASK-002 | Update CSS to ensure `direction: rtl` and `text-align: right` are applied to Arabic chat bubbles. | | |
| TASK-003 | Mirror UI components (avatars, timestamps) to the left side for RTL messages. | | |

### Implementation Phase 2: BiDi (Bidirectional) Text Handling

- GOAL-002: Ensure mixed Arabic/English text renders correctly.

| Task | Description | Completed | Date |
|------|-------------|-----------|------|
| TASK-004 | Configure the chat engine to use the Unicode Bidirectional Algorithm (Bidi) for mixed content. | | |
| TASK-005 | Ensure phone numbers and numeric dates within RTL text are displayed as LTR to preserve correct digit order. | | |

## 3. Alternatives

- **ALT-001**: Global RTL for the entire app. Rejected to support multi-lingual users who may have LTR and RTL messages in the same thread.

## 4. Dependencies

- **DEP-001**: Standard Browser/OS Bidirectional text engine.

## 5. Files

- **FILE-001**: `chat_styles.css` (or equivalent stylesheet)
- **FILE-002**: `message_component.dart` (or equivalent UI logic)

## 6. Testing

- **TEST-001**: Verify that a sentence ending in "?" has the mark on the far left.
- **TEST-002**: Verify that mixed text (e.g., "أنا أستخدم Flutter") renders "Flutter" LTR but the sentence flows RTL.

## 7. Risks & Assumptions

- **RISK-001**: Some legacy browsers may struggle with complex BiDi layouts.
- **ASSUMPTION-001**: The system font supports all necessary Arabic glyphs and ligatures.

## 8. Related Specifications / Further Reading

- [W3C RTL Authoring Guidelines](https://www.w3.org/International/articles/inline-bidi-markup/)
---

# Copy/Paste-Ready Rule Block: RTL Arabic Enforcement

**Title**: RTL Arabic Chat Enforcement Rule
**Role & stance**: You are an Arabic Language RTL Specialist. Your stance is to ensure that every Arabic character and punctuation mark is rendered with 100% directionality accuracy.
**Task**: Enforce Right-to-Left (RTL) formatting for all Arabic chat inputs and outputs.
**Context**: You are interacting with users in Arabic. The interface must respect the natural flow of the language.
**Inputs available**: Arabic text strings, mixed-language strings (Arabic/English).
**Output requirements**: 
1. Set `direction: rtl`.
2. Right-align all text blocks containing Arabic.
3. Ensure punctuation follows RTL logic.
4. Keep numbers and English words LTR within the RTL flow.

**Constraints / Do-nots**:
- لا تستخدم المحاذاة اليسارية للنصوص العربية أبداً.
- لا تضع علامات الترقيم في بداية السطر (الجهة اليمنى) إذا كانت تتبع نصاً عربياً.
- Do not mix LTR assumptions into Arabic sentences.

**Examples / References**:
- *Prompt*: "كيف حالك اليوم؟" (Correct RTL)
- *Response*: "أنا بخير، شكراً لسؤالك! كيف يمكنني مساعدتك؟" (Correct alignment and punctuation)
- *Mixed*: "أنا أعمل على تطبيق Flutter الجديد." (Arabic RTL, "Flutter" LTR)

**Execution checklist**:
- [ ] Verify `direction: rtl` is active for the message container.
- [ ] Confirm text is aligned to the right.
- [ ] Check that the period/question mark is on the left side of the sentence.
- [ ] Ensure numbers (0-9) read correctly from left to right.

**Conflict resolution**:
If a technical constraint forces LTR (e.g., a code block), wrap only the code in an LTR container while keeping the surrounding Arabic explanation RTL.
