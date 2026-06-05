# Learning Without Borders Europe

**Open Education for Everyone, Everywhere.**

Learning Without Borders Europe is an open-source educational initiative dedicated to
providing free, accessible, and high-quality learning opportunities for people across
Europe and beyond. Our mission is to remove barriers to education through open
technologies, community-driven content, multilingual resources, and collaborative
partnerships.

🌐 **Live site:** <https://openlearneurope.github.io/courses/>

## Courses

The current catalogue covers parallel programming for HPC:

- **OpenMP** — shared-memory parallel programming for multicore CPUs.
- **CUDA** — GPU programming with NVIDIA CUDA.
- **OpenACC** — directive-based GPU acceleration.

Each course includes an introduction, preparation instructions, and hands-on exercises.

## Building the site locally

The site is built with [MkDocs](https://www.mkdocs.org/) via the `properdocs`
distribution. It's tested with Python 3.13, but 3.10+ works.

```bash
# create and activate a virtual environment
python3 -m venv .venv
source .venv/bin/activate

# install dependencies
pip install -r requirements.txt

# preview locally with live reload
properdocs serve -f properdocs.yml
```

Then open <http://127.0.0.1:8000/courses/> (the site is served under `/courses/`).

To produce a static build instead of serving:

```bash
properdocs build -f properdocs.yml
```

If you prefer [uv](https://docs.astral.sh/uv/), the equivalent setup is:

```bash
uv venv --python "$(cat .python)" .venv
source .venv/bin/activate
uv pip install -r requirements.txt
```

## Checking before you push

The CI lints YAML and Markdown on every push and pull request. To catch issues
locally first, run the same checks:

```bash
pip install yamllint pymarkdownlnt
yamllint -c config/yamllint.yml properdocs.yml config/
pymarkdown --config config/pymarkdown.yml scan docs/
```

No output means everything passed.

## Deployment

Deployment is automatic. Every push to `main` triggers the GitHub Actions workflow in
`.github/workflows/deploy.yml`, which lints, builds, and publishes the site to GitHub
Pages. Pull requests run the lint and build steps as a check but do not deploy.

## Contributing

Contributions are welcome — from educators, developers, students, researchers,
translators, and designers. Open an issue or a pull request at
<https://github.com/OpenLearnEurope/courses>. Course material lives under `docs/`, and
the site structure is defined in `properdocs.yml`.

## Licence

- **Educational content** (everything under `docs/`) is licensed under
  [Creative Commons Attribution 4.0 International (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/) —
    you are free to share and adapt it, as long as you give appropriate credit.
    - **Code** (build scripts, configuration, tooling) is licensed under the
      [European Union Public Licence v1.2 (EUPL-1.2)](https://eupl.eu/).

See the [`LICENSE`](LICENSE) file for the full text.