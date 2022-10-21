# Bayesian_normative_models

This repository contains the Stan files used for the hierarchical Bayesian linear model (HBLM.stan), the hierarchical Bayesian Gaussian Process model (HBGPM.stan) and the simple Bayesain linear model (NoSite.stan) as described in the paper "Accommodating site variation in neuroimaging data using normative and hierarchical Bayesian models" (Bayer et al., 2022).

# The code can be run in a singularity container.

## Install singularity

Install singularity on your machine. A guide for installation on different operating systems can be found [here](https://docs.sylabs.io/guides/3.2/user-guide/installation.html#install-on-windows-or-mac)

A good example of how rstan can be run in singularity is via an image provided by [Wytamma Wirth](https://blog.wytamma.com/blog/Singularity-RStan/)
# once singularity is installed, pull the following container:

```
$ singularity pull docker://jrnold/rstan
```
This should download the image 'rstan_latest.sif' to your computer.

In singularity, now run the image using the command

```
singularity shell rstan_latest.sif
```

to execute the image.

You can execute any 