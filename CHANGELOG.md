# Release

## v2.1.1
- **Open Lab CSV Export**: Enabled the Download CSV action (`Icons.download_rounded`) for Open Lab in both `ExploreScreen` and `RoadmapDetailScreen` so Open Lab topics can be exported to local storage just like regular trackers.
- **Metrics 7-Day Beat Graph Bar Color**: Updated non-today active-day bars in the 7-day beat graph (`PerformanceGraphsCard`) to solid `Colors.black` in light mode instead of muted grey.

## v2.1.0
- **Self-Paced & Scheduled Tracker Modes**: Added a `Tracker Mode` selector (`With Dates` vs. `No Dates`) when creating new tracks so learners can choose either scheduled start/target deadlines or open-ended, self-paced tracks with zero date pressure.
- **Per-Tracker CSV Export & Topic Start Tracking**: Added a Download CSV action (`Icons.download_rounded`) inside each main tracker (`RoadmapDetailScreen` and `ExploreScreen` cards) to export `topic-name`, `topic start date`, `topic end date`, and `total number of days taken to finish that topic` to local storage, backed by a clean SQLite v3 `beats.started_at` migration.
- **Creator & Contributors Card in Settings**: Added a Liquid Glass `CREATOR & CONTRIBUTORS` card in Settings fetching `@itsurajx`'s GitHub profile avatar, bio, and repository contributors with offline caching and graceful fallback.
- **GitHub Repository Handle Migration**: Updated in-app update endpoints, fallback AI model download links, tests, and documentation from `ImSurajx/rythem-app` to `itsurajx/rythem-app`.

## v2.0.0
- **User-Defined Beat & Effort Points Preservation**: Full Markdown and JSON syllabus parsing support for custom beat/effort weights across bracket notations (`[2.5]`, `[effort: 3.0]`, `[2.5 beats]`, `[2 pts]`), parenthetical notations (`(2.5)`, `(3 beats)`), delimiters (`| 2.5 beats`, `- 2.5 beats`, `: 2.5 beats`), and prefix notations.
- **Accurate Roadmap Effort Accounting**: When creating tracks from syllabus files or pasted markdown, user-specified effort points are strictly honored and preserved when no resource is attached, cleanly reflecting total effort in pacing budgets, progress meters, and metrics dashboards.
- **Resource Attachment & Gap Preservation**: When attaching video resources to subjects/chapters, covered videos cleanly adopt duration-based effort weights while uncovered syllabus benchmark gaps preserve their custom user-defined effort weights rather than resetting to default.
- **Enhanced SyllabusTopic Data Architecture**: Upgraded `SyllabusTopic` with native `effortPoints` modeling, safe numeric type-casting, and serialization parity across database entities and ingestion parsers.

## v1.1.9
- **Real Location Weather & Natural Diurnal Greetings**: Integrated GPS-based live ambient weather using Open-Meteo and BigDataCloud free APIs (zero signup, zero API keys) with accurate diurnal time-of-day greetings (e.g. 1 AM is classified as night, reflecting true diurnal and weather conditions).
- **Daily Inspirational Quotes**: Seamless daily quote integration in Flow Screen powered by ZenQuotes and DummyJSON free public endpoints (zero signup, zero keys) with an offline curated mastery reserve.
- **Minimalist Apple-Style Onboarding**: Streamlined first-launch wizard with clean circular raw icon navigation, elegant progress indicators, and removed box shadows for crisp icon rendering.
- **Open Lab Progress Tracking & Pinned Header**: Open Lab card now features a dedicated progress meter and stays pinned to the top of the Explore screen for persistent visibility, with refined icon styling.
- **Flag Notes & Friction Deletion**: Direct deletion on Explore flag note cards, "Remove Flag" action in confusion dialogs, and one-tap reflection clearing in checkpoint dialogs.
- **Global App UI Enhancement**: Overhauled visual aesthetics with electric cyan and amber accent gradients, luminous glowing progress meters, liquid glass cards, and an elevated frosted bottom navigation dock.
- **In-Place Backup Engine Replacement**: Overhauled local backup storage to atomically replace and update the master backup file in place, preventing timestamped file clutter and conforming to global button styling.
- **Global Terminology Shift to "Beats"**: Unified progress tracking and task weights to "Beats" across metrics, flow screens, checkpoint dialogs, custom tasks, roadmaps, and offline AI mentors.
