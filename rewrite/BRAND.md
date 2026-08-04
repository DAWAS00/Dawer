# Ghuson (غصن) — Developer Brand Tokens

Distilled from *Ghuson Brand Identity Guidelines v1.0 (2026, Applied Science University)* — full doc + master logo in `rewrite/brand/`.
**Identity:** Ghuson · غصن · "The Operating System for the Circular Economy" · domain `ghuson.io`
**Feel:** Linear/Notion/Swiss — technology-led, quietly premium. NOT eco-campaign green. Dark theme leads product surfaces.

## Color — "Copper Patina"

### Light theme
| Token | Hex | Use |
|---|---|---|
| primary | `#13605B` | brand, primary actions, links |
| deepAnchor | `#183B38` | headlines, depth |
| ink | `#1F2926` | body text |
| muted | `#68736E` | captions, secondary text |
| border | `#D8DDD7` | dividers, outlines |
| canvas | `#F4F1EA` | app background (never pure white) |
| surface | `#FFFCF6` | cards, sheets |

### Dark theme (leads product UI)
| Token | Hex | Use |
|---|---|---|
| brandPrimary | `#6FB8AE` | primary/links on dark (AA 7.4:1 on scaffold) |
| scaffold | `#101C1B` | app background |
| surface | `#172623` | cards |
| surfaceVariant | `#20312E` | elevated/nested surfaces |
| onSurface | `#F5F1EA` | headings + body |
| muted | `#A7B6B0` | captions |
| border | `#344943` | dividers |

### Secondary & accent (both themes)
| Token | Hex | Rule |
|---|---|---|
| patinaLight | `#6FB8AE` | secondary UI, charts |
| patinaTint | `#E5EEEB` | quiet fills, surface tint |
| copperSignal | `#A9744E` | THE single data-highlight accent — never body text |
| alert | `#B7472F` | destructive/error states ONLY |

### Neutrals
`N900 #1F2926 · N700 #3A453F · N500 #68736E · N400 #9AA39D · N300 #D8DDD7 · N200 #E5E2DA · N100 #F4F1EA · N0 #FFFCF6`

## Typography

| Script | Family | Weights | Notes |
|---|---|---|---|
| Latin | **Hanken Grotesk** | 300–800 | display + body; tabular figures for data |
| Arabic | **IBM Plex Sans Arabic** | 300–700 | Arabic-first companion, matched rhythm |

Scale: Display 64/600/-3% · Heading 40/600/-2% · Subheading 24/500 · Body 16/400/1.65 · Label 12/500/+12%.
Weights: Medium = workhorse UI · SemiBold = headlines/brand · ExtraBold = rare emphasis.
Replaces legacy Cairo / DM Sans everywhere.

## Logo & mark

- Mark = Arabic غ (Ghayn) as one monoline stroke, branch → leaf, two node terminals. Master files in `rewrite/brand/` — never reconstruct, rotate, stretch, recolor, or add effects.
- Clear space = one node height on all sides. Minimums: screen 32 px, favicon 16 px; below 90 px use icon-only (no wordmark).
- App icon: rounded square / circle / tinted variants per guidelines.
- Don't place teal mark on low-contrast backgrounds; cream + reversed variants exist for dark surfaces.

## Shape language

Monoline strokes, circular nodes, continuous arcs. Corner radius scale: **6 sm · 12 md · 18 lg · full**. Icons: 24px grid, logo stroke weight, rounded terminals; two-tone = primary + brandPrimary only. Background motifs (flow lines / node grid / enlarged mark): one per surface, low contrast, sparing.

## App-specific rulings

- Canvas `#F4F1EA` replaces pure white in light theme; scaffold `#101C1B` in dark.
- Product surfaces are dark-led per guidelines — app defaults to dark theme with light available (flip of the legacy default).
- "Green Score" is a first-class brand concept in app mockups (node cards + score) — carry the naming into the credits/analytics features.
- Voice: simple & direct, evidence-driven, optimistic, professional. Arabic-first copy.
