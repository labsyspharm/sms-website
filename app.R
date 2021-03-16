source("global.R", local = TRUE)

all_loaded <- FALSE
data_loaded <- c()

server <- function(input, output, session) {

  # Display message about data loading to user
  if (!all_loaded) {
    pb <- Progress$new(min = 0, max = 1)
    pb$set(message = "Loading data...")
    observe({
      all_loaded <<- pmap_lgl(
        data_futures,
        function(name, ...) {
          if (name %in% data_loaded) {
            TRUE
          } else if (resolved(get(paste0("f_", name)))) {
            pb$inc(amount = 0.25, paste0("Loaded ", name))
            data_loaded <<- c(data_loaded, name)
            TRUE
          }
          else
            FALSE
        }
      ) %>%
        all()
      if (all_loaded)
        pb$close()
      else
        invalidateLater(500)
    }, priority = 1)
  }

  observe({
    showNavPane(input$tab)
  })

  .modal_about <- modal(
    id = NULL,
    size = "lg",
    header = h5("About"),
    HTML(htmltools::includeMarkdown("inst/about.md"))
  )
  observeEvent(input$about, {
    showModal(.modal_about)
  })

  .modal_funding <- modal(
    id = NULL,
    size = "md",
    header = h5("Funding"),
    p("This open-access webtool is funded by NIH grants U54-HL127365, U24-DK116204 and U54-HL127624.")
  )
  observeEvent(c(input$funding, input$funding2),
    ignoreInit = TRUE, {
    showModal(.modal_funding)
  })

  callModule(
    module = bindingDataServer,
    id = "binding"
  )

  callModule(
    module = selectivityServer,
    id = "selectivity"
  )

  callModule(
    module = similarityServer,
    id = "similarity"
  )

  callModule(
    module = libraryServer,
    id = "library"
  )
}

# library(waiter)
ui <- function(req) {
  tagList(
    # use_waiter(),
    # waiter_show_on_load(html = spin_fading_circles()),
    page_headers(),
    webpage(
      nav = navbar_ui(),
      nav_content_ui()
    )
  )
}

app <- shinyApp(ui, server, enableBookmarking = "url")
