## HEADER ####
## Food Consumption and Emissions Shiny App
## Florence Galliers
## 2020-02-19

library(shiny)
library(shinythemes)

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

# Define a User Interface
ui <- fluidPage(
  # set theme
  theme=shinytheme("superhero"),
  # Title
  titlePanel("Carbon Footprint of the World"),
  # Sidebar layout with input and output definitions
  sidebarLayout(
    # sidebar panel for inputs
    sidebarPanel("Select two countries to compare:",
      selectInput(inputId = "country1",
                  label = "Choose country 1:",
                  # use countrys, sort into alphabetical order
                  choices = sort(food_consumption$country)),
    selectInput(inputId = "country2",
                label = "Choose country 2:",
                # use countrys, sort into alphabetical order
                choices = sort(food_consumption$country))),
    # main panel for displaying outputs
    mainPanel("Breakdown of carbon footprint into food categories",
              textOutput(outputId = "text1"),
              plotOutput(outputId = "plot1"),
              textOutput(outputId = "text2"),
              plotOutput(outputId = "plot2")
    )
  )
)

# Define the Server
server <- function(input, output){
  # use renderplot to indicate that it is reactive and the output type is a plot
 # Output for country 1
   output$text1 <- renderText({
    paste("Country 1:", input$country1)
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
                      size = 10,
                      make_proportional = T,
                      data = footprint[footprint$country == input$country1, 2:3]) +
       scale_label_pictogram(
         name = NULL,
         values = "shoe-prints",
         labels = c("Beef",
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
       ) +
       scale_color_manual(
         name = NULL,
         values = food_colours,
         labels = c("Beef",
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
       ) +
       coord_equal() +
       theme_minimal() +
       theme(panel.grid = element_blank())
     
  })
   # output text for country 2
   output$text2 <- renderText({
     paste("Country 2:", input$country2)
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
                     flip = TRUE,
                     size = 10,
                     make_proportional = T,
                     data = footprint[footprint$country == input$country2, 2:3]) +
      scale_label_pictogram(
        name = NULL,
        values = "shoe-prints",
        labels = c("Beef",
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
      ) +
      scale_color_manual(
        name = NULL,
        values = food_colours,
        labels = c("Beef",
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
      ) +
      coord_equal() +
      theme_minimal() +
      theme(panel.grid = element_blank())
    
  })
}

# Run the App
shinyApp(ui = ui,
         server = server)

