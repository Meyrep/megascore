derive_megascore <- function(df, outcome,
                             n_folds = 5,
                             seed = 123,
                             n_cores = 8,
                             lambda_choice = c("lambda.1se", "lambda.min")) {

  lambda_choice <- match.arg(lambda_choice)

  library(glmnet)
  library(caret)
  library(doParallel)
  library(foreach)

  set.seed(seed)

  # ------------------ Outcome ------------------
  y <- df[[outcome]]

  # ------------------ Predictors ------------------
  x <- df[, setdiff(names(df), outcome)]

  # Proper design matrix (IMPORTANT)
  x <- model.matrix(~ . - 1, data = x)

  # ------------------ CV folds ------------------
  folds <- createFolds(y, k = n_folds, list = TRUE)

  cv_preds <- rep(NA, length(y))
  selected_vars <- vector("list", n_folds)
  lambda_used <- numeric(n_folds)

  # ------------------ Parallel ------------------
  cl <- makeCluster(min(n_cores, parallel::detectCores() - 1))
  registerDoParallel(cl)

  # ------------------ Outer CV ------------------
  res <- foreach(i = seq_along(folds),
                 .packages = "glmnet",
                 .options.snow = list(seed = TRUE)) %dopar% {

    test_idx <- folds[[i]]
    train_idx <- setdiff(seq_len(nrow(x)), test_idx)

    # Inner CV
    cv_fit <- cv.glmnet(
      x[train_idx, ], y[train_idx],
      family = "binomial",
      alpha = 1,
      type.measure = "auc",
      nfolds = 5
    )

    best_lambda <- cv_fit[[lambda_choice]]

    model <- glmnet(
      x[train_idx, ], 
      y[train_idx],
      family = "binomial",
      alpha = 1,
      lambda = best_lambda
    )

    preds <- as.numeric(
      predict(model, newx = x[test_idx, ], type = "response")
    )

    vars <- rownames(coef(model))[
      coef(model)[, 1] != 0
    ]
    vars <- setdiff(vars, "(Intercept)")

    list(
      fold = i,
      test_idx = test_idx,
      preds = preds,
      vars = vars,
      lambda = best_lambda
    )
  }

  stopCluster(cl)
  registerDoSEQ()

  # ------------------ Collect ------------------
  for (i in seq_along(res)) {
    cv_preds[res[[i]]$test_idx] <- res[[i]]$preds
    selected_vars[[i]] <- res[[i]]$vars
    lambda_used[i] <- res[[i]]$lambda
  }

  list(
    predictions = cv_preds,
    selected_vars = selected_vars,
    lambda = lambda_used,
    folds = folds,
    model_type = "LASSO logistic regression (nested CV)"
  )
}