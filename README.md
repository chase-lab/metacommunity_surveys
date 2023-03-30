

[![DOI](https://zenodo.org/badge/454080355.svg)](https://zenodo.org/badge/latestdoi/454080355)

# metacommunity surveys

## Description

This research compendium regroups scripts used to download, re-structure and aggregate data sets to constitute a large meta-analysis of communities sampled at least twice, 10 years apart or more. This is a child project of chase-lab/homogenisation and brother project to chase-lab/checklist-change

## Availability
### Release v1.0.0

 - Code archived on Zenodo: https://doi.org/10.5281/zenodo.7785287
 - Used by Dr Wubing Xu in his manuscript 'Regional occupancy increases for widespread species but decreases for narrowly distributed species in metacommunity time series' published in Nature Communication in March 2023: https://doi.org/10.1038/s41467-023-37127-2
 - Data archived on iDiv Data Portal: https://doi.org/10.25829/idiv.3503-jevu6s


## Reproducibility and R environment
### Installation
After downloading or cloning this repository, run these scripts in order to download raw data, wrangle raw data and merge all data sets into one long table.
```
source('./R/1.0_downloading_raw_data.r')
source('./R/2.0_wrangling_raw_data.r')
source('./R/3.0_merging_long-format_tables')
```
And finally, as described below: `renv::restore()`

### Containerisation
To ensure that the working environment (R version and package version) are documented and isolated, the package renv (https://rstudio.github.io/renv/index.html) was used. By running `renv::restore()`, renv will install all missing packages at once. This function will use the renv.lock file to download the same versions of packages that we used.

### Additional installations
You might need to install the 64-bit version of Java to run Tabulizer.
