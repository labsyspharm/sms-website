dir_data <- here("data")

data_files <- tribble(
  ~file, ~load_type,
  "shiny_chemical_probes.fst", "syn",
  "shiny_compound_names.fst", "asyn",
  "shiny_compounds.fst", "asyn",
  # "shiny_inchis.fst",
  "shiny_library.fst", "syn",
  "shiny_pfp.fst", "syn",
  "shiny_selectivity.fst", "asyn",
  "shiny_targets.fst", "syn",
  "shiny_target_map.fst", "syn",
  "shiny_tas.fst", "asyn"
) %>%
  mutate(
    name = str_replace(file, fixed("shiny"), "data") %>%
      str_replace(fixed(".fst"), "")
  )

data_files %>%
  filter(load_type == "syn") %>%
  pwalk(
    function(name, file, ...) {
      message("Loading ", name)
      data <- read_fst(
        file.path(dir_data, file),
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
      assign(name, data, envir = .GlobalEnv)
    }
  )

# Handling compound names separately and asynchronously because it is so large
# and only required in a single place
data_futures <- data_files %>%
  filter(load_type == "asyn")

data_futures %>%
  pwalk(
    function(name, file, ...) {
      f <- future({
        message("Async loading ", name)
        data <- read_fst(
          file.path(dir_data, file),
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
      }, lazy = FALSE, globals = c("SELECTIVITY_ORDER"), packages = c("data.table", "fst"))
      assign(paste0("f_", name), f, envir = .GlobalEnv)
    }
  )

data_fingerprints <- MorganFPS$new(
  file.path(dir_data, "shiny_fingerprints.bin"),
  from_file = TRUE
)

data_gene_lists <- fread(
  file.path(dir_data, "gene_lists.csv.gz")
)
