library(lme4)

library(lmerTest)

library(reshape2)

GEAR_dataCI<-read.csv("/GEAR_CI_Participants.csv", header = TRUE)

DataCI<-melt(GEAR_dataCI, id = c("Participant.ID", "Age", "Age.ASL","Age.CI"),
                         measured = c("English", "Hindi"), variable.name = "Language", value.name = "d.score")

DataCI$English<-str_detect(DataCI$Language,"English")
DataCI$Hindi<-str_detect(DataCI$Language,"Hindi")

data_english<-subset(DataCI, Language == "English")
data_hindi<-subset(DataCI, Language == "Hindi")      

a=mean(data_english$d.score)
a1=sd(data_english$d.score)

b=mean(data_hindi$d.score, na.rm=T)
b1=sd(data_hindi$d.score, na.rm=T)

c=mean(DataCI$d.score, na.rm=T)
c1=sd(DataCI$d.score, na.rm=T)
DataCI$Language=relevel(factor(DataCI$Language), ref = "Hindi")

# LME Models
lmer.main<-lmer(d.score ~ Language*Age.ASL*Age.CI + (1|Participant.ID), data=DataCI)
summary(lmer.main)

# Eliminate 3-way interaction by subsetting the data by Language

data_englishCI = subset(DataCI, Language=="English")
data_hindiCI = subset(DataCI, Language=="Hindi")  


data_modelCI<-lm(d.score ~ Age.CI*Age.ASL, data = data_englishCI)          
summary(data_modelCI)

english_mod <- lm(d.score ~ Age.CI, data = data_englishCI)
summary(english_mod)

english_mod2 <- lm(d.score ~ Age.ASL+Age.CI, data = data_englishCI)
summary(english_mod2)

data_hindiCI<-lm(d.score ~ Age.CI*Age.ASL, data = data_hindiCI)          
summary(data_hindiCI)

#there is a an effect of Age.CI, and a marginal interaction between CI and ASL age in English data

#### plot all beh data 
GEAR_beh<-read.csv("/GEAR_dPrime_All_noage.csv", header = TRUE)
gear_df <- subset(GEAR_beh, select = -c(English_d, Hindi_d))
gear_dp <- subset(GEAR_beh, select = -c(English_hit, Hindi_hit, English_fa, Hindi_fa))
beh_df <-melt(gear_df, id = c("Group", "Participant.ID"),
               measured = c("English_hit", "Hindi_hit", 
                            "English_fa", "Hindi_fa"), variable.name = "measure", 
              value.name = "rate")
dprime <-melt(gear_dp, id = c("Group", "Participant.ID"),
              measured = c("English_d", "Hindi_d"), variable.name = "language", 
              value.name = "dscore")

gear_sum.data <- beh_df %>% group_by(Group, measure) %>%
  summarise(rate=mean(rate, na.rm = TRUE))

GEAR.plot <- ggplot(beh_df, aes(x = Group, y = rate, group=measure, color=Group)) +
  geom_point(cex = 1.5, pch = 1.0,position = position_jitter(w = 0.1, h = 0))
GEAR.plot


GEAR.plot <- GEAR.plot +
  stat_summary(fun.data = 'mean_se', geom = 'errorbar', width = 0.2) +
  stat_summary(fun.data = 'mean_se', geom = 'pointrange') +
  geom_point(data=beh_df, aes(x=Group, y=rate)) #can use the sum.data data here
GEAR.plot


GEAR.plot <- GEAR.plot + 
  #geom_text(data=Beh_df, label=gear_sum.data$Group, vjust = -8, size = 5) +
  facet_wrap(~ measure, labeller = labeller(measure = 
                                           c("English_hit" = "Hit rate for English",
                                             "Hindi_hit" = "Hit rate for Hindi",
                                             "English_fa" = "False alarm rate for English",
                                             "Hindi_fa" = "False alarm rate for Hindi"))) 
GEAR.plot


GEAR.plot <-GEAR.plot +
  theme_classic() + 
  labs(title = "",
       x = "",
       y = "Rate")
GEAR.plot<-GEAR.plot + scale_y_continuous (limits=c(0, 20))
GEAR.plot


##plot dprime
gear_dp <- subset(GEAR_beh, select = -c(English_hit, Hindi_hit, English_fa, Hindi_fa))

dprime <-melt(gear_dp, id = c("Group", "Participant.ID"),
              measured = c("English_d", "Hindi_d"), variable.name = "language", 
              value.name = "dscore")

d.plot <- ggplot(dprime, aes(x = Group, y = dscore, group=language, color=Group)) +
  geom_point(cex = 1.5, pch = 1.0,position = position_jitter(w = 0.1, h = 0))
d.plot


d.plot <- d.plot +
  stat_summary(fun.data = 'mean_se', geom = 'errorbar', width = 0.2) +
  stat_summary(fun.data = 'mean_se', geom = 'pointrange') +
  geom_point(data=dprime, aes(x=Group, y=dscore)) #can use the sum.data data here
d.plot


d.plot <- d.plot + 
  #geom_text(data=Beh_df, label=gear_sum.data$Group, vjust = -8, size = 5) +
  facet_wrap(~ language, labeller = labeller(language = 
                                              c("English_d" = "d-prime for English",
                                                "Hindi_d" = "d-prime for Hindi"))) 
d.plot


d.plot <-d.plot +
  theme_classic() + 
  labs(title = "",
       x = "CI = Cochlear Implant Users, H = Typically Hearing ",
       y = "d-prime for Phonemic Discrimination")
d.plot <- d.plot + scale_y_continuous (limits=c(-3, 3))

figure <- ggarrange(GEAR.plot, d.plot, 
                    labels = c("A", "B"), common.legend = TRUE, legend = "right",ncol = 1, nrow = 2)


## unilaterals
Unilaterals<-read.csv("/GEAR_CI_Unilaterals.csv", header = TRUE)

uni_CI<-melt(Unilaterals, id = c("Participant.ID", "Age", "Age.ASL","Age.CI"),
             measured = c("English", "Hindi"), variable.name = "Language", value.name = "d.score")

uni_english<-subset(uni_CI, Language == "English")
uni_hindi<-subset(uni_CI, Language == "Hindi")      

mean(uni_english$d.score)
sd(uni_english$d.score)

mean(uni_hindi$d.score, na.rm=T)
sd(uni_hindi$d.score, na.rm=T)


uni_CI$Language=relevel(factor(uni_CI$Language), ref = "Hindi")

# LME Models
lmer.uni<-lmer(d.score ~ Language*Age.ASL*Age.CI + (1|Participant.ID), data=uni_CI)
summary(lmer.uni)

uni_englishCI = subset(uni_CI, Language=="English")
uni_hindiCI = subset(uni_CI, Language=="Hindi")  


uni_modelCI<-lm(d.score ~ Age.CI*Age.ASL, data = uni_englishCI)          
summary(uni_modelCI)


uni_modelCI2<-lm(d.score ~ Age.CI+Age.ASL, data = uni_englishCI)          
summary(uni_modelCI2)

uni_modelCI3<-lm(d.score ~ Age.CI+Age.ASL, data = uni_hindiCI)          
summary(uni_modelCI3)



## born deaf only
deaf_only<-read.csv("/GEAR_CI_BornDeafOnly.csv", header = TRUE)
deaf_CI<-melt(deaf_only, id = c("Participant.ID", "Age", "Age.ASL","Age.CI"),
             measured = c("English", "Hindi"), variable.name = "Language", value.name = "d.score")

deaf_english<-subset(deaf_CI, Language == "English")
deaf_hindi<-subset(deaf_CI, Language == "Hindi")  
deaf_CI$Language=relevel(factor(deaf_CI$Language), ref = "Hindi")

# LME Models
lmer.deaf<-lmer(d.score ~ Language*Age.ASL*Age.CI + (1|Participant.ID), data=deaf_CI)
summary(lmer.deaf)
