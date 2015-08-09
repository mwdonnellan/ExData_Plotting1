##################################################################################
#
#       File: plot3.R
#       Description:    script written in the R language to fulfil part 1 of 4
#                       of Course Project 1, for the Exploratory Data Analysis
#                       course offered by Johns Hopkins University through Coursera
#                       (http://www.coursera.org).  The Exploratory Data Analysis
#                       course is the 4th of 9 courses in the Data Science Specialization
#                       certificate program.
#                       
#                       Course Project 1 includes 4 separate tasks, each of which
#                       requires generating a chart from a data file downloaded
#                       from a specified URL.
#                       
#                       Plot 3 is a line chart of the 3 "Sub_metering" data series
#                       in the source data file.
#
#       Author: mwd
#
#       Date: 201508091837 UTC -4 
#
#       Runtime directions: working directory must be empty before running.
#
##################################################################################
#Start clean
rm(list = ls(all = TRUE))

#install and load the necessary libraries
install.packages("data.table")
library(data.table)
install.packages("png")
library(png)
install.packages("lubridate") #masks hour, mday, month, quarter, wday, week, yday, year from data.table
library(lubridate)

#create a directory for the data file to be downloaded
dir.create("./energyusedata")

#put the relative path into a variable
euDataFileDir <- dir()[1]

#put the URL for the original source data file into a var
dlURL <- "https://d396qusza40orc.cloudfront.net/exdata%2Fdata%2Fhousehold_power_consumption.zip"

#put the destination path and filename into a var
dlFileName <- file.path(euDataFileDir,basename(dlURL))

#download the data file
download.file(dlURL,dlFileName)

#decompress the data file, get the list of files into a vector for interactive inspection
#to choose files (interactive inspection not coded)
dataFileList <- unzip(dlFileName, list=TRUE)

#get the data in the file into a (rather large) data table in our environment
#32 GB in this box, one hopes it is sufficient, taking a long time though... OK it returned
#the read.table parameters here were set after visual inspection of the result of a default import, 
#where it became clear that the first line has the column names, and the separator is semicolon ';'.
#We are told in the assignment that the NA character is '?'.  
#Notice that we don't want our Date and Time values to be factors, but rather strings, so
#that subsequent conversion to proper types is straightforward.
#Therefore we supply the necessary parameters in the call to read.table:
#energyUseTable <- read.table(unzip(dlFileName, "household_power_consumption.txt"), sep=';', na.strings='?', skip=1, stringsAsFactors = FALSE)

#new & improved
energyUseTable <- read.table(unzip(dlFileName, dataFileList$Name), sep=';', na.strings='?', skip=1, stringsAsFactors = FALSE)

#Now we need to subset to get just February 1 and 2 for year 2007:
#get our date boundaries into a vector using the same bizarre date format used in the data.
#the lubridate package is our friend, that's where the dmy function comes from.
dates <- dmy(c('1/2/2007','2/2/2007'))
#now munge the date strings in the original data set in just the same way (dmy) in order to obtain a match at both ends of the date range
euSubSet <- subset(energyUseTable, ((dmy(V1) >= dates[1]) & dmy(V1) <= dates[2]))

#write out the subset for use by other scripts, although for this project we will keep each script
#completely independent with its own download, etc., etc.  In real life we'd be more efficient
#and re-use rather than re-download.
#commented out here since we're keeping each script completely independent.
#write.csv(euSubSet, "./energyUseDataSubset")

#now that we have the data for the 2 days of concern, let's free up some resources
rm(energyUseTable)
unlink("./household_power_consumption.txt")

#now add a datetime column to help with the next charts

euSubSet <- within(euSubSet, {DateTime=format(as.POSIXct(paste(dmy(V1), V2)), "%d/%m/%Y %H:%M:%S") })

#plot 3
png(filename = "plot3.png",width = 480, height = 480, units = "px", pointsize = 12, bg = "white", res = NA, family = "", restoreConsole = TRUE, type = c("windows", "cairo", "cairo-png"))
plot(dmy_hms(euSubSet$DateTime), euSubSet$V7, type="l", xlab = "", ylab = "Energy sub metering")
par(new=T)
plot(dmy_hms(euSubSet$DateTime), euSubSet$V8, type="l", axes="F", col="red", ylim = c(0,40), xlab = "", ylab = "")
par(new=T)
plot(dmy_hms(euSubSet$DateTime), euSubSet$V9, type="l", axes="F", col="blue", ylim = c(0,40), xlab = "", ylab = "")
lCaptions <- c("Sub_metering_1","Sub_metering_2","Sub_metering_3")
lColors <- c("black","red","blue")
legend('topright', lCaptions, col=lColors, lty=1, lwd=1, cex=1.0)

dev.off()

#clean up
rm(list = ls(all = TRUE))
unlink("./energyUseDataSubset")