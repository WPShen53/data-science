library(quanteda)
library(LaF)
library(R.utils)

set.seed(335599)

### for twitter
num_lines <- countLines("final/en_US/en_US.twitter.txt")
tweets <- sample_lines("final/en_US/en_US.twitter.txt", 0.6*num_lines)
tweets <- gsub("#\\w+ *","",tweets)

## build word sequence matrix using {quanteda} package
us_corpus <- corpus(tweets)
tweet_ws <- collocations (us_corpus, removePunct=TRUE, removeNumbers=TRUE)
tweet_ws <- tweet_ws[order(tweet_ws$count, decreasing=TRUE)]
head(tweet_ws)
head(tweet_ws[word1=="the"])
write.csv(subset(tweet_ws, select=c(word1,word2,count)),
          file = gzfile("tweet_ws.csv.gz"), row.names=FALSE)

tweet_ws2 <- collocations (us_corpus, removePunct=TRUE, 
                           removeNumbers=TRUE, ngrams=2)
tweet_ws2$word3 <- gsub("\\w+_","",tweet_ws2$word2)
tweet_ws2 <- tweet_ws2[tweet_ws2$count>1]
tweet_ws2 <- tweet_ws2[order(tweet_ws2$count, decreasing=TRUE)]
head(tweet_ws2[grepl("^the_", tweet_ws2$word1)])
write.csv(subset(tweet_ws2, select=c(word1,word3,count)), 
          file = gzfile("tweet_ws2.csv.gz"), row.names=FALSE)

## free up memory
rm(tweets, tweet_ws, tweet_ws2, us_corpus)


### for blogs
num_lines <- countLines("final/en_US/en_US.blogs.txt")
blogs <- sample_lines("final/en_US/en_US.blogs.txt", 0.6*num_lines)
#blogs <- gsub("#\\w+ *","",blogs)

## build word sequence matrix using {quanteda} package
us_corpus <- corpus(blogs)
blogs_ws <- collocations (us_corpus, removePunct=TRUE, removeNumbers=TRUE)
blogs_ws <- blogs_ws[order(blogs_ws$count, decreasing=TRUE)]
head(blogs_ws)
head(blogs_ws[word1=="the"])
write.csv(subset(blogs_ws, select=c(word1,word2,count)),
          file = gzfile("blogs_ws.csv.gz"), row.names=FALSE)

blogs_ws2 <- collocations (us_corpus, removePunct=TRUE, 
                           removeNumbers=TRUE, ngrams=2)
blogs_ws2$word3 <- gsub("\\w+_","",blogs_ws2$word2)
head(blogs_ws2[grepl("^the_", blogs_ws2$word1)])
write.csv(subset(blogs_ws2, select=c(word1,word3,count)),
          file = gzfile("blogs_ws2.csv.gz"), row.names=FALSE)

## free up memory
rm(blogs, blogs_ws, blogs_ws2, us_corpus)


### for news
num_lines <- countLines("final/en_US/en_US.news.txt")
news <- sample_lines("final/en_US/en_US.news.txt", 0.01*num_lines)

## build word sequence matrix using {quanteda} package
us_corpus <- corpus(news)
news_ws <- collocations (us_corpus, removePunct=TRUE, removeNumbers=TRUE, size=2:3)
news_ws <- news_ws[news_ws$count>1]
news_ws <- news_ws[order(news_ws$count, decreasing=TRUE)]
head(news_ws)
head(news_ws[word1=="the"])
write.csv(subset(news_ws, select=c(word1,word2,count)),
          file = gzfile("news_ws.csv.gz"), row.names=FALSE)

news_ws2 <- collocations (us_corpus, removePunct=TRUE, 
                          removeNumbers=TRUE, ngrams=2)
news_ws2 <- news_ws2[news_ws2$count>1]
news_ws2 <- news_ws2[order(news_ws2$count, decreasing=TRUE)]
news_ws2$word3 <- gsub("\\w+_","",news_ws2$word2)
head(news_ws2[grepl("^the_", news_ws2$word1)])
write.csv(subset(news_ws2, select=c(word1,word3,count)),
          file = gzfile("news_ws2.csv.gz"), row.names=FALSE)

## free up memory
rm(news, news_ws, news_ws2, us_corpus)




