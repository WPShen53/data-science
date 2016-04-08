library(AppliedPredictiveModeling)
data(segmentationOriginal)
library(caret)

dt <- segmentationOriginal
inTrain <- dt[dt$Case=="Train",]
inTest <- dt[dt$Case=="Test",]

set.seed(125)
fitModel <- train (Class~., method = "rpart", data = inTrain)
fitModel$finalModel
plot(fitModel$finalModel)
text(fitModel$finalModel, use.n = TRUE, all = TRUE, cex = 0.8)

library(pgmm)
data(olive)
olive = olive[,-1]
fitTree <- train(Area~., method = "rpart", data = olive)
newdata = as.data.frame(t(colMeans(olive)))
predict(fitTree, newdata)

library(ElemStatLearn)
data(SAheart)
set.seed(8484)
train = sample(1:dim(SAheart)[1],size=dim(SAheart)[1]/2,replace=F)
trainSA = SAheart[train,]
testSA = SAheart[-train,]
set.seed(13234)
fitGlm <- train(chd ~ age + alcohol + obesity + tobacco + typea + ldl, method = "glm", family = "binomial", 
	data = trainSA)
trainingpredict <- predict(fitGlm, trainSA)
testingpredict <- predict(fitGlm, testSA)
sum(abs(trainingpredict-trainSA$chd) > 0.5)/231
sum(abs(testingpredict-testSA$chd) > 0.5)/231

library(ElemStatLearn)
data(vowel.train)
data(vowel.test)
vowel.train$y <- factor(vowel.train$y)
vowel.test$y <- factor(vowel.test$y)
set.seed(33833)
fitRF <- train (y ~., method = "rf", data = vowel.train)
varImp (fitRF)
