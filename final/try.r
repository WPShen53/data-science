library(quanteda)
library(tm)
library(LaF)
library(tau)
library(RWeka)

blogs_ws <- readRDS ("blog_ws.RDS")
news_ws <- readRDS ("news_ws.RDS")
tweet_ws <- readRDS ("tweet_ws.RDS")
unlink(".RDS")
blogs_ws <- blogs_ws[blogs_ws$count>1]
news_ws <- news_ws[news_ws$count>1]
tweet_ws <- tweet_ws[tweet_ws$count>1]
blogs_ws <- blogs_ws[order(blogs_ws$count, decreasing = TRUE)]
news_ws <- news_ws[order(news_ws$count, decreasing = TRUE)]
tweet_ws <- tweet_ws[order(tweet_ws$count, decreasing = TRUE)]

set.seed(335599)
tweets <- sample_lines("final/en_US/en_US.twitter.txt", 1000)
tweets <- gsub("#\\w+ *", "", tweets)  #remove username start with #


## using {tm} package
tmtwCorpus <- Corpus(VectorSource(tweets))
BigramTokenizer <- function(x) NGramTokenizer(x, Weka_control(min = 2, max = 2))
ttweet_tdm <- TermDocumentMatrix(tmtwCorpus, 
                                 control = list(tokenize = BigramTokenizer,
                                                stripWhitespace = TRUE,
                                                removePunctuation = TRUE, 
                                                removeNumbers = TRUE,
                                                tolower = TRUE))
findFreqTerms(ttweet_tdm, 10)
freq_matrix <- rowSums(as.matrix(ttweet_tdm))
freq_matrix <- freq_matrix[order(freq_matrix, decreasing=TRUE)]
head(freq_matrix)
head(freq_matrix[grepl("^the ", names(freq_matrix))])



## using {quanteda} package
q_dfm3 <- dfm(us_corpus, ngrams=3)
freq_matrix <- colSums(as.matrix(q_dfm3))
freq_matrix <- freq_matrix[order(freq_matrix, decreasing=TRUE)]
head(freq_matrix[grepl("^the_", names(freq_matrix))])

