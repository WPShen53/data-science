#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(datasets)
library(ggplot2)

mtcars$cyl <- factor(mtcars$cyl)

# Define server logic required to draw a histogram
shinyServer(function(input, output) {
    
    dispName <- c(mpg='Miles/(US) gallon',
                  cyl='Number of cylinders',
                  disp='Displacement (cu.in.)',
                  hp='Gross horsepower',
                  drat='Rear axle ratio',
                  wt='Weight (1000 lbs)',
                  qsec='1/4 mile time',
                  vs='V/S',
                  am='Transmission (0 = automatic, 1 = manual)',
                  gear='Number of forward gears',
                  carb='Number of carburetors)')
    
    data <- reactive({
        # Combine the selected variables into a new data frame
        mtcars[(mtcars$cyl%in%input$cyl & mtcars$am==input$am), 
               c("mpg", input$x, "cyl")]
        
    })
    
    output$distPlot <- renderPlot({
        
        title <- paste("Coorlation for",as.character(input$cyl),"cylenders",
                       ifelse(input$am==0, "automatic", "manual") ,
                       "transmission")
        
        #colnames(data())[2] <- "y"
        
        p<- ggplot(data(), aes(mpg, data()[[input$x]])) +
            geom_point(size=3, aes(color=cyl)) +
            geom_smooth(method = "lm") +
            labs (title=title, y=dispName[["mpg"]], x=dispName[[input$x]]) +
            theme_bw(base_size = 16)
        
        print(p)
        
    })
    
    output$table <- renderTable({
        data()
    })
    
})
