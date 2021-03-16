dir_data <- here("data")

library(tictoc)

data_files <- c(
  "shiny_chemical_probes.fst",
  "shiny_compound_names.fst",
  "shiny_compounds.fst",
  # "shiny_inchis.fst",
  "shiny_library.fst",
  "shiny_pfp.fst",
  "shiny_selectivity.fst",
  "shiny_targets.fst",
  "shiny_target_map.fst",
  "shiny_tas.fst"
) %>%
  set_names(
    str_replace(., fixed("shiny"), "data") %>%
      str_replace(fixed(".fst"), "")
  )

data_files %>%
  extract(names(.) != "data_compound_names") %>%
  imap(
    ~{
      message("Loading ", .y)
      tic()
      data <- read_fst(
        file.path(dir_data, .x),
        as.data.table = TRUE
      )
      toc(quiet = FALSE)
      if ("selectivity_class" %in% colnames(data))
        data[
          ,
          selectivity_class := factor(
            selectivity_class,
            levels = names(SELECTIVITY_ORDER), labels = SELECTIVITY_ORDER
          )
        ]
      data
    }
  ) %>%
  iwalk(
    ~assign(.y, .x, envir = .GlobalEnv)
  )

# Handling compound names separately and asynchronously because it is so large
# and only required in a single place
library(future)
plan(multicore)
f_data_compound_names <- future({
  message("Loading data_compound_names")
  tic()
  x <- read_fst(
    file.path(dir_data, data_files[["data_compound_names"]]),
    as.data.table = TRUE
  )
  toc(quiet = FALSE)
  x
})

data_fingerprints <- MorganFPS$new(
  file.path(dir_data, "shiny_fingerprints.bin"),
  from_file = TRUE
)

data_gene_lists <- fread(
  file.path(dir_data, "gene_lists.csv.gz")
)
