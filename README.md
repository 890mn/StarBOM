# Link2BOM

Link2BOM is a Qt 6 / Qt Quick desktop tool for importing, organizing, filtering, comparing, and exporting BOM data.

The current codebase is positioned between a usable beta and a release-oriented refactor stage. The recent focus has been on three areas:
- stabilizing the main BOM workflow
- reducing coupling between QML and C++ layers
- preparing the project for later analytics and feature expansion

## Current Feature Set

- Import LCSC BOM data from `csv`, `xlsx`, and `xls`
- Organize BOM data by project
- Manage categories and assign entries to groups
- Search, filter, and sort BOM rows
- Adjust visible columns and persist column width ratios
- Compare grouped BOM differences
- Export the current BOM view to CSV
- Switch theme and UI language
- Route logs through `spdlog` into file, debug output, and QML

## Project Goals

Short-term goals:
- make the existing workflow stable enough for daily use
- continue reducing large-file coupling in QML and controller code
- keep the codebase easy to extend

Mid-term goals:
- improve diff analysis and statistics
- add more import sources
- improve build performance in the local Windows toolchain

Long-term goals:
- add richer BOM analytics
- add inventory-health evaluation
- reserve a clean integration point for local model-assisted suggestions