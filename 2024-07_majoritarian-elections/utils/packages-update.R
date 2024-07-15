# install 'pak' to use modern package installer
if (!"pak" %in% installed.packages()) {
  install.packages("pak", repos = getOption("repos")[[1]])
}

# get packages used in project folder
pak::pkg_install("renv", ask = FALSE, upgrade = FALSE)
deps <- unique(renv::dependencies()[["Package"]])

# install project packages
pak::pkg_install(deps, ask = FALSE, upgrade = TRUE)
# pak::lockfile_install(update = FALSE)

# create lock file of versions for all packages
pak::lockfile_create(deps)
