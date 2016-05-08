library(quanteda)
library(LaF)
library(data.table)

set.seed(335599)

###
### Creat Word Sequence Function
###
createWordSequenceFile <- function(inTxt, outTxt, 
                                   perc = 0.6,
                                   toGzip = FALSE,
                                   verbose = TRUE) 
{
    require(quanteda)
    require(LaF)
    require(data.table)
    
    ### readin from file
    if (verbose) print("counting file length ...")
    num_lines <- determine_nlines(inTxt)
    if (verbose) print("reading in data ...")
    txt <- sample_lines(inTxt, perc*num_lines)
    if (verbose) print("cleaning up text ...")
    txt <- cleanUpTxt(txt)
    
    ## build word sequence matrix using {quanteda} package
    if (verbose) print("building word sequence matrix ...")
    ws <- collocations (txt, removePunct=TRUE, removeNumbers=TRUE, size=2)
    ws <- ws[ws$count>2]
    ws <- ws[order(ws$count, decreasing=TRUE)]
    ws2 <- collocations (txt, removePunct=TRUE, removeNumbers=TRUE, size=3)
    ws2 <- ws2[ws2$count>2]
    ws2 <- ws2[order(ws2$count, decreasing=TRUE)]
    
    ### trim the word sequence matrix
    if (verbose) print("triming word sequence matrix ...")
    ws <- data.table(ws)
    setkey(ws, word1)
#    ws <- ws[,.SD[order(count,decreasing=TRUE)[1:10]],by=word1]
    ws <- rbind(ws, ws2)
    ws <- ws[ws$word1 != ws$word2]
    ws <- ws[ws$word1 != ws$word3]
    ws <- ws[ws$word2 != ws$word3]
    #ws <- subset(ws, select=-G2)
    
    ## output to file
    f1 <- paste(outTxt,".csv", sep="")
    if (toGzip == TRUE) {
        if (verbose) print("output to files ...")
        write.csv(ws, file = gzfile(paste(f1,".gz",sep="")), row.names=FALSE)
    }
    ws
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
    inTxt <- gsub("â€“", " ", inTxt) #remove --
    inTxt <- gsub("â€™", "'", inTxt)
    inTxt
}


###
### Find Next Words, return atmost 5 words (the Model)
###
nNextWord <- function (inTxt, ws, nword=3L) {
    inTxt <- cleanUpTxt(inTxt)
    words <- tokenize(toLower(inTxt), removePunct=TRUE, removeNumbers=TRUE)
    if (length(words[[1]]) < 1) return (c("No word to be used"))
    
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
    list("good",rTxt)
}

###
### Calculate the accuracy of next word predictive
###
accuracy <- function (txt, ws, nword=5, verbose=FALSE) {
    txt <- strsplit(txt, split = " ")
    tmatch <- 0
    for (i in 1:nline) {
        match <- 0
        ntxt <- length(txt[[i]])
        sentance <- ""
        for (j in 1:(ntxt-1)) {
            sentance <- paste (sentance, txt[[i]][j], sep=" ")
            n_words <- nNextWord(sentance, ws, nword)
            if (n_words[[1]]!="good") next
            if (txt[[i]][j+1] %in% n_words[[2]]) match <- match+1
        }
        tmatch <- tmatch + match
        if (verbose==TRUE) print (c(match, (ntxt-1)))
    }
    acc <- tmatch/(sum(sapply(txt, length))-length(txt))
    acc
}



###########################
memory.limit(size = 16000)
sample_ratio <- 0.1 
news_ws <- createWordSequenceFile ("final/en_US/en_US.news.txt", outTxt = "news_ws",
                                   perc = sample_ratio, toGzip = FALSE)
blogs_ws <- createWordSequenceFile ("final/en_US/en_US.blogs.txt", outTxt = "blogs_ws",
                                    perc = sample_ratio, toGzip = FALSE)
tweet_ws <- createWordSequenceFile ("final/en_US/en_US.twitter.txt", outTxt = "tweet_ws",
                                    perc = sample_ratio, toGzip = FALSE)
total_ws <- rbind(news_ws,blogs_ws,tweet_ws)


news_ws <- data.table(read.csv("news_ws.csv.gz",header=TRUE,stringsAsFactors=FALSE))
## test the accuracy of prediction
nline <- 20
txt <- sample_lines("final/en_US/en_US.twitter.txt", nline)

## do comparison of suggested words
accTable <- data.frame(acc=c(0,0))
for (n in 1:10) {
    accTable[n,] <- accuracy(txt, news_ws, nword = n, verbose = FALSE)
    print (accTable[n,])
}
accTable

## do comparison of Frequence/Likelihood and min occurrence
gnews_ws <- news_ws[order(news_ws$G2, decreasing = TRUE)]
accTable <- data.frame(Freq=c(0,0),G2=c(0,0),Size=c(0,0))
### full word sequence
facc <- accuracy(txt, news_ws, verbose = TRUE)
gacc <- accuracy(txt, gnews_ws, verbose = TRUE)
accTable[1,] <- c(facc, gacc, object.size(news_ws))
### drop the low occurance word pairs
for (n in 1:20) {
    news_ws <- news_ws[news_ws$count>n]
    gnews_ws <- gnews_ws[gnews_ws$count>n]
    facc <- accuracy(txt, news_ws)
    gacc <- accuracy(txt, gnews_ws)
    accTable[n+1,] <- c(facc, gacc, object.size(news_ws))
}
accTable


 



## build a sentance with a initial word
sentance <- "mom"
for (i in 1:10) {
    print(sentance)
    n_words <- nNextNWord (sentance, news_ws)
    if (n_words[[1]]!="good") break
    sentance <- paste(sentance, n_words[[2]][1], sep=" ")
    print(n_words[[2]])
}
print(sentance)



## testing the word coverage
library(stringi)
inTxt <- "final/en_US/en_US.news.txt"
num_lines <- determine_nlines(inTxt)
ntokens <- rep(0L, 10)
for (n in 1:10) {
    print(n)
    txt <- sample_lines(inTxt, as.integer(num_lines*n/10))
    stats <- tokenize(txt, what='fastestword')
    ntokens[n] <- length(stats)
}
system("wc -m -w -l -L *.txt")
