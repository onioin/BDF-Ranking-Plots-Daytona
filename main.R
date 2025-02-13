require(dplyr)
require(ggplot2)
require(RColorBrewer)
require(readr)
require(tidyr)
require(magrittr)
require(forcats)


#~~~~~~~~~~~~~~~~~~ CONSTANTS ~~~~~~~~~~~~~~~~~~#
RANKINGS_PATH <- "./rankings.csv"
ENTRIES_PATH  <- "./entries.csv"
TIMING_PATH   <- "./liveTiming.csv"
PLOTS_DIR     <- "./generatedPlots/"

SNAMES  <- c("1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12")
COLOURS <- brewer.pal(12, "Paired")
CARSTR  <- c("1984 Nissan #20 Bluebird Super Silhouette",
             "1979 Datsun #33 280ZX Turbo",
             "1983 Porsche #11 956",
             "1974 Porsche #1 911 RSR",
             "1983 Nissan #23 Silvia Super Silhouette",
             "1983 Jaguar #44 XJR-5",
             "1976 Chevrolet #76 Greenwood Corvette",
             "1982 Ferrari #72 512 BB/LM",
             "1975 BMW #25 3.0 CSL",
             "1981 Ford #2 Capri Turbo",
             "1982 Ford #6 Mustang IMSA GT",
             "1985 Nissan #83 GTP ZX-Turbo")

#~~~~~~~~~~~~~~~~~~ DATA ~~~~~~~~~~~~~~~~~~#

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
# Pivot to keep the data tidy
# Join with rank data
# Sort by Stint, Lobby, Class
TORAStints <- read_csv(TIMING_PATH, skip=1, col_select=seq(13, 91, by=7),
                       show_col_types=FALSE, name_repair="unique_quiet") %>%
  mutate(across(1:12, toupper)) %>%
  filter(row_number() != 1) %>%
  rename_with(~SNAMES) %>% 
  pivot_longer(1:12, names_to="STINT", values_to="DRIVER") %>%
  mutate(across(1, as.integer)) %>% 
  mutate(across(1, as.factor)) %>% 
  merge(TORARankings) %>%
  arrange(STINT, LBY, desc(CLA))


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
  mutate(CAR=fct_reorder(CAR, SCORE, .fun=median, .desc=TRUE)) %>%
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

# Distribution w/ all cars except those w/ small sample sizes (n < 5)
TORARankings %>% drop_na() %>%
  filter(as.integer(CAR) != 12) %>%
  filter(as.integer(CAR) != 7) %>%
  mutate(CAR=fct_reorder(CAR, SCORE, .fun=median, .desc=TRUE)) %>%
  ggplot(aes(x=SCORE, group=CAR, fill=CAR)) +
  geom_density(alpha=0.8, colour='black') +
  facet_wrap(~CAR) +
  scale_fill_brewer(palette="Paired") +
  theme(
    strip.text=element_text(size=6.5, debug=FALSE),
    strip.background=element_blank()
  ) +
  labs(x="Score", y="Density", title="Score Distribution per Car")
ggsave(paste0(PLOTS_DIR, "sumScoreAllCars.png"))

# Distribution of Score per car
for(i in 1:12){
  TORARankings %>% drop_na() %>%
    mutate(fct_reorder(CAR, SCORE, .fun=median, .desc=TRUE)) %>%
    filter(as.integer(CAR) == i) %>%
    ggplot(aes(x=SCORE)) +
    geom_density(fill=COLOURS[i], alpha=0.8, colour='black') +
    labs(x="Score", y="Density", title=paste0("Score Distribution for ",
                                              CARSTR[i]))
  ggsave(paste0(PLOTS_DIR, "distScoreCar", as.character(i), ".png"))
}

# Distribution of score for all stints
TORAStints %>% drop_na() %>%
  ggplot(aes(x=SCORE, group=STINT, fill=STINT)) +
  geom_density(alpha=0.8, colour='black') +
  facet_wrap(~STINT) +
  guides(fill="none") +
  theme(
    strip.background=element_blank()
  ) +
  scale_fill_brewer(palette="Set3") +
  labs(x="Score", y="Density", title="Score Distribution for all Stints")
ggsave(paste0(PLOTS_DIR, "sumScoreAllStints.png"))

# Distribution plot of Score per stint
for(i in 1:12){
  TORAStints %>% 
    filter(as.integer(STINT) == i) %>%
    drop_na() %>%
    ggplot(aes(x=SCORE)) +
    geom_density(fill=brewer.pal(12, "Set3")[i],
                 alpha=0.8, colour='black') +
    labs(x="Score", y="Density", title=paste0("Score Distribution for Stint ",
                                              as.character(i)))
  ggsave(paste0(PLOTS_DIR, "distScoreStint", as.character(i), ".png"))
}

# Distribution plot per stint, separated by car class
for(i in 1:12){
  PCLASS <- TORAStints %>%
    filter(as.integer(STINT) == i) %>%
    drop_na() %>% filter(as.integer(CLA) == 3)
  GTCLASS <- TORAStints %>%
    filter(as.integer(STINT) == i) %>%
    drop_na() %>% filter(as.integer(CLA) == 2)
  ggplot(data=NULL, mapping=aes(fill=CLA)) + 
    geom_density(data=GTCLASS, aes(x=SCORE, y=..density..)) +
    geom_density(data=PCLASS, aes(x=SCORE,y=-..density..)) +
    labs(x="Score", y="Density", fill="Class", 
         title=paste0("Score Distribution for Stint ", as.character(i)))
  ggsave(paste0(PLOTS_DIR, "distScoreClassStint", as.character(i), ".png"))
}

# Distribution plot per stint, separated by lobby
for(i in 1:12){
  TORAStints %>%
    filter(as.integer(STINT) == i) %>%
    drop_na() %>%
    ggplot(aes(x=SCORE, group=LBY, fill=LBY)) +
    geom_density(alpha=0.5, colour='black') +
    labs(x="Score", y="Density", fill="Lobby", 
         title=paste0("Score Distribution per Lobby for Stint",
                      as.character(i)))
  ggsave(paste0(PLOTS_DIR, "distScoreLobbyStint", as.character(i), ".png"))
}

# Distribution plot for all stints, grouped by lobby
TORAStints %>% drop_na() %>%
  ggplot(aes(x=SCORE, group=STINT)) +
  geom_density(aes(group=LBY, fill=LBY), alpha=0.5, colour='black') +
  facet_wrap(~STINT) +
  theme(
    strip.background=element_blank()
  ) +
  labs(x="Score", y="Density", fill="Lobby", 
       title="Score Distribution per Lobby for all Stints")
ggsave(paste0(PLOTS_DIR, "sumScoreLobbyAllStints.png"))
