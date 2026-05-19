# Ames Housing — Exploratory Data Analysis

An end-to-end exploratory data analysis and predictive modelling project using the Ames Housing dataset, built in R as a portfolio piece.

---

## Project Summary

This project investigates **what drives residential home sale prices** in Ames, Iowa using 2,930 sales recorded between 2006 and 2010. The analysis covers the full data science workflow: data loading, cleaning, visualisation, and predictive modelling — all compiled into a self-contained R Markdown report.

---

## Key Findings

- **Sale prices are right-skewed** — the median sale price is ~$160k, but a long tail of luxury homes pulls the mean higher.
- **Living area is the strongest continuous predictor** — each additional square foot adds ~$55 to the predicted price.
- **Overall quality dominates all other variables** — with a correlation of ~0.80 with sale price, material and finish quality is the single biggest driver.
- **Neighborhood matters enormously** — average prices vary by over $216k between the most and least expensive neighborhoods.
- **A 3-variable linear regression model** (living area + overall quality + garage capacity) explains ~75% of the variance in sale price (R² ≈ 0.75), with an RMSE of ~$38k.

---

## Visualisations

| # | Chart | Key Takeaway |
|---|-------|-------------|
| 1 | Distribution of Sale Prices | Right-skewed; median ~$160k |
| 2 | Sale Price vs. Living Area | Strong positive linear trend |
| 3 | Average Price by Neighborhood | Up to $216k gap across 28 neighborhoods |
| 4 | Correlation Heatmap | Overall quality, living area, and garage size top the rankings |
| 5 | Predicted vs. Actual (Regression) | Model fits well in the $100k–$300k range; underpredicts luxury homes |

---

## Tools & Packages

| Tool | Purpose |
|------|---------|
| R 4.5 | Core language |
| `tidyverse` | Data wrangling and transformation |
| `ggplot2` | All custom visualisations |
| `corrplot` | Correlation heatmap |
| `scales` | Dollar and comma axis formatting |
| `AmesHousing` | Source dataset (no manual download needed) |
| R Markdown | Compiled HTML report with inline results |

---

## Project Structure

```
ames-housing-eda/
├── scripts/
│   ├── 01_setup_and_eda.R        # Standalone script: cleans data, saves plots
│   └── ames_housing_report.Rmd   # Full R Markdown report (self-contained)
├── data/                         # Cleaned CSV written here at runtime
├── output/                       # PNG plots and HTML report written here
└── README.md
```

---

## How to Run

**Prerequisites:** R 4.0+ and RStudio (recommended). All packages are installed automatically on first run.

### Option A — Knit the full report (recommended)

Opens a polished HTML report with all code, charts, and written insights:

```r
rmarkdown::render("scripts/ames_housing_report.Rmd", output_dir = "output/")
```

Then open `output/ames_housing_report.html` in your browser.

### Option B — Run the standalone EDA script

Saves cleaned data and 4 PNG plots to `data/` and `output/` without knitting:

```r
source("scripts/01_setup_and_eda.R")
```

---

## Dataset

The **Ames Housing Dataset** was compiled by Dean De Cock (2011) as a modern alternative to the Boston Housing dataset. It contains 80 variables describing residential properties sold in Ames, Iowa between 2006 and 2010.

Loaded directly via the [`AmesHousing`](https://cran.r-project.org/package=AmesHousing) R package, no manual download required.

---

## Author

**Christopher** 
