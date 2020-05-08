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
    plotOutput(ns("facetPlot"), height = 1000, click = "plot_click")
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
}
    
## To be copied in the UI
# 
    
## To be copied in the server
# 
 
