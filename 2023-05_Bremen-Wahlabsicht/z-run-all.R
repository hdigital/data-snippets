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


## Run R scripts and render notebooks ----

# run R scripts in subfolders
r_scripts <- dir_ls(".", glob = "*.R", recurse = 1)
r_scripts <- r_scripts[!stringr::str_starts(r_scripts, "z-")]
map(r_scripts, rscript, spinner = TRUE)

# render Quarto notebooks in project folder
system("quarto render *.qmd")

# remove Rplots created with print()
if (file_exists("Rplots.pdf")) {
  file_delete("Rplots.pdf")
}
