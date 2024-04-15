library(ggplot2)
library(patchwork)
library(rvest)
library(stringr)

shots_taken_nodes <- read_html(
  "https://www.espn.com/nba/playbyplay/_/gameId/401360926"
) |> 
  html_elements(
    "li.ShotChart__court__play"
  )

shots_xy <- shots_taken_nodes |> 
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

plot(shots_xy_df$x, shots_xy_df$y)

shot_info <- shots_taken_nodes |> 
  html_text()

shooter <- str_extract(shot_info, ".*(?=\\smisses)|.*(?=\\smakes)|(?<=blocks ).*(?=')")

distance <- str_extract(shot_info, "[0-9]+-?foot")

distance <- str_extract(distance, "[0-9]+")

distance <- ifelse(is.na(distance), 0, distance)

distance <- as.numeric(distance)

result <- ifelse(grepl("misses|blocks", shot_info), "missed", "made")

full_table <- read_html("https://www.espn.com/nba/playbyplay/_/gameId/401360926") |> 
  html_table() 

read_html("https://www.espn.com/nba/playbyplay/_/gameId/401360926") |> 
  html_elements("*") |> 
  html_text()

full_table <- full_table[[which(grepl("PLAY", sapply(full_table, colnames)))]]

final_df <- data.frame(shooter, distance, result)

final_df <- cbind(final_df, shots_xy_df)

court_image <- "https://secure.espncdn.com/redesign/assets/img/nba/bg-court.svg"

download.file(court_image, destfile = "nba_floor.svg")

img <- magick::image_read_svg("nba_floor.svg")

magick::image_write(img, path = "nba_floor.png", "png")

nba_court <- png::readPNG("nba_floor.png")

ggplot(final_df, aes(x, y, shape = result)) +
  ggpubr::background_image(nba_court) +
  geom_point(size = 3) +
  scale_shape_manual(values = c("made" = 19, "missed" = 13)) +
  theme_void() +
  theme(legend.position = "bottom")

