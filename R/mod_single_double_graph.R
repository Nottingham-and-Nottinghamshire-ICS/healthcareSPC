#' single_double_graph UI Function
#'
#' @description A shiny Module.
#'
#' @param id,input,output,session Internal parameters for {shiny}.
#'
#' @noRd 
#'
#' @importFrom shiny NS tagList 
mod_single_double_graph_ui <- function(id){
  ns <- NS(id)
  tagList(
    mod_draw_comparison_graph_ui(ns("draw_comparison_graph_ui_1")),
    mod_draw_comparison_graph_ui(ns("draw_comparison_graph_ui_2"))
  )
}

#' single_double_graph Server Function
#'
#' @noRd 
mod_single_double_graph_server <- function(input, output, session){
  ns <- session$ns
  
  callModule(mod_draw_comparison_graph_server, "draw_comparison_graph_ui_1")
  callModule(mod_draw_comparison_graph_server, "draw_comparison_graph_ui_2")
}
