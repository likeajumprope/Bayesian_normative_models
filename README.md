# Bayesian_normative_models

This repository contains the Stan files used for the hierarchical Bayesian linear model (HBLM.stan), the hierarchical Bayesian Gaussian Process model (HBGPM.stan) and the simple Bayesain linear model (NoSite.stan) as described in the paper "Accommodating site variation in neuroimaging data using normative and hierarchical Bayesian models" (Bayer et al., 2022).

# The code can be run in a singularity container.

## Install singularity

Install singularity on your machine. A guide for installation on different operating systems can be found [here](https://docs.sylabs.io/guides/3.2/user-guide/installation.html#install-on-windows-or-mac)

# once singularity is installed, pull the following container:

```
$ singularity pull docker://jrnold/rstan
```
