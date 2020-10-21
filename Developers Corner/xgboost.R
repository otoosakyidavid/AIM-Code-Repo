getwd()
setwd("C:\\Users\\Ankit\\Desktop\\shufflenet\\XGBoost In R")
getwd()

# Installing Packages 
install.packages("data.table") 
install.packages("dplyr") 
install.packages("ggplot2") 
install.packages("caret") 
install.packages("xgboost") 
install.packages("e1071") 
install.packages("cowplot")
install.packages("matrix")
install.packages("magrittr")

# Loading packages 
library(data.table)  
library(dplyr)      
library(ggplot2)   
library(caret)       
library(xgboost)    
library(e1071)       
library(cowplot)      
library(Matrix)
library(magrittr)

#Reading the csv file
data <- read.csv("binary.csv")
print(data)
str(data)
data$rank <- as.factor(data$rank)

#Split the train and test data
set.seed(1234)
ind <- sample(2, nrow(data), replace = T, prob = c(0.8, 0.2))
train <- data[ind==1,]
test <- data[ind==2,]

# Create matrix - One-Hot Encoding for Factor variables
training <- sparse.model.matrix(admit ~ .-1, data = train)
head(training)
train_label <- train[,"admit"]
train_matrix <- xgb.DMatrix(data = as.matrix(training), label = train_label)

testing <- sparse.model.matrix(admit~.-1, data = test)
test_label <- test[,"admit"]
test_matrix <- xgb.DMatrix(data = as.matrix(testing), label = test_label)

# Parameters
nc <- length(unique(train_label))
xgb_params <- list("objective" = "multi:softprob",
                   "eval_metric" = "mlogloss",
                   "num_class" = nc)
watchlist <- list(train = train_matrix, test = test_matrix)

# Extreme Gradient Boosting Model
best_model <- xgb.train(params = xgb_params,
                       data = train_matrix,
                       nrounds = 100,
                       watchlist = watchlist,
                       eta = 0.001,
                       max.depth = 3,
                       gamma = 0,
                       subsample = 1,
                       colsample_bytree = 1,
                       missing = NA,
                       seed = 333)

# Training & test error plot
x<- data.frame(best_model$evaluation_log)
plot(x$iter, x$train_mlogloss, col = 'blue')
lines(x$iter, x$test_mlogloss, col = 'red')

min(x$test_mlogloss)
x[x$test_mlogloss == 0.675193,]

# Feature importance
imp_fearture <- xgb.importance(colnames(train_matrix), model = best_model)
print(imp_fearture)
xgb.plot.importance(imp_fearture,xlab="Probability",ylab="feature importance")

# Prediction on test data
pred <- predict(best_model, newdata = test_matrix)
prediction <- matrix(pred, nrow = nc, ncol = length(pred)/nc) %>%
  t() %>%
  data.frame() %>%
  mutate(label = test_label, max_prob = max.col(., "last")-1)
head(prediction)

#Confusion Matrix
table(Prediction = prediction$max_prob, Actual = prediction$label)