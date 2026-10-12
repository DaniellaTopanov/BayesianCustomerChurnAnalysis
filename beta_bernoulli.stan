
// The input data is a array 'y' of length 'N'.
data {
  int<lower=0> N;
  array[N] int<lower=0, upper=1> y;
  array[N] int<lower=1, upper=2> group;
}

// The parameters accepted by the model. Our model
// accepts one parameters 'theta'.
parameters {
  vector<lower=0, upper=1>[2] theta;
}

// The model to be estimated. We model the output
// 'y' to be Bernoulli distribution with parameter theta.
// 'theta' distributed beta(1,1)
model {
 target += beta_lpdf(theta | 1,1);
 for (i in 1:N) {
   target += bernoulli_lpmf(y[i] | theta[group[i]]);
 }
}

generated quantities {
  real delta = theta[1] - theta[2];
}
