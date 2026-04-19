# Gamma Presentation Prompt — Dwaar App

## Instructions for Gamma

Use this prompt to generate an **8-slide professional presentation** about the Dwaar (دوّر) mobile application. The presentation should be clean, modern, and minimal — suitable for an academic or startup pitch context. Use a green-and-white color palette (primary green: #2E7D32, accent amber: #FFC107, background: white or very light gray). Include the app screenshots provided alongside this prompt in the relevant slides.

---

## App Context (Read before generating)

**App Name:** Dwaar (دوّر)
**Meaning:** Arabic for "search" / "recycle"
**Platform:** Flutter mobile app (iOS & Android)
**Market:** Jordan — Arabic-speaking users, RTL interface
**Domain:** Waste recycling logistics

**Three user roles:**
- **Supplier** — individuals or businesses that have recyclable waste to give away
- **Driver** — collects and transports waste from suppliers
- **Recycling Company** — receives waste, posts orders on marketplace

**Core flow:** Supplier posts waste → Driver picks up → Recycling Company receives → waste is recycled

**AI feature:** An integrated AI assistant (chatbot) inside the app that helps users navigate orders, understand waste types, and get smart recommendations.

---

## Slide Content Instructions

### Slide 1 — Current Situation & Opportunity
**Title:** The Recycling Gap in Jordan
- Jordan generates significant solid waste daily with low formal recycling rates
- Informal recycling sector is fragmented — no digital coordination between suppliers, drivers, and recycling companies
- Growing environmental awareness + government pressure creates a market opportunity
- Gap: no mobile platform exists that connects all three recycling stakeholders in Arabic
- Include: one app screenshot showing the home dashboard

### Slide 2 — Related Work
**Title:** What Exists Today
- Brief comparison table or bullet list of existing solutions:
  - WhatsApp groups / informal coordination (no tracking, no accountability)
  - General logistics apps (not waste-specific, not Arabic-first)
  - Municipality portals (web-only, no role-based mobile flows)
  - International apps (RecycleNation, iRecycle) — not localized for Arab markets
- Gap: none combine role-based access + Arabic RTL + AI assistant + live order tracking

### Slide 3 — Problem Statement
**Title:** The Problem
- Recyclable waste is lost because suppliers don't know where to send it
- Drivers operate without digital dispatch or route context
- Recycling companies have no visibility into incoming supply
- Language barrier: no Arabic-first recycling logistics platform in Jordan
- Result: recyclable material ends up in landfill due to coordination failure
- Include: app screenshot showing order list or tracking screen

### Slide 4 — Solution
**Title:** Dwaar — Closing the Loop
- One mobile app, three tailored role-based experiences (Supplier, Driver, Recycling Company)
- End-to-end order lifecycle: creation → pickup → delivery → completion
- Marketplace where recycling companies post open orders
- Real-time order status tracking for all parties
- Fully Arabic, RTL, portrait-only — built for Jordan users
- Include: app screenshot showing the role picker or marketplace

### Slide 5 — Project Objectives
**Title:** What We Set Out to Build
1. Digitize the waste pickup request flow for suppliers
2. Give drivers a mobile dispatch and tracking tool
3. Give recycling companies a marketplace and order management dashboard
4. Make the entire experience Arabic-first and culturally appropriate for Jordan
5. Embed an AI assistant to reduce user friction and support decision-making
6. Lay a scalable foundation for future backend integration

### Slide 6 — AI Core: Bridging Vision and Reality
**Title:** AI at the Heart of Dwaar
- Integrated AI chatbot accessible from every role's home screen
- Powered by a large language model with app-specific context
- Use cases:
  - Supplier: "What waste types can I recycle?" → instant answer in Arabic
  - Driver: "Which order should I prioritize?" → smart suggestion
  - Recycling Co: "Summarize today's incoming orders" → quick digest
- The AI bridges the gap between a complex logistics workflow and non-technical users
- Include: app screenshot of the AI chatbot screen

### Slide 7 — Technology & Tools Used
**Title:** Built With
Present as a clean icon/badge grid or two-column list:

| Layer | Technology |
|---|---|
| Mobile Framework | Flutter (Dart) |
| Architecture | MVVM + Provider |
| UI | Material 3, Google Fonts, RTL |
| AI Assistant | LLM API integration (chatbot) |
| Image Processing | ML Kit (barcode/label scan) |
| State Management | ChangeNotifier / Provider |
| Navigation | Imperative (Navigator.push) |
| Data (current) | Mock layer — ready for backend |
| Platform | iOS & Android |
| Design System | Custom AppColors + AppTheme |

### Slide 8 — Conclusion & Future Work
**Title:** What's Next for Dwaar
**Conclusion (2–3 bullets):**
- Dwaar proves that a role-based, Arabic-first recycling logistics platform is buildable and usable
- The AI assistant reduces onboarding friction and adds intelligence to a traditionally manual process
- The architecture is clean and backend-ready

**Future Work:**
- Live backend: REST API + real-time database (orders, users, tracking)
- GPS route optimization for drivers
- Gamification: supplier rewards for recycling milestones
- Analytics dashboard for recycling companies
- Expansion to other Arab cities and countries
- Carbon footprint tracker per order

Include: final app logo or a collage of multiple app screens

---

## Presentation Style Notes for Gamma
- Tone: professional, confident, slightly academic
- Slide layout: title + 3–5 bullet points max per slide (no walls of text)
- Use icons or visuals where possible instead of long sentences
- Place provided app screenshots prominently — they are the proof of concept
- 8 slides total, no more
