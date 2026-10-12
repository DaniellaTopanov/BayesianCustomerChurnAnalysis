# Load all the necessary libraries 
library(cmdstanr)
library(bayesplot)
library(tidyverse)
library(posterior)
library(ggdist)
library(ggplot2)
library(patchwork)
library(bayestestR)

# Load the data
data <- read.csv("customer_churn.csv")

# Group the data (1 = Monthly, 2 = Annual/Quarterly)
data$group <- NA
for (i in 1:nrow(data)) {
  if (data$Contract.Length[i] == "Monthly"){
    data$group[i] <- 1 
  } else {
    data$group[i] <- 2 
  }
}

# Verify the grouping
table(data$group)
table(data$Contract.Length, data$group)

# Compiling the data for lower time complexity 
model <- cmdstan_model("beta_bernoulli.stan", force_recompile = TRUE)
y <- data$Churn
N <- length(y)
data_list <- list(N=N, y=y, group = data$group)

# Running the model
fit_post <- model$sample(
  data = data_list,
  chains = 4, # Number of chains
  iter_warmup = 200, # Burn-in samples
  iter_sampling = 2000, # Total iterations per chain
  thin = 1, # No thinning
  seed = 1234,
  adapt_delta = 0.8 # controls the step size by the desired acceptance rate
)

# Diagnostics
post_draws <- as_draws_rvars(fit_post)
rhat(post_draws$theta)
ess_mean(post_draws$theta)
mcse_mean(post_draws$theta)

# Traceplot
mcmc_trace(fit_post$draws("theta")) + ggtitle("Traceplot for theta (Groups 1 & 2)")

# Calculate totals for each group
N1 <- sum(data$group == 1)
total_churn1 <- sum(data$Churn[data$group == 1])

N2 <- sum(data$group == 2)
total_churn2 <- sum(data$Churn[data$group == 2])

# Plot for Group 1 (Monthly)
p1 <- ggplot() +
  xlim(0, 1) +
  stat_function(fun = dbeta,
                args = list(shape1 = total_churn1 + 1, shape2 = N1 - total_churn1 + 1),
                color = "red", size = 1.2) +
  stat_slab(aes(xdist = post_draws$theta[1]), 
            fill = "green", alpha = 0.5, normalize = "none") +
  stat_function(fun = dbeta,
                args = list(shape1 = 1, shape2 = 1),
                color = "blue", size = 1.2, linetype = "dashed") +
  labs(title = expression(theta[1] ~ " - Group 1 (Monthly)"),
       x = "Probability of Churn", y = "Density") +
  theme_minimal()

# Plot for Group 2 (Annual/Quarterly)
p2 <- ggplot() +
  xlim(0, 1) +
  stat_function(fun = dbeta,
                args = list(shape1 = total_churn2 + 1, shape2 = N2 - total_churn2 + 1),
                color = "purple", size = 1.2) +
  stat_slab(aes(xdist = post_draws$theta[2]), 
            fill = "orange", alpha = 0.5, normalize = "none") +
  stat_function(fun = dbeta,
                args = list(shape1 = 1, shape2 = 1),
                color = "blue", size = 1.2, linetype = "dashed") +
  labs(title = expression(theta[2] ~ " - Group 2 (Annual/Quarterly)"),
       x = "Probability of Churn", y = "Density") +
  theme_minimal()

# Display plots side by side
p1 + p2

# Report central measures (Mean, Median, MAP) for theta
point_est <- point_estimate(post_draws$theta)
print(point_est)

# Report the 90% Credible Interval using the HDI method
ci_90 <- describe_posterior(post_draws$theta, ci = 0.90, ci_method = "HDI", test = NULL)
print(ci_90)

# Create a plot
theta_plot_df <- data.frame(
  theta = post_draws$theta,
  Group = c("1 - Monthly", "2 - Annual/Quarterly")
)

ggplot(theta_plot_df, aes(y = Group)) +
  stat_slabinterval(aes(xdist = theta, fill = after_stat(level)), 
                    point_interval = "median_hdi",
                    .width = 0.90) + 
  stat_spike(aes(xdist = theta), 
             at = list("mean", "median", "Mode"), 
             color = "red", linewidth = 1) + 
  scale_fill_brewer() +
  labs(title = "Posterior Distributions of Theta (Groups 1 & 2)",
       subtitle = "Red spikes: Mean, Median & MAP ,Colored area: 90% HDI",
       x = expression(theta ~ "(Probability of Churn)"),
       y = "Contract Type") +
  theme_minimal()

# Compute ROPE, PD, and P_MAP
rope_result <- p_rope(post_draws["delta"], range = c(-0.05, 0.05))
rope_result

pd_result <- p_direction(post_draws["delta"])
pd_result

pmap_result <- p_map(post_draws["delta"])
pmap_result


# Posterior Distribution Plot for difference
ggplot() +
  stat_slab(aes(xdist = post_draws$delta), fill = "lightblue", alpha = 0.8) +
  geom_rect(aes(xmin = -0.05, xmax = 0.05, ymin = 0, ymax = Inf), fill = "grey80", alpha = 0.6) + 
  geom_vline(xintercept = 0, linetype = "dashed", color = "red", linewidth = 1) +
  labs(title = "Posterior Distribution of Difference in Churn",
       subtitle = "Group 1 (Monthly) vs. Group 2 (Annual/Quarterly)",
       x = "Delta (Difference in Probability of Churn)", y = "Density") +
  theme_minimal()

# Part C

#PPD

set.seed(123)

# Predictions for new 100 customers 
prediction_100_1 <- rvar_rng(rbinom, n=1, size = 100, prob = post_draws$theta[1])
prediction_100_2 <- rvar_rng(rbinom, n=1, size = 100, prob = post_draws$theta[2])

ppd_df <- data.frame(
  Group = c("1 - Monthly", "2 - Annual/Quarterly"),
  prediction = c(prediction_100_1, prediction_100_2)
)

ggplot(ppd_df, aes(y=Group)) +
  stat_slab(aes(xdist = prediction), fill = "navy", alpha = 0.8)+
  scale_x_continuous(breaks = seq(0, 100, by = 5))+
  labs ( title = "PPD: Predicted Churns out of 100 New Customers",
         x = "Number of Predicted Churns", y = "Contract Type") +
  theme_minimal()

#PPC
set.seed(123)

pred_actual_1 <- rvar_rng(rbinom, n = 1, size = N1, prob = post_draws$theta[1])
pred_actual_2 <- rvar_rng(rbinom, n = 1, size = N2, prob = post_draws$theta[2])

ppc_df <- data.frame(
  Group = c("1 - Monthly", "2 - Annual/Quarterly"),
  pred_actual = c(pred_actual_1, pred_actual_2),
  actual_churns = c(total_churn1, total_churn2)
)

ggplot(ppc_df, aes(y = Group)) +
  stat_slab(aes(xdist = pred_actual), fill = "#00674F", alpha = 0.8) +
  scale_x_continuous(breaks = seq(0, 100, by = 5))+
  geom_point(aes(x = actual_churns), color = "red", size = 4) +
  labs(title = "PPC: Predicted vs. Actual Churns",
       subtitle = "Red dot represents the actual observed churns in the dataset",
       x = "Total Number of Churns", y = "Contract Type") +
  theme_minimal()


# Part D

library(loo)
library(bridgesampling)
library(distributional)

# Prepare stan and compile
stan_data_M1 <- list(N = nrow(data),y = data$Churn, force_recomiple =TRUE)

stan_data_M2 <- list(N = nrow(data), y = data$Churn, group = data$group, force_recomiple =TRUE)

mod1 <- cmdstan_model("model1.stan")
mod2 <- cmdstan_model("model2.stan")

# Models

# Model 1 - churn_prob ~ bernuolli(theta)
set.seed(123)
M1 <- mod1$sample(
  data = stan_data_M1,
  chains = 8,
  iter_sampling = 10000,
  iter_warmup = 200,
  thin = 1,
  seed = 1234,
  parallel_chains = 4
)
# Model 2 - churn_prob ~ bernoulli(thata1) - monthly sub
#           churn_prob ~ bernoulli(thata2) - annual/quarter sub  
M2 <- mod2$sample(
  data = stan_data_M2,
  chains = 8,
  iter_sampling = 10000,
  iter_warmup = 200,
  thin = 1,
  seed = 1234,
  parallel_chains = 4
)

bf_result <- bayes_factor(
  bridge_sampler(M1, repetitions = 10),
  bridge_sampler(M2, repetitions = 10)
)

print(bf_result)

# ELPD

LOOs <- list(
  Model_1_Single = M1$loo(),
  Model_2_Split = M2$loo()
)

loo_compare(LOOs) |> as.data.frame()
