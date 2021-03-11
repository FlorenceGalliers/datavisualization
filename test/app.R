#
# This is a Shiny web application. You can run the application by clicking
# the 'Run App' button above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(rnaturalearth)
library(rnaturalearthdata)

tuesdata <- tidytuesdayR::tt_load('2018-11-13')
malaria_deaths_age <- tuesdata$malaria_deaths_age
malaria_deaths <- tuesdata$malaria_deaths
malaria_inc <- tuesdata$malaria_inc

world <- ne_countries(scale = "medium", returnclass = "sf")

malaria_deaths$deaths <- malaria_deaths$`Deaths - Malaria - Sex: Both - Age: Age-standardized (Rate) (per 100,000 people)`

malaria_deaths$iso_a2 <- countrycode(malaria_deaths[[2]], "iso3c", "iso2c") 


africa <- world %>% 
    filter(continent == "Africa") %>% 
    filter(iso_a2 != "EH") %>% #remove easter sahara as NA values
    left_join(malaria_deaths, by = "iso_a2") %>% 
    dplyr::select(Entity, Year, deaths) %>% 
    st_transform("+proj=aea +lat_1=20 +lat_2=-23 +lat_0=0 +lon_0=25")

# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Old Faithful Geyser Data"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            sliderInput("bins",
                        "Number of bins:",
                        min = 1,
                        max = 50,
                        value = 30)
        ),

        # Show a plot of the generated distribution
        mainPanel(
           plotOutput("distPlot")
        )
    )
)

# Define server logic required to draw a histogram
server <- function(input, output) {

    output$distPlot <- renderPlot({
        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white')
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
