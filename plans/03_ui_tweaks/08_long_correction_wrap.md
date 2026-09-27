---
status: done
---

# 08 - A long correction wraps while it streams

## The problem

From the list in `00_start.md`: "while they stream, a long correction is not wrapped; then when the correction is finished, it is wrapped well."

`CorrectionCard._buildDiff` draws a streaming row in one of three states. While the original has arrived and the corrected form has not, it used a `Row` of `Text(original)`, `' -> '` and a skeleton. A `Row` lays its children out with unbounded width, so a long original stayed on one line and ran off the card. As soon as the first character of the corrected form arrived, the row switched to a `RichText`, which wraps, and the line reflowed.

## The change

The pending state is a `Text.rich` too: the struck-through original, the arrow, and the skeleton as a `WidgetSpan`. The line wraps from its first character and keeps the same shape when the corrected form arrives.

## What the implementation found

- **Test seen failing first:** a 240-pixel-wide card with a 108-character original and no corrected form. Before the fix: `A RenderFlex overflowed by 1450 pixels on the right`. The same card with the corrected form present passed, which pins the cause to the pending state. After the fix both pass, and the original's height shows it wrapped.
- `streaming_tutor_entry_test.dart` found the pending original as a plain `Text` widget; it now finds it inside the rich text. What it checks is unchanged.
- Checked on the Pixel on 2026-09-27 with build `0.0.1+c45ce050`: a long wrong sentence's correction wraps while it streams.
