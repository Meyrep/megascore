evaluate_megascore <- function(y, preds) {

  library(pROC)

  roc_obj <- roc(y, preds)

  list(
    AUC = auc(roc_obj),
    CI = ci.auc(roc_obj),
    roc_object = roc_obj
  )
}