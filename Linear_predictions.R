library(tidyverse)
library(ggpubr)
library(caret)
library(MLmetrics)

path1 = '../../all_variables_and_GPI_monthly_all_countries/'
path2 = '../../lm_results/'
country_files = list.files(path1, pattern="*.csv")

for (i in country_files){
  coun<-strsplit(i,"_")[[1]][[3]]
  country<-strsplit(coun, ".", fixed = TRUE)[[1]][[1]]
  
  print(country)
  #Load the data
  file_df <- file.path(path1, paste('all_variables_', country, '.csv', sep = '')) 
  if (file.exists(file_df)){
    df_country_initial<- read.csv(file_df, stringsAsFactors = FALSE)
    rownames(df_country_initial) <- df_country_initial$MonthYear 
    
    drops <- c("MonthYear")
    df_country<-df_country_initial[ , !(names(df_country_initial) %in% drops)] 

    ## Remove columns with more than 60% zeros
    df_country <-df_country[, which(as.numeric(colSums(df_country != 0)) > nrow(df_country)*0.6)]
    
    #Set the train percentage 
    train_set<-0.5
    
    train.data <- head(df_country, round(length(df_country$GPI) * train_set))
    h <- length(df_country$GPI) - length(train.data$GPI)
    test.data <- tail(df_country, h)
    
    #Create predictions dataframe
    df_predictions <- setNames(data.frame(matrix(ncol = 13, nrow = 0)), c("MonthYear", "Predictions1", "Predictions2", "Predictions3", "Predictions4", "Predictions5", "Predictions6", "Predictions7", "Predictions8", "Predictions9", "Predictions10", "Predictions11", "Predictions12"))
    
    k=0
    for (i in (1:(nrow(test.data)))) { #(i in (1:(nrow(test.data)-25))){
      print(i)
      model <- train(
        GPI ~., data = train.data, method = "lm", 
        trControl = trainControl(method = "timeslice",  initialWindow = 12, horizon = 6, fixedWindow = FALSE, allowParallel = TRUE, number = 10),
        tuneLength = 10
      )
      
      
      if ((nrow(test.data) - i) < 11){
        k = k + 1
      }  
      
      predictions <-model %>% predict(test.data[i:(i+11-k),])
      predictions <- as.numeric(unlist(predictions))
      predictions <- c(tail(row.names(train.data), n = 1), predictions)
      if (k>0){
        for (l in (1:k)){
          predictions <- c(predictions, '-')
        }
      }
      df_predictions[(nrow(df_predictions) + 1), ] <- predictions
      
      train.data <- rbind(train.data[2:nrow(train.data),], test.data[i:i,]) 
      
    }
    
    #Save the predictions
    write.csv(df_predictions, file.path (path2, paste(country, '_lm_', train_set, '_predictions.csv', sep = '')))
    
    df_results_analytics <- setNames(data.frame(matrix(ncol = 3, nrow = 0)), c("Pearson", "RMSE", "MAPE"))
    
    j = 0
    for (predname in colnames(df_predictions)[2:13]){
      actualpreds <- as.numeric(df_predictions[[predname]])
      actualpreds <- actualpreds[!is.na(actualpreds)]
      
      actualtest <- tail(test.data, nrow(test.data)-j) # 

      # Model performance metrics
      results_analytics <- data.frame(
        Pearson = cor(actualtest$GPI, actualpreds,  method = "pearson"),
        RMSE = RMSE(actualpreds, actualtest$GPI), 
        Mape = MAPE(actualpreds, actualtest$GPI)*100
      )
      df_results_analytics[(nrow(df_results_analytics) + 1), ] <- results_analytics
      j = j + 1 
    }
    write.csv(df_results_analytics, file.path (path2, paste(country, '_lm_', train_set, '_results.csv', sep = '')), row.names=T)
  }
  #Confirm remove all objects before going to the next interation
  #rm(list = ls(all.names = TRUE))
}  
