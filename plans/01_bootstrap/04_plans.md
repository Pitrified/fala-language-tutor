---
status: done
---

# Phase 04 - Move the open plan folders

## Plan

- Copy the folders in the table in `00_start.md` under their new numbers.
- Relative links into folders that stay in the source become absolute GitHub links to the source's `main`.
- A note at the top of each moved `00_start.md`: its source folder and the date it moved.
- In the source, the matching folders are marked moved; that is the source's phase 05, not this one.

## Done when

- `scripts/plans.py check --citations` and the link gate pass here.

## What the implementation found

- Six folders copied under their new numbers with a script: 21 files, with every relative link to a folder rewritten either to the new number or to the source on GitHub, and backticked folder names of the moved six renamed.
- Prose numbers ("folder 16", "phase 07/01") are not rewritten. Each moved `00_start.md` starts with a note linking its source folder and listing the six renumberings, so a bare number reads as the source's unless it is in that list.
- `07_dependency_upgrades` depended on the source's `20_repo_split`, which is not in this repo. It now depends on `01_bootstrap`, the split as seen from here, and says so.
- `list` shows the seven folders, with `02_release` and `03_ui_tweaks` still `in progress` as they were in the source.
