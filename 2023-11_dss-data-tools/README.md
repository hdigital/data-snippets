# DSS presentation APIs · 📽️

<https://hdigital.github.io/dss-presentation_data-tools/>

```sh
quarto render dss-data-presentation.ipynb

quarto publish gh-pages
```

Add a Zenodo API key to an `.env` file to access [Zenodo REST API](https://developers.zenodo.org/) — see [`.env.example`](.env.example)

---

Template based on __A Jupyter starter project · 🚀📊__

## Installation · ⚙️

### Local · 💻

Run in [VS Code](https://code.visualstudio.com/docs/datascience/jupyter-notebooks) or with [JupyterLab](https://jupyterlab.readthedocs.io/en/latest/).

```sh
python -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt

python -m jupyter lab
```

### Codespace · 🛰️

Run in [GitHub Codespaces](https://docs.github.com/en/codespaces/overview).

See `init-codespace.sh` and `devcontainer.json`

## How to · 🤔

Pin dependencies with [pip-tools](https://github.com/jazzband/pip-tools#requirements-from-requirementsin) defined in `requirements.in`.

```sh
python -m pip install pip-tools

# create or upgrade dependencies in 'requirements.txt'
python -m piptools compile --generate-hashes --allow-unsafe --upgrade requirements.in

# sync installed packages with requirements.txt
python -m piptools sync
```

Clean a Jupyter notebook with [nbdev_clean](https://nbdev.fast.ai/tutorials/git_friendly_jupyter.html)

```sh
nbdev_clean --fname .
```

Format Python and Jupyter files with [black](https://black.readthedocs.io/en/stable/usage_and_configuration/the_basics.html)

```sh
black .
```

Run [pre-commit](https://pre-commit.com/#usage) hooks on all files

```sh
pre-commit run --all-files

# pre-commit autoupdate
```

## License · ⚖️

[MIT](https://choosealicense.com/licenses/mit/) – Copyright (c) 2023 Holger Döring
