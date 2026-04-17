# MEGASCORE

This repository contains the code for deriving and validating the MEGASCORE, a high-dimensional multi-omic risk score integrating Olink proteomic scores, DNA methylation-based scores and polygenic scores, using LASSO penalized logistic regression with nested cross-validation for model training and performance estimation.

## Overview

- Model: LASSO logistic regression
- Feature selection: embedded
- Validation: 5-fold nested cross-validation
- Performance metric: AUC (out-of-fold predictions)

## Requirements

```r
install.packages(c("glmnet", "caret", "doParallel", "foreach", "pROC", "dplyr"))
