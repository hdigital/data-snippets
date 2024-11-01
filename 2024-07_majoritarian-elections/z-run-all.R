# Install all R packages (locked versions) and render notebook
# run in local container or codespace with: Rscript z-run-all.R

run_all <- FALSE


## Install and lock packages ----

if (!fs::file_exists("pkg.lock")) {
  deps <- unique(renv::dependencies()[["Package"]])
  pak::lockfile_create(deps)
}
pak::lockfile_install()


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
  callr::rscript("data-raw.R")
}

# render notebook
system("quarto render majoritarian-elections.qmd --cache-refresh")

# copy notebook to site folder
fs::file_copy(
  "majoritarian-elections.html",
  "../_site/notebooks/2024_majoritarian-elections.html",
  overwrite = TRUE
)
