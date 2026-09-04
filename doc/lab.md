# Kleer Lab (`lab.kleer.la`)

This document summarizes **why** Kleer Lab exists and **how** it is served from
this Sinatra app. It is the distilled replacement for the standalone Rails
repo's design docs — the old `openspec/` and `docs/` trees were intentionally
**not** carried over during the migration.

## Why

**Kleer Lab** is a sub-brand of Kleer (`www.kleer.la`). Its single offering,
**"Soluciones Express"**, transforms manual business processes into
AI-powered applications in weeks, for **PyMEs (SMBs) that have no internal
technical team**.

The positioning is deliberately narrow (May 2026 strategic pivot,
"pivot-lab-to-pyme-segment"):

- **One audience.** An earlier attempt tried to speak simultaneously to SMBs
  without tech staff *and* to companies with a saturated tech department. A
  single voice for two buyers convinced neither, and the only two publishable
  case studies (CenPed, Importador China-Colombia) both belong to the SMB
  segment. Lab now addresses **only** PyMEs without an internal tech team.
- **The laboratory metaphor is the differentiator.** The scientific method
  applied to an SMB's operations — hypothesis → experiment → measurement →
  transfer — is what separates Lab from a traditional consultancy. The home
  page's "Cómo trabajamos" section is built around those four steps.
- **Measurable, no lock-in.** Results from the first iteration, full handover
  of code and context to the client's team.

Canonical value proposition (Spanish only; the site is not multilingual):

> **Kleer Lab: soluciones operativas sostenibles con IA en tiempo récord.**
> Transformamos procesos manuales en aplicaciones inteligentes en semanas, sin
> requerir equipo técnico interno. Resultados medibles desde la primera
> iteración.

## How

Kleer Lab was originally a **standalone Rails 8 app** deployed to
`lab.kleer.la`. It has been **ported into this Sinatra app** and is served on
the `lab.` subdomain, mirroring the existing **L'Atelier** pattern — one
codebase, one deploy. The old Rails service is retired.

### Serving model

- **Subdomain detection** — `app.rb`'s `before` filter sets
  `@is_lab = request.host.start_with?('lab.') || request.host.start_with?('qa.lab.')`.
  Lab hosts are never redirected (`unify_domains` uses an exact-match list).
- **Routes** — `controllers/lab_controller.rb` owns `/contacto` (GET/POST),
  `/contacto/gracias`, and `/casos/:slug`, each guarded with
  `pass unless @is_lab` so other hosts are unaffected. The shared `/` and
  `/sitemap.xml` routes call `handle_lab_home` / `handle_lab_sitemap` when
  `@is_lab`. `lab_controller` is required before the `/:slug` flagship
  catch-all so `/contacto` resolves to Lab.
- **Views** — `views/lab/*.erb` with a dedicated `views/lab/layout.erb`
  (`erb :'lab/...', layout: :'lab/layout'`). Helpers live in
  `lib/helpers/lab_seo_helper.rb` (titles/descriptions/canonical + JSON-LD
  Organization/Article/BreadcrumbList) and `lib/helpers/lab_view_helper.rb`
  (section header builder, contact email, WhatsApp link).

### Content

- Case studies are **Markdown files with YAML front matter** in
  `data/lab/cases/*.md` (currently `cenped.md`, `importador-china-colombia.md`).
  `lib/models/lab_case.rb` (a plain-Ruby port of the old `CaseRecord`) parses
  them and drives the home metrics, case cards, and `/casos/:slug` pages.
- **Zero new dependencies:** front matter is parsed with stdlib `YAML`, and the
  Markdown body is rendered with the app's existing redcarpet wrapper
  (`lib/helpers/custom_markdown.rb`) — no `front_matter_parser`/`kramdown`.

### Contact form

The contact form reuses website17's existing Keventer integration: it verifies
reCAPTCHA (`verify_recaptcha`) and forwards leads through `send_mail` /
`Mailer` (`lib/services/mailer.rb`), which POSTs to Keventer's `contact_us`
endpoint with `CONTACT_US_SECRET` — the same endpoint the old Rails app used.
No background job or separate HTTP client was ported.

### Assets & design system

- Static assets live under `public/lab/` (`application.css`, `lab.js`, brand
  images). The stylesheet is the hand-written **"Kinetic Laboratory"** design
  system (~1,300 lines of plain CSS — tokens + components + utility classes; no
  Tailwind or other framework).
- `public/lab/lab.js` is a small vanilla-JS reimplementation of the old
  Stimulus contact-modal controller (open/close, backdrop, Esc). No
  Stimulus/Turbo/importmap.
- The theme A/B experiment (`?theme=`) and PWA manifest/service-worker from the
  old repo were intentionally dropped; only the single default theme ships.

### Analytics

Lab shipped without any analytics: GTM lived only in `views/layout/layout2022.erb`.
`views/lab/layout.erb` now includes the same partials, and so the same container
(`GTM-W5H5CPKF`) as the main site.

Events are pushed to `dataLayer` from `public/lab/lab.js`, all prefixed `lab_`
so they are easy to isolate in GTM. Elements are marked in the views rather than
selected by class, so restyling cannot silently break measurement:

| Event | Marked with | Where |
|---|---|---|
| `lab_cta_hero` | `data-lab-track="cta_hero"` | hero primary button |
| `lab_cta_navbar` | `data-lab-track="cta_navbar"` | "Escríbenos", top bar |
| `lab_cta_cierre` | `data-lab-track="cta_cierre"` | closing CTA |
| `lab_cta_footer` | `data-lab-track="cta_footer"` | "Escríbenos", footer |
| `lab_caso` | `data-lab-track="caso"` | case cards; carries `lab_caso` with the slug |
| `lab_whatsapp` | `data-lab-track="whatsapp"` | WhatsApp button |
| `lab_correo` | `data-lab-track="correo"` | the two mailto links |
| `lab_formulario_abierto` | — | pushed whenever the modal opens |
| `lab_formulario_enviado` | `data-lab-event` on `thanks.erb` | /contacto/gracias, the conversion |

The four CTAs fire their own event *and* `lab_formulario_abierto`, so a funnel
can be built without losing which button started it.

`track()` creates `window.dataLayer` if it does not exist, so a blocked or
absent container breaks nothing.

Note the contact email is a `mailto:` link now. It used to be plain text, which
meant there was nothing to click and nothing to measure.

### Deploy

`lab.kleer.la` is listed in `config/deploy.yml` `proxy.hosts` (and
`qa.lab.kleer.la` in `config/deploy.qa.yml`). Kamal-proxy routes it to the same
website17 container. Required secrets (`KEVENTER_URL`, `CONTACT_US_SECRET`,
`RECAPTCHA_*`) are already configured for website17.

**Cutover note:** when deploying, the old standalone `lab` Kamal service on the
shared server must be removed so kamal-proxy routes `lab.kleer.la` to
website17. Also confirm the website17 reCAPTCHA site key permits the
`lab.kleer.la` domain.
