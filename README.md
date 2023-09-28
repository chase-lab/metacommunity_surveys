
[![DOI](https://zenodo.org/badge/454080355.svg)](https://zenodo.org/badge/latestdoi/454080355)

# Metacommunity surveys

## Description

This research compendium regroups scripts used to download, re-structure and aggregate data sets to constitute a large meta-analysis of communities sampled at least twice, 10 years apart or more.  

As of 2.4, data are provided in a raw and standardised states. Raw data were restructured to fit a common template and few modifications were made, see `rulebook.md`. Standardised data were restructured to fit a common template and the effort was standardised to be consistent between localities and years of the same region.  

Variable definitions are in files:
```
   ./data/definitions_communities.txt
   ./data/definitions_metadata_raw.txt
   ./data/definitions_metadata_standardised.txt
```

## Availability
### Release v2.4-Blowes_etal_Science_Advances 

 - Code archived on Zenodo: https://doi.org/10.5281/zenodo.7785287
 - Data are also available in this repository in the following files:
 
 ```
    ./data/communities_raw.rds
    ./data/metadata_raw.rds
    ./data/communities_standardised.rds
    ./data/metadata_standardised.rds
 ```
 - Used by Dr Shane Blowes in the manuscript 'Local changes dominate variation in biotic homogenization and differentiation' submitted to Science Advances.

### Release v1.0.0

 - Code archived on Zenodo: https://doi.org/10.5281/zenodo.7785287
 - Used by Dr Wubing Xu in his manuscript 'Regional occupancy increases for widespread species but decreases for narrowly distributed species in metacommunity time series' published in Nature Communication in March 2023: https://doi.org/10.1038/s41467-023-37127-2
 - Data archived on iDiv Data Portal: https://doi.org/10.25829/idiv.3503-jevu6s


## Reproducibility and R environment
### R Packages
To ensure that the working environment (R version and packages version) are documented and isolated, the package `renv` (https://rstudio.github.io/renv/index.html) was used. By running `renv::restore()`, `renv` will install all missing packages at once. This function will use the `renv.lock` file to download the same versions of packages that we used.

### Execution
After downloading or cloning this repository, run `renv::restore()` and these scripts in order to download raw data, wrangle raw data and merge all data sets into one long table.
```
source('./R/1.0_downloading_raw_data.r')
source('./R/2.0_wrangling_raw_data.r')
source('./R/3.1_merging_long-format_tables_raw.r')
source('./R/3.2_merging_long-format_tables_standardised.r')
```

### Additional installations
You might need to install the 64-bit version of Java to run the `Tabulizer` package.
