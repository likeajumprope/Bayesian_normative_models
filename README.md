## Bayesian normative models

This repository contains the Stan files used in the hierarchical Bayesian linear model (HBLM.stan), the hierarchical Bayesian Gaussian Process model (HBGPM.stan) and the simple Bayesian linear model (NoSite.stan) as described in the paper "Accommodating site variation in neuroimaging data using normative and hierarchical Bayesian models" [(Bayer et al., 2022)](https://www.sciencedirect.com/science/article/pii/S1053811922008205?via%3Dihub).

<details>
    <summary>Instructions on how to structure input files</summary>


    int<lower=1> N; // total number of observations

    vector[N] Y; // response variable (cortical thickness)

    int<lower=1> K;  // number of population-level effects 

    matrix[N, K] X;  // population-level design matrix  
  

Gaussian process parts population level effects

    int<lower=1> Kgp_1;
    int<lower=1> Dgp_1; // number of dimensions of GP (= one == Age)
    vector[Dgp_1] Xgp_1[N]; // input vector of GP = Age vector again

Data for group-level effects of ID 1

    int<lower=1> J_1[N]; // Site vector, lookup table for site
    int<lower=1> N_1; // number of sites == 20
    int<lower=1> M_1; // number of group level effects == 2 == slope and intercept for site
    vector[N] Z_1_1; // long vector for intercept regressor of site == all ones
    int prior_only;  // should the likelihood be ignored?

Test input

    int<lower=1> N_test; //number of test cases
    matrix[N_test, K] X_test; // test cases design matrix

Data for group-level effects of ID 1 test cases

    int<lower=1> J_1_test[N_test]; //site index
    vector[N_test] Z_1_1_test; // test set: long vector for intercept regressor of site == all ones
    vector[Dgp_1] Xgp_2[N_test]; // test set:  input vector of GP = Age vector again
    vector[N_test] Y_test;

</details>
<br>

<details>
    <summary>Rstan and  pystan</summary>
<br>

The stan code can be run via the R or Python interface libraries. For R, the libraries <a href="https://mc-stan.org/users/interfaces/rstan">rstan</a>  and <a href="https://mc-stan.org/rstanarm/">rstanarm</a>  can be downloaded via CRAN. Alterantively, the latest version of rstan can be downloaded from the [rstan Github](https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started).

For Python, <a href="https://pystan.readthedocs.io/en/latest/">pystan</a> can be installed via the pip install system. 

The [rstan Github](https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started) also provides information on how to configure the C++ Toolchain on your machine and some useful information on the general use of rstan and stan.


</details>
<br>

<details>
    <summary>Rstan in a singularity container</summary>

## Install singularity

Install singularity on your machine. A guide for installation on different operating systems can be found [here](https://docs.sylabs.io/guides/3.2/user-guide/installation.html#install-on-windows-or-mac)

A good example of how rstan can be run in singularity is via an image provided by [Wytamma Wirth](https://blog.wytamma.com/blog/Singularity-RStan/).

## Pull the image

once singularity is installed, pull the following container:

```
singularity pull docker://jrnold/rstan
```

This should download the image 'rstan_latest.sif' to your computer (it might take a while).

In singularity, now run the image using the command

```
singularity shell rstan_latest.sif
```

to execute the image.

## Run singularity

Run singularity by typing

```
singularity
```

in the command line.  

The singularity image comes with a version of R that has the rstan library installed.
Typing ```R``` after the singularity prompt should load R:

```
Singularity> R

R version 3.5.1 (2018-07-02) -- "Feather Spray"
Copyright (C) 2018 The R Foundation for Statistical Computing
Platform: x86_64-pc-linux-gnu (64-bit)

R is free software and comes with ABSOLUTELY NO WARRANTY.
You are welcome to redistribute it under certain conditions.
Type 'license()' or 'licence()' for distribution details.

R is a collaborative project with many contributors.
Type 'contributors()' for more information and
'citation()' on how to cite R or R packages in publications.

Type 'demo()' for some demos, 'help()' for on-line help, or
'help.start()' for an HTML browser interface to help.
Type 'q()' to quit R.
```

</details>

<br>
<details>
    <summary>Running the stan scripts as part of the rstan framework</summary>
    

## 
    library(rstan)
    library(rstan)
    library(rlist)

    N <-read.csv("N.csv")[1,1]
    Y<-read.csv("Y.csv")
    Y<-Y[1:nrow(Y), 1]
    K<-read.csv("K.csv") [1,1]
    X<-as.matrix(read.csv("X.csv"))
    Z_1_1<-as.numeric(unlist(read.csv("Z_1_1.csv")))
    Dgp_1<-read.csv("Dgp_1.csv")[1,1]
    Kgp_1<-read.csv("Kgp_1.csv")[1,1]
    Xgp_1<-as.matrix(read.csv("Xgp_1.csv"))
    J_1<-as.numeric(unlist(read.csv("J_1.csv")))
    N_1<-read.csv("N_1.csv")[1,1]
    M_1<-read.csv("M_1.csv")[1,1]
    NC_1<-read.csv("NC_1.csv")[1,1]
    prior_only<-read.csv("prior_only.csv")[1,1]
    N_test <-read.csv("N_test.csv")[1,1]
    X_test<-as.matrix(read.csv("X_test.csv"))
    J_1_test<-as.numeric(unlist(read.csv("J_1_test.csv")))
    Z_1_1_test<-as.numeric(unlist(read.csv("Z_1_1_test.csv")))
    Xgp_2<-as.matrix(read.csv("Xgp_2.csv"))
    Y_test<-as.numeric(unlist(read.csv("Y_test.csv")))


  
    to_stan_RIFS_model3_GP<-list(N= N, 
                                Y=Y, 
                                K= K,  
                                X=X, Z_1_1=Z_1_1, Dgp_1=Dgp_1, Kgp_1=Kgp_1, Xgp_1=Xgp_1,
                                J_1=J_1, N_1=N_1, M_1=M_1, NC_1=NC_1, prior_only=prior_only,
                                N_test=N_test, X_test=X_test, J_1_test=J_1_test, Z_1_1_test=Z_1_1_test,
                                Xgp_2=Xgp_2, Y_test=Y_test)



    fit_RIFS_model3_GP<-stan(file='RIFS_GP.stan', data=to_stan_RIFS_model3_GP, warmup = 1000, iter = 2000, chains = 4, cores=4, control = list(max_treedepth = 15))
    save(fit_RIFS_model3_GP,file='fit_RIFS_model3_GP.rds')


</details>
