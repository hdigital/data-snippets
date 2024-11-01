# Install all R packages (locked versions) and render notebook
# run in local container or codespace with: Rscript z-run-all.R

library(callr)
library(fs)
library(purrr)


## Install and lock packages ----

if (!file_exists("pkg.lock")) {
  deps <- unique(renv::dependencies()[["Package"]])
  pak::lockfile_create(deps)
}
pak::lockfile_install()

# install tmap v4 from GitHub (see https://github.com/r-tmap/tmap/issues/733)
pak::pak("r-tmap/tmap")


## Format and check code ----

# format project code with tidyverse style guide
styler::style_dir(exclude_dirs = c(".cache", "renv"))

# check code style, syntax errors and semantic issues
lintr::lint_dir()


## Run R scripts and render notebooks ----

# run R scripts in subfolders
r_scripts <- dir_ls(".", glob = "*.R")
r_scripts <- r_scripts[!stringr::str_starts(r_scripts, "z-run-all.R")]
map(r_scripts, rscript, spinner = TRUE)

# render Quarto notebooks in project folder
system("quarto render *.qmd --cache-refresh")


## Copy notebook to data snippets site ----

file_copy(
  "zensus-2022.html",
  "../_site/notebooks/2024_zensus-2022.html",
  overwrite = TRUE
)
