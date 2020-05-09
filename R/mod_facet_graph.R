#' facet_graph UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_facet_graph_ui <- function(id){
  ns <- NS(id)
  tagList(
    h4("Click a plot to see a bigger version"),
    plotOutput(ns("facetPlot"), height = 1000, click = ns("plot_click"))
  )
}

#' facet_graph Server Function
#'
#' @noRd 
mod_facet_graph_server <- function(input, output, session, title, variable){
  ns <- session$ns
  
  output$facetPlot <- renderPlot({
    
    open_data %>% 
      dplyr::group_by(Date) %>% 
      dplyr::count(.data[[variable]]) %>% 
      dplyr::ungroup() %>% 
      dplyr::rename("Incident" = .data[[variable]]) %>% 
      tidyr::complete(Date, Incident, fill = list(n = 0)) %>% 
      qicharts2::qic(Date, n,
                     data = .,
                     title = title,
                     facet = ~ Incident,
                     scales = "free_y",
                     ncol = 5)
  })
  
  observeEvent(input$plot_click, {
    
    showModal(
      modalDialog(
        plotOutput(ns("zoomedGraph")),
        size = "l")
    )
  })
  
  output$zoomedGraph <- renderPlot({
    
    open_data %>% 
      dplyr::group_by(Date) %>% 
      dplyr::count(.data[[variable]]) %>% 
      dplyr::ungroup() %>% 
      tidyr::complete(Date, .data[[variable]], fill = list(n = 0)) %>%
      dplyr::filter(.data[[variable]] == input$plot_click$panelvar1) %>% 
      qicharts2::qic(Date, n,
                     data = .)
  })
}
