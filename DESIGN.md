# Kleer Design System

This document describes the actual design language of kleer.la as implemented in the codebase (2024-2026). It serves as the source of truth for visual consistency across pages.

---

## 1. Color Palette

### Brand Colors

| Token | Hex | SCSS Variable | Usage |
|-------|-----|---------------|-------|
| Primary Blue | `#68CEF2` | `$primary-blue` | Hero backgrounds, brand identity, highlights |
| Secondary Blue | `#00BBEE` | `$secondary-blue` | Link hover, accents, TOC titles |
| Blue Kleer | `#7bcaea` | `$blue-kleer` | Softer brand blue, secondary surfaces |
| Celeste | `#E8F8FD` | `$celeste` | Light backgrounds (resources hero) |

### Accent Colors

| Token | Hex | SCSS Variable | Usage |
|-------|-----|---------------|-------|
| Primary Yellow | `#FFE600` | `$primary-yellow` | Decorative elements, category flags |
| Secondary Yellow | `#FCDC2D` | `$secondary-yellow` | Badges, highlights |
| Primary Red | `#EF5662` | `$primary-red` | Alerts, decorative shapes |
| Secondary Red | `#EA2A46` | `$secondary-red` | Error states |
| Primary Green | `#43B045` | `$primary-green` | Success, positive indicators |
| Secondary Green | `#0DAC52` | `$secondary-green` | Confirmation |

### CTA & Neutrals

| Token | Hex | SCSS Variable | Usage |
|-------|-----|---------------|-------|
| CTA Orange | `#FFA901` | `$primary-cta` | Primary buttons, call-to-action |
| Black | `#333333` | `$black` | Body text, headings |
| Grey | `#B3B3B3` | `$grey` | Secondary text, metadata |
| Soft Grey | `#D9D9D9` | `$soft-grey` | Borders, dividers |
| Card Grey | `#EAEAEA` | `$grey-card` | Card backgrounds |
| White | `#FFFFFF` | `$white` | Page background |

### Service Area Dynamic Colors

Each service area defines its own color set via API (primary, secondary, font colors). These are injected as CSS custom properties (`--background-primary`, `--text-primary`, etc.) to theme hero sections and cards per area.

---

## 2. Typography

### Font Stack

- **Headings (H1):** `"degular", sans-serif` — weight 600. Loaded from Adobe Typekit.
- **Headings (H2-H6):** `"degular-text", sans-serif` — weight 600 (H2-H3), 700 (H4-H6).
- **Body:** `"Raleway", sans-serif` — weight 400. Google Fonts.
- **Base size:** `112.5%` (18px on 16px browser default). All sizing uses `rem`.

### Scale

| Role | Desktop | Mobile (<420px) | Weight |
|------|---------|-----------------|--------|
| H1 | 4rem (72px) | 2.222rem (40px) | 600 |
| H2 | 3.111rem (56px) | 1.778rem (32px) | 600 |
| H3 | 2.222rem (40px) | 1.333rem (24px) | 600 |
| H4 | 1.778rem (32px) | 1.111rem (20px) | 700 |
| H5 | 1.333rem (24px) | 1rem (18px) | 700 |
| H6 | 1.111rem (20px) | — | 700 |
| Body (p) | 1rem (18px) | — | 400 |
| Small label | 0.833rem (15px) | — | 400/700 |
| Hero description | 1.222rem (22px) | — | 400 |
| Common subtitle | 1.778rem (32px) | 1.111rem (20px) | 700 |
| Common item | 1.333rem (24px) | — | 600 |

### Text Colors

- Body text: `$black` (#333333) — never pure `#000`
- Links: `$black` default, `$secondary-blue` on hover
- No underlines on links (decoration: none)

---

## 3. Buttons

### Primary Button (`.my-primary-button`)

- Background: `$primary-cta` (#FFA901, orange)
- Text: `$black` (#333333)
- Height: 2.889rem (52px)
- Padding: 0.889rem 1.778rem (16px 32px)
- Border-radius: 100px (pill)
- Font: 600 weight, 1rem
- Max-width: 300px
- Hover: `box-shadow: 0px 8px 26px rgba(51, 51, 51, 0.2)`

### Secondary Button (`.my-secondary-button`)

- Background: `$white`
- Border: 2px solid `$primary-cta`
- Same dimensions and radius as primary
- Hover: subtle shadow, same border

### Utility Buttons

- `.clean-button` — white, borderless, for reset/clear actions
- `.blue-link` — `$primary-blue` text, no border, bold. Used for inline actions.

---

## 4. Layout Framework

### Grid

- **Bootstrap 5.0.2** — standard 12-column grid
- Common breakpoints: `col-lg-*` (992px), `col-md-*` (768px), `col-sm-*` (576px)
- Container: Bootstrap `.container` (max-width ~1140px) and `.container-fluid`

### Responsive Breakpoints

| Breakpoint | Width | Behavior |
|------------|-------|----------|
| Desktop | 992px+ | Multi-column, full nav, decorative SVGs visible |
| Tablet | 768–991px | 1-2 columns, hamburger nav, `.desktop_figure` hidden |
| Mobile | <768px | Single column, stacked cards, `.mobile_figure` shown |
| Small mobile | <420px | Reduced heading sizes, compact spacing |

### Page Skeleton

```
<body>
  ├── Sticky navbar (_menu.erb)
  ├── Flash messages (_flash_messages.erb)
  ├── Page content (yield) — starts at margin-top: 100px
  ├── Footer (_footer.erb)
  ├── Contact modal (_modal_contact.erb)
  └── Bootstrap JS + utils.js
```

---

## 5. Component Library

### Hero Sections

| Variant | Height | Background | Content | Used on |
|---------|--------|------------|---------|---------|
| Full hero | calc(100vh - 100px) | Varies (blue, gradient, image) | Title + description + CTA + image | Home |
| Medium hero (`.hero-medium`) | 70vh | `$primary-blue` | Centered title + subtitle | Blog listing |
| Generic hero (`.generic-hero`) | Auto | Solid color | H1 + subtitle + decorative SVGs | Catalog, about |
| Service hero | 70vh | Dynamic area color | Title + description + illustration | Services |
| Light hero | 60vh | `$celeste` (#E8F8FD) | Centered title + subtitle | Resources |

### Cards

| Type | Width | Features | Used on |
|------|-------|----------|---------|
| Course card | Responsive grid | Image + badge overlay, category, metadata (duration/date), CTA | Catalog, agenda |
| Article card (`.blog-card`) | 22rem, 530px height | Image + category flag, title, description, author + date | Blog listing |
| Resource card | 18rem (inline) | Image + title + description, mobile flip behavior | Resources |
| Client card | 22rem | Logo image, optional industry label | Clients |
| Trainer card | Flexible | Round photo, name, role badge, bio, social links | About, blog |
| Service card | Flexible, 330px min-h | Colored header matching area, title, description, link | Services |

### Common Shadows

- Cards: `box-shadow: 0px 18px 76px rgba(51, 51, 51, 0.1)` — diffused, subtle
- Buttons hover: `box-shadow: 0px 8px 26px rgba(51, 51, 51, 0.2)` — tighter
- Search box: `box-shadow: 0px 18px 76px rgba(51, 51, 51, 0.1)` — same as cards

### Border Radius

- Buttons: 100px (pill)
- Cards: 8px
- Images in detail pages: 14-20px
- Content table: 16px
- Modals/containers: 1rem (16px)

### Decorative SVG Elements

The site uses scattered, absolutely-positioned SVG shapes for visual energy:
- Yellow bean, yellow circle, yellow oval
- Green bean, green worm
- Red circle, red triangle, red bean
- Blue oval, rustic asterisk
- Hidden on tablet/mobile via `.desktop_figure` / `.mobile_figure` classes

---

## 6. Navigation

### Navbar

- Sticky, fixed top
- Logo left, 5 dropdown menu groups center, orange CTA button right
- Scroll behavior: adds `.navbar-scrolled` class (shadow/background change)
- Collapses to hamburger at 992px
- Language selector (ES/EN)

### Footer

- 4-column layout (3 content + 1 social/legal)
- Content columns configurable from locale YAML
- Last column: social icons, newsletter form (ES), copyright, privacy/terms, language switcher
- Collapses to 2-column on mobile

---

## 7. Page Design Maturity

Not all pages share the same design generation. The modern pages use the full design language; older pages are more utilitarian.

### Modern Pages (current design language)

- **Home** — full hero with animated text highlights, service cards, client grid, layered SVG decorations
- **Services** — dynamic area theming, large cards with 3D hover, expandable content sections, generous whitespace (60-80px margins)
- **Course landing** — structured sections (takeaways, program, trainers, testimonials, FAQ), rich metadata

### Dated Pages (functional but visually behind)

- **Blog listing** — plain card grid, minimal visual hierarchy, no featured/pinned articles, body text at 16px (vs. site standard 18px)
- **Blog article** — good TOC sidebar, but body text styling diverges from site conventions, limited visual richness
- **Resources hub** — rigid card widths (18rem inline style), mobile "flip" interaction feels dated, minimal color
- **Resource detail** — functional form-heavy layout, assessment forms use basic gray/border styling
- **Nuestra filosofia** — orphan page in `views/old_page/`, not reachable from navigation

---

## 8. Improvement Plan: Blog & Resources

### New Accent Colors

For blog and resources, introduce a turquoise palette to differentiate these content sections while staying on-brand:

| Token | Hex | Usage |
|-------|-----|-------|
| Turquoise Dark | `#2d6a9f` | Hero backgrounds, section headers, TOC accents |
| Turquoise Light | `#a5e4f1` | Card hover states, category tags, surface tints |

These complement the existing blue family (`$primary-blue` #68CEF2) but give blog/resources their own identity, similar to how service areas each have their own color.

### Blog Listing — Proposed Improvements

**Current issues:**
- Cards are uniform — no visual hierarchy between featured and regular articles
- Category flag is a small yellow label — easily missed
- No hover interaction on cards
- Search box floats below hero with basic styling
- Body text at 16px is smaller than the site's 18px standard

**Suggestions:**

1. **Featured article hero card** — First article spans full width with large image left + title/excerpt right, using `#2d6a9f` as background with white text. Creates immediate visual anchor.

2. **Category chips** — Replace yellow flag with pill-shaped chips using `#a5e4f1` background and `#2d6a9f` text. More visible and tappable.

3. **Card hover state** — Add `transform: translateY(-4px)` and elevated shadow on hover (matching service cards). Border-top: 3px solid `#2d6a9f` on hover for a color accent.

4. **Reading time badge** — Add estimated reading time in the card metadata row (clock icon + "5 min"). Data likely available from article word count.

5. **Search box redesign** — Integrate into hero section instead of floating below. Use `#2d6a9f` accent on focus state. Add magnifying glass icon inside the input.

6. **Fix body text** — Normalize blog body to 1rem (18px) to match the rest of the site.

7. **Hero gradient** — Replace flat `$primary-blue` with a gradient: `linear-gradient(135deg, #2d6a9f 0%, #a5e4f1 100%)` for more depth.

### Blog Article — Proposed Improvements

**Current issues:**
- TOC sidebar uses `$secondary-blue` title — disconnected from blog identity
- No reading progress indicator
- Author section is a horizontal scroll — feels dated on mobile
- Article body paragraph is justified text (hard to read on narrow screens)

**Suggestions:**

1. **TOC accent** — Use `#2d6a9f` for TOC title and active-item highlight. Add a thin left border (3px solid `#2d6a9f`) on the active section.

2. **Reading progress bar** — Thin bar at the top of the viewport, filled with `#2d6a9f`, tracking scroll position. Lightweight JS addition.

3. **Author cards** — Stack vertically on mobile instead of horizontal scroll. Use `#a5e4f1` as background tint for the author section.

4. **Text alignment** — Change body text from `text-align: justify` to `left` for better readability on all screen sizes.

5. **Blockquote styling** — Add left border in `#2d6a9f` (4px) with `#a5e4f1` background tint for blockquotes.

### Resources Hub — Proposed Improvements

**Current issues:**
- Cards use inline `width: 18rem` — rigid, doesn't adapt to grid
- Mobile flip interaction (JS toggles image/text) feels dated
- Hero is plain `$celeste` with basic circles — less dynamic than other pages
- No resource type filtering (all types mixed in one grid)

**Suggestions:**

1. **Remove inline card width** — Use CSS Grid or Bootstrap grid (`col-*`) to let cards fill available space. Minimum 280px, maximum 1fr.

2. **Replace card flip with overlay** — On mobile, show title overlaid on image (white text on dark gradient) instead of flipping. On hover (desktop), reveal description with a slide-up panel using `#2d6a9f` semi-transparent background.

3. **Resource type filter bar** — Horizontal chip bar below hero: "All | E-books | Tools | Assessments | Posters". Chips use `#a5e4f1` background, active chip uses `#2d6a9f` with white text.

4. **Hero upgrade** — Gradient background `linear-gradient(135deg, #2d6a9f 0%, #a5e4f1 100%)` with white text. Match the depth of service-area heroes.

5. **Type badge on cards** — Small pill badge (top-left of image) indicating resource type, using `#2d6a9f` background with white text.

### Resource Detail — Proposed Improvements

**Current issues:**
- Download form is utilitarian (plain Bootstrap inputs, gray backgrounds)
- Assessment forms use `#f8f9fa` gray with green left-border — disconnected from blog/resources palette

**Suggestions:**

1. **Form styling** — Use `#a5e4f1` as input focus ring color. Section headers in `#2d6a9f`. Replace gray assessment backgrounds with very light turquoise tint.

2. **Hero consistency** — Use `#2d6a9f` as hero background (replacing dynamic `var(--background-primary)` which defaults to `$primary-blue`). White text for contrast.

3. **Download CTA** — Keep orange primary button but add a `#2d6a9f` secondary "Preview" button option for resources that have previews.

---

## 9. Implementation Priority

For the blog & resources refresh, suggested order:

1. **Add SCSS variables** — `$turquoise-dark: #2d6a9f` and `$turquoise-light: #a5e4f1` to UIKit.scss
2. **Blog listing hero gradient + category chips** — highest visual impact, low effort
3. **Card hover states** — small CSS addition, big polish gain
4. **Resource card grid refactor** — remove inline widths, use CSS grid
5. **Resource type filter bar** — improves usability significantly
6. **Blog featured article** — requires template change but big visual upgrade
7. **TOC + reading progress** — nice-to-have polish for blog articles
8. **Resource detail form styling** — lower priority, smaller audience
