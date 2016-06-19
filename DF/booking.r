library(dplyr)
library(lubridate)

FillMissingMonth <- function (tm, dur) {
    missing_mon <- dur[dur<max(tm$BOOK_MONTH) & 
                           dur>min(tm$BOOK_MONTH) & 
                           !(dur%in%tm$BOOK_MONTH)]
    if (length(missing_mon)>0) {
        newrow <- tm[1:length(missing_mon),]
        newrow <- mutate(newrow, QTY12=0, BOOK_MONTH=missing_mon)
        tm <- rbind(tm, newrow)
    }
    tm <- mutate(tm, MonDif = CalMonthDif(BOOK_MONTH))
    tm <- tm[order(tm$MonDif),]
    tm
}

CalMonthDif <- function(month) {
    start <- month[1]
    dif <- month - start
    for (i in 1:7) {
        dif[which(dif>88)] <- dif[which(dif>88)] - 88
    }
    dif
}

unfactorize <- function(df){
    for(i in which(sapply(df, class) == "factor")) df[[i]] = as.character(df[[i]])
    return(df)
}

# df_booking_Qty <- read.csv("~/R/Project/df_booking_Qty.csv")

load("~/R/Project/df_booking_Qty.RData")


## Build the booking quantity in QTY12 for each TM6 and split into
## a list of data.frame where TM6 is the names of list

df <- subset(df_booking_Qty, select=-c(QTY8,SVC,Sector,Segment))
df <- mutate(df, CusTM6 = paste(as.character(df$Customer.Family), as.character(df$TM6), sep="."))
sum(duplicated(df))
dur <- unique(df$BOOK_MONTH)
df <- aggregate (QTY12 ~ CusTM6 + BOOK_MONTH, data = df, sum)
#df <- df[order(df$CusTM6),]

tm6.list <- split (df, df$CusTM6)
tm6.list <- lapply(tm6.list, FUN=subset, select=-CusTM6)
tm6.list <- lapply(tm6.list, FUN=unfactorize)
tm6.list <- lapply(tm6.list, FUN=FillMissingMonth, dur=dur)

tms <- tm6.list[["TMS477"]] #TMS477, TMF472
plot(x=tms$MonDif,y=tms$QTY12)
lines(x=tms$MonDif,y=tms$QTY12)


## Build the summary data.frame which conten the 

sum_df <- aggregate(QTY12 ~ Customer.Family + TM6, data = df_booking_Qty, sum)
sum_df <- mutate(sum_df, CusTM6 = paste(as.character(sum_df$Customer.Family), as.character(sum_df$TM6), sep="."))
sum_df <- unfactorize(sum_df)
# cus_list <- unique(sum_df$Customer.Family)
# tm6_list <- unique(sum_df$TM6)
startM <- sapply(tm6.list, FUN=function(tm){min(tm$BOOK_MONTH)})
endM <- sapply(tm6.list, FUN=function(tm){max(tm$BOOK_MONTH)})
perM <- sapply(tm6.list, FUN=function(tm){length(tm$BOOK_MONTH)})
sum_df <- mutate(sum_df, mon.start=startM, mon.end=endM, mon.dur=perM)



### working script sets

tms <- tm6.list[["TMS477"]] #TMF472
tms <- FillMissingMonth(tms, dur)
tms <- mutate(tms, MonDif = CalMonthDif(BOOK_MONTH))
tms <- tms477[order(tms$MonDif),]
plot(x=tms$MonDif,y=tms$QTY12)
lines(x=tms$MonDif,y=tms$QTY12)


qbooking <- booking_sum_Cus[["Qualcomm"]]
qbooking_TM6 <- split(qbooking, qbooking$TM6)
k <- sapply(qbooking_TM6, nrow)
qbooking_TM6 <- qbooking_TM6[k!=0]
k <- sapply(qbooking_TM6, nrow)
hist(k, breaks=100, xlim=c(0,10))

plot(density(k))
