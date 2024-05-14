library(data.table)
library(gganimate)
library(ggplot2)
t
load("data/nba_pbp_14_24.RData")

lbj <- all_pbp_data[grepl("LeBron James", all_pbp_data$shooter), ]

lbj[, date := lubridate::ymd(date)]

lbj[, year := lubridate::year(date)]

lbj$x[lbj$x < 50] <- abs(lbj$x[lbj$x < 50] - 100)
lbj$y[lbj$x < 50] <- abs(lbj$y[lbj$x < 50] - 100)

# ggplot(lbj, aes(x_test, y_test, group = year)) +
#   geom_hex() +
#   theme_minimal() +
#   labs(title = "{closest_state}") +
#   transition_states(year)

# To rotate (x,y) points 90 degrees, 
# you need to make it (y, -x)

lbj$x_rotate <- lbj$y
lbj$y_rotate <- lbj$x * -1

lbj$x_scale <- (lbj$x_rotate - 50) * .5
lbj$y_scale <- (lbj$y_rotate + 100) * 1


anim_plot <- ggplot(data=data.frame(x=1,y=1),aes(x,y))+
  geom_hex(data = lbj, mapping = aes(x_scale, y_scale, group = year)) + 
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
  labs(title = paste0("GOAT Shots for ", "{closest_state}")) +
  transition_states(year) +
  theme_void()

anim_save("lbj_shots.gif")
