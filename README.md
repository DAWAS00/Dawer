# Dwaar (دوّر) — Recycling Logistics Marketplace

Dwaar (دوّر) is an Arabic-first, RTL-oriented mobile marketplace for recycling logistics in Jordan. It acts as a three-sided platform connecting Suppliers (households, restaurants, businesses), Drivers (gig transporters), and Recycling Companies (buyers) to manage collection jobs and process recyclable waste.

---

## 🚀 Navigation & Developer Entry Points

Below are the primary guides and instructions for developers and agent environments:

| Guide | Description | File Link |
| :--- | :--- | :--- |
| **Codebase Master Docs** | The central index for all codebase architecture guides, plans, and system designs. | [docs/README.md](docs/README.md) |
| **Agent Guide** | Standard workflow rules, folder structures, environment variables, and code style. | [AGENTS.md](AGENTS.md) |
| **Claude Cheatsheet** | Fast cheat sheet for commands, local linting, building, and running. | [CLAUDE.md](CLAUDE.md) |
| **Gemini CLI Config** | Knowledge management flow and Obsidian vault integration checklist. | [GEMINI.md](GEMINI.md) |

---

## 📁 Repository Directory Structure

A high-level map of where files live in this workspace:

```
dwaar/
├── docs/                   # Master folder for architecture, plans, and specs
│   ├── codebase-guide/     # Complete 9-part developer walk-through
│   ├── plan/               # Implemented feature specifications
│   ├── supabase/           # Supabase backend schema and policies guides
│   └── system-design/      # Word documents and architecture flowcharts
├── devPlans/               # Historical and active developer status reports
├── lib/                    # Flutter application source code
│   ├── core/               # Cross-cutting concerns (theme, config, Result monad)
│   ├── data/               # Models, concrete repositories (Supabase/Mock), and services
│   ├── domain/             # Entities and repository interfaces (no external frameworks)
│   └── ui/                 # Presentation layer (MVVM via Provider + ChangeNotifier)
├── supabase/               # Backend Deno Edge Functions and SQL migrations
└── wiki/                   # Conceptual reference documents
```

---

## 🛠️ Tech Stack Highlights

*   **Mobile App**: Flutter 3.x (Dart SDK `^3.8.0`)
*   **State Management**: `provider` + `ChangeNotifier` (Single source of truth: `AppOrderStore`)
*   **Database & Auth**: Supabase (Postgres, Row Level Security, Realtime tables, Phone OTP Auth)
*   **Location & Tracking**: Foreground GPS publishing (`geolocator`) + geofenced arrivals
*   **Artificial Intelligence**: Google Gemini API (`google_generative_ai` / Gemini 1.5 Flash) + Google ML Kit Image Labeling
*   **Localization**: Bilingual Arabic-first RTL support (`Cairo` font)

---

> For detailed setup commands, running instructions, and deployment guides, please open the master [docs/README.md](docs/README.md) folder index.
