library(ElemStatLearn)
library(caret)
data(vowel.train)
data(vowel.test)
set.seed(33833)
vowel.train$y <- factor(vowel.train$y)
vowel.test$y <- factor(vowel.test$y)
fitRF <- train (y~., method = "rf", data = vowel.train)
fitGbm <- train (y~., method = "gbm", data = vowel.train, verbose=FALSE)
rfPred <- predict(fitRF, vowel.test)
gbmPred <- predict(fitGbm, vowel.test)
confusionMatrix(vowel.test$y,rfPred)$overall["Accuracy"]
confusionMatrix(vowel.test$y,gbmPred)$overall["Accuracy"]
sum(rfPred == gbmPred)/length(rfPred)


library(caret)
library(gbm)
set.seed(3433)
library(AppliedPredictiveModeling)
data(AlzheimerDisease)
adData = data.frame(diagnosis,predictors)
inTrain = createDataPartition(adData$diagnosis, p = 3/4)[[1]]
training = adData[ inTrain,]
testing = adData[-inTrain,]
set.seed(62433)
fit1 <- train(diagnosis~., method="rf", data=training)
fit2 <- train(diagnosis~., method="gbm", data=training, verbose=FALSE)
fit3 <- train(diagnosis~., method="lda", data=training)
pred1 <- predict(fit1, testing)
pred2 <- predict(fit2, testing)
pred3 <- predict(fit3, testing)
ctraining <- data.frame(pred1, pred2, pred3, diagnosis=testing$diagnosis)
fit4 <- train(diagnosis~., method="rf", data=ctraining)
pred4 <- predict(fit4, testing)
confusionMatrix(testing$diagnosis, pred1)$overall["Accuracy"]
confusionMatrix(testing$diagnosis, pred2)$overall["Accuracy"]
confusionMatrix(testing$diagnosis, pred3)$overall["Accuracy"]
confusionMatrix(testing$diagnosis, pred4)$overall["Accuracy"]


set.seed(3523)
library(AppliedPredictiveModeling)
data(concrete)
inTrain = createDataPartition(concrete$CompressiveStrength, p = 3/4)[[1]]
training = concrete[ inTrain,]
testing = concrete[-inTrain,]
set.seed(233)
fitLasso <- train(CompressiveStrength~., method="lasso", data=training)
plot.enet(fitLasso$finalModel, xvar="penalty", use.color=TRUE)


library(lubridate) # For year() function below
dat = read.csv("~/R/Coursera/MachineLearning/gaData.csv")
training = dat[year(dat$date) < 2012,]
testing = dat[(year(dat$date)) > 2011,]
tstrain = ts(training$visitsTumblr)
library(forecast)
fitTs <- bats(tstrain)
fcast <- forecast(fitTs, level = 95, h = dim(testing)[1])
sum(fcast$lower < testing$visitsTumblr & testing$visitsTumblr < fcast$upper) / 
    dim(testing)[1]


set.seed(3523)
library(AppliedPredictiveModeling)
data(concrete)
inTrain = createDataPartition(concrete$CompressiveStrength, p = 3/4)[[1]]
training = concrete[ inTrain,]
testing = concrete[-inTrain,]
set.seed(325)
library(e1071)
fitSvm <- svm(CompressiveStrength ~ ., data = training)
pred <- predict(fitSvm, testing)
accuracy(pred, testing$CompressiveStrength)
