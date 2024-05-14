library(data.table)
library(sjPlot)

pl_data <- fread("C:/Users/sberry5/Downloads/openpowerlifting-latest/openpowerlifting-2024-04-27/openpowerlifting-2024-04-27-ae089792.csv")

pl_data <- pl_data[order(Name), ]

pl_model_data <- pl_data[, .(Sex, Equipment, Age, BodyweightKg, TotalKg, Tested)]

rm(pl_data)

test_mod <- lm(TotalKg ~ Age + BodyweightKg * Sex + Tested, data = pl_model_data)

summary(test_mod)

plot_model(test_mod, type = "int", 
           mdrt.values = "meansd")

load("~/teaching/mssa_70200/data/all_nba_stats.RData")

complete_output <- complete_output[complete_output$season != "Career", ]

complete_output <- complete_output[, c(1:5, 23:37, 42:52)]

library(corrr)
library(DALEX)
library(dplyr)
library(sjPlot)

nba_career_stats <- complete_output |> 
  group_by(player) |> 
  summarize(pts = sum(PTS), 
            reb = sum(REB), 
            ast = sum(AST), 
            to = sum(TO), 
            stl = sum(STL), 
            pf = sum(PF), 
            blk = sum(BLK), 
            gp = sum(GP), 
            gs = sum(GS), 
            avg_min = mean(MIN), 
            dq = sum(DQ), 
            eject = sum(EJECT), 
            tech = sum(TECH), 
            flag = sum(FLAG))

stat_corrs <- correlate(nba_career_stats)
stat_corrs <- rearrange(stat_corrs, method = "HC")
stat_corrs <- shave(stat_corrs)

rplot(stat_corrs)

test_lm <- lm(pts ~ gp + flag, data = nba_career_stats)

summary(test_lm)

plot_model(test_lm, type = "pred")
