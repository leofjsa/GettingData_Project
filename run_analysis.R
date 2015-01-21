########################################################################
## COURSERA / JHU - DATA SCIENCE SPECILIZATION
## GETTING AND CLEANING DATA - Course project
########################################################################

#Libraries
library(dplyr)
library(knitr)



########################################################################
## 1. LOADING AND PROCESSING THE DATA
########################################################################

########################################################################
## 1.a) Load auxiliary data for the training and test sets (features and activity labels)
########################################################################

## Column names for the 561 features
FolderName <- "./UCI HAR Dataset"
FileName <- "features.txt"
labelFeatures <- read.table(file = paste(FolderName, FileName, sep = "/"))

dim(labelFeatures)
head(labelFeatures)
tail(labelFeatures)

## Activity label
FolderName <- "./UCI HAR Dataset"
FileName <- "activity_labels.txt"
labelActivity <- read.table(file = paste(FolderName, FileName, sep = "/"))
names(labelActivity) <- c("act_id", "act_label")

dim(labelActivity)
print(labelActivity)

########################################################################
## 1.b) Load and process the training data set (individual + activity + features with column names)
########################################################################

## Main data (561 features)
FolderName <- "./UCI HAR Dataset"
FileName <- "/train/X_train.txt"
TrainData <- read.table(file = paste(FolderName, FileName, sep = "/"))
names(TrainData) <- labelFeatures[,2]

dim(TrainData)
head(TrainData[1:6])

## Activity  (1 column that identifies the activity and 1 column for the label)

### Loads data (activity id)
FolderName <- "./UCI HAR Dataset"
FileName <- "/train/y_train.txt"
TrainActivity <- read.table(file = paste(FolderName, FileName, sep = "/"))
names(TrainActivity) <- "act_id"

### Includes labels
TrainActivity <- merge(x = TrainActivity, y = labelActivity, 
                       by.x = "act_id", by.y = "act_id", 
                       all = FALSE)

### Check results
head(TrainActivity)
table(TrainActivity)

## Individual id (1 column that identifies the individual being monitored)
FolderName <- "./UCI HAR Dataset"
FileName <- "/train/subject_train.txt"
TrainIndividual <- read.table(file = paste(FolderName, FileName, sep = "/"))
names(TrainIndividual) <- "individual"

dim(TrainIndividual)
table(TrainIndividual)

## Unified training dataset
TrainData <- data.frame(TrainIndividual, TrainActivity, "DataType" = "Train", TrainData, 
                        check.names = TRUE)

dim(TrainData)
head(TrainData[1:6])


########################################################################
## 1.c) Load and process the testing data set (individual + activity + features with column names)
########################################################################

## Main data (561 features)
FolderName <- "./UCI HAR Dataset"
FileName <- "/test/X_test.txt"
TestData <- read.table(file = paste(FolderName, FileName, sep = "/"))
names(TestData) <- labelFeatures[,2]

dim(TestData)
head(TestData[1:5])

## Activity id (1 column that identifies the activity being executed and monitored)

### Loads data (activity id)
FolderName <- "./UCI HAR Dataset"
FileName <- "/test/y_test.txt"
TestActivity <- read.table(file = paste(FolderName, FileName, sep = "/"))
names(TestActivity) <- "act_id"

### Includes labels
TestActivity <- merge(x = TestActivity, y = labelActivity, 
                       by.x = "act_id", by.y = "act_id", 
                       all = FALSE)

### Check results
head(TestActivity)
table(TestActivity)


## Individual id (1 column that identifies the individual being monitored)
FolderName <- "./UCI HAR Dataset"
FileName <- "/test/subject_test.txt"
TestIndividual <- read.table(file = paste(FolderName, FileName, sep = "/"))
names(TestIndividual) <- "individual"

dim(TestIndividual)
table(TestIndividual)


## Unified testing dataset
TestData <- data.frame(TestIndividual, TestActivity, "DataType" = "Test", TestData, 
                        check.names = TRUE)

dim(TestData)
head(TestData[1:6])
head(TrainData[1:6])


########################################################################
## 1.d) Make a full data set (binding training and test datasets)
########################################################################

## Full dataset (training and test, with activities and feature labels)
FullData <- rbind(TrainData, TestData)
rm(TrainData, TrainActivity, TrainIndividual, TestData, TestActivity, TestIndividual)
rm(FileName, FolderName)



########################################################################
## 2. CREATING THE DATASETS DEMANDED IN THE PROJECT DEFINITION
########################################################################

########################################################################
## 2. a) Extracts only the measurements on the mean and standard deviation for each measurement (item 2)
##       final dataframe: Data_VarMeanStd
########################################################################

## Keeps only the feature columns that: contain the strings 'mean' or 'std' (lower case), except for 'meanFreq'
labelFeatures_Mean <- grep(pattern = "mean" , 
                           x = labelFeatures[, 2], 
                           ignore.case = FALSE, 
                           value = FALSE)             # Index for features that contain string 'mean'
labelFeatures_MeanExclude <- grep(pattern = "meanFreq", 
                                  x = labelFeatures[, 2], 
                                  ignore.case = FALSE, 
                                  value = FALSE)      # Index for features that contain string 'meanFreq'
labelFeatures_Mean <- labelFeatures_Mean[!(labelFeatures_Mean %in% labelFeatures_MeanExclude)]  #contains 'mean' and doesn't contain 'meanFreq'
labelFeatures_Std <- grep(pattern = "std" , 
                          x = labelFeatures[, 2], 
                          ignore.case = FALSE, 
                          value = FALSE)

NumericColumns <- c(labelFeatures_Mean+4, labelFeatures_Std+4)
rm(labelFeatures_Mean, labelFeatures_MeanExclude, labelFeatures_Std)

Data_VarMeanStd <- FullData[, c(1:4, NumericColumns)]



########################################################################
## 2. b) "Tidy dataset" (item 5)
##       final dataframe: Data_AveragesPerGroup
########################################################################

## Identifies valid groups (existing combinations of individual x activity)
ValidGroupsAux <- group_by (Data_VarMeanStd, individual, act_id, act_label)
ValidGroups <- attributes(ValidGroupsAux)$labels

## Calculates the average for each numeric variable, per group
ValueMatrix <- matrix(nrow = NROW(ValidGroups),
                      ncol = NROW(NumericColumns))
colnames(ValueMatrix) <- colnames(FullData[NumericColumns])

for (i in 1:40) {
      Filter <- FullData$individual == ValidGroups$individual[i] & FullData$act_id == ValidGroups$act_id[i]
      ValueMatrix[i, ] <- colMeans(FullData[Filter, NumericColumns])
}
      
## Merges the groups definition with the average values
Data_AveragesPerGroup <- data.frame(ValidGroups, ValueMatrix)
rm(ValidGroups, ValidGroupsAux, ValueMatrix, Filter, NumericColumns, i)

## Writes final dataset in a file
FolderName <- "./Assignments/3- Getting and cleaning data"
FileName <- "TidyData2.txt"
write.table(x = Data_AveragesPerGroup, 
            file = paste(FolderName, FileName, sep="/"), 
            append = FALSE, 
            quote = FALSE, 
            sep = "\t", 
            row.names = FALSE, 
            col.names = TRUE)
