require(dplyr)
require(ggplot2)
require(RColorBrewer)
require(readr)
require(tidyr)
require(magrittr)
require(forcats)

RANKINGS_PATH <- "./rankings.csv"
ENTRIES_PATH  <- "./entries.csv"
TIMING_PATH   <- "./liveTiming.csv"
PLOTS_DIR     <- "./generatedPlots/"

SNAMES <- c("STINT 1", "STINT 2", "STINT 3", "STINT 4", "STINT 5", "STINT 6",
            "STINT 7", "STINT 8", "STINT 9", "STINT 10", "STINT 11", "STINT 12")
SDOTNAMES <- c("STINT.1", "STINT.2", "STINT.3", "STINT.4", "STINT.5", "STINT.6",
               "STINT.7", "STINT.8", "STINT.9", "STINT.10", "STINT.11", "STINT.12")


# Read in BDF's Rankings
# Clean up unused data
# Change lobby and class to factors (easier grouping)
# Remove drivers whose lobby is 'N/A'
TORARankings <- read_csv(RANKINGS_PATH, col_select=(3:7), 
                         show_col_types=FALSE, na="NULL") %>%
  mutate(across(c(1,2), as.factor)) %>% 
  mutate(DRIVER=toupper(DRIVER)) %>%
  filter(as.integer(LBY) != 5)

# Read in the entry list
# Clean up unused and duplicate data
# Change car to factor (easier grouping)
# Rename columns to match the standard
TORAEntries <- read_csv(ENTRIES_PATH, skip=3, col_select=c(1,3), 
                        show_col_types=FALSE, name_repair="unique_quiet") %>%
  mutate(across(2, as.factor)) %>%
  mutate(TEAM=`Team Name...1`, CAR=`Car Choice...3`) %>%
  select(all_of(c("TEAM", "CAR")))

# Perform a natural join on the two data sets
# Essentially adding which car the team drove to the table
TORARankings %<>% merge(TORAEntries, sort=FALSE)

# Read in stint data, skipping un-needed rows and columns
# Remove the unnecessary row
# Rename columns to match the standard
TORAStints <- read_csv(TIMING_PATH, skip=1, col_select=seq(13, 91, by=7),
                       show_col_types=FALSE, name_repair="unique_quiet") %>%
  mutate(across(1:12, toupper)) %>%
  filter(row_number() != 1) %>%
  rename_with(~SNAMES)

# Replace each driver name in each stint with their score
tmp = c()
for(name in SNAMES){
  tmp %<>% append( TORARankings %>% 
                     filter(DRIVER %in% TORAStints[[name]]) %>%
                     select(SCORE) %>% rename(!!name := SCORE)
  )
}

# Do some odd manipulation to put the data in a usable form
TORAStintScore <- data.frame(STINT=SNAMES) %>% cbind(t(data.frame(t(tmp)))) %>%
  rename("SCORES" = 2)

# Calculate the box plot stats for each stint
TORAStintStats <- data.frame(S=1:12,YMIN=0,LOWER=0,MIDDLE=0,UPPER=0,YMAX=0) %>%
  mutate(across(1, as.factor))
for(i in 1:12){
  tmp <- boxplot.stats(TORAStintScore$SCORES[i][[SDOTNAMES[i]]]) 
  TORAStintStats$YMIN[i] <- tmp$stats[1]
  TORAStintStats$LOWER[i] <- tmp$stats[2]
  TORAStintStats$MIDDLE[i] <- tmp$stats[3]
  TORAStintStats$UPPER[i] <- tmp$stats[4]
  TORAStintStats$YMAX[i] <- tmp$stats[5]
}

#~~~~~~~~~~~~~~~~~~ PLOTS ~~~~~~~~~~~~~~~~~~#

# Box plot of score, grouped by lobby
# Not terribly useful, shows that higher lobby drivers have higher scores (duh)
TORARankings %>% drop_na() %>%
  ggplot(mapping=aes(x=LBY, y=SCORE, fill=LBY)) + 
  geom_boxplot() +
  guides(fill="none") +
  labs(x="Lobby", y="Score", title="Score Distibution per Lobby")
ggsave(paste0(PLOTS_DIR, "boxScoreLobby.png"))

# Violin plot of above
TORARankings %>% drop_na() %>%
  ggplot(mapping=aes(x=LBY, y=SCORE, fill=LBY)) +
  geom_violin() +
  guides(fill="none") +
  labs(x="Lobby", y="Score", title="Score Distribution per Lobby")
ggsave(paste0(PLOTS_DIR, "violinScoreLobby.png"))

# Combined plot of above
TORARankings %>% drop_na() %>%
  ggplot(mapping=aes(x=LBY, y=SCORE, fill=LBY)) +
  geom_violin() +
  geom_boxplot(width=0.1, colour='grey', alpha=0.3) +
  guides(fill="none") +
  labs(x="Lobby", y="Score", title="Score Distribution per Lobby")
ggsave(paste0(PLOTS_DIR, "combinedScoreLobby.png"))

# Box plot of score, grouped by class
# Not extremely useful, shows that Proto drivers have a higher median score
# Not statistically significant i.e. both confidence intervals cover similar
# ranges, the notches on the plot roughly represent these intervals 
# (McGill et al. (1978))
# 51.498 for GT vs 53.565 for P
# Uncomment below line for the full summary
# aggregate(TORARankings$SCORE, list(TORARankings$CLA), boxplot.stats)
TORARankings %>% drop_na() %>% 
  ggplot(mapping=aes(x=CLA, y=SCORE, fill=CLA)) +
  geom_boxplot(notch=TRUE) +
  guides(fill="none") +
  labs(x="Car Class", y="Score", title="Score Distribution per Car Class")
ggsave(paste0(PLOTS_DIR, "boxScoreClass.png"))

# Violin plot of above
TORARankings %>% drop_na() %>% 
  ggplot(mapping=aes(x=CLA, y=SCORE, fill=CLA)) +
  geom_violin() +
  guides(fill="none") +
  labs(x="Car Class", y="Score", title="Score Distribution per Car Class")
ggsave(paste0(PLOTS_DIR, "violinScoreClass.png"))

# Combined plot of above
TORARankings %>% drop_na() %>% 
  ggplot(mapping=aes(x=CLA, y=SCORE, fill=CLA)) +
  geom_violin() +
  geom_boxplot(notch=TRUE, width=0.1, colour='grey', alpha=0.3) +
  guides(fill="none") +
  labs(x="Car Class", y="Score", title="Score Distribution per Car Class")
ggsave(paste0(PLOTS_DIR, "combinedScoreClass.png"))

# Box plot of score, grouped by lobby and class
TORARankings %>% drop_na() %>% 
  ggplot(mapping=aes(x=LBY, y=SCORE, fill=CLA)) +
  geom_boxplot(notch=TRUE) +
  labs(x="Lobby", y="Score", fill="Car Class", 
       title="Score Distribution per Lobby and Car Class")
ggsave(paste0(PLOTS_DIR, "boxScoreLobbyClass.png"))

# Violin plot of above
TORARankings %>% drop_na() %>% 
  ggplot(mapping=aes(x=LBY, y=SCORE, fill=CLA)) +
  geom_violin() +
  labs(x="Lobby", y="Score", fill="Car Class", 
       title="Score Distribution per Lobby and Car Class")
ggsave(paste0(PLOTS_DIR, "violinScoreLobbyClass.png"))

# Combined plot of above
TORARankings %>% drop_na() %>% 
  ggplot(mapping=aes(x=LBY, y=SCORE, fill=CLA)) +
  geom_violin(position=position_dodge(0.9)) +
  geom_boxplot(notch=TRUE, width=0.1, colour='grey', alpha=0.3, 
               position=position_dodge(0.9)) +
  labs(x="Lobby", y="Score", fill="Car Class", 
       title="Score Distribution per Lobby and Car Class")
ggsave(paste0(PLOTS_DIR, "combinedScoreLobbyClass.png"))

# Box plot of score, grouped by car, also plotting the mean and sample size
sampleSize <- TORARankings %>% group_by(CAR) %>% summarize(num=n())

TORARankings %>% drop_na() %>% 
  mutate(CAR=fct_reorder(CAR, SCORE, .fun=median)) %>%
  ggplot(mapping=aes(x=CAR, y=SCORE, fill=CAR)) +
  geom_boxplot(colour='black', outlier.shape=1) + 
  stat_summary(fun=mean, geom="point") +
  geom_text(data=sampleSize, aes(CAR, -1, label=paste0("n=",num))) +
  theme(
    axis.ticks.x=element_blank(),
    axis.text.x=element_blank()
  ) +
  labs(x="Car", y="Score", fill="Car", title="Score Distribution per Car") +
  scale_fill_brewer(palette="Paired")
ggsave(paste0(PLOTS_DIR, "boxScoreCar.png"))

# Density plots for each stint
for(i in 1:12){
  TORAStintScore$SCORES[i] %>% data.frame() %>%
    ggplot(aes_string(SDOTNAMES[i])) + 
    geom_density(fill="red", alpha=0.5) +
    labs(x="Score",y="Density", 
         caption=paste0("Mean: ", 
                        mean(TORAStintScore$SCORES[i][[SDOTNAMES[i]]], 
                             na.rm=TRUE), "\nMedian: ",
                        median(TORAStintScore$SCORES[i][[SDOTNAMES[i]]], 
                               na.rm=TRUE)),
         title=paste0("Distribution of Scores for Stint ", as.character(i)))
  ggsave(paste0(PLOTS_DIR, "stint", as.character(i), "Dist.png"))
}

# Box plots of distribution per stint
ggplot(data=TORAStintStats, 
       mapping=aes(x=S, ymin=YMIN, lower=LOWER, 
                   middle=MIDDLE, upper=UPPER, ymax=YMAX, fill=S)) +
  geom_boxplot(stat="identity") +
  geom_text(aes(y=(MIDDLE+2), label=MIDDLE)) +
  guides(fill='none') +
  scale_fill_brewer(palette="Set3") +
  labs(x="Stint", y="Score", title="Score Distribution per Stint")
ggsave(paste0(PLOTS_DIR, "boxScoreStint.png"))

