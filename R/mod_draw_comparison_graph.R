#' draw_comparison_graph UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_draw_comparison_graph_ui <- function(id){
  ns <- NS(id)
  tagList(
    fluidRow(
      column(3,
             selectInput(ns("categoryOne"), "Type of data",
                         choices = c("Acuity" = "Acuity_SNOMED",
                                     "Chief complaint" = "ChiefComplaint_SNOMED",
                                     "Grouped diagnosis" = "Diagnosis1_Grouped_SNOMED")),
             uiOutput(ns("renderThingOne"))
      ),
      column(9,
             plotOutput(ns("plotOne"))
      )
    )
  )
}

#' draw_comparison_graph Server Function
#'
#' @noRd 
mod_draw_comparison_graph_server <- function(input, output, session){
  ns <- session$ns
  
  # return the facets that they can plot
  
  plotFacets <- reactive({
    
    variable <- input$categoryOne
    
    open_data %>%
      dplyr::filter(!is.na(.data[[variable]])) %>%
      dplyr::arrange(.data[[variable]]) %>%
      dplyr::pull(.data[[variable]]) %>%
      unique(.)
    
  })
  
  output$renderThingOne <- renderUI({
    
    selectInput(session$ns("thingOne"), 
                "Select categories", 
                choices = plotFacets(),
                multiple = TRUE)
  })
  
  output$plotOne <- renderPlot({
    
    validate(need(input$thingOne, "Please select a category"))

    variable <- input$categoryOne

    open_data %>%
      dplyr::group_by(Date) %>%
      dplyr::count(.data[[variable]]) %>%
      dplyr::ungroup() %>%
      dplyr::rename("Incident" = .data[[variable]]) %>%
      tidyr::complete(Date, Incident, fill = list(n = 0)) %>%
      dplyr::filter(Incident %in% input$thingOne) %>%
      qicharts2::qic(Date, n,
                     data = .,
                     title = knitr::combine_words(input$thingOne),
                     chart = "c")
  })
}
