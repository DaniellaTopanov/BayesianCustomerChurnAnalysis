# BayesianCustomerChurnAnalysis
Bayesian Beta-Bernoulli modeling, MCMC sampling via Stan, and model comparison (LOO, Bayes Factors) for customer churn analysis in R.

## Overview
This project applies Bayesian statistical modeling to analyze customer churn behavior based on contract length (Monthly vs. Annual/Quarterly). Using Stan and R, the analysis builds a Beta-Bernoulli conjugate model, evaluates posterior distributions, conducts predictive checks (PPC/PPD), and performs model selection via LOO-CV and Bayes Factors.

## Key Methods & Workflow
- **Model Specification:** Built a Beta-Bernoulli model in Stan estimating churn probabilities ($\theta$) across customer segments.
- **Posterior Inference & Diagnostics:** Ran MCMC sampling via cmdstanr (4 chains, 2,000 iterations), checked convergence using R-hat and effective sample size (ESS), and analyzed highest density intervals (HDI) and ROPE.
- **Posterior Predictive Checks (PPC & PPD):** Simulated new customer data to assess model fit against observed churn counts.
- **Model Comparison:** Compared pooled and contract-grouped models using leave-one-out cross-validation (LOO-CV) and bridge sampling (Bayes factors).

## Results

The analysis used 70 customer observations and compared two models with Beta(1, 1) priors:

- **Pooled model:** one churn probability shared across all customers.
- **Contract-grouped model:** separate churn probabilities for monthly and longer-term customers, with quarterly and annual contracts grouped together.

### Prior model comparison

Bridge sampling estimated a Bayes factor of **3.295 in favor of the pooled model**. Repeated estimates ranged from 3.2939 to 3.2957 (interquartile range: 0.00053). This is positive but modest evidence for the pooled model under the specified priors; it is below the report's rule-of-thumb threshold of 6 for stronger evidence.

### Leave-one-out predictive comparison

| Model | ELPD difference | SE of difference | ELPD-LOO | p-LOO | LOOIC |
| --- | ---: | ---: | ---: | ---: | ---: |
| Pooled, one churn rate | 0.00 | 0.00 | −48.48 | 0.99 | 96.95 |
| Contract-grouped | −0.94 | 0.30 | −49.42 | 1.97 | 98.83 |

The pooled model ranked first. The contract-grouped model's ELPD-LOO was 0.94 lower, with a reported standard error of 0.30. Estimating a separate churn rate for each contract group did not improve leave-one-out predictive performance in this comparison.

### Conclusion and limitations

Both the prior Bayes-factor comparison and the LOO comparison favor the simpler pooled model for this dataset. The results provide limited evidence for different churn rates by contract group. This conclusion is limited by the sample of 70 observations and by grouping quarterly and annual customers together; a different grouping or a larger dataset could lead to a different result.

## Tech Stack & Libraries
- **Language:** R, Stan (cmdstanr)
- **Packages:** bayesplot, posterior, ggdist, tidyverse, loo, bridgesampling
