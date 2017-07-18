#############################################

# Getting and Cleaning Data Course Project
# Coder: Josh Dormont
# Spring/Summer 2017

###

## runAnalysis.R will:

# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names.
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

##############################################

## Load required packages
library(dplyr)
library(data.table)
library(tidyr)
library(plyr)

### 1. Merge the training and test sets to create one data set

## Read in the data files

filesPath <- "D:/CodingWithR/GettingCleaningData/UCI HAR Dataset"

# Read subject files
dataSubjectTrain <- tbl_df(read.table(file.path(filesPath, "train", "subject_train.txt")))
dataSubjectTest  <- tbl_df(read.table(file.path(filesPath, "test" , "subject_test.txt" )))

# Read activity files
dataActivityTrain <- tbl_df(read.table(file.path(filesPath, "train", "Y_train.txt")))
dataActivityTest  <- tbl_df(read.table(file.path(filesPath, "test" , "Y_test.txt" )))

# Read data files
dataTrain <- tbl_df(read.table(file.path(filesPath, "train", "X_train.txt" )))
dataTest  <- tbl_df(read.table(file.path(filesPath, "test" , "X_test.txt" )))

## Merge into one data frame
# for both Activity and Subject files this will merge the training and the test 
# sets by row binding and rename variables "subject" and "activityNum"
alldataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
setnames(alldataSubject, "V1", "subject")
alldataActivity<- rbind(dataActivityTrain, dataActivityTest)
setnames(alldataActivity, "V1", "activityNum")

#combine the DATA training and test files
dataTable <- rbind(dataTrain, dataTest)

# name variables according to feature e.g.(V1 = "tBodyAcc-mean()-X")
dataFeatures <- tbl_df(read.table(file.path(filesPath, "features.txt")))
setnames(dataFeatures, names(dataFeatures), c("featureNum", "featureName"))
colnames(dataTable) <- dataFeatures$featureName

#column names for activity labels
activityLabels<- tbl_df(read.table(file.path(filesPath, "activity_labels.txt")))
setnames(activityLabels, names(activityLabels), c("activityNum","activityName"))

# Merge columns
alldataSubjAct<- cbind(alldataSubject, alldataActivity)
dataTable <- cbind(alldataSubjAct, dataTable)

### 2. Extract only the measurements on the mean and standard deviation for each measurement.
dataFeaturesMeanStd <- grep("mean\\(\\)|std\\(\\)", dataFeatures$featureName, value = TRUE)

dataFeaturesMeanStd <- union(c("subject","activityNum"), dataFeaturesMeanStd)
dataTable<- subset(dataTable,select=dataFeaturesMeanStd) 

### 3. Uses descriptive activity names to name the activities in the data set

##enter name of activity into dataTable
dataTable <- merge(activityLabels, dataTable , by="activityNum", all.x=TRUE)
dataTable$activityName <- as.character(dataTable$activityName)

## create dataTable with variable means sorted by subject and Activity
dataTable$activityName <- as.character(dataTable$activityName)
dataAggr <- aggregate(. ~ subject - activityName, data = dataTable, mean) 
dataTable <- tbl_df(arrange(dataAggr,subject,activityName))

### 4. Appropriately labels the data set with descriptive variable names.

# Add descriptive variable names
names(dataTable) <- gsub("std()", "SD", names(dataTable))
names(dataTable) <- gsub("mean()", "MEAN", names(dataTable))
names(dataTable) <- gsub("^t", "time", names(dataTable))
names(dataTable) <- gsub("^f", "frequency", names(dataTable))
names(dataTable) <- gsub("Acc", "Accelerometer", names(dataTable))
names(dataTable) <- gsub("Gyro", "Gyroscope", names(dataTable))
names(dataTable) <- gsub("Mag", "Magnitude", names(dataTable))
names(dataTable) <- gsub("BodyBody", "Body", names(dataTable))

# check structure of new table
head(str(dataTable), 6)

### 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

sensor_averages = ddply(dataTable, c("subject","activityName"), numcolwise(mean))
write.table(sensor_averages, file = "tidyData.txt", row.name = FALSE)
