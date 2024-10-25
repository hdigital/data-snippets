library(callr)
library(fs)
library(purrr)

run_all <- FALSE


## Use locked package versions ----

deps <- unique(renv::dependencies()[["Package"]])
pak::lockfile_create(deps)


## Format and check code ----

# format project code with tidyverse style guide
styler::style_dir(exclude_dirs = c(".cache", "renv"))

# check code style, syntax errors and semantic issues
if (run_all) {
  lintr::lint_dir()
}


## Run R scripts and render notebooks ----

# created datasets for analysis (needs gitingore files)
if (run_all) {
  rscript("data-btw-2021.R")
}

# render Quarto notebook
system("quarto render deu-election-2021.qmd --cache-refresh")


# copy notebook to site folder
file_copy(
  "deu-election-2021.html",
  "../_site/notebooks/2024_deu-election-2021.html",
  overwrite = TRUE
)
