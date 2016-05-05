library(quanteda)
library(LaF)
library(R.utils)

set.seed(335599)

###
### Creat Word Sequence Function
###
createWordSequenceFile <- function(inTxt, outTxt, 
                                   perc = 0.6,
                                   toGzip = TRUE,
                                   verbose = TRUE) 
{
    require(quanteda)
    require(LaF)
    require(R.utils)
    
    ### readin from file
    if (verbose) print("counting file length ...")
    num_lines <- countLines(inTxt)
    if (verbose) print("reading in data ...")
    txt <- sample_lines(inTxt, perc*num_lines)
    if (verbose) print("cleaning up text ...")
    txt <- cleanUpTxt(txt)
    
    ## build word sequence matrix using {quanteda} package
    if (verbose) print("building 1-gram word sequence ...")
    ws <- collocations (txt, removePunct=TRUE,  
                        removeNumbers=TRUE, size=2:3)
    ws <- ws[ws$word1 != ws$word2]
    ws <- ws[ws$word1 != ws$word3]
    ws <- ws[ws$word2 != ws$word3]

    ## output to file
    f1 <- paste(outTxt,".csv", sep="")
    if (verbose) print("output to files ...")
    if (toGzip == TRUE) {
        write.csv(ws, file = gzfile(paste(f1,".gz",sep="")), row.names=FALSE)
    } else {
        write.csv(ws, file = f1, row.names=FALSE)
    }
    ws
}


###
### Text Clean Up
###
cleanUpTxt <- function (inTxt) {
    inTxt <- gsub("#\\w+ *","", inTxt) #remove user name in Tweets
    inTxt <- gsub(" www(.+) ", " ", inTxt) #remove url
    inTxt <- gsub("\\d+\\w+", "", inTxt) #remove alphanum
    inTxt <- gsub("\\&", " and ", inTxt)
    inTxt <- gsub("-", " ", inTxt) 
    inTxt <- gsub("â€“", " ", inTxt) #remove --
    inTxt <- gsub("â€™", "'", inTxt)
    inTxt
}


###
### Find Next Words, return atmost 3 words
###
nextWords <- function (inTxt, ws) {
    inTxt <- cleanUpTxt(inTxt)
    words <- tokenize(toLower(inTxt), removePunct=TRUE, removeNumbers=TRUE)
    if (length(words[[1]]) < 1) return (c("No word to be used"))
    
    rTxt <- c("", "", "")
    backoff <- FALSE
    lastWord <- tail(words[[1]],1)
    
    #implement prediction for two words input 
    if (length(words[[1]]) > 1) { 
        last2ndWord <- tail(words[[1]],2)[1]
        subws <- subset(ws, word1==last2ndWord & word2==lastWord & word3!="")
        n <- ifelse (nrow(subws)>=3L, 3L, nrow(subws))
        for (i in 1:n) {
            rTxt[i] <- subws$word3[i]
        }
        if (n<3L) backoff <- TRUE
    }
    
    # implement backoff or one word input
    k <- ifelse (backoff, n+1, 1)
    subws <- subset(ws, word1==lastWord & word3=="")
    n <- ifelse (nrow(subws)>=3L, 3L, nrow(subws))
    for (i in k:n) {
        rTxt[i] <- subws$word2[i]
    }

    list("good",rTxt)
}


###########################
sample_ratio <- 0.1 
news_ws <- createWordSequenceFile ("final/en_US/en_US.news.txt", outTxt = "news_ws",
                                   perc = sample_ratio, toGzip = FALSE)
blogs_ws <- createWordSequenceFile ("final/en_US/en_US.blogs.txt", outTxt = "blogs_ws",
                                   perc = sample_ratio, toGzip = FALSE)
tweet_ws <- createWordSequenceFile ("final/en_US/en_US.twitter.txt", outTxt = "tweet_ws",
                                   perc = sample_ratio, toGzip = FALSE)

## build a sentance with a initial word
sentance <- "mom"
for (i in 1:10) {
    n_words <- nextWords (sentance, tweet_ws)
    if (n_words[[1]]!="good") break
    sentance <- paste(sentance, n_words[[2]][1], sep=" ")
}
sentance


# build the predictive algorithm
