# Learning Without Borders Europe

**Open Education for Everyone, Everywhere.**

Learning Without Borders Europe is an open-source educational initiative dedicated to
providing free, accessible, and high-quality learning opportunities for people across
Europe and beyond. Our mission is to remove barriers to education through open
technologies, community-driven content, multilingual resources, and collaborative
partnerships.

🌐 **Live site:** <https://vectorscientificcomputing.github.io/education/>

## Courses

The current catalogue covers parallel programming for HPC:

- **OpenMP** — shared-memory parallel programming for multicore CPUs.
- **CUDA** — GPU programming with NVIDIA CUDA.
- **OpenACC** — directive-based GPU acceleration.

Each course includes an introduction, preparation instructions, and hands-on exercises.

## Building the site locally

The site is built with [Zensical](https://zensical.org/), the successor to
Material for MkDocs. It's tested with Python 3.13, but 3.10+ works.

```bash
# create and activate a virtual environment
python3 -m venv .venv
source .venv/bin/activate

# install dependencies
pip install -r requirements.txt

# preview locally with live reload
zensical serve
```

Then open <http://localhost:8000>.

To produce a static build instead of serving:

```bash
zensical build
```

The generated site is written to the `site/` directory.

If you prefer [uv](https://docs.astral.sh/uv/), the equivalent setup is:

```bash
uv venv --python 3.13 .venv
source .venv/bin/activate
uv pip install -r requirements.txt
```

## Checking before you push

The build itself is the check — if it compiles locally, it will compile in CI.
Run it before pushing:

```bash
zensical build --clean
```

`No issues found` means you're good to go. To stop a broken build from ever
reaching GitHub, chain the steps so nothing is committed unless the build passes:

```bash
zensical build --clean && git add . && git commit -m "your message" && git push
```

## Deployment

Deployment is automatic. Every push to `main` triggers the GitHub Actions workflow in
`.github/workflows/deploy.yml`, which checks the required files, builds the site with
Zensical, and publishes it to GitHub Pages. Pull requests run the check and build steps
as validation but do not deploy.

## Contributing

Contributions are welcome — from educators, developers, students, researchers,
translators, and designers. Open an issue or a pull request at
<https://github.com/VectorScientificComputing/education>. Course material lives under
`docs/`, and the site structure is defined in `mkdocs.yml`.

## Licence

- **Educational content** (everything under `docs/`) is licensed under
  [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/) —
    you are free to share and adapt it, as long as you give appropriate credit.
    - **Code** (build scripts, configuration, tooling) is licensed under the
      [European Union Public Licence v1.2 (EUPL-1.2)](https://eupl.eu/).

See the [`LICENSE`](LICENSE) file for the full text.