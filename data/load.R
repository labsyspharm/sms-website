dir_data <- here("data")

c(
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
  ) %>%
  imap(
    ~{
      message("Loading ", .y)
      data <- read_fst(
        file.path(dir_data, .x),
        as.data.table = TRUE
      )
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

data_targets[["symbol_lower"]] <- str_to_lower(data_targets[["symbol"]])

data_fingerprints <- MorganFPS$new(
  file.path(dir_data, "shiny_fingerprints.bin"),
  from_file = TRUE
)

data_gene_lists <- fread(
  file.path(dir_data, "gene_lists.csv.gz")
)

dl_table_descriptions <- fread(
  file.path(dir_data, "dl_table_descriptions.csv")
)
