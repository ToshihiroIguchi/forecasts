library(shiny)

shinyUI(
  fluidPage(
    titlePanel("Easily forecast future using prophet"),
    sidebarLayout(
      sidebarPanel(
        fileInput("file", "Choose CSV File",
                  accept = c(
                    "text/csv",
                    "text/comma-separated-values,text/plain",
                    ".csv")
        ),
        tags$hr(),
        
        htmlOutput("ds"),
        htmlOutput("y"),
        
        htmlOutput("freq"),
        htmlOutput("periods"),
        htmlOutput("change_scale"),
        
        
        actionButton("submit", "Analyze")
        
      ),
      
      mainPanel(
        tabsetPanel(type = "tabs",
                    tabPanel("Table", tableOutput("table")),
                    tabPanel("Result", plotOutput("plot")),
                    tabPanel("Forecast", tableOutput("sum")),
                    tabPanel("Components", plotOutput("plot_components"))
                    
        )
      )
    )
  )
)