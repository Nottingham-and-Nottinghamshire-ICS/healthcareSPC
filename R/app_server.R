#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  
  # List the first level callModules here
  callModule(mod_facet_graph_server, "facet_graph_ui_1", 
             title = "Acuity", variable = "Acuity_SNOMED")
  callModule(mod_facet_graph_server, "facet_graph_ui_2", 
             title = "Grouped diagnosis", variable = "Diagnosis1_Grouped_SNOMED")
  callModule(mod_single_double_graph_server, "single_double_graph_ui_1")
}
