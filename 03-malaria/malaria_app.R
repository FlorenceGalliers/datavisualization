## HEADER ####
## Interactive Map with Shiny
## Florence Galliers
## 2020-02-23

# Packages ####
library(shiny)

# Get Data ####
tuesdata <- tidytuesdayR::tt_load('2018-11-13')
malaria_deaths_age <- tuesdata$malaria_deaths_age
malaria_deaths <- tuesdata$malaria_deaths
malaria_inc <- tuesdata$malaria_inc

# ui
ui <- fluidPage(
  titlePanel("World Malaria Incidence and Death Rate Over Time"),
  sidebarLayout(
    sidebarPanel(
      sliderInput("year",
                  "Year:",
                  min = 2000,
                  max = 2015,
                  step = 5,
                  value = 2010)
    ),
    mainPanel(
      leafletOutput("map")
    )
  )
)

# server

server <- function(input, output) {
  output$map <- renderLeaflet({
    
    inc_by_year <- filter(malaria_inc,
                          year == input$year)
    
    leaflet(data = inc_by_year) %>%
      addTiles() 
  })
}

# run application
shinyApp(ui = ui,
         server = server)
