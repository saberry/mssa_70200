#####################
### Scraping ESPN ###
###  Shot Charts  ###
###   Link Clean  ###
#####################

library(stringr)

load("data/all_game_links.RData")

all_pbp_links <- na.omit(all_pbp_links)

all_pbp_links <- all_pbp_links[!grepl("^https", all_pbp_links$link), ]

game_links <- data.frame(
  link = all_pbp_links$link, 
  gameId = str_extract(all_pbp_links$link, "[0-9]+"), 
  date = str_extract(all_pbp_links$date, "[0-9]+")
)

game_links <- game_links[!duplicated(game_links$gameId), ]

game_links$game_pbp_links <- paste0(
  "https://www.espn.com/nba/playbyplay/_/gameId/", 
  game_links$gameId
)

write.csv(game_links, "data/game_pbp_links.csv", row.names = FALSE)
