GEAR_dataNH<-read.csv("~/GEAR_hearing_participants.csv", header = TRUE)
str(GEAR_dataNH)

DataNH<-melt(GEAR_dataNH, id = c("Participant.ID", "Age","Gender"), measured = c("English", "Hindi"), variable.name = "Language", value.name = "d.score")

DataNH$English<-str_detect(DataNH$Language,"English")
DataNH$Hindi<-str_detect(DataNH$Language,"Hindi")

data_english<-subset(DataNH$English==TRUE)
data_hindi<-subset(DataNH$Hindi==TRUE)      

mean(data_english$d.score)
sd(data_english$d.score)

mean(data_hindi$d.score)
sd(data_hindi$d.score)

mean(DataNH$d.score)
sd(DataNH$d.score)


lmer.nh<-lmer(d.score ~ Language + (1|Participant.ID), data=DataNH)
summary(lmer.nh)