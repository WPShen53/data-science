#
# This is the server logic of a Shiny web application. You can run the 
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
# 
#    http://shiny.rstudio.com/
#

library(shiny)
library(quanteda)
library(LaF)
library(data.table)


### initialize the word sequence data.table
ws <- data.table(read.csv("ws.csv.gz",header=TRUE,stringsAsFactors=FALSE))
ws <- ws[order(ws$G2, decreasing = TRUE)]


###
### Find Next Word, return atmost 5 words (the Model)
###
nNextWord <- function (inTxt, ws, nword=5L) {
    inTxt <- cleanUpTxt(inTxt)
    words <- tokenize(toLower(inTxt), removePunct=TRUE, removeNumbers=TRUE)
    if (length(words[[1]]) < 1) return (c("Message:: Please type in a few words above."))
    
    rTxt <- rep("", nword)
    backoff <- FALSE
    lastWord <- tail(words[[1]],1)
    
    #implement prediction for two words input 
    if (length(words[[1]]) > 1) { 
        last2ndWord <- tail(words[[1]],2)[1]
        subws <- subset(ws, word1==last2ndWord & word2==lastWord & word3!="")
        #        subws <- subws[order(subws$count, decreasing = TRUE)]
        n <- ifelse (nrow(subws)>=nword, nword, nrow(subws))
        for (i in 1:n) {
            rTxt[i] <- subws$word3[i]
        }
        if (n<nword) backoff <- TRUE
    }
    
    # implement backoff or one word input
    k <- ifelse (backoff, n+1, 1)
    subws <- subset(ws, word1==lastWord & word3=="")
    n <- ifelse (nrow(subws)>=nword, nword, nrow(subws))
    for (i in k:n) {
        rTxt[i] <- subws$word2[i]
    }
    rTxt
}

###
### Text Clean Up
###
cleanUpTxt <- function (inTxt) {
    inTxt <- enc2utf8(inTxt)
    inTxt <- gsub("#\\w+ *","", inTxt) #remove user name in Tweets
    inTxt <- gsub("@\\w+ *","", inTxt) #remove user name in Tweets
    inTxt <- gsub(" www(.+) ", " ", inTxt) #remove url
    inTxt <- gsub("\\d+\\w+", "", inTxt) #remove alphanum
    inTxt <- gsub("\\&", " and ", inTxt)
    inTxt <- gsub("-", " ", inTxt) 
    inTxt
}


shinyServer(function(input, output) {

    
    output$oWordPredictions <- renderText({
        input$submitButton
        results <- isolate(paste(
            unlist(lapply(nNextWord(input$sentenceInputVar, ws),
                          function(x) paste0("[", x, "]")))
        ))
    })
})
