# GETTING AND CLEANING DATA - course project

## General definitions
This script is structured as follows:  

1. Loading and processing the data:  
a) Load auxiliary data for the training and test sets (features and activity labels)  
b) Load and process the training data set (merges individual + activity + features with column names)  
c) Load and process the testing data set (merges individual + activity + features with column names)  
d) Make a full data set (binding training and test datasets)

2. Creating the datasets demanded in the project definition:  
a) Extracts only the measurements on the mean and standard deviation for each measurement (item 2)  
b) "Tidy dataset" (item 5)

This script assumes that the data is available and unziped in a folder called "UCI HAR Dataset" in the working directory.


## Code book for the "tidy dataset" (file TidyData.txt)
The "tidy dataset" has 3 'identification' columns that defines the groups and 66 'numeric values' columns. The existing combinations for individuals and activities generated a total of 40 groups.  

The 3 'identification' columns are:  
* individual: identification of the indidividual subject to the measures (30 distinct individuals)
* act_id: code for the type of activity being measured (6 distinct types)
* act_label: description for the type of activity

The 66 'numeric values' columns contain the mean values per grupo (individual x activity) for 66 features in the original data. The 66 selected features are the ones which contain the strings 'mean' or 'std' (lower case, except for 'meanFreq') in its name, according to the definition in the project item 2 ('Extracts only the measurements on the mean and standard deviation for each measurement')

These 66 columns are labeled according to the original data (tBodyAcc.mean...X, tBodyAcc.mean...Y, fBodyBodyGyroMag.std..)

The file contains headers and the columns are separated by tabs.
