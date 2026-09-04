# `renv``

## Configure `renv`
install.packages("renv")
update.packages()
renv::init()
file.exists("renv.lock")

## Workflow to update `renv`
update.packages()
renv::snapshot()
renv::status()

# SBOM

## Configure SBOM
use_sbom()
pak::pak("MVR-GIS/reproducibleai")


## Install or validate durable agentic context
reproducibleai::use_agentic_context(
  path = ".",
  profiles = c("base", "r-package")
)
reproducibleai::validate_agentic_context(path = ".", strict = TRUE)


## Update docs
devtools::document()
devtools::load_all()
devtools::install()
pkgdown::build_site()

