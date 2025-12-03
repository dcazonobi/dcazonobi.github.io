#Assignment 5

# Load core data-wrangling/plotting helpers.
library(tidyverse)
library(car)

# Set and check the working directory (where files will be read/saved).
setwd("C:/Users/dcazo/OneDrive/Documents/Data Analysis/3. Course 3/assignment")
getwd()

# Load the CSV you choose from a file dialog (make sure it's the correct dataset).
df <- read.csv(file.choose(), header = TRUE)

# Quick peek at the first rows to confirm columns loaded as expected.
head(df)

# High-level summary for each column (min/median/mean/max, etc.).
summary(df)

# --- Choose the numeric columns we care about for EDA.
cols <- c("loyalty_points", "spending_score", "remuneration_kgbp", "age")
cols <- cols[cols %in% names(df)]  # keep only those that exist
cols

# Compute summary() for each selected column and keep results in a list.
summary_list <- lapply(df[cols], summary)
summary_list

# Plot histograms to see distributions for each numeric variable.
lapply(cols, function(x) {
  hist(df[[x]], breaks = 30,
       main = paste("Histogram of", x),
       xlab = x, col = "lightblue", border = "white")
})

# Boxplots give a quick view of spread and possible outliers.
boxplot(df[cols],
        main = "Boxplots (spot potential outliers)",
        col = "green", las = 2)

# Count potential outliers per variable using the IQR rule.
iqr_stats <- sapply(df[cols], function(v) {
  v <- v[!is.na(v)]
  q1 <- quantile(v, 0.25); q3 <- quantile(v, 0.75)
  iqr <- q3 - q1
  lower <- q1 - 1.5 * iqr; upper <- q3 + 1.5 * iqr
  sum(v < lower | v > upper)
})
iqr_stats

# Simple relationship check: scatter of spending vs loyalty (if both columns exist).
if (all(c("spending_score", "loyalty_points") %in% colnames(df))) {
  with(df, plot(spending_score, loyalty_points,
                pch = 19, col = "gray40",
                main = "Loyalty points vs Spending score",
                xlab = "Spending score", ylab = "Loyalty points"))
}

# Create simple customer bands (low/mid/high) for spending, income, and age.
df$spend_band <- cut(df$spending_score, breaks = c(-Inf, 50, 70, Inf),
                     labels = c("Low","Mid","High"), right = TRUE)

df$pay_band <- cut(df$remuneration_kgbp, breaks = c(-Inf, 40, 70, Inf),
                   labels = c("Low","Mid","High"), right = TRUE)

df$age_band <- cut(df$age, breaks = c(-Inf, 30, 45, 60, Inf),
                   labels = c("<30","30–45","46–60",">60"), right = TRUE)

# Average loyalty by spending band (business-readable check).
print(aggregate(loyalty_points ~ spend_band, data = df, FUN = mean, na.rm = TRUE))

# Average loyalty by spending × income bands (shows interaction in a simple table).
print(aggregate(loyalty_points ~ spend_band + pay_band, data = df, FUN = mean, na.rm = TRUE))

# ENHANCED: Clean segment summary with all key metrics
segment_summary <- aggregate(
  loyalty_points ~ spend_band + pay_band, 
  data = df,
  FUN = function(x) c(
    n_customers = length(x),
    pct_customers = round(100 * length(x) / nrow(df), 1),
    avg_loyalty = round(mean(x, na.rm = TRUE), 0),
    total_loyalty = round(sum(x, na.rm = TRUE), 0)
  )
)

# Flatten into clean columns
segment_table <- data.frame(
  spend = segment_summary$spend_band,
  pay = segment_summary$pay_band,
  n_customers = segment_summary$loyalty_points[, "n_customers"],
  pct_customers = segment_summary$loyalty_points[, "pct_customers"],
  avg_loyalty = segment_summary$loyalty_points[, "avg_loyalty"],
  total_loyalty = segment_summary$loyalty_points[, "total_loyalty"]
)

# Print clean summary table
print(segment_table)


# Assignment 6


# Summaries again 
summary(df[, c("loyalty_points","spending_score","remuneration_kgbp","age")])

# Basic scatterplots to visualise relationships vs loyalty_points.
plot(df$spending_score, df$loyalty_points, pch = 19, col = "gray40",
     main = "Loyalty vs Spending", xlab = "Spending score", ylab = "Loyalty points")
plot(df$remuneration_kgbp, df$loyalty_points, pch = 19, col = "gray40",
     main = "Loyalty vs Remuneration", xlab = "Remuneration (kGBP)", ylab = "Loyalty points")
plot(df$age, df$loyalty_points, pch = 19, col = "gray40",
     main = "Loyalty vs Age", xlab = "Age", ylab = "Loyalty points")

# Correlation matrix using only rows with no missing values.
tmp <- df[, c("loyalty_points","spending_score","remuneration_kgbp","age")]
tmp <- tmp[complete.cases(tmp), ]
cor(tmp)

# OBJECTIVE I: Test predictive model (R² target > 0.75)
model <- lm(loyalty_points ~ spending_score + remuneration_kgbp, data = df)
summary(model)  

# Test interaction term (mentioned in report Section 7 as alternative)
model_interaction <- lm(loyalty_points ~ spending_score * remuneration_kgbp, data = df)
summary(model_interaction)


# OBJECTIVE II: Identify actionable segments
segment_table  # Shows 9 distinct spend/pay combinations for marketing

# Compute predictions from the model used by several plots below.
pred <- predict(model)

# Predicted vs Actual: points near the blue line indicate a good overall fit.
plot(df$loyalty_points, pred,
     pch = 19, col = "gray40",
     main = "Predicted vs Actual loyalty points",
     xlab = "Actual", ylab = "Predicted")
abline(0, 1, col = "blue", lwd = 2)

# Residual diagnostics: check model assumptions visually.
par(mfrow = c(1,2))

# Residuals vs Fitted.
plot(fitted(model), resid(model),
     pch = 19, col = "gray40",
     main = "Residuals vs Fitted",
     xlab = "Fitted values", ylab = "Residuals")
abline(h = 0, col = "red")

# Normal Q–Q.
qqnorm(resid(model), pch = 19, col = "gray40",
       main = "Normal Q–Q (residuals)")
qqline(resid(model), col = "red")
par(mfrow = c(1,1))

# Slice view 1: Effect of spending at average income (model line overlay).
avg_pay <- mean(df$remuneration_kgbp, na.rm = TRUE)
grid <- data.frame(
  spending_score    = seq(min(df$spending_score, na.rm = TRUE),
                          max(df$spending_score, na.rm = TRUE), length.out = 120),
  remuneration_kgbp = avg_pay
)
grid$yhat <- predict(model, newdata = grid)

plot(df$spending_score, df$loyalty_points,
     pch = 19, col = "gray75",
     main = "Loyalty vs Spending (line at average income)",
     xlab = "Spending score", ylab = "Loyalty points")
lines(grid$spending_score, grid$yhat, col = "blue", lwd = 2)

# Slice view 2: Effect of income at average spending.
avg_spend <- mean(df$spending_score, na.rm = TRUE)
grid2 <- data.frame(
  spending_score    = avg_spend,
  remuneration_kgbp = seq(min(df$remuneration_kgbp, na.rm = TRUE),
                          max(df$remuneration_kgbp, na.rm = TRUE), length.out = 120)
)
grid2$yhat <- predict(model, newdata = grid2)

plot(df$remuneration_kgbp, df$loyalty_points,
     pch = 19, col = "gray75",
     main = "Loyalty vs Remuneration (line at average spending)",
     xlab = "Remuneration (kGBP)", ylab = "Loyalty points")
lines(grid2$remuneration_kgbp, grid2$yhat, col = "blue", lwd = 2)

# Scenario predictions: show how the model is used for planning.
# Define a few realistic spend/income combinations.
scenarios <- data.frame(
  spending_score    = c(40, 60, 85, 60, 60),
  remuneration_kgbp = c(35, 55, 80, 35, 80)
)
row.names(scenarios) <- c(
  "A) Low spend, low income",
  "B) Mid spend, mid income",
  "C) High spend, high income",
  "D) Mid spend, low income",
  "E) Mid spend, high income"
)

# Point predictions.
pred_point <- predict(model, newdata = scenarios)

# 95% prediction intervals for each scenario.
pred_pi <- predict(model, newdata = scenarios, interval = "prediction", level = 0.95)

# Neat table combining inputs, prediction, and intervals.
pred_table <- cbind(scenarios, round(pred_pi, 0))
names(pred_table)[3:5] <- c("predicted", "pi_low", "pi_high")
pred_table

# descriptive stats.
summary(df[, c("loyalty_points","spending_score","remuneration_kgbp","age")])

# Quantiles and IQR help describe skew and spread (less sensitive to outliers than mean/SD).
quantile(df$loyalty_points, probs = c(.01, .25, .5, .75, .99), na.rm = TRUE)
IQR(df$loyalty_points, na.rm = TRUE)

# Correlations (recomputed on complete cases) to confirm drivers.
tmp <- df[, c("loyalty_points","spending_score","remuneration_kgbp","age")]
tmp <- tmp[complete.cases(tmp), ]
round(cor(tmp), 3)

# Group summaries by bands to make segment patterns obvious to business users.
df$spend_band <- cut(df$spending_score, c(-Inf, 50, 70, Inf),
                     labels = c("Low","Mid","High"), include.lowest = TRUE)
df$pay_band   <- cut(df$remuneration_kgbp, c(-Inf, 40, 70, Inf),
                     labels = c("Low","Mid","High"), include.lowest = TRUE)

aggregate(loyalty_points ~ spend_band, data = df,
          FUN = function(x) c(n = length(x), mean = mean(x), median = median(x)))
aggregate(loyalty_points ~ spend_band + pay_band, data = df,
          FUN = function(x) c(n = length(x), mean = mean(x), median = median(x)))

#quick visuals to wrap up: distributions + a key relationship.
par(mfrow = c(2,2))
hist(df$loyalty_points,    breaks = 30, main = "Loyalty points", xlab = "loyalty_points", col = "lightblue")
hist(df$spending_score,    breaks = 30, main = "Spending score", xlab = "spending_score", col = "lightblue")
hist(df$remuneration_kgbp, breaks = 30, main = "Remuneration (kGBP)", xlab = "remuneration_kgbp", col = "lightblue")
plot(df$spending_score, df$loyalty_points, pch = 19, col = "gray40",
     main = "Loyalty vs Spending", xlab = "Spending score", ylab = "Loyalty points")
par(mfrow = c(1,1))

# Check multicollinearity
vif(model)


# Check for influential outliers
cooksd <- cooks.distance(model)
plot(cooksd, main = "Cook's Distance (identifying influential points)")
abline(h = 4/nrow(df), col = "red", lty = 2)
