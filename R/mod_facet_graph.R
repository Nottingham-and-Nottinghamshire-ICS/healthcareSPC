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
  
  # produce reactive which knows how many choices are showing if sigma is selected
  
  plotFacets <- reactive({
    
    plot_variables <- list_outputs[[variable]]$data %>% 
      dplyr::filter(sigma.signal) %>% 
      dplyr::group_by(facet1) %>% 
      dplyr::count(sigma.signal)
    
    if(sigma_choices$sigmaTrue()){
      
    plot_variables <- plot_variables %>% 
      dplyr::filter(n >= sigma_choices$sigmaLevel())
    }
    
    plot_variables <- plot_variables %>%
      dplyr::pull(facet1)
  })
  
  output$dynamicPlot <- renderUI({
    
    # calculate height of plot
    
    number_of_plots <- length(unique(plotFacets()))
    
    plot_height <- ceiling(number_of_plots / 5) * 300
    
    plotOutput(session$ns("facetPlot"), height = plot_height, click = ns("plot_click"))
  })
  
  output$facetPlot <- renderPlot({
    
    final_data <- list_outputs[[variable]]$data
    
    # filter by sigma if that's what they want
    
    if(sigma_choices$sigmaTrue()){
      
      final_data <- final_data %>%
        dplyr::filter(facet1 %in% plotFacets())
      
      return(
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
      )
      
    } else {     # or just return the pre-cached plot
      
     return(list_outputs[[variable]]) 
    }
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
