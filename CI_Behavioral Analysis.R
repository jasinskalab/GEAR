library(lme4)

library(lmerTest)

library(reshape2)

GEAR_dataCI<-read.csv("~/GEAR_CI_Participants.csv", header = TRUE)

DataCI<-melt(GEAR_dataCI, id = c("Participant.ID", "Age", "Age.ASL","Age.CI"),
                         measured = c("English", "Hindi"), variable.name = "Language", value.name = "d.score")

DataCI$English<-str_detect(DataCI$Language,"English")
DataCI$Hindi<-str_detect(DataCI$Language,"Hindi")

data_english<-subset(DataCI$English==TRUE)
data_hindi<-subset(DataCI$Hindi==TRUE)      

mean(data_english$d.score)
sd(data_english$d.score)

mean(data_hindi$d.score)
sd(data_hindi$d.score)

mean(DataCI$d.score)
sd(DataCI$d.score)

# LME Models
lmer.main<-lmer(d.score ~ Language*Age.CI *Age.ASL + (1|Participant.ID), data=restructuredDataCI)
summary(lmer.main)


# Eliminate 3-way interaction
lmer.ntw=lmer(d.score ~ Language*Age.CI + Language*Age.ASL + Age.CI*Age.ASL + (1|Participant.ID), data=restructuredDataCI)
summary(lmer.ntw)

#Eliminate 2-way interactions one by one

lmer.rmv1=lmer(d.score ~ Language*Age.CI + Age.CI*Age.ASL + (1|Participant.ID), data=restructuredDataCI)
summary(lmer.rmv1)

lmer.rmv2= lmer(d.score ~ Language+ Age.CI*Age.ASL + (1|Participant.ID), data=restructuredDataCI)
summary(lmer.rmv2)


