# BayesianCustomerChurnAnalysis
Bayesian Beta-Bernoulli modeling, MCMC sampling via Stan, and model comparison (LOO, Bayes Factors) for customer churn analysis in R.

## Overview
This project applies Bayesian statistical modeling to analyze customer churn behavior based on contract length (Monthly vs. Annual/Quarterly). Using **Stan** and **R**, the analysis builds a Beta-Bernoulli conjugate model, evaluates posterior distributions, conducts predictive checks (PPC/PPD), and performs rigorous model selection via LOO-CV and Bayes Factors.

## Key Methods & Workflow
- **Model Specification:** Built a Beta-Bernoulli model in Stan estimating churn probabilities ($\theta$) across different customer segments.
- **Posterior Inference & Diagnostics:** Ran MCMC sampling via `cmdstanr` (4 chains, 2000 iterations), verified convergence using Rhat and Effective Sample Size (ESS), and analyzed Highest Density Intervals (HDI) and ROPE.
- **Posterior Predictive Checks (PPC & PPD):** Simulated new customer data to validate model fit against observed churn counts.
- **Model Comparison:** Compared single-parameter and grouped models using Leave-One-Out Cross-Validation (LOO-CV) and bridge sampling (Bayes Factors).

## Tech Stack & Libraries
- **Language:** R, Stan (`cmdstanr`)
- **Packages:** `bayesplot`, `posterior`, `ggdist`, `tidyverse`, `loo`, `bridgesampling`

