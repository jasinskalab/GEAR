library(lme4)
library(lmerTest)
library(reshape2)

GEAR_all<-read.csv("~/GEAR_dPrimeOnly_All.csv", header = TRUE)

Data_All<-melt(GEAR_all, id = c("Group", "Participant.ID"), measured = c("English_d", "Hindi_d"), variable.name = "Language", value.name = c("d_score"))

Data_All$Group=relevel(factor(Data_All$Group), ref = "TD")
Data_All$Language=relevel(factor(Data_All$Language), ref = "Hindi_d")

t.test(d_score~Group, data=Data_All)

data_CI = subset(Data_All, Group=="CI")
data_NH = subset(Data_All, Group=="TD") 

data_englishTD<-subset(data_NH, Language == "English_d")
data_hindiTD<-subset(data_NH, Language == "Hindi_d")  

data_englishCI<-subset(data_CI, Language == "English_d")
data_hindiCI<-subset(data_CI, Language == "Hindi_d")  

td_tstat1=t.test(data_englishTD$d_score, mu = 0)
td_tstat2=t.test(data_hindiTD$d_score, mu = 0)
td_tstat3=t.test(d_score~Language, data=data_NH)

ci_tstat1=t.test(data_englishCI$d_score, mu = 0)
ci_tstat2=t.test(data_hindiCI$d_score, mu = 0)
ci_tstat3=t.test(d_score~Language, data=data_CI)

lmer.all<-lmer(d_score  ~ Group + Language + Group*Language + (1|Participant.ID) , data=Data_All)
summary(lmer.all)

lmer_CI<-lmer(d_score  ~ Language + (1|Participant.ID) , data=data_CI)
summary(lmer_CI)

lmer_NH<-lmer(d_score  ~ Language + (1|Participant.ID) , data=data_NH)
summary(lmer_NH)

