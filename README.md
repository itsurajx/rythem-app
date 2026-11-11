<div align="center">

# 🎵 Rythem
### The Ambient, User-Driven Learning Operating System & Curriculum Orchestrator

[![Release](https://img.shields.io/github/v/release/itsurajx/rythem-app?color=10B981&label=Release&logo=github)](https://github.com/itsurajx/rythem-app/releases/latest)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![License: PolyForm Noncommercial 1.0.0](https://img.shields.io/badge/License-PolyForm_Noncommercial_1.0.0-blue.svg)](https://polyformproject.org/licenses/noncommercial/1.0.0)
[![Offline First](https://img.shields.io/badge/Offline-100%25%20Local-10B981)](#-architecture--privacy-first-engineering)
[![SQLite](https://img.shields.io/badge/Database-SQLite-003B57?logo=sqlite)](https://sqlite.org)

**Beats over clocks. User-driven momentum over rigid quotas. Progress felt, not measured.**

[The Evolution](#-the-evolution-what-rythem-has-become) •
[Core Pillars](#-the-four-core-pillars) •
[Universal Beats & Ingestion](#-universal-beats--curriculum-ingestion-v200) •
[Formatting Syllabi with AI](#-how-to-format--import-any-syllabus-using-ai) •
[Architecture](#-architecture--privacy-first-engineering) •
[Getting Started](#-getting-started--local-development) •
[Contributing](#-contributing)

</div>

---

## 🌊 The Evolution: What Rythem Has Become

Traditional learning and study apps treat education like a factory floor: toxic countdown timers, arbitrary hour quotas, guilt-inducing overdue banners, and rigid daily quotas that collapse the moment unexpected real-world demands arise.

Early iterations of Rythem explored automated pacing math. But as the system matured through real daily usage, a deeper truth emerged: **forced algorithmic daily quotas still cause anxiety, whereas genuine mastery flourishes under user-driven momentum in a peaceful, ambient environment.**

Today, **Rythem v2.0.0 is a complete, local-first learning operating system**:

```
           Initial Stage                           Rythem Today (v2.0.0)
 ──────────────────────────────────       ──────────────────────────────────────────────
 ⏱️ Stopwatch & minute pressure          ➔  🎵 Universal "Beats" (atomic weight of work)
 🤖 Algorithmic daily quotas              ➔  🎯 User-Driven Focus (pull tasks when ready)
 📉 Stressful overdue penalties           ➔  🌙 Peaceful evening rest & ambient context
 🗂️ Flat checklists                       ➔  🏛️ Hierarchical Roadmap & Subject Orchestration
 🔒 Rigid, locked-in curricula            ➔  🧪 Pinned Open Lab for spontaneous exploration
 ☁️ Cloud surveillance & subscriptions    ➔  🔒 100% Air-Gapped, Private On-Device SQLite
```

---

## 🌟 The Core Philosophy

### 1. 🎵 Beats Over Clocks
Time spent sitting in front of a screen is a deceptive metric. In Rythem, work is measured in **Beats** (atomic milestones, exercises, video chapters, or syllabus topics). A beat reflects substantive cognitive effort—never clocks, stopwatches, or minutes.

### 2. 🎯 User-Driven Momentum (Pull-Next-Topic)
You are the architect of your focus. When you sit down to learn, tap **Pull Next Topic** to draw the immediate sequential milestone into your active queue. No algorithm forces an arbitrary daily count; you advance as deeply as your focus carries you.

### 3. 🌤️ Ambient Mastery Environment
Real learning exists in harmony with the natural world. Rythem connects to zero-signup, key-free ambient providers to display your true **location weather and diurnal greetings** (e.g. night-time recognition at 1 AM), paired with **daily inspirational quotes** backed by an offline reserve.

### 4. 👑 "Mentor's Flow is King"
When you attach a comprehensive YouTube playlist or video course to your curriculum, the instructor's original chronological sequence is preserved with 100% fidelity. Non-syllabus bonus videos are retained as `Mentor Extra` badges—never deleted, reordered, or discarded.

### 5. 🧪 Pinned Open Lab Sandbox
Not all learning fits into structured course syllabi. The **Open Lab** stays permanently pinned to the top of your workspace, allowing you to log ad-hoc research, practice problems, and spontaneous deep dives with custom beat weights.

---

## 🏛️ The Four Core Pillars

```
┌─────────────────────────────────────────────────────────────────────────────────┐
│                              RYTHEM INTERFACE SUITE                             │
├───────────────────┬───────────────────┬───────────────────┬─────────────────────┤
│      1. FLOW      │     2. EXPLORE    │    3. METRICS     │     4. SETTINGS     │
│   (Daily Focus)   │  (Main Tracker)   │ (Habit Velocity)  │ (Local AI & Backups)│
└───────────────────┴───────────────────┴───────────────────┴─────────────────────┘
```

### 1. ⚡ Flow: The Focused Daily Workspace
- **Diurnal Ambient Header**: Displays live real-world weather conditions and dynamic greetings reflecting your current time of day.
- **Daily Inspiration**: Curated daily quotes from ZenQuotes / DummyJSON backed by an offline 365-day reserve.
- **Active Focus Card**: Shows your current in-focus topic with its roadmap badge, beat weight, and direct checkpoint actions.
- **Pull Next Topic**: If no topic is active, one tap pulls the next incomplete milestone in chronological mentor order.
- **Friction & Checkpoint Logger**: Log partial percentages, record reflections, or flag roadblocks for later review.

### 2. 🗺️ Explore: The Main Tracker & Curriculum Catalog
- **Pinned Open Lab Header**: Dedicated progress meter for ad-hoc study tasks and spontaneous practice sessions.
- **Curriculum Cards**: At-a-glance status across all active tracks showing progress ratios (e.g. `12.5 of 45.0 beats`), category tags, and target dates.
- **Deep Chapter Accordions**: Expandable modular chapters displaying sequential beats, video durations, `Mentor Extra` tags, and interactive checkpoints.
- **Multi-Resource Ingestion**: Attach YouTube playlists, standalone videos, or articles to entire roadmaps, specific chapters, or individual topics.

### 3. 📊 Metrics: Visual Momentum & Habit Velocity
- **Full-Month Streak Calendar**: Emerald heat-map calendar displaying completed daily beats, honest streak continuity, and month-by-month pagination.
- **7-Day Study Rhythm**: Clean bar visualizations showing daily beat completions across the active week.
- **Momentum Velocity Chart**: Financial-style graph highlighting velocity acceleration, peak performance days, and trendlines.
- **Cumulative Lifetime Curve**: Tracks your aggregate completed beats growing over the lifetime of your learning journey.

### 4. ⚙️ Settings: Local Control & Data Sovereignty
- **On-Device AI Mentorship**: Manage offline Small Language Models (Qwen 2.5 0.5B Compact or 1.5B Balanced) for offline curriculum audits.
- **In-Place Atomic Backups**: One-tap master backup that updates cleanly in place without creating clutter or duplicates.
- **Air-Gapped Import & Export**: Full JSON database backup and restore for 100% data portability.
- **In-App GitHub Updater**: Built-in glass update checker verifying GitHub releases with interactive changelog viewing.

---

## 📥 Universal Beats & Curriculum Ingestion (v2.0.0)

In Rythem **v2.0.0**, you can import custom curricula from Markdown or JSON with **first-class user beat point preservation**:

```
                                  Ingestion Lifecycle
 ┌──────────────────────┐      ┌──────────────────────────┐      ┌──────────────────────────┐
 │  Markdown Syllabus   │ ───► │   Roadmap (No Resource)  │ ───► │  Resource Attached Later │
 │  - Arrays [2.5 beats]│      │   Beats retain user's    │      │  • Videos get duration   │
 │  - Two Sum (1.5)     │      │   exact custom weights:  │      │  • Gaps keep user beats  │
 │  - Graphs | 3.0 pts  │      │   2.5, 1.5, 3.0...       │      │  • Mentor extras kept    │
 └──────────────────────┘      └──────────────────────────┘      └──────────────────────────┘
```

### Supported Markdown Beat Syntax
Rythem's parser extracts custom beat weights while cleanly stripping annotations from the visible topic title:
- **Bracket Notations**: `- Dynamic Programming [2.5]`, `- Trees [effort: 3.0]`, `- Heaps [2.5 beats]`
- **Parenthetical Notations**: `- Binary Search (1.5)`, `- Two Pointers (3 beats)`, `- Math (effort: 2.0)`
- **Delimiters & Pipes**: `- Graph Theory | 3.0 beats`, `- Bit Manipulation | 2.0`, `- Recursion: 2.5 beats`
- **Prefix Styles**: `- [3.0 beats] System Design`, `- (2.0) Concurrency`
- **JSON Schemas**: Supports `effort`, `effort_points`, `effort_weight`, `points`, and `beats` fields.

---

## 🤖 How to Format & Import Any Syllabus Using AI

You can paste the prompt below into Claude, ChatGPT, Gemini, or any LLM with your syllabus filled in at the bottom:

### 📋 The Master Prompt

````markdown
You are formatting a study syllabus into a Markdown file that imports into the Rythem learning-tracker app. Follow every rule exactly.

## How the app reads the file
- Every line starting with # (any level) becomes a SUBJECT. There is no nesting, so never use ## for sub-sections.
- Every other non-empty line becomes a TOPIC. So the file must contain NO title line, intro text, notes, tables, links, dividers (---), code fences or blank bullets.
- Topic format, one per line: `- Topic title [2.0 beats]`
- 1 beat = 10 minutes of focused work. Weight range is 0.1 to 50.
- Never end a topic title with a number, a bracket or a pipe character.
- Never write an unbulleted line starting with Module, Chapter, Unit, Section, Part or Phase plus a number, because it becomes a subject.
- Subjects with no topics are dropped.

## How resources get matched (this is where most mistakes happen)
The user later attaches a YouTube playlist to each subject. The app compares video titles to topic titles by word overlap (score 0.5 or higher counts as a match). A topic with no matching video becomes a "gap" and keeps its weight. A video with no matching topic becomes a "Mentor Extra".

So:
1. One subject per resource (playlist, course or book). Name the subject with the words used in the playlist title. The matcher ignores digits, so "Calculus 1" and "Calculus 2" look alike.
2. One concept per topic, 2 to 6 words, using the words videos actually use. Put sub-topics after a colon, separated by commas or &. Each part is matched separately: `- Joins: Inner, Left & Full Outer [2.0 beats]`
3. Do not build topics from generic words such as Introduction, Basics, Overview or Tutorial. The matcher ignores them.
4. If two topics share words, put the more specific topic first, because ties go to the first topic.
5. If one video covers two ideas (for example "Markov Matrices; Fourier Series"), merge them into one topic.
6. The matcher treats some words as the same concept and also matches them as substrings. Avoid these in topic titles unless the topic is genuinely about that concept, and never put two topics from the same group in one subject:
   - calculus, derivatives, integrals, limits
   - precalculus, algebra, trig, trigonometry
   - condition, class, loop, init, exception
   - tree, graph, sort, hash, queue, node
   - api, requests, pip, git, github, commit, branch
   - pr (inside probability, product, problem, project, privacy), init (inside definite, infinite, definition)
   Example: write "Limit Laws & Continuity", not "Limits".
7. Non-YouTube links (course pages, PDFs) import as a single item, so tell the user to use a YouTube playlist instead.

## Weights
- For subjects that will get a video resource: use 1.0 to 2.0 per topic (core topics 2.0). Video lengths replace these weights when matched.
- Topics the user marks as skip or optional: 0.5.
- For PROJECT subjects (no resource attached): estimate the hours a fresher needs for each task, multiply by 6, and cap at 50. Make each project its own subject, with build tasks as topics plus a final topic starting "Completion gate:".

## What to include and leave out
- Include only learning topics and project build tasks. Leave out revision tables, link lists, career advice, schedules and notes, unless the user asks otherwise.
- Do not invent topics. You may split a comma list into separate topics. Flag anything you add.

## Process
1. If the user has not said which resource goes with each part, ask for the playlist or video titles first.
2. Reply with a short breakdown: subject list, topic counts, and anything risky (trigger words, vague topics, single-video resources). Wait for approval.
3. Then output the final file as ONE Markdown code block with nothing else inside it.
4. After the file, give 3 short instructions: import the file, attach each resource once from inside its own subject, use + on a gap only with a single-video link.

## Example of correct output
# Python
- Syntax: Variables, Loops & Functions [2.0 beats]
- File Handling: CSV & JSON [1.5 beats]

# Project 1: Data-Cleaning Tool
- Detect missing and invalid rows [18.0 beats]
- Completion gate: explain the code structure [12.0 beats]

## My syllabus
[PASTE SYLLABUS HERE]

## My resources (optional)
[PASTE PLAYLIST OR VIDEO TITLES, ONE PER SUBJECT]
````

### 💡 Tips for Using It
- Paste your messy syllabus as it is, including tables. The prompt tells the AI to clean it up.
- Attach each resource only once. A second attach adds a duplicate copy.
- If a topic comes out as a gap, check whether the playlist covers it before blaming the file.

---

## 🏗️ Architecture & Privacy-First Engineering

Rythem is built on local-first, air-gapped foundations:

```
┌─────────────────────────────────────────────────────────────────────────┐
│                            PRESENTATION LAYER                           │
│   FlowScreen   │   ExploreScreen   │   MetricsScreen   │  SettingsTab   │
│         (Apple-Inspired Frosted Liquid Glass System · 120 FPS)          │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
┌────────────────────────────────────▼────────────────────────────────────┐
│                         IN-FLIGHT SYNC PIPELINE                         │
│       Optimistic Toggle Registry  ·  Debounced Database Synchronization │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
┌────────────────────────────────────▼────────────────────────────────────┐
│                              DOMAIN ENGINES                             │
│     CurriculumIngestionEngine     │       AmbientWeatherService         │
│     (YouTube / Markdown / JSON)   │       (Open-Meteo & BigDataCloud)   │
│     DailyQuoteService (Offline)   │       AutoBackupManager (Atomic)    │
└────────────────────────────────────┬────────────────────────────────────┘
                                     │
┌────────────────────────────────────▼────────────────────────────────────┐
│                            PERSISTENCE LAYER                            │
│                 Embedded SQLite Database (Foreign Keys ON)              │
│       RoadmapRepo  │  ChapterRepo  │  BeatRepo  │  BeatLogRepo          │
└─────────────────────────────────────────────────────────────────────────┘
```

For detailed architectural guidelines, review:
- **[Architecture Blueprints](.agents/ARCHITECTURE.md)**
- **[Codebase Map](.agents/CODEBASE_MAP.md)**
- **[Developer & Testing Guide](.agents/DEVELOPER_GUIDE.md)**

---

## 🛠️ Getting Started & Local Development

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.2.x+ stable)
- Android Studio / Xcode command line tools
- Java 17 (recommended for Gradle build toolchain)

### Setup & Run Commands

```bash
# 1. Clone the repository
git clone https://github.com/itsurajx/rythem-app.git
cd rythem-app

# 2. Switch to active release branch
git checkout release/v2.1.2

# 3. Install dependencies
flutter pub get

# 4. Verify static analysis (0 warnings / 0 errors)
flutter analyze

# 5. Run full test suite (176+ unit and widget tests)
flutter test

# 6. Build release APK
flutter build apk --release
```

---

## 🤝 Contributing

We welcome contributions aligned with Rythem's design ethos:
1. **Branching**: Always branch from `master` or current `release/v*`.
2. **Commit Standards**: Sign off on all commits with Developer Certificate of Origin: `git commit -s`.
3. **Design System**: Use `RythemColors`, `RythemTypography`, and standardized glass card surfaces.
4. **Zero-Warning Guarantee**: Ensure all code passes `flutter analyze` and `flutter test`.
5. **Changelog**: Add your contributions to [CHANGELOG.md](CHANGELOG.md).

---

## 📄 License

Distributed under the **PolyForm Noncommercial License 1.0.0**. See [LICENSE](LICENSE) for terms.

<div align="center">
<sub>Crafted with care for autonomous, lifelong learners.</sub>
</div>
