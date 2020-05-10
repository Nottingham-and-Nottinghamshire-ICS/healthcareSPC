#' The application server-side
#' 
#' @param input,output,session Internal parameters for {shiny}. 
#'     DO NOT REMOVE.
#' @import shiny
#' @noRd
app_server <- function(input, output, session) {
  
  sigma_choices <- callModule(mod_select_sigma_filter_server, "select_sigma_filter_ui_1")
  # List the first level callModules here
  callModule(mod_facet_graph_server, "facet_graph_ui_1", 
             title = "Acuity", variable = "Acuity_SNOMED", sigma_choices = sigma_choices)
  callModule(mod_facet_graph_server, "facet_graph_ui_2", 
             title = "Grouped diagnosis", variable = "Diagnosis1_Grouped_SNOMED", 
             sigma_choices = sigma_choices)
  callModule(mod_facet_graph_server, "facet_graph_ui_3", 
             title = "Chief complaint", variable = "ChiefComplaint_SNOMED", 
             sigma_choices = sigma_choices)
  callModule(mod_single_double_graph_server, "single_double_graph_ui_1")
}
