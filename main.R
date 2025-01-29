require(dplyr)
require(ggplot2)
require(readr)
require(magrittr)

RANKINGS_PATH <- "./rankings.csv"
ENTRIES_PATH  <- "./entries.csv"
TIMING_PATH   <- "./liveTiming.csv"


# Read in BDF's Rankings
# Clean up unused data
# Change lobby and class to factors (easier grouping)
# Remove drivers whose lobby is 'N/A'
TORARankings <- read_csv(RANKINGS_PATH, col_select=(3:7), 
                         show_col_types=FALSE) %>%
  mutate(across(c(1,2), as.factor)) %>% 
  filter(as.integer(LBY) != 5)

# Read in the entry list
# Clean up unused and duplicate data
# Change car to factor (easier grouping)
# Rename columns to match BDF's standard
TORAEntries <- read_csv(ENTRIES_PATH, skip=3, col_select=c(1,3), 
                        show_col_types=FALSE, name_repair="unique_quiet") %>%
  mutate(across(2, as.factor)) %>%
  mutate(TEAM=`Team Name...1`, CAR=`Car Choice...3`) %>%
  select(all_of(c("TEAM", "CAR")))

# Perform a natural join on the two data sets
# Essentially adding which car the team drove to the table
TORARankings %<>% merge(TORAEntries, sort=FALSE)

TORAStints <- read_csv(TIMING_PATH, skip=1, col_select=seq(13, 91, by=7),
                       show_col_types=FALSE, name_repair="unique_quiet") %>%
  mutate()


