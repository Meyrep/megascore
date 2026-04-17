predict_megascore <- function(model, newdata) {

  library(glmnet)

  x_new <- model.matrix(~ . - 1, data = newdata)

  # Average coefficients across folds (simple ensemble approach)
  # alternative: refit final model on full dataset (recommended)

}