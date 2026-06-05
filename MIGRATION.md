# Migrating the `education` site to Zensical

This summarizes the changes that make your site build with **Zensical**
(tested with zensical 0.0.44 — the full site, all 28 pages, builds with
"No issues found"). Drop the files in this folder into your repo as
described below.

## Files to add / replace

| File                          | Action                                                        |
| ----------------------------- | ------------------------------------------------------------- |
| `mkdocs.yml`                  | **New** — the migrated config (Zensical reads `mkdocs.yml`).  |
| `requirements.txt`            | **Replace** — now just `zensical`.                            |
| `.github/workflows/deploy.yml`| **Replace** your old workflow with this Zensical version.     |

## Files to delete

- `properdocs.yml` — replaced by `mkdocs.yml` (Zensical looks for `mkdocs.yml`).
- `scripts/extra.py` — the MkDocs hook; Zensical doesn't run MkDocs hooks (see below).
- `setup.sh` — it ran `mkdocs gh-deploy`; deployment is now the GitHub Actions workflow.

(You can keep `config/yamllint.yml` and `config/pymarkdown.yml` if you still
lint locally — just point yamllint at `mkdocs.yml` instead of `properdocs.yml`.)

## What changed in the config

1. **Theme:** `materialx` → `material`. Zensical natively provides the official
   Material theme; it does not recognize the third-party `materialx` fork.

2. **Plugins kept:** `search`, `glightbox` — both supported natively by Zensical,
   no extra packages needed.

3. **Plugins removed** (not yet supported by Zensical, alpha):
   - `rss` — no RSS/feed file will be generated.
   - `minify` — HTML is served unminified (purely cosmetic; no visible difference).
   - `document-dates` — the "created/updated" dates at the bottom of pages are gone.
   - `include-markdown` — safe to drop; your content uses no include syntax.
   - `site-urls` — safe to drop; your content uses no root-relative (`/...`) links.

4. **Markdown extensions removed:**
   - `mdx_truly_sane_lists` — third-party, not bundled. Deeply-nested lists may
     render slightly differently; re-add the package if you need its exact behavior.
   - `markdown_include.include` — unused in your content.
   All your `pymdownx.*` extensions (math via `arithmatex`, code highlighting,
   admonitions, tabs, task lists, emoji, mermaid fences, etc.) are kept and work.

5. **Custom hook removed:** `scripts/extra.py` only substituted the current year
   into the copyright string. Since Zensical doesn't run MkDocs hooks, the year is
   now hardcoded: `Copyright © 2026 ...`. Update the `copyright:` line each year,
   or drop the year range entirely.

## Build & preview locally

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt

zensical serve     # preview at http://localhost:8000
zensical build     # produce the static site/ folder
```

## What you lose for now

Only page dates, the RSS feed, and HTML minification — all cosmetic or
non-essential. These plugins are on Zensical's roadmap toward feature parity
with Material for MkDocs, so they can be re-enabled later as Zensical adds them.
Everything load-bearing (navigation, search, math, code, images/lightbox,
admonitions, the card grid, analytics, social links) works today.
