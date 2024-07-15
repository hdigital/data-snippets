library(callr)
library(fs)
library(purrr)


## Use locked package versions ----

if (file_exists("pkg.lock")) {
  pak::lockfile_install()
} else {
  deps <- unique(renv::dependencies()[["Package"]])
  pak::lockfile_create(deps)
}

## Format and check code ----

# format project code with tidyverse style guide
styler::style_dir(exclude_dirs = c(".cache", "renv"))

# check code style, syntax errors and semantic issues
lintr::lint_dir()


## Run R scripts and render notebooks ----

# run R scripts in subfolders
r_scripts <- dir_ls(".", glob = "*.R", recurse = 1)
r_scripts <- r_scripts[!stringr::str_starts(r_scripts, "utils/")]
map(r_scripts, rscript, spinner = TRUE)

# render RMarkdown notebooks in subfolders
rmd_scripts <- dir_ls(".", glob = "*.Rmd", recurse = 1)
map(rmd_scripts, rmarkdown::render)

# render Quarto notebooks in project folder
system("quarto render *.qmd")

# remove Rplots created with print()
if (file_exists("Rplots.pdf")) {
  file_delete("Rplots.pdf")
}


## Log session info ----

# add session info (load all project packages)
conflicted::conflicts_prefer(callr::run)
map_lgl(dplyr::pull(renv::dependencies(), Package), require)
sessionInfo()
