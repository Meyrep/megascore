library(dplyr)

source("R/derive_megascore.R")
source("R/evaluate_megascore.R")

# df must contain outcome + predictors
result <- derive_megascore(
  df = df,
  outcome = "outcome",
  n_folds = 5
)

eval <- evaluate_megascore(
  y = df$outcome,
  preds = result$predictions
)

cat("AUC:", eval$AUC, "\n")
print(eval$CI)