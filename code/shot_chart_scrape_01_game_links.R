#####################
### Scraping ESPN ###
###  Shot Charts  ###
###   Game Links  ###
#####################

# Step 1: Getting gameId values
# across years

# To manage this task, I'll create a data frame
# with all combinations of days/months/years.

library(furrr)
library(future)
library(httr2)
library(magrittr)
library(rvest)

game_days <- expand.grid(
  year = 2014:2024, 
  month = 06:12, 
  day = 1:31
)

game_days$month <- ifelse(
  nchar(game_days$month) == 1, 
  paste0(0,game_days$month), 
  game_days$month
)

game_days$day <- ifelse(
  nchar(game_days$day) == 1, 
  paste0(0,game_days$day), 
  game_days$day
)

# Now we can paste them altogether to create
# a ymd ordered string. We will need this for
# our links:

nba_game_days <- paste0(game_days$year, 
                        game_days$month, 
                        game_days$day)

# We can put those dates into the stub of the link:

game_day_links <- paste0(
  "https://www.espn.com/nba/scoreboard/_/date/", 
  nba_game_days
)

# Parallelize for speed:

plan(multisession, workers = parallel::detectCores() - 2)

# And then get all of our game links over the years:

all_pbp_links <- furrr::future_map(game_day_links, ~{
  
  Sys.sleep(runif(1, .1, 1))
  
  tryCatch({
    html_request <- request(.x) %>%
      req_retry(max_tries = 3, backoff = ~ 5) %>%
      req_error(is_error = function(resp) FALSE) %>%
      req_perform()
    
    request_body <- resp_body_string(html_request)
    
    link_read <- read_html(request_body) 
    
    links <- link_read %>% 
      html_elements("a.AnchorLink[href*='gameId']") %>%
      html_attr("href")
    
    return(links)
  }, error = function(e) {
    return(paste0("Problem:", .x))
  })
  
}, .options = furrr_options(seed = NULL))

all_pbp_links <- unlist(all_pbp_links)

sum(grepl("Problem", all_pbp_links))

save(all_pbp_links, file = "data/all_game_links.RData")

plan(sequential)

# if(length(links) == 0) {
#   pbp_link <- NA
# } else if(any(grepl("playbyplay/", links))) {
#   pbp_link <- grep("playbyplay/", links, value = TRUE)
# } else if(any(grepl("gameId/", links))) {
#   pbp_link <- grep("gameId/", links, value = TRUE)
# }


#https://www.espn.com/nba/game/_/gameId/401585675/mavericks-kings

#https://www.espn.com/nba/playbyplay/_/gameId/401585537
#https://www.espn.com/nba/playbyplay/_/gameId/401071650

