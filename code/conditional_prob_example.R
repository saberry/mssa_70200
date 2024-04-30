library(data.table)
library(ggplot2)

load("data/nba_pbp_14_24.RData")

three_point_count <- nrow(all_pbp_data[three == TRUE, ])

three_point_made <- nrow(all_pbp_data[three == TRUE & result == "made", ])

three_point_prob <- three_point_made / three_point_count

assist_possible <- sum(!(is.na(all_pbp_data$assist)))

assist_count <- sum(all_pbp_data$assist, na.rm = TRUE)

assist_prob <- assist_count / assist_possible

# Now the goal is to find the conditional probability of a making
# a 3 point shot given that it was an assist. 

#P(3-point|Assist) = P(3-point intersection Assist) / P(Assist)

three_point_assist_count <- sum(all_pbp_data$three == TRUE & all_pbp_data$assist, na.rm = TRUE)

three_point_assist_prob <- three_point_assist_count / sum(!(is.na(all_pbp_data$result)))

three_point_assist_prob / assist_prob

three_point_assist_count / assist_count

# FUTURE LBJ Stuff for now

lbj <- all_pbp_data[grepl("LeBron James", all_pbp_data$shooter), ]

lbj[, date := lubridate::ymd(date)]

lbj$x[lbj$x < 50] <- abs(lbj$x[lbj$x < 50] - 100)
lbj$y[lbj$x < 50] <- abs(lbj$y[lbj$x < 50] - 100)

library(ggplot2)

ggplot(data=data.frame(x=1,y=1),aes(x,y))+
  ###outside box:
  geom_path(data=data.frame(x=c(-25,-25,25,25,-25),y=c(0,47,47,0,0)))+
  ###solid FT semicircle above FT line:
  geom_path(data=data.frame(x=c(-6000:(-1)/1000,1:6000/1000),y=c(19+sqrt(6^2-c(-6000:(-1)/1000,1:6000/1000)^2))),aes(x=x,y=y))+
  ###dashed FT semicircle below FT line:
  geom_path(data=data.frame(x=c(-6000:(-1)/1000,1:6000/1000),y=c(19-sqrt(6^2-c(-6000:(-1)/1000,1:6000/1000)^2))),aes(x=x,y=y),linetype='dashed')+
  ###key:
  geom_path(data=data.frame(x=c(-8,-8,8,8,-8),y=c(0,19,19,0,0)))+
  ###box inside the key:
  geom_path(data=data.frame(x=c(-6,-6,6,6,-6),y=c(0,19,19,0,0)))+
  ###restricted area semicircle:
  geom_path(data=data.frame(x=c(-4000:(-1)/1000,1:4000/1000),y=c(5.25+sqrt(4^2-c(-4000:(-1)/1000,1:4000/1000)^2))),aes(x=x,y=y))+
  ###halfcourt semicircle:
  geom_path(data=data.frame(x=c(-6000:(-1)/1000,1:6000/1000),y=c(47-sqrt(6^2-c(-6000:(-1)/1000,1:6000/1000)^2))),aes(x=x,y=y))+
  ###rim:
  geom_path(data=data.frame(x=c(-750:(-1)/1000,1:750/1000,750:1/1000,-1:-750/1000),y=c(c(5.25+sqrt(0.75^2-c(-750:(-1)/1000,1:750/1000)^2)),c(5.25-sqrt(0.75^2-c(750:1/1000,-1:-750/1000)^2)))),aes(x=x,y=y))+
  ###backboard:
  geom_path(data=data.frame(x=c(-3,3),y=c(4,4)),lineend='butt')+
  ###three-point line:
  geom_path(data=data.frame(x=c(-22,-22,-22000:(-1)/1000,1:22000/1000,22,22),y=c(0,169/12,5.25+sqrt(23.75^2-c(-22000:(-1)/1000,1:22000/1000)^2),169/12,0)),aes(x=x,y=y))+
  ###fix aspect ratio to 1:1
  coord_fixed() +
  theme_minimal()

## Now we need to rotate the x, y for lbj by 90 degrees:

lbj[, x := 94 - x]
lbj[, y := ]

ggplot(lbj, aes(x, y)) +
  geom_hex() +
  theme_minimal()
