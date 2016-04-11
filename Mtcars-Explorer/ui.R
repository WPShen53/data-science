#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(datasets)

dispName <- c('Weight (1000 lbs)'='wt',
              'Displacement (cu.in.)'='disp',
              'Gross horsepower'='hp',
              'Rear axle ratio'='drat',
               '1/4 mile time'='qsec',
              'V/S'='vs',
              'Number of forward gears'='gear',
              'Number of carburetors'='carb')


# Define UI for application that draws a histogram
shinyUI(fluidPage(
  
  # Application title
  titlePanel("Linear Regression Analysis of Miles/(US) gallon"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
        selectInput('x', 'Regressor', dispName),
        radioButtons("am", label = "Transmission",
                     choices = list("Automatic"=0, "Manual"=1),
                     selected = 1),
        checkboxGroupInput("cyl", label = "Number of Cyclinders",
                     choices = list("4"=4, "6"=6, "8"=8),
                     selected = 4)
#        radioButtons("cyl", label = "Number of Cyclinders",
#                     choices = list("4"=4, "6"=6, "8"=8),
#                     selected = 4)
    ),
    
    # Show a plot of the generated distribution
    mainPanel(
       plotOutput("distPlot")
    )
  )
