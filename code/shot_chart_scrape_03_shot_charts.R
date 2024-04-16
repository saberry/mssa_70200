#####################
### Scraping ESPN ###
###  Shot Charts  ###
###  Chart Scrape ###
#####################

library(future)
library(furrr)
library(httr2)
library(magrittr)
library(rvest)

shot_links <- read.csv("data/game_pbp_links.csv")

plan(multisession, workers = parallel::detectCores() - 1)

complete_data <- future_map2_dfr(
  .x = shot_links$game_pbp_links, 
  .y = shot_links$date, 
  .f = ~{
    
    Sys.sleep(runif(1, .1, .5))
    
    tryCatch({
      html_request <- request(.x) %>%
        req_retry(max_tries = 3, backoff = ~ 5) %>%
        req_error(is_error = function(resp) FALSE) %>%
        req_perform()
      
      request_body <- resp_body_string(html_request)
      
      shots_taken_read <- read_html(request_body)
      
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
      
      shooter <- str_extract(shot_info, 
                             ".*(?=\\smisses)|.*(?=\\smakes)|(?<=blocks ).*(?=')")
      
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
      
      final_df <- data.frame(shot_info, shooter, 
                             three, distance, 
                             result, assist, 
                             date = .y, 
                             link  = .x)
      
      final_df <- cbind(final_df, shots_xy_df)
    }, error = function(e) {
      data.frame(shot_info = NA, 
                 date = .y, 
                 link = .x
      )
    })
    
    
  }, .options = furrr_options(seed = NULL))

plan(sequential)

complete_data <- dplyr::bind_rows(complete_data)

save(complete_data, file = "data/complete_nba_pbp.RData")
