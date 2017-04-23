#download file from source
if(!file.exists("./data")) { dir.create("./data")}
fileurl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileurl, destfile = "./data/sourcedata.zip")
unzip(zipfile = "./data/sourcedata.zip", exdir = "./data")

#----------------------------reading file--------------------------
#read training file
x_train<-read.table(file = "./data/UCI HAR Dataset/train/X_train.txt")
y_train<-read.table(file = "./data/UCI HAR Dataset/train/y_train.txt")
subject_train<-read.table(file = "./data/UCI HAR Dataset/train/subject_train.txt")

#read test file
x_test <- read.table("./data/UCI HAR Dataset/test/X_test.txt")
y_test <- read.table("./data/UCI HAR Dataset/test/y_test.txt")
subject_test <- read.table("./data/UCI HAR Dataset/test/subject_test.txt")

# Reading feature vector:
features <- read.table("./data/UCI HAR Dataset/features.txt")

# Reading activity labels:
activityLabels = read.table("./data/UCI HAR Dataset/activity_labels.txt")


#------------------set columns for training and test sets----------
colnames(x_train)<-features[,2]
colnames(y_train)<-"activityID"
colnames(subject_train)<-"subjectID"

colnames(x_test)<-features[,2]
colnames(y_test)<-"activityID"
colnames(subject_test)<-"subjectID"
colnames(activityLabels)<-c("activityID","activityLabels")

#-----------------------merge datasets
merge_train<-cbind(x_train,y_train, subject_train) #563 variables
merge_test<-cbind(x_test,y_test,subject_test) #563 variables
combine_train_test<-rbind(merge_train, merge_test)# 563 variables

##reading columns for statistics
colname<-colnames(combine_train_test)

## identify required columns from dataset
md_sd<-( grepl("activityID", colname) |
          grepl("subjectID",colname) |
          grepl("mean..", colname) |
          grepl("sd..", colname)
           )

##dateset with required columns
dataset_mean_sd<-combine_train_test[,md_sd == TRUE] # 48variables

##add activity labels based on activityid
dataset_with_activitynames<-merge(x = dataset_mean_sd, y = activityLabels,
                   by = "activityID", all.x = TRUE) #49 variables

##finding mean based on subjectid and activityid, then sort result
tidydataset <- aggregate(. ~subjectID + activityID, dataset_with_activitynames, mean)
tidydataset<-tidydataset[order(tidydataset$subjectID, tidydataset$activityID),]


##writing results to file
write.table(tidydataset,file = "tidydataset.txt",row.names = FALSE, col.names = TRUE)
