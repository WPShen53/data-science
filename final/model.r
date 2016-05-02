library(quanteda)
library(LaF)
library(R.utils)

set.seed(335599)

### for twitter
num_lines <- countLines("final/en_US/en_US.twitter.txt")
tweets <- sample_lines("final/en_US/en_US.twitter.txt", 0.001*num_lines)
tweets <- gsub("#\\w+ *","",tweets)

## using {quanteda} package
us_corpus <- corpus(tweets)
tweet_ws <- collocations (us_corpus, removePunct=TRUE, removeNumbers=TRUE)
tweet_ws <- tweet_ws[order(tweet_ws$count, decreasing=TRUE)]
head(tweet_ws)
head(tweet_ws[word1=="the"])
write.csv(subset(tweet_ws, select=c(word1,word2,count)),
          file = gzfile("tweet_ws.csv.gz"))

tweet_ws2 <- collocations (us_corpus, removePunct=TRUE, 
                           removeNumbers=TRUE, ngrams=2)
tweet_ws2$word3 <- gsub("\\w+_","",tweet_ws2$word2)
head(tweet_ws2[grepl("^the_", tweet_ws2$word1)])
write.csv(subset(tweet_ws2, select=c(word1,word3,count)), 
          file = gzfile("tweet_ws2.csv.gz"))

### for blogs
num_lines <- countLines("final/en_US/en_US.blogs.txt")
blogs <- sample_lines("final/en_US/en_US.blogs.txt", 0.001*num_lines)
#blogs <- gsub("#\\w+ *","",blogs)

## using {quanteda} package
us_corpus <- corpus(blogs)
blogs_ws <- collocations (us_corpus, removePunct=TRUE, removeNumbers=TRUE)
blogs_ws <- blogs_ws[order(blogs_ws$count, decreasing=TRUE)]
head(blogs_ws)
head(blogs_ws[word1=="the"])
write.csv(subset(blogs_ws, select=c(word1,word2,count)),
          file = gzfile("blogs_ws.csv.gz"))

blogs_ws2 <- collocations (us_corpus, removePunct=TRUE, 
                           removeNumbers=TRUE, ngrams=2)
blogs_ws2$word3 <- gsub("\\w+_","",blogs_ws2$word2)
head(blogs_ws2[grepl("^the_", blogs_ws2$word1)])
write.csv(subset(blogs_ws2, select=c(word1,word3,count)),
          file = gzfile("blogs_ws2.csv.gz"))

