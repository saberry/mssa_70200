#####################
### Scraping ESPN ###
###  Shot Charts  ###
###  Chart Scrape ###
#####################

library(httr2)
library(magrittr)
library(rvest)


shot_links <- read.csv("data/game_pbp_links.csv")

shots_taken_read <- read_html(
  "https://www.espn.com/nba/playbyplay/_/gameId/401360926"
)

shots_taken_elements <- shots_taken_read %>% 
  html_elements(
    "li.ShotChart__court__play"
  )

shots_xy <- shots_taken_elements |> 
  html_attr("style") |> 
  str_extract_all("[0-9]+\\.?[0-9]*%")

shots_xy_df <- lapply(shots_xy, function(pos) {
  data.frame( 
    x = pos[2], 
    y = pos[1])
})

shots_xy_df <- do.call(rbind, shots_xy_df)

shots_xy_df[, c("x", "y")] <- lapply(c("x", "y"), function(x) {
  shots_xy_df[, x] <- as.numeric(str_remove_all(shots_xy_df[, x], "%"))
})

shot_info <- shots_taken_elements |> 
  html_text()

shooter <- str_extract(shot_info, ".*(?=\\smisses)|.*(?=\\smakes)|(?<=blocks ).*(?=')")

distance <- str_extract(shot_info, "[0-9]+-?foot")

distance <- str_extract(distance, "[0-9]+")

distance <- ifelse(is.na(distance), 0, distance)

distance <- as.numeric(distance)

assist <- str_detect(shot_info, "assist")

three <- str_detect(shot_info, "three")

result <- ifelse(grepl("misses|blocks", shot_info), "missed", "made")

full_table <-  shots_taken_read %>%
  html_table() 

full_table <- full_table[[which(grepl("PLAY", sapply(full_table, colnames)))]]

final_df <- data.frame(shot_info, shooter, three, distance, result, assist)

final_df <- cbind(final_df, shots_xy_df)
