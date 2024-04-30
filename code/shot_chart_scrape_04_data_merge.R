

library(data.table)

# We will pull out the gameId and the dates
# for joining purposes

load("data/all_game_links.RData")

all_pbp_links$date <- stringr::str_extract(all_pbp_links$date, "\\d+")
all_pbp_links$gameID <- stringr::str_extract(all_pbp_links$link, "\\d+")

all_pbp_links <- na.omit(all_pbp_links)

all_pbp_links <- as.data.table(all_pbp_links)

all_pbp_links <- all_pbp_links[, list(date, gameID)]

all_pbp_links <- all_pbp_links[!duplicated(all_pbp_links), ]

# Now that gameIds and dates are isolated, we can join 
# those into the main play-by-play data.

all_pbp_data <- fread("data/all_nba_pbp_data.csv")

all_pbp_data$gameID <- stringr::str_extract(all_pbp_data$link, "\\d+")

all_pbp_data <- merge.data.table(all_pbp_data, all_pbp_links, 
                                 all.x = TRUE, all.y = FALSE, 
                                 by = "gameID", allow.cartesian = TRUE)

rm(all_pbp_links)
gc()

# Now we need to bring in the shot location data:

load("data/complete_nba_pbp.RData")

# Just to mitigate any potential space issues, 
# we can strip out extra spaces from both:

all_pbp_data$play <- stringr::str_squish(all_pbp_data$play)

complete_data$shot_info <- stringr::str_squish(complete_data$shot_info)

complete_data$gameID <- stringr::str_extract(complete_data$link, "\\d+")

all_pbp_data <- merge.data.table(
  all_pbp_data, complete_data, 
  all.x = TRUE, all.y = FALSE, 
  by.x = c("gameID", "play", "link"), 
  by.y = c("gameID", "shot_info", "link"), 
  allow.cartesian = TRUE, 
  sort = FALSE
  )

setnames(all_pbp_data, "date.x", "date", skip_absent = TRUE)

all_pbp_data[, date.y := NULL]

rm(complete_data)

all_pbp_data$team <- stringr::str_extract(all_pbp_data$logo, "(?<=scoreboard/)\\w+(?=.png)")

all_pbp_data$logo <- stringr::str_extract(all_pbp_data$logo, "https:.*png")

all_pbp_data <- all_pbp_data[
  !duplicated(all_pbp_data[, !grepl("distance|x|y", colnames(all_pbp_data))]), 
]

save(all_pbp_data, file = "data/nba_pbp_14_24.RData")
write.csv(all_pbp_data, "data/nba_pbp_14_24.csv", row.names = FALSE)