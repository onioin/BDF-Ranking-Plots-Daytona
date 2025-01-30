# BDF's TORA Rankings, Visualized

Using the power of [R](https://cran.r-project.org/), and more specifically, the [ggplot2](https://ggplot2.tidyverse.org/reference/ggplot.html) library, I decided to create some charts for the TORA Daytona 24.

## Statistics

BDF, a TORA competitor, created a summary statistic for ranking drivers' performances. The statistic is a measure of how well a driver performed against their peers. Using a weighted average of individual stints, qualifying, and finish position, BDF rolled a driver's performance into one number ranging from 0 to 100. I will not get into the exact math and statistics used here, I highly recommend reading [BDF's original document](https://docs.google.com/document/d/1AUtG1Lt3-mtRqqFU6U-f93of3MlO4FcdzYaH_cKHklk/edit?tab=t.0).

In addition to [BDF's rankings](https://docs.google.com/spreadsheets/d/1hftIMKRO3ESpFKAkAoglUX69Ox8ZlyhUHWJ8V8o9IRc/edit?gid=1317095257#gid=1317095257), I added extra data about the competitors' car choice, as well as per stint data.

## Plots

I have generated a number of plots, but I will only highlight one example of each here. The full assortment of charts can be viewed in the `/generatedPlots/` directory.

### Box Plots

Box plots show several statistical features on one plot:

-   **Median Line**: The [median](https://en.wikipedia.org/wiki/Median) of the data, 50% of observations lie below and 50% above.

-   **Quartiles**: The upper(Q3) and lower(Q1) edges of the box represent the first and third [quartiles](https://en.wikipedia.org/wiki/Quartile) of the data, 25% of observations lie above Q3 and 25% lie below Q1.

-   **Interquartile Range**: The 'box' part of the box plot shows the [interquartile range](https://en.wikipedia.org/wiki/Interquartile_range) of the data, the middle 50% of observations.

-   **Whiskers**: The lines extending from the box show the range of values `[Q1 - 1.5 * IQR, Q3 + 1.5 * IQR]`

-   **Outliers**: Any points that are not covered by the whiskers will be shown as markers.

![Box Plot Example](https://github.com/onioin/BDF-Ranking-Plots-Daytona/blob/master/generatedPlots/boxScoreLobby.png?raw=true)

Box plots will match with `box[*].png` where [\*] represents a specific chart.

### Violin Plots

One major downside to box plots is that they hide the underlying distribution of the data. A violin plot fixes this by showing a density estimate of the observations. On a few charts (ones that match `combined[*].png` where [\*] is replaced with a more descriptive name for the plot), I have plotted a box plot on top of the violin plot.

![Violin Plot Example](https://github.com/onioin/BDF-Ranking-Plots-Daytona/blob/master/generatedPlots/violinScoreLobby.png?raw=true)

Violin plots will match with `violin[*].png` where [\*] represents a specific chart.

### Density Plots

Density plots represent the distribution of a variable, they are similar to violin plots, but show the density on the y-axis rather than with the shape. On some charts, I have plotted multiple density plots on one set of axes. There are two ways I did this:

-   Mirror: One group's density is show in the positive y direction, and the other group's in the negative y direction.

-   Overlay: Overlay several groups' distributions on one set of axes, this works best when the medians of the groups are quite distinct.

![Density Plot Example](https://github.com/onioin/BDF-Ranking-Plots-Daytona/blob/master/generatedPlots/distScoreCar4.png?raw=true)

Density plots will match with `dist[*].png` where [\*] represents a specific chart

### Summary Plots

For a selection of variables (cars and stints), I have elected to plot several plots in a grid. This can make it easier to quickly see differences in the distributions between different values.

![Summary Plot Example](https://github.com/onioin/BDF-Ranking-Plots-Daytona/blob/master/generatedPlots/sumScoreLobbyAllStints.png?raw=true)

Summary plots will match with `sum[*].png` where [\*] represents a specific chart

## Conclusions

This was mainly done as an exercise for me to practice R, so some of the charts may not be extremely insightful. There are some interesting things though, and I implore you to take a look through some of the charts. The code that was used to generate the plots is in `main.R` and is somewhat documented, if you have any questions, feel free to reach out. A massive thank you is due to BDF and [TORA](racetora.com), this project would not be possible without the work of the many individuals behind the scenes at TORA, and BDF's rankings kick-started this whole project.
