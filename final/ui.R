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

shinyUI(fluidPage(wellPanel(
    
    # Application title
    titlePanel("Data Scientist Capstone Project"),
    
    wellPanel(
        strong ("What will you type next? - A word prediction model"),
        helpText ("In this webapp, a previously build word sequence model is used 
                  on server to predict the next word(s) from your inputs. The model
                  was created using algorithms of Natural Language Processing 
                  and machine learning on a set of real text simples from online 
                  News, Blogs and Tweets (~550 MB). Input matching was done assuming the 
                  Markov Chain is true and 3-grams text processing is applied. 
                  Backoff and smoothing were also done to improve the result. 
                  By typing a few words of your sentence in the input box and 
                  click the submit bottom, the application can return up to 5
                  suggested next words. In self-validation that also used real
                  online captured sentences, the model showed an average of 26%
                  hit rate. Hope you enjoy it!"),
        helpText ("* When starts the application for the first time, please wait 
                  a few seconds until the output panel shows [Message:: Please 
                  type in a few words above.]. This allows the word sequence model
                  to be loaded.")
    ),
    hr(),
    
    wellPanel(
        textInput('sentenceInputVar', 'Type your sentence here:'),
        helpText('(Example: "I went to the" or "Why nobody")'),
        actionButton('submitButton', 'Submit')
    ),
    
    wellPanel(
        strong ("Next possible words are"),br(),br(),
        verbatimTextOutput("oWordPredictions")
    )

)))
