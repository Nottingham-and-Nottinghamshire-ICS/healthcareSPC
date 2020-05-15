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
    uiOutput(ns("dynamicPlot"))
  )
}

#' facet_graph Server Function
#'
#' @noRd 
mod_facet_graph_server <- function(input, output, session, title, variable, sigma_choices){
  ns <- session$ns
  
  output$dynamicPlot <- renderUI({
    
    plotOutput(session$ns("facetPlot"), height = 1000, click = ns("plot_click"))
  })

  facetReactive <- reactive({
    
    open_data %>% 
      dplyr::group_by(Date) %>% 
      dplyr::count(.data[[variable]]) %>% 
      dplyr::ungroup() %>% 
      dplyr::rename("Incident" = .data[[variable]]) %>% 
      tidyr::complete(Date, Incident, fill = list(n = 0)) %>% 
      qicharts2::qic(Date, n,
                     data = .,
                     title = title,
                     chart = "c",
                     facet = ~ Incident,
                     scales = "free_y",
                     ncol = 5)
  })
  
  facetDebounce <- facetReactive %>%
    debounce(1000)
  
  # pull into reactive and debounce
  
  output$facetPlot <- renderPlot({
    
    final_data <- facetDebounce()$data
    
    # filter by sigma if that's what they want
    
      if(sigma_choices$sigmaTrue()){
        
        plotVariables <- facetDebounce()$data %>% 
          dplyr::filter(sigma.signal) %>% 
          dplyr::group_by(facet1) %>% 
          dplyr::count(sigma.signal) %>% 
          dplyr::filter(n >= sigma_choices$sigmaLevel()) %>%
          dplyr::pull(facet1)
        
        final_data <- final_data %>%
          dplyr::filter(facet1 %in% plotVariables)
      }

    final_data %>%
      qicharts2::qic(x, y,
                     data = .,
                     title = title,
                     chart = "c",
                     freeze = which(seq(min(open_data$Date), max(open_data$Date), by = "day") == as.POSIXct("2020-03-23")),
                     part.labels = c("Pre lockdown", "Lockdown"),
                     facet = ~ facet1,
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
                     data = .,
                     chart = "c",
                     title = input$plot_click$panelvar1,
                     freeze = which(seq(min(open_data$Date), max(open_data$Date), by = "day") == as.POSIXct("2020-03-23")),
                     part.labels = c("Pre lockdown", "Lockdown")
      )
  })
}
