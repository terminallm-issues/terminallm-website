# terminallm.app

Static website for [TerminaLLM](https://terminallm.app) — the mobile SSH terminal built for AI coding assistants.

## Pages

| Path | Purpose |
|------|---------|
| `/` | Landing page |
| `/support` | FAQ, troubleshooting, contact info |
| `/privacy` | Privacy policy |
| `/terms` | Terms of service |
| `/account-deletion` | Data deletion instructions |

## Deployment

Hosted on Cloudflare Pages. No build step required.

- **Build command:** _(none)_
- **Output directory:** `/`
- **Custom domain:** `terminallm.app`

## Design

Theming mirrors the TerminaLLM app's UI — dark terminal aesthetic with green accents:

- `#121212` scaffold, `#1E1E1E` surfaces, `#2A2A2A` inputs, `#000000` code blocks
- `#4CAF50` primary green, `#69F0AE` accent
- Monospace brand mark (`>_T`)
- Warning callouts (info/caution/danger) matching the app's `WarningCallout` widget
