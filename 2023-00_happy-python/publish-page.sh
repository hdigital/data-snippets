#!/bin/bash

uv venv --seed
uv pip install jupyter

source .venv/bin/activate

quarto render happy-python.qmd

rm -r .venv

cp happy-python.html ../_site/notebooks/2023_happy-python.html
