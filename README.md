# Bayesian_normative_models

This repository contains the Stan files used for the hierarchical Bayesian linear model (HBLM.stan), the hierarchical Bayesian Gaussian Process model (HBGPM.stan) and the simple Bayesain linear model (NoSite.stan) as described in the paper "Accommodating site variation in neuroimaging data using normative and hierarchical Bayesian models" (Bayer et al., 2022).

# The code can be run in a singularity container.

## Install singularity

Install singularity on your machine. A guide for installation on different operating systems can be found [here](https://docs.sylabs.io/guides/3.2/user-guide/installation.html#install-on-windows-or-mac)

A good example of how rstan can be run in singularity is via an image provided by [Wytamma Wirth](https://blog.wytamma.com/blog/Singularity-RStan/).

## Pull the image
once singularity is installed, pull the following container:

```
$ singularity pull docker://jrnold/rstan
```
This should download the image 'rstan_latest.sif' to your computer (it might take a while).

In singularity, now run the image using the command

```
$ singularity shell rstan_latest.sif
```

to execute the image.
## Run singularity

Run singularity by typing

``` 
$ singularity
```
in the command line.  

The singularity image comes with a version of R that has the rstan library installed.
Tyoing ```R``` after the singularity prompt should load R:

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

