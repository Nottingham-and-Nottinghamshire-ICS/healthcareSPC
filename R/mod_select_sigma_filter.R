#' select_sigma_filter UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_select_sigma_filter_ui <- function(id){
  ns <- NS(id)
  tagList(
    
    conditionalPanel(
      condition = "input.tabset != 'compare'",
      tagList(
        
        checkboxInput(ns("showSlider"), "Filter by number of points outside CL", value = FALSE),
        conditionalPanel(
          condition = "input.showSlider", ns = ns,
          sliderInput(ns("slider"), "Number of points outside of sigma",
                      min = 1, max = 20, value = 10)
        )
      )
    )
  )
}

#' select_sigma_filter Server Function
#'
#' @noRd 
mod_select_sigma_filter_server <- function(input, output, session){
  ns <- session$ns
  
  return(
    list(
      sigmaTrue = reactive({ input$showSlider }),
      sigmaLevel = reactive({ input$slider })
    )
  )
}

