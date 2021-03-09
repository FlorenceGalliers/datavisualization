## HEADER ####
## Interactive Map with Shiny
## Florence Galliers
## 2020-02-23

# Packages ####
library(shiny)
library(leaflet)
library(shinythemes)
library(countrycode)
library(maps)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(dplyr)
library(rgeos)

# Get Data ####
tuesdata <- tidytuesdayR::tt_load('2018-11-13')
malaria_deaths_age <- tuesdata$malaria_deaths_age
malaria_deaths <- tuesdata$malaria_deaths
malaria_inc <- tuesdata$malaria_inc

world <- ne_countries(scale = "medium", returnclass = "sf")

malaria_deaths$deaths <- malaria_deaths$`Deaths - Malaria - Sex: Both - Age: Age-standardized (Rate) (per 100,000 people)`

malaria_deaths$iso_a2 <- countrycode(malaria_deaths$Code, "iso3c", "iso2c") 

africa <- world %>% 
    filter(continent == "Africa") %>% 
    filter(iso_a2 != "EH") %>% #remove easter sahara as NA values
    left_join(malaria_deaths, by = "iso_a2") %>% 
    dplyr::select(Entity, Year, deaths) %>% 
    st_transform("+proj=aea +lat_1=20 +lat_2=-23 +lat_0=0 +lon_0=25")

# ui
ui <- fluidPage(theme = shinytheme("united"),
                titlePanel("Malaria mortality rate in Africa"),
                fluidRow(
                    column(12,
                           sliderInput(inputId = "year",
                                       label = "Year",
                                       min = 1990,
                                       max = 2016,
                                       value = 2000,
                                       step = 1,
                                       sep = "",
                                       animate = animationOptions(
                                           interval = 1000, 
                                           loop = TRUE,
                                           playButton = "Play",
                                           pauseButton = "Pause"
                                       )))),
                fluidRow(
                    column(12, 
                           leafletOutput(outputId = "map",
                                         width = "600px",
                                         height = "600px"))
                )
)

# server

server <- function(input, output) {
    output$map <- renderLeaflet({
        
        malaria_year <- africa %>%
            filter(Year == input$year)
        
        # create bins for color palette
        bins <- c(0, 20, 40, 60, 80, 120, 150, Inf)
        # create palette
        palette <- colorBin("YlOrRd", domain = africa$deaths, bins = bins)
        
        mytext <- paste(malaria_year$Entity,
                        "<br/>",
                        "Number of Deaths: ", round(malaria_year$deaths, 0),
                        "<br/>",
                        sep="") %>%
            lapply(htmltools::HTML)
        
        leaflet() %>% 
            addProviderTiles(providers$CartoDB.PositronNoLabels) %>% 
            addPolygons(data = st_transform(malaria_year, 4326),
                        fillColor = ~palette(deaths),
                        weight = 1,
                        color = "black", 
                        fillOpacity = 1,
                        label = mytext,
                        labelOptions = labelOptions(
                            stype = list("font-weight" = "normal",
                                         padding = "3px 8px"),
                            textsize = "15px",
                            direction = "auto"
                        )) %>%
            addLegend("bottomleft", pal = palette,
                      values = malaria_year$deaths,
                      title = "Mortality Rate (per 100,000 people)",
                      opacity = 1)
    })
}

# run application
shinyApp(ui = ui,
         server = server)
