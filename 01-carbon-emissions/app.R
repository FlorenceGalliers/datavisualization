## HEADER ####
## Food Consumption and Emissions Shiny App
## Florence Galliers
## 2020-02-19

library(shiny)
library(shinythemes)


# User Interface
ui <- fluidPage(theme=shinytheme("superhero"),
  sidebarLayout(
    sidebarPanel("This is the sidebar",
      numericInput(inputId = "n",
                   "Sample size", 
                   value = 25,
                   min = 5, 
                   max = 100,
                   step = 5),),
    mainPanel("This is the main panel",
      plotOutput(outputId = "hist")
    )
  )
)

# Server
server <- function(input, output){
  output$hist <- renderPlot({
    hist(rnorm(input$n))
  })
}

# App
shinyApp(ui = ui,
         server = server)
