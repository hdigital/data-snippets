#!/bin/bash

bash utils/run-all.sh

cp majoritarian-elections.html ../_site/notebooks/2024_majoritarian-elections.html

cd ../_site/
quarto render index.qmd
