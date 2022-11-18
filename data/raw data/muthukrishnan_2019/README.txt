This data package accompanies the paper:
Muthukrishnan, R., and Larkin, D., Invasive species and biotic homogenization in temperate aquatic plant communities. Global Ecology and Biogeography. 

Within the compressed archive are several data files (in .csv format for tabular data) and the R code for all analyses (a series of .R scripts). All files should be kept in a single folder and then the "Biotic_homogenization_archive_master.R" script can be run which will in turn source other scripts that load data files, set up data structures and run analyses. The results of each analysis will then be called by the master script. The data sets are large and analyses can take some time so expect some scripts, in particular the "Biotic_homogenization_archive_data_setup.R" script, to take an extended amount of time to run. Additionally some analyses that also take a significant amount of time to run (e.g., ANOSIM, parametric bootstraps) have been commented out in the "Biotic_homogenization_archive_data_analysis.R" to allow the script to run quickly. These sections should be uncommented to conduct those additional analyses. In addition a number of additional packages will ned to be loaded in order to run analyses, these are listed in the "Biotic_homogenization_archive_master.R" script. 


Data files:
Lake_plant_diversity_data.csv
This is the main data file for plant survey results from DNR surveys

MpcaFqa.csv
tnrs_invasives.csv
tnrs_results.csv
These files provide plant lists that are used to determine native and invasive species. The TNRS files are outputs from the Taxonomic Name Resolution Service that are used to provide more standard names.

plant_growth_forms_and_invasiveness.csv
This file includes a list of macrophyte species analyzed and the invasiveness status and growth form type used for analysis.

lake_info.csv
This file includes a list of the lakes used in the analysis with their ID codes (from the Minnesota Department of Natural Resources), the county the lake is in, and the DNR administrative region the lake is in.  

BH_lakes_spatial_data.csv
This file includes a list of the lakes used in the analysis with geographic coordinates of their locations (in UTM coordinates)

drawdown_lakes.csv
This file includes a list of lakes where water level drawdowns were used as a management treatment.


Analysis files:
Biotic_homogenization_archive_master.R
Main analysis file that will run all other scripts and provide results for each statistical analysis

Biotic_homogenization_archive_data_setup.R
File to load and organize plant survey data

Biotic_homogenization_archive_data_analysis.R
File to run all main analyses 

Biotic_homogenization_archive_spatial_scale_supplemental_analysis.R
File to run supplemental analyses of community similarity between invaded and uninvaded lakes when jaccard similarities are calculated at different spatial scales.

Biotic_homogenization_archive_growth_form_supplemental_analysis.R
File to run supplemental analyses of changes in biotic homogenization or species richness for different macrophyte growth forms (submersed and emergent)
