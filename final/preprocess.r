library(quanteda)
library(tm)
library(LaF)
library(tau)
library(RWeka)

set.seed(335599)
tweets <- sample_lines("final/en_US/en_US.twitter.txt", 1000)

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
us_corpus <- corpus(tweets)
qtweet_ws <- collocations (us_corpus)
qtweet_ws <- qtweet_ws[order(qtweet_ws$count, decreasing=TRUE)]
head(qtweet_ws)
head(qtweet_ws[word1=="the"])

qtweet_ws2 <- collocations (us_corpus, ngrams=2)
head(qtweet_ws2[grepl("^the_", qtweet_ws2$word1)])

q_dfm3 <- dfm(us_corpus, ngrams=3)
freq_matrix <- colSums(as.matrix(q_dfm3))
freq_matrix <- freq_matrix[order(freq_matrix, decreasing=TRUE)]
head(freq_matrix[grepl("^the_", names(freq_matrix))])


