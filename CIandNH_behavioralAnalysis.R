library(lme4)
library(lmerTest)
library(reshape2)

GEAR_all<-read.csv("~/GEAR_dPrime_All.csv", header = TRUE)

Data_All<-melt(GEAR_all, id = c("Group", "Participant.ID"), measured = c("English", "Hindi"), variable.name = "Language", value.name = "d.score")


lmer.all<-lmer(d.score  ~ Group + Language + Group*Language + (1|Participant.ID) , data=Data_All)
summary(lmer.all)