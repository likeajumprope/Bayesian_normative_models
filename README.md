## Bayesian normative models

This repository contains the Stan files used in the hierarchical Bayesian linear model (HBLM.stan), the hierarchical Bayesian Gaussian Process model (HBGPM.stan) and the simple Bayesian linear model (NoSite.stan) as described in the paper "Accommodating site variation in neuroimaging data using normative and hierarchical Bayesian models" (Bayer et al., 2022).

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
    <summary>Running the code via rstan or pystan</summary>
<br>

The stan code can be run via the R or Python interface libraries. For R, the libraries <a href="https://mc-stan.org/users/interfaces/rstan">rstan</a>  and <a href="https://mc-stan.org/rstanarm/">rstanarm</a>  can be downloaded via CRAN. Alterantively, the latest version of rstan can be downloaded from the [rstan Github](https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started).

For Python, <a href="https://pystan.readthedocs.io/en/latest/">pystan</a> can be installed via the pip install system. 

The [rstan Github](https://github.com/stan-dev/rstan/wiki/RStan-Getting-Started) also provides information on how to configure the C++ Toolchain on your machine and some useful information on the general use of rstan and stan.


</details>
<br>

<details>
    <summary>Running the code in a singularity container</summary>

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
