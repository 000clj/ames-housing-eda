# =============================================================================
# Ames Housing EDA — Setup, Cleaning, and Visualizations
# =============================================================================
# This script:
#   1. Installs and loads required packages
#   2. Downloads the Ames Housing dataset
#   3. Cleans the data
#   4. Produces 4 visualizations saved to output/
# =============================================================================


# -----------------------------------------------------------------------------
# 1. INSTALL & LOAD PACKAGES
# -----------------------------------------------------------------------------

# Install packages only if they aren't already installed
required_packages <- c("tidyverse", "ggplot2", "corrplot", "scales", "AmesHousing")

new_packages <- required_packages[!(required_packages %in% installed.packages()[, "Package"])]
if (length(new_packages) > 0) {
  install.packages(new_packages, repos = "https://cloud.r-project.org")
}

library(tidyverse)    # data wrangling + ggplot2 included
library(ggplot2)      # data visualization
library(corrplot)     # correlation heatmap
library(scales)       # nicer axis labels (e.g. dollar signs)
library(AmesHousing)  # contains the Ames Housing dataset


# -----------------------------------------------------------------------------
# 2. LOAD THE AMES HOUSING DATASET
# -----------------------------------------------------------------------------

# The AmesHousing package provides a cleaned version of the dataset.
# make_ames() returns a tibble with proper column names (no spaces).
housing <- AmesHousing::make_ames()

# Quick look at the data
glimpse(housing)
cat("\nDimensions:", nrow(housing), "rows x", ncol(housing), "columns\n")


# -----------------------------------------------------------------------------
# 3. DATA CLEANING
# -----------------------------------------------------------------------------

# --- 3a. Check for missing values ---
missing_counts <- colSums(is.na(housing))
missing_cols   <- missing_counts[missing_counts > 0]

if (length(missing_cols) == 0) {
  cat("\nNo missing values found — dataset is already clean.\n")
} else {
  cat("\nColumns with missing values:\n")
  print(missing_cols)
}

# --- 3b. Handle missing values ---
# Numeric columns: replace NA with the column median (robust to outliers)
# Character/factor columns: replace NA with "Unknown"
housing_clean <- housing %>%
  mutate(across(where(is.numeric),  ~ ifelse(is.na(.), median(., na.rm = TRUE), .))) %>%
  mutate(across(where(is.character), ~ ifelse(is.na(.), "Unknown", .))) %>%
  mutate(across(where(is.factor),    ~ fct_na_value_to_level(., level = "Unknown")))

# --- 3c. Check data types ---
cat("\nData types summary:\n")
housing_clean %>%
  summarise(across(everything(), class)) %>%
  pivot_longer(everything(), names_to = "column", values_to = "type") %>%
  count(type) %>%
  print()

# --- 3d. Remove extreme outliers in Sale_Price (keep middle 99%) ---
price_bounds <- quantile(housing_clean$Sale_Price, probs = c(0.005, 0.995))
housing_clean <- housing_clean %>%
  filter(Sale_Price >= price_bounds[1], Sale_Price <= price_bounds[2])

cat("\nRows after outlier removal:", nrow(housing_clean), "\n")

# Save the cleaned dataset for use in the R Markdown report
write_csv(housing_clean, "data/ames_housing_clean.csv")
cat("\nCleaned data saved to data/ames_housing_clean.csv\n")


# -----------------------------------------------------------------------------
# 4. VISUALIZATIONS
# -----------------------------------------------------------------------------

# Helper: consistent ggplot2 theme for all plots
theme_ames <- function() {
  theme_minimal(base_size = 13) +
    theme(
      plot.title    = element_text(face = "bold", size = 15),
      plot.subtitle = element_text(color = "grey40"),
      axis.title    = element_text(face = "bold"),
      plot.caption  = element_text(color = "grey50", size = 9)
    )
}


# --- Plot 1: Distribution of Sale Prices ---
p1 <- ggplot(housing_clean, aes(x = Sale_Price)) +
  geom_histogram(bins = 50, fill = "#4E79A7", color = "white", alpha = 0.85) +
  geom_vline(aes(xintercept = median(Sale_Price)),
             color = "#E15759", linetype = "dashed", linewidth = 1) +
  annotate("text",
           x = median(housing_clean$Sale_Price) * 1.05,
           y = Inf, vjust = 2,
           label = paste0("Median: $", comma(median(housing_clean$Sale_Price))),
           color = "#E15759", size = 4) +
  scale_x_continuous(labels = dollar_format()) +
  labs(
    title    = "Distribution of Home Sale Prices",
    subtitle = "Ames, Iowa — 2006 to 2010",
    x        = "Sale Price (USD)",
    y        = "Number of Homes",
    caption  = "Source: Ames Housing Dataset (AmesHousing R package)"
  ) +
  theme_ames()

ggsave("output/01_sale_price_distribution.png", p1, width = 9, height = 5.5, dpi = 150)
cat("Saved: output/01_sale_price_distribution.png\n")


# --- Plot 2: Sale Price vs. Above-Ground Living Area (scatter) ---
p2 <- ggplot(housing_clean, aes(x = Gr_Liv_Area, y = Sale_Price)) +
  geom_point(alpha = 0.35, color = "#4E79A7", size = 1.5) +
  geom_smooth(method = "lm", color = "#E15759", se = TRUE, linewidth = 1.2) +
  scale_y_continuous(labels = dollar_format()) +
  scale_x_continuous(labels = comma_format()) +
  labs(
    title    = "Sale Price vs. Above-Ground Living Area",
    subtitle = "Each point = one home sale; red line = linear trend",
    x        = "Above-Ground Living Area (sq ft)",
    y        = "Sale Price (USD)",
    caption  = "Source: Ames Housing Dataset"
  ) +
  theme_ames()

ggsave("output/02_price_vs_living_area.png", p2, width = 9, height = 5.5, dpi = 150)
cat("Saved: output/02_price_vs_living_area.png\n")


# --- Plot 3: Average Sale Price by Neighborhood (bar chart) ---
neighborhood_avg <- housing_clean %>%
  group_by(Neighborhood) %>%
  summarise(avg_price = mean(Sale_Price), .groups = "drop") %>%
  arrange(desc(avg_price)) %>%
  mutate(Neighborhood = fct_reorder(Neighborhood, avg_price))

p3 <- ggplot(neighborhood_avg, aes(x = Neighborhood, y = avg_price, fill = avg_price)) +
  geom_col(show.legend = FALSE) +
  scale_fill_gradient(low = "#AEC6CF", high = "#1F4E79") +
  scale_y_continuous(labels = dollar_format()) +
  coord_flip() +
  labs(
    title    = "Average Sale Price by Neighborhood",
    subtitle = "Neighborhoods ranked from highest to lowest average price",
    x        = NULL,
    y        = "Average Sale Price (USD)",
    caption  = "Source: Ames Housing Dataset"
  ) +
  theme_ames()

ggsave("output/03_avg_price_by_neighborhood.png", p3, width = 9, height = 8, dpi = 150)
cat("Saved: output/03_avg_price_by_neighborhood.png\n")


# --- Plot 4: Correlation Heatmap of Numeric Variables ---
# Select the most meaningful numeric columns for readability
key_numeric_vars <- c(
  "Sale_Price", "Gr_Liv_Area", "Total_Bsmt_SF", "Garage_Area",
  "Year_Built", "Year_Remod_Add", "Lot_Area", "Overall_Qual",
  "Overall_Cond", "TotRms_AbvGrd", "Bedroom_AbvGr", "Full_Bath"
)

cor_matrix <- housing_clean %>%
  select(all_of(key_numeric_vars)) %>%
  # Some columns (e.g. Overall_Qual, Overall_Cond) are ordered factors —
  # convert everything to numeric so cor() works
  mutate(across(everything(), ~ as.numeric(.))) %>%
  cor(use = "complete.obs")

# Save as PNG via png() device (corrplot doesn't return a ggplot object)
png("output/04_correlation_heatmap.png", width = 900, height = 800, res = 120)
corrplot(
  cor_matrix,
  method     = "color",
  type       = "upper",
  tl.cex     = 0.85,
  tl.col     = "black",
  addCoef.col = "black",
  number.cex = 0.65,
  col        = colorRampPalette(c("#4E79A7", "white", "#E15759"))(200),
  title      = "Correlation Heatmap — Key Numeric Variables",
  mar        = c(0, 0, 2, 0)
)
dev.off()
cat("Saved: output/04_correlation_heatmap.png\n")

cat("\nAll plots saved to output/. Run the R Markdown report next:\n")
cat("  rmarkdown::render('scripts/ames_housing_report.Rmd')\n")
