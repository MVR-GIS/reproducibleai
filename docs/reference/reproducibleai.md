# reproducibleai: Reproducible AI-assisted development workflows

`{reproducibleai}` provides tools for building reproducible, reviewable
AI-assisted workflows around reusable instruction modules.

## Details

The package is instruction-first:

- canonical instruction content is stored as static markdown in
  `inst/instructions/`

- public workflows compose modules by name or via lightweight recipes

- [`use_instructions()`](https://mvr-gis.github.io/reproducibleai/reference/use_instructions.md)
  installs selected modules into `dev/instructions/`

- internal handlers support installation and, for selected modules,
  supporting repository scaffolding

This design keeps instruction content easy to review and diff while
allowing selected modules such as `development-governance` to scaffold
the repository structure they depend on.
