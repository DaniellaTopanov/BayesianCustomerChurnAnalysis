

data {
  int<lower=0> N; /// Number of customers
  array[N] int<lower=0, upper=1> y;
}


parameters {
  real <lower = 0, upper =1> theta;
}


model {
  target += beta_lpdf(theta | 1,1);
  for (n in 1:N) {
    target += bernoulli_lpmf (y[n] | theta);
  }
}

generated quantities {
  vector [N] log_lik;
  for (n in 1:N){
    log_lik[n] = bernoulli_lpmf(y[n] | theta);
  }
}
