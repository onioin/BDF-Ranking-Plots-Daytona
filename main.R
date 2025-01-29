require(dplyr)
require(ggplot2)
require(readr)
require(magrittr)

RANKINGS_PATH <- "./TORA/daytona/rankings.csv"
ENTRIES_PATH  <- "./TORA/daytona/"

TORARankings <- read_csv(RANKINGS_PATH, col_select=(3:7)) %>%
  mutate(across(c(1,2)), as.factor) %>% 
  filter(as.integer(LBY) != 5)
