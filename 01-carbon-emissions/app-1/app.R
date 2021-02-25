## HEADER ####
## Food Consumption and Emissions Shiny App
## Florence Galliers
## 2020-02-19

library(shiny)
library(shinythemes)
library(dplyr)
library(tidyr)
library(ggplot2)
library(plyr)
library(waffle)

food_consumption <- readr::read_csv('https://raw.githubusercontent.com/rfordatascience/tidytuesday/master/data/2020/2020-02-18/food_consumption.csv')
food_consumption$food_category <- factor(food_consumption$food_category)
levels(food_consumption$food_category)
food_consumption$food_category <- revalue(food_consumption$food_category,
                                          c("Lamb & Goat" = "Lamb/Goat",
                                            "Milk - inc. cheese" = "Dairy",
                                            "Nuts inc. Peanut Butter" = "Nuts",
                                            "Wheat and Wheat Products" = "Wheat"))

footprint <- food_consumption %>%
  select(country, food_category, co2_emmission)


food_colours <- c("#e31a1c",
                  "#ffff99",
                  "#1f78b4",
                  "#6a3d9a",
                  "#a6cee3",
                  "#b15928",
                  "#ff7f00",
                  "#fb9a99",
                  "#cab2d6",
                  "#33a02c",
                  "#b2df8a")

category_names <- c("Beef",
                    "Eggs",
                    "Fish",
                    "Lamb/Goat",
                    "Dairy",
                    "Nuts",
                    "Pork",
                    "Poultry",
                    "Rice",
                    "Soybean",
                    "Wheat")

footprint_total <- footprint %>%
  select(country, co2_emmission) %>%
  group_by(country) %>%
  dplyr::summarise(total = sum(co2_emmission))


# Define a User Interface
ui <- fluidPage(
  # set theme
  theme=shinytheme("journal"),
  #shinythemes::themeSelector(),
  # Title
  titlePanel("Carbon Footprint of the World"),
  # Sidebar layout with input and output definitions
  fluidRow(
    
    # panel for inputs
    column(12, 
           "Select two countries from the drop-down menus below and compare the variation in carbon footprint caused by the different food categories. 
           The information shown is a proportion of the total carbon footprint, which varies from country to country.")),
  
  fluidRow(
    column(6,
      selectInput(inputId = "country1",
                  label = "Choose country 1:",
                  # use countrys, sort into alphabetical order
                  choices = sort(food_consumption$country),
                  selected = sort(food_consumption$country)[1])),
    column(6, 
    selectInput(inputId = "country2",
                label = "Choose country 2:",
                # use countrys, sort into alphabetical order
                choices = sort(food_consumption$country),
                selected = sort(food_consumption$country)[1]))
    ),
    # main panel for displaying outputs
    fluidRow(
      column(6, 
             # country name
              h2(textOutput(outputId = "text1")),
             # total carbon footprint
             h4(textOutput(outputId = "total1")),
             # footprint plot
              plotOutput(outputId = "plot1")),
      column(6,
             # country name 2
              h2(textOutput(outputId = "text2")),
             # total carbon footprint 2
             h4(textOutput(outputId = "total2")),
             # footprint plot 2
              plotOutput(outputId = "plot2"))),
    
    fluidRow(
      column(6,
             textOutput(outputId = "text3")),
      column(6, 
             textOutput(outputId = "text4"))
    )
)

# Define the Server
server <- function(input, output){
  # use renderplot to indicate that it is reactive and the output type is a plot
 # Output for country 1
   output$text1 <- renderText({
    paste(input$country1)
  })
   # total for country 1
   output$total1 <- renderText({
     paste("Total carbon footprint:",
       footprint_total[footprint_total$country == input$country1, 2], 
       "kg/person/year"
     )
   })
   # output plot for country 1
   output$plot1 <- renderPlot({
     ggplot(footprint, 
            aes(fill = food_category,
                values = co2_emmission)) +
       geom_pictogram(n_rows = 10,
                      aes(label = food_category,
                          values = co2_emmission,
                          color = food_category),
                      flip = TRUE,
                      size = 8,
                      make_proportional = T,
                      data = footprint[footprint$country == input$country1, 2:3]) +
       scale_label_pictogram(
         name = NULL,
         values = "shoe-prints",
         labels = category_names
       ) +
       scale_color_manual(
         name = NULL,
         values = food_colours,
         labels = category_names
       ) +
       coord_equal() +
       theme_minimal() +
       theme(panel.grid = element_blank(),
             axis.text = element_blank(),
             legend.position = "none")
     
  })
   # output text for country 2
   output$text2 <- renderText({
     paste(input$country2)
   })
   # total for country 2
   output$total2 <- renderText({
     paste("Total carbon footprint:",
           footprint_total[footprint_total$country == input$country2, 2], 
           "kg/person/year"
     )
   })
   # output plot for country 2
  output$plot2 <- renderPlot({
    ggplot(footprint, 
           aes(fill = food_category,
               values = co2_emmission)) +
      geom_pictogram(n_rows = 10,
                     aes(label = food_category,
                         values = co2_emmission,
                         color = food_category),
                     flip = T,
                     size = 8,
                     make_proportional = T,
                     data = footprint[footprint$country == input$country2, 2:3]) +
      scale_label_pictogram(
        name = NULL,
        values = "shoe-prints",
        labels = category_names
      ) +
      scale_color_manual(
        name = NULL,
        values = food_colours,
        labels = category_names
      ) +
      coord_equal() +
      theme_minimal() +
      theme(panel.grid = element_blank(),
            axis.text = element_blank(),
            legend.position = "none")
  })
    
    # output text 3
    output$text3 <- renderText({
      paste("Country 1:", input$country1)
    })
  
}

# Run the App
shinyApp(ui = ui,
         server = server)

