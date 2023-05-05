library(dplyr)

#Getting Data ----

activities <- read.table("UCI HAR Dataset/activity_labels.txt", col.names = c("id_activities", "activity"))
features <- read.table("UCI HAR Dataset/features.txt", col.names = c("id_features","functions"))

subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt", col.names = "subject")
x_test <- read.table("UCI HAR Dataset/test/X_test.txt", col.names = features$functions)
y_test <- read.table("UCI HAR Dataset/test/y_test.txt", col.names = "id_activities")

subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt", col.names = "subject")
x_train <- read.table("UCI HAR Dataset/train/X_train.txt", col.names = features$functions)
y_train <- read.table("UCI HAR Dataset/train/y_train.txt", col.names = "id_activities")

#Binding ----

x <- bind_rows(x_train, x_test)
y <- bind_rows(y_train, y_test)
subj <- bind_rows(subject_train, subject_test)
data <- bind_cols(subj, x, y)

#Only variables with "mean" and "std" ----

data1 <- tbl_df(data) %>% 
        select(subject, id_activities, contains("mean"), contains("std"))

#Renaming activities name on data----

data2 <- left_join(data1, activities, by="id_activities")

data2 <- tbl_df(data2) %>%
        select(-id_activities)

#Changing the variables names----

names(data2)<-gsub("Acc", "Accelerometer", names(data2))
names(data2)<-gsub("BodyBody", "Body", names(data2))
names(data2)<-gsub("Gyro", "Gyroscope", names(data2))
names(data2)<-gsub("Mag", "Magnitude", names(data2))
names(data2)<-gsub("^t", "Time", names(data2))
names(data2)<-gsub("^f", "Frequency", names(data2))
names(data2)<-gsub("tBody", "TimeBody", names(data2))
names(data2)<-gsub("-mean()", "Mean", names(data2), ignore.case = TRUE)
names(data2)<-gsub("-std()", "STD", names(data2), ignore.case = TRUE)
names(data2)<-gsub("-freq()", "Frequency", names(data2), ignore.case = TRUE)
names(data2)<-gsub("angle", "Angle", names(data2))
names(data2)<-gsub("gravity", "Gravity", names(data2))

#Average of each variable for activity and subject----

data3 <- tbl_df(data2) %>%
        group_by(subject, activity) %>%
        summarise_all(funs(mean))

#Writting----

write.table(data3, "Data.txt", row.name=FALSE)

