# Ames Housing EDA Project

Exploratory Data Analysis of the Ames Housing dataset using R.

## Project Structure

```
eda-housing-project/
├── data/               ← cleaned dataset saved here after running the script
├── scripts/
│   ├── 01_setup_and_eda.R          ← standalone R script (run this first)
│   └── ames_housing_report.Rmd     ← R Markdown report (knit after the script)
├── output/             ← PNG plots saved here
└── README.md
```

## How to Run

### Option A — Run the standalone script first, then knit the report

```r
# Step 1: Run the EDA script (installs packages, saves plots + cleaned CSV)
source("scripts/01_setup_and_eda.R")

# Step 2: Knit the R Markdown report to HTML
rmarkdown::render("scripts/ames_housing_report.Rmd", output_dir = "output/")
```

### Option B — Knit only the R Markdown report

The `.Rmd` file is self-contained — it installs packages, loads data, cleans,
and plots everything inline.

```r
rmarkdown::render("scripts/ames_housing_report.Rmd", output_dir = "output/")
```

## Dataset

The Ames Housing dataset is loaded directly from the
[`AmesHousing`](https://cran.r-project.org/package=AmesHousing) R package
(no manual download needed). It contains 2,930 home sales in Ames, Iowa (2006–2010).

## Packages Used

| Package | Purpose |
|---------|---------|
| `tidyverse` | Data wrangling (dplyr, tidyr, readr) |
| `ggplot2` | Visualizations |
| `corrplot` | Correlation heatmap |
| `scales` | Dollar/comma formatting on axes |
| `AmesHousing` | Source dataset |
