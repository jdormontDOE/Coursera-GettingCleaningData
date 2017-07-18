# Coursera-GettingCleaningData
Getting and Cleaning Data Week 4 Course Project

The R script runAnalysis.R does the following actions:
1. Download the dataset if it does not already exist in the working directory
2. Load the activity and feature info
3. Loads both the training and test datasets, keeping only those columns which
   reflect a mean or standard deviation
4. Loads the activity and subject data for each dataset, and merges those
   columns with the dataset
5. Merges the two datasets
6. Converts the `activity` and `subject` columns into factors
7. Creates a tidy dataset that consists of the average (mean) value of each
   variable for each subject and activity pair.

The end result is shown in the file `tidy.txt`.

NOTE: To use this script you will need to update your working directory found on line 29
