functions { 
  // compute a latent Gaussian process
  //Args:
    //  x: array of continuous predictor values
  //   sdgp: marginal SD parameter
  //   lscale: length-scale parameter
  //   zgp: vector of independent standard normal variables 
  //
    //   https://mc-stan.org/docs/2_19/stan-users-guide/simulating
  //  -from-a-gaussian-process.html
  //
    vector gp(vector[] x, real sdgp, real lscale, vector zgp) { 
      matrix[size(x), size(x)] cov;
      cov = cov_exp_quad(x, sdgp, lscale);
      for (n in 1:size(x)) {
        // deal with numerical non-positive-definiteness
        cov[n, n] = cov[n, n] + 1e-12;
      }
      return cholesky_decompose(cov) * zgp; 
    }
} 
data { 
  int<lower=1> N;  // total number of observations 
  vector[N] Y;  // response variable (cortical thickness)
  int<lower=1> K;  // number of population-level effects (3)
  matrix[N, K] X;  // population-level design matrix  ()
  // Gaussian process parts population level effects
  int<lower=1> Kgp_1;
  int<lower=1> Dgp_1; // number of dimensions of GP (= one == Age)
  vector[Dgp_1] Xgp_1[N]; // input vector of GP = Age vector again
  // data for group-level effects of ID 1
  int<lower=1> J_1[N]; // Site vector, lookup table for site
  int<lower=1> N_1; // number of sites == 20
  int<lower=1> M_1; // number of group level effects == 2 == slope and intercept for site
  vector[N] Z_1_1; // long vector for intercept regerssor of site == all ones
  int prior_only;  // should the likelihood be ignored? 
    //test input
  int<lower=1> N_test; //number of test cases
  matrix[N_test, K] X_test; // test cases design matrix
  // data for group-level effects of ID 1 test cases
  int<lower=1> J_1_test[N_test]; //site index
  vector[N_test] Z_1_1_test; // test set: long vector for intercept regerssor of site == all ones
  vector[Dgp_1] Xgp_2[N_test]; // test set:  input vector of GP = Age vector again
  vector[N_test] Y_test;
} 
transformed data { 
  int Kc = K - 1; 
  matrix[N, K - 1] Xc =X[,2:3]; //  drop the first column of the design matrix as it
  // will be modelled as the \"temporal_Intercept\"
  matrix[N_test, K-1] Xc_test = X_test[,2:3];
  int<lower=1>N_full=N+N_test;
  
  // make a full vector for Xgp
  vector[Dgp_1] Xgp[N+N_test];
  for (n in 1:N) {
  Xgp[n] = Xgp_1[n];
  }
  for (n_test in 1:N_test) {
  Xgp[N+n_test] = Xgp_2[n_test];
  }
} 
  parameters { 
  vector[Kc] b;  // population-level effects: slope and Age 
  real temp_Intercept;  // temporary intercept: interecpt offset
  real<lower=0> sigma;  // residual SD 
  //Gaussian Process Parameters
  vector<lower=0>[Kgp_1] sdgp_1;
  vector<lower=1, upper=8>[Kgp_1] lscale_1; // note that the length scale is kept \"long\" 
  // (not too long) by constraining them
  vector[N+N_test] zgp; // vector with normally distributed variables, length training set, 
  //to be multplied to the cholesky decomposition L
  //vector[N_test] zgp_2; // vector with normally distributed variables, 
  // length test set, to be multplied to the cholesky decomposition L
  vector<lower=0>[M_1] sd_1;  // group-level (site) standard deviations, 
  ///two slots for temporal intercept, slope, 
  vector[N_1] z_1[M_1];  // unscaled group-level effects
  
  real<lower=0> sigma_p_Intercept;
  real<lower=0> sigma_p_slope;
  real<lower=0> sd_1_sigma;
  real<lower=0> sigma_sigma;
  vector[N_test] yhat_test;
  
  } 
  transformed parameters { 
  // group-level effects (site, slope and intercept effects)
  vector[N_1] r_1_1 = sd_1[1] * (z_1[1]); 
  } 
  model { 
  //vector[N] mu = temp_Intercept + Xc * b;
  vector[N+N_test] Y_full;
  vector[N+N_test] mu;
  
  // vector[N] mu_train = temp_Intercept + Xc * b + gp(Xgp_1, sdgp_1[1], lscale_1[1], zgp_1);
  // vector [N_test] mu_test= temp_Intercept + Xc_test * b + gp(Xgp_2, sdgp_1[1], lscale_1[1], zgp_2);
  
  
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
  
  mu += gp(Xgp, sdgp_1[1], lscale_1[1], zgp);
  
  for (n in 1:N) {
  Y_full[n] = Y[n];
  }
  for (n_test in 1:N_test) {
  Y_full[N+n_test] = yhat_test[n_test];
  }
  
  // population level effects: Intercept, Age(slope), Sex offset
  target += normal_lpdf(temp_Intercept | 0, sigma_p_Intercept);
  target += inv_gamma_lpdf(sigma_p_Intercept| 2,2);
  
  target += normal_lpdf(b[1]| 0, sigma_p_slope);
  target +=  inv_gamma_lpdf(sigma_p_slope| 2,2);
  
  target += inv_gamma_lpdf(sdgp_1 | 2, 2); 
  //target += normal_lpdf(zgp_1 | 0, 1);
  //target += normal_lpdf(zgp_2 | 0, 1);
  
  to_vector(zgp) ~ normal(0, 1); 
  //to_vector(zgp_2) ~ normal(0, 1);
  
  // put a constraint on this one!!!!
  target += uniform_lpdf(lscale_1 |1,8);
  
  // noise 
  target += normal_lpdf(sigma | 0, sigma_sigma); 
  target += inv_gamma_lpdf(sigma_sigma| 2,2);
  
  // group level
  target += normal_lpdf(z_1[1]| 0, 1);
  
  target += normal_lpdf(sd_1 |0,sd_1_sigma);
  target += inv_gamma_lpdf(sd_1_sigma| 2,2);
  
  // likelihood including all constants 
  if (!prior_only) { 
  
  // model
  target += normal_lpdf(Y_full | mu, sigma);
  } 
  } 
  generated quantities { 
  vector[N] log_lik;
  vector[N_test] log_lik_test;
  vector [N+N_test] yhat_full;
  
  vector[N+N_test] mu;
  
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
  
  mu += gp(Xgp, sdgp_1[1], lscale_1[1], zgp);
  
  for (n in 1:N){
  yhat_full[n]= normal_rng(mu[n], sigma);
  }
  
  for (n_test in 1:N_test){
  yhat_full[N+n_test]= normal_rng(mu[N+n_test], sigma);
  }
  for (n in 1:N){ 
  log_lik[n] = normal_lpdf(Y[n] | mu[n], sigma);
  }
  for (n_test in 1:N_test){ log_lik_test[n_test] = normal_lpdf(Y_test[n_test] | mu[N+n_test], sigma);}
  }