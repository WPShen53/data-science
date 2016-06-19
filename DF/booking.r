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


# df_booking_Qty <- read.csv("~/R/Project/df_booking_Qty.csv")

load("~/R/Project/df_booking_Qty.RData")

df <- subset(df_booking_Qty, select=-c(QTY8,SVC,Sector,Segment))
sum(duplicated(df))
df <- aggregate (QTY12 ~ Customer.Family + TM6 + BOOK_MONTH, data = df, sum)
df <- df[order(df$Customer.Family, df$TM6),]
dur <- unique(df$BOOK_MONTH)
cus <- unique(df$Customer.Family)
tm6 <- unique(df$TM6)

tm6.list <- split (df, df$TM6)
lapply(tm6.list, FUN=FillMissingMonth, dur=dur)

df_tm6 <- aggregate(QTY12 ~ Customer.Family + TM6, data = df, sum)


### working script sets

tms477 <- tm6.list[["TMS477"]]
tms477 <- FillMissingMonth(tms477, dur)
tms477 <- mutate(tms477, MonDif = CalMonthDif(BOOK_MONTH))
tms477 <- tms477[order(tms477$MonDif),]
plot(x=tms477$MonDif,y=tms477$QTY12)
lines(x=tms477$MonDif,y=tms477$QTY12)


qbooking <- booking_sum_Cus[["Qualcomm"]]
qbooking_TM6 <- split(qbooking, qbooking$TM6)
k <- sapply(qbooking_TM6, nrow)
qbooking_TM6 <- qbooking_TM6[k!=0]
k <- sapply(qbooking_TM6, nrow)
hist(k, breaks=100, xlim=c(0,10))

plot(density(k))
