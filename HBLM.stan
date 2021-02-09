functions { 
} 
data { 
  int<lower=1> N;  // total number of observations 
  vector[N] Y;  // response variable 
  int<lower=1> K;  // number of population-level effects 
  matrix[N, K] X;  // population-level design matrix 
  // data for group-level effects of ID 1
  int<lower=1> J_1[N];
  int<lower=1> N_1;
  int<lower=1> M_1;
  vector[N] Z_1_1;
  int prior_only;  // should the likelihood be ignored? 
    //test input
  int<lower=1> N_test; //number of test cases
  matrix[N_test, K] X_test; // test cases design matrix
  // data for group-level effects of ID 1 test cases
  int<lower=1> J_1_test[N_test]; //site index
  vector[N_test] Z_1_1_test; // column intercepts for site (ones)
  vector[N_test] Y_test;
  
} 
transformed data { 
  int Kc = K - 1; 
  matrix[N, K - 1] Xc =X[,2:3]; // centered version of X 
  matrix[N_test, K-1] Xc_test = X_test[,2:3];
  
} 
parameters { 
  vector[Kc] b;  // population-level effects 
  real temp_Intercept;  // temporary intercept 
  real<lower=0> sigma;  // residual SD 
  vector<lower=0>[M_1] sd_1;  // group-level standard deviations
  vector[N_1] z_1[M_1];  // unscaled group-level effects
  
  // cholesky factor of correlation matrix
  real<lower=0> sigma_p_Intercept;
  real<lower=0> sd_1_sigma;
  real<lower=0> sigma_sigma;
  vector[N_test] yhat_test;
  
} 
transformed parameters { 
  // group-level effects 
  vector[N_1] r_1_1 = sd_1[1] * (z_1[1]);
  
} 
model { 
  vector[N+N_test] Y_full;
  vector[N+N_test] mu;
  
  vector[N] mu_train = temp_Intercept + Xc * b;
  vector [N_test] mu_test= temp_Intercept + Xc_test * b;
  
  for (n in 1:N) { 
    mu_train[n] += r_1_1[J_1[n]] * Z_1_1[n];  // running through 
    // the intercepts and slopes per individuals
    // collecting them in the site parameter
  } 
  
  for (n_test in 1:N_test) { 
    mu_test[n_test] += r_1_1[J_1_test[n_test]] * Z_1_1_test[n_test];
  }
  
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
  
  // priors including all constants 
  // population level effects: Intercept, Age(slope), Sex offset
  target += normal_lpdf(temp_Intercept | 0, sigma_p_Intercept);
  target += inv_gamma_lpdf(sigma_p_Intercept| 2,2);
  
  // noise 
  target += normal_lpdf(sigma | 0, sigma_sigma); 
  target += inv_gamma_lpdf(sigma_sigma| 2,2);
  
  target += normal_lpdf(sd_1 |0,sd_1_sigma);
  target += inv_gamma_lpdf(sd_1_sigma| 2,2);
  
  target += normal_lpdf(z_1[1] | 0, 1);
  
  // likelihood including all constants 
  if (!prior_only) { 
    
    // model
    target += normal_lpdf(Y_full | mu, sigma);
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
    mu_train[n] += r_1_1[J_1[n]] * Z_1_1[n]; // running through
    // the intercepts and slopes per individuals
    // collecting them in the site parameter
  }
  for (n_test in 1:N_test) {
    mu_test[n_test] += r_1_1[J_1_test[n_test]] * Z_1_1_test[n_test];
  }
  
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
    yhat_full[N+n_test]= normal_rng(mu[N+n_test], sigma);}
    

   for (n in 1:N) {
     log_lik[n] = normal_lpdf(Y[n] | mu[n], sigma);
     }
   
   for (n_test in 1:N_test){
     log_lik_test[n_test] = normal_lpdf(Y_test[n_test] | mu[N+n_test], sigma);
   }
  }