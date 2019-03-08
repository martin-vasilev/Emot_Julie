
library(EMreading)
setwd("D:/Data/asc")

# preprocess data
data<- SingleLine(data_list= "C:/Users/marti/Desktop/EMOT", ResX= 1920, ResY=1080, maxtrial= 24)

# save raw data so that you don't have to re-do this later on:
save(data, file = "data.Rda")

dataN<- cleanData(data)

FD<- wordMeasures(dataN, multipleItems = T)

save(FD, file= "FD.Rda")

library(readr)
FD$frame<- NULL
FD2<- NULL

for(i in 1:length(unique(FD$sub))){
  
  t<- subset(FD, sub== i)
  file<- read_table2(paste("C:/Users/marti/Desktop/Emot_Julie/design/P", toString(i), ".txt", sep= ""))
  
  for(j in 1:nrow(t)){
    
    a<- which(file$item== t$item[j] & file$cond== t$cond[j])
    t$frame[j]<- file$frame[a]
  }
  FD2<- rbind(FD2, t)
  
}

write.csv(FD2, file= "Word_data.csv")
