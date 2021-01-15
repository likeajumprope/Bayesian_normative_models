functions{
}
data {
  int<lower=1> N;  // number of observations
  vector[N] Y;  // response variable
  int<lower=1> K;  // number of population-level effects
  matrix[N, K] X;  // population-level design matrix
  int prior_only;  // should the likelihood be ignored?
  int<lower=1> N_test; // number of test cases 
  matrix[N_test, K] X_test;
  vector[N_test] Y_test;
}
transformed data {
  matrix[N, K-1] Xc =X[,2:3]; // centered version of X  // centered version of X without an intercept
  matrix[N_test, K-1] Xc_test = X_test[,2:3];
}
parameters {
  vector[K-1] b;  // population-level effects
  real temp_Intercept;  // temporary intercept for centered predictors
  real<lower=0> sigma;  // residual SD
  real<lower=0> sigma_p_Intercept;
  real<lower=0> sigma_sigma;
  vector[N_test] yhat_test;
}
transformed parameters {
}
model {
  vector[N+N_test] Y_full;
  vector[N+N_test] mu;
  
  vector[N] mu_train = temp_Intercept + Xc * b;
  vector [N_test] mu_test= temp_Intercept + Xc_test * b;
  
  for (n in 1:N) {
    mu[n] = mu_train[n];
  }
  for (n_test in 1:N_test) {
    mu[N+n_test] = mu_test[n_test];
  }
  
   for (n in 1:N) {
    Y_full[n] = Y[n];
  }
  for (n_test in 1:N_test) {
    Y_full[N+n_test] = yhat_test[n_test];
  }
  
  //priors including all constants
  target += normal_lpdf(temp_Intercept | 0, sigma_p_Intercept);
  target +=normal_lpdf(sigma|0, sigma_sigma);
  target += inv_gamma_lpdf(sigma_sigma| 2,2);
  target +=inv_gamma_lpdf(sigma_p_Intercept|2,2);

  if (!prior_only) {
    target +=normal_lpdf(Y_full | mu, sigma);
  }
}
generated quantities {
  vector [N+N_test] yhat_full;
  vector[N+N_test] mu;
  vector[N] log_lik;
  vector[N_test] log_lik_test;
  vector[N] mu_train = temp_Intercept + Xc * b;
  vector [N_test] mu_test= temp_Intercept + Xc_test * b;
  
  for (n in 1:N) {
    mu[n] = mu_train[n];
  }
	 	
  for (n_test in 1:N_test) {
    mu[N+n_test] = mu_test[n_test];
  }
	 	
  for (n in 1:N){
    yhat_full[n]= normal_rng(mu[n], sigma);
  }
	 
  for (n_test in 1:N_test){
    yhat_full[N+n_test]= normal_rng(mu[N+n_test], sigma);
    }
	 
   for (n in 1:N) {
     log_lik[n] = normal_lpdf(Y[n] | mu[n], sigma);
     }
     
   for (n_test in 1:N_test){
     log_lik_test[n_test] = normal_lpdf(Y_test[n_test] | mu[N+n_test], sigma);
    }
}
