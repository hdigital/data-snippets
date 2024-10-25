run_all <- FALSE


## Install and lock packages ----

if (fs::file_exists("pkg.lock")) {
  pak::lockfile_install()
} else {
  deps <- unique(renv::dependencies()[["Package"]])
  pak::lockfile_create(deps)
}


## Format and check code ----

# format project code with tidyverse style guide
styler::style_dir(exclude_dirs = c(".cache", "renv"))

# check code style, syntax errors and semantic issues
if (run_all) {
  lintr::lint_dir()
}


## Create notebook ----

# create datasets for analysis (needs gitignore files)
if (run_all) {
  callr::rscript("data-btw-2021.R")
}

# render notebook
system("quarto render deu-election-2021.qmd --cache-refresh")

# copy notebook to site folder
fs::file_copy(
  "deu-election-2021.html",
  "../_site/notebooks/2024_deu-election-2021.html",
  overwrite = TRUE
)
